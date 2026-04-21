#!/bin/bash
#############################################################################
# TerminatorZ v3.0 - Utilities Module
# Dependency check, multi-source URL gathering, logging, helpers.
#############################################################################

TZ_REQUIRED_DEPS=("curl" "subfinder" "waybackurls" "httpx")
TZ_OPTIONAL_DEPS=("figlet" "lolcat" "toilet")

tz_install_hint() {
    local tool=$1
    case "$tool" in
        curl)         echo "apt install curl   (or your distro equivalent)" ;;
        subfinder)    echo "go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest  (or: apt install subfinder / brew install subfinder)" ;;
        waybackurls)  echo "go install github.com/tomnomnom/waybackurls@latest" ;;
        httpx)        echo "go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest" ;;
        figlet)       echo "apt install figlet   (brew install figlet on macOS)" ;;
        lolcat)       echo "apt install lolcat   (brew install lolcat on macOS)" ;;
        toilet)       echo "apt install toilet" ;;
        *)            echo "see your package manager" ;;
    esac
}

check_dependencies() {
    tz_section "Dependency Check" "$NEON_CYAN"
    echo

    local missing_required=()
    local missing_optional=()
    local dep

    for dep in "${TZ_REQUIRED_DEPS[@]}"; do
        if [ "$dep" = "httpx" ]; then
            # Special case: must be ProjectDiscovery httpx, not Python's
            local pd_httpx
            pd_httpx=$(_tz_resolve_httpx)
            if [ -n "$pd_httpx" ]; then
                printf '    %b[✓]%b %-20s %brequired (%s)%b\n' "$NEON_GREEN" "$RESET" "$dep" "$DIM" "$pd_httpx" "$RESET"
            else
                printf '    %b[✗]%b %-20s %bREQUIRED — ProjectDiscovery httpx not found (Python httpx does not count)%b\n' "$NEON_RED" "$RESET" "$dep" "$NEON_YELLOW" "$RESET"
                printf '        %s\n' "$(tz_install_hint "$dep")"
                missing_required+=("$dep")
            fi
        elif command -v "$dep" &>/dev/null; then
            printf '    %b[✓]%b %-20s %brequired%b\n' "$NEON_GREEN" "$RESET" "$dep" "$DIM" "$RESET"
        else
            printf '    %b[✗]%b %-20s %bREQUIRED — %s%b\n' "$NEON_RED" "$RESET" "$dep" "$NEON_YELLOW" "$(tz_install_hint "$dep")" "$RESET"
            missing_required+=("$dep")
        fi
    done

    for dep in "${TZ_OPTIONAL_DEPS[@]}"; do
        if command -v "$dep" &>/dev/null; then
            printf '    %b[✓]%b %-20s %boptional%b\n' "$NEON_GREEN" "$RESET" "$dep" "$DIM" "$RESET"
        else
            printf '    %b[-]%b %-20s %boptional — %s%b\n' "$NEON_YELLOW" "$RESET" "$dep" "$DIM" "$(tz_install_hint "$dep")" "$RESET"
            missing_optional+=("$dep")
        fi
    done

    echo
    if [ ${#missing_required[@]} -gt 0 ]; then
        tz_err "Missing required dependencies: ${missing_required[*]}"
        tz_err "Install the above and re-run."
        exit 1
    fi

    if [ ${#missing_optional[@]} -gt 0 ]; then
        tz_warn "Optional tools missing — styling will use built-in fallback."
    fi

    tz_ok "All required dependencies found."
    sleep 1
}

check_internet() {
    if curl -s --max-time 5 -o /dev/null -w "%{http_code}" https://1.1.1.1 | grep -qE '^[23]'; then
        return 0
    fi
    if curl -s --max-time 5 -o /dev/null -w "%{http_code}" https://google.com | grep -qE '^[23]'; then
        return 0
    fi
    return 1
}

# Log a vulnerability with structured fields
log_vulnerability() {
    local url=$1
    local check_key=$2
    local severity=$3
    local domain=$4
    local poc=${5:-$url}
    local proof=${6:-""}

    local display_name
    display_name=$(tz_display_name "$check_key")
    local findings_file="$TZ_CURRENT_RESULT_PATH/$domain.txt"

    (
        flock -x 200
        {
            echo "[$severity] $display_name"
            echo "  target: $url"
            echo "  poc:    $poc"
            [ -n "$proof" ] && echo "  proof:  $proof"
            echo ""
        } >> "$findings_file"
    ) 200>"$findings_file.lock"
}

recompute_stats() {
    local domain=$1
    local findings_file="$TZ_CURRENT_RESULT_PATH/$domain.txt"
    if [ ! -f "$findings_file" ]; then
        VULN_CRITICAL=0; VULN_HIGH=0; VULN_MEDIUM=0; VULN_LOW=0
    else
        VULN_CRITICAL=$(grep -c '^\[CRITICAL\]' "$findings_file" 2>/dev/null); VULN_CRITICAL=${VULN_CRITICAL:-0}
        VULN_HIGH=$(grep     -c '^\[HIGH\]'     "$findings_file" 2>/dev/null); VULN_HIGH=${VULN_HIGH:-0}
        VULN_MEDIUM=$(grep   -c '^\[MEDIUM\]'   "$findings_file" 2>/dev/null); VULN_MEDIUM=${VULN_MEDIUM:-0}
        VULN_LOW=$(grep      -c '^\[LOW\]'      "$findings_file" 2>/dev/null); VULN_LOW=${VULN_LOW:-0}
    fi
    export VULN_CRITICAL VULN_HIGH VULN_MEDIUM VULN_LOW
}

format_time() {
    local seconds=$1
    printf "%dm%02ds" $((seconds/60)) $((seconds%60))
}

url_base() {
    local url=$1
    echo "$url" | sed -E 's|^(https?://[^/]+).*|\1|'
}

tz_curl()         { curl -s --max-time 8 -k -A "Mozilla/5.0 (TerminatorZ/3.0)" "$@"; }
tz_curl_follow()  { curl -s -L --max-redirs 3 --max-time 8 -k -A "Mozilla/5.0 (TerminatorZ/3.0)" "$@"; }
tz_curl_headers() { curl -s -I --max-time 8 -k -A "Mozilla/5.0 (TerminatorZ/3.0)" "$@"; }

#############################################################################
# URL sanitiser — drops malformed / concatenated URLs
#############################################################################
# Rules:
#   - Must match: ^https?://<host>(:port)?(/path)?(\?query)?$
#   - No whitespace anywhere
#   - 'http' or 'https' may appear AT MOST ONCE (rejects sendcommand.phphttp://...)
#   - No duplicate ://
#   - Length < 2000
_tz_url_is_valid() {
    local url=$1
    local len=${#url}
    [ "$len" -lt 10 ] && return 1
    [ "$len" -gt 2000 ] && return 1
    # Whitespace reject
    case "$url" in *[[:space:]]*) return 1 ;; esac
    # Must start with http:// or https://
    case "$url" in
        http://*|https://*) : ;;
        *) return 1 ;;
    esac
    # Reject if "http" substring appears more than once after position 0
    # (catches ...phphttp://... concatenation bugs)
    local rest="${url:4}"   # strip leading "http"
    case "$rest" in *http*) return 1 ;; esac
    # Host portion must be alphanumeric/dots/dashes/colon (port)
    local after_scheme="${url#*://}"
    local host="${after_scheme%%/*}"
    host="${host%%\?*}"
    [ -z "$host" ] && return 1
    case "$host" in
        *[!A-Za-z0-9.:-]*) return 1 ;;
    esac
    return 0
}

#############################################################################
# Multi-source URL gathering
#   Sources: subfinder (subdomains) + waybackurls (paths).
#   Everything logged to recon.log for later review.
#############################################################################
gather_urls_multisource() {
    local domain=$1
    local result_path=$2
    local raw_file="$result_path/urls_raw.txt"
    local recon_log="$result_path/recon.log"
    : > "$raw_file"
    : > "$recon_log"

    {
        echo "============================================================"
        echo "  TerminatorZ recon log"
        echo "  Target: $domain"
        echo "  Started: $(date '+%Y-%m-%d %H:%M:%S')"
        echo "============================================================"
        echo ""
    } >> "$recon_log"

    #-------------------------------------------------------------------------
    # Source 1: subfinder (subdomains)
    #-------------------------------------------------------------------------
    printf '  %b[subfinder]%b discovering subdomains...\n' "${NEON_PURPLE}${BOLD}" "$RESET"
    echo "[subfinder] $(date '+%H:%M:%S') starting" >> "$recon_log"

    local sub_tmp
    sub_tmp=$(mktemp)
    # Run subfinder with a reasonable timeout
    ( subfinder -d "$domain" -silent -timeout 30 -t 50 2>>"$recon_log" > "$sub_tmp" ) &
    local sf_pid=$!
    local waited=0
    while kill -0 "$sf_pid" 2>/dev/null && [ "$waited" -lt 120 ]; do
        sleep 1
        waited=$((waited + 1))
    done
    if kill -0 "$sf_pid" 2>/dev/null; then
        kill "$sf_pid" 2>/dev/null
        echo "[subfinder] timeout after 120s — using partial results" >> "$recon_log"
    fi
    wait "$sf_pid" 2>/dev/null

    local sub_count=0
    local sub_shown=0
    local SUB_SHOW_LIMIT=60
    while IFS= read -r sub; do
        [ -z "$sub" ] && continue
        # subfinder emits bare hostnames — turn each into two URL roots
        local u1="https://${sub}/"
        local u2="http://${sub}/"
        if _tz_url_is_valid "$u1"; then
            echo "$u1" >> "$raw_file"
            echo "$u1" >> "$recon_log"
            sub_count=$((sub_count + 1))
            if [ "$sub_shown" -lt "$SUB_SHOW_LIMIT" ]; then
                printf '    %b→%b %s\n' "$NEON_CYAN" "$RESET" "$u1"
                sub_shown=$((sub_shown + 1))
            fi
        fi
        if _tz_url_is_valid "$u2"; then
            echo "$u2" >> "$raw_file"
        fi
    done < "$sub_tmp"
    local sub_total
    sub_total=$(wc -l < "$sub_tmp" | tr -d ' ')
    rm -f "$sub_tmp"
    [ "$sub_count" -gt "$sub_shown" ] && \
        printf '    %b…%b (+%d more, display truncated — full list in recon.log)\n' "$DIM" "$RESET" $((sub_count - sub_shown))
    printf '    %b[subfinder]%b found %d subdomains\n\n' "${NEON_GREEN}${BOLD}" "$RESET" "$sub_total"
    echo "[subfinder] done: $sub_total subdomains" >> "$recon_log"
    echo "" >> "$recon_log"

    #-------------------------------------------------------------------------
    # Source 2: waybackurls (archived path URLs for the base domain)
    #-------------------------------------------------------------------------
    printf '  %b[waybackurls]%b fetching archived paths from Wayback Machine...\n' "${NEON_PURPLE}${BOLD}" "$RESET"
    echo "[waybackurls] $(date '+%H:%M:%S') starting" >> "$recon_log"

    local wb_tmp
    wb_tmp=$(mktemp)
    ( waybackurls "$domain" 2>>"$recon_log" > "$wb_tmp" ) &
    local wb_pid=$!
    waited=0
    while kill -0 "$wb_pid" 2>/dev/null && [ "$waited" -lt 90 ]; do
        sleep 1
        waited=$((waited + 1))
    done
    if kill -0 "$wb_pid" 2>/dev/null; then
        kill "$wb_pid" 2>/dev/null
        echo "[waybackurls] timeout after 90s — using partial results" >> "$recon_log"
    fi
    wait "$wb_pid" 2>/dev/null

    local wb_raw_total wb_valid=0 wb_dropped=0 wb_shown=0
    wb_raw_total=$(wc -l < "$wb_tmp" | tr -d ' ')
    local WB_SHOW_LIMIT=60

    while IFS= read -r line; do
        [ -z "$line" ] && continue
        # Strip any trailing carriage return
        line="${line%$'\r'}"
        if _tz_url_is_valid "$line"; then
            echo "$line" >> "$raw_file"
            echo "$line" >> "$recon_log"
            wb_valid=$((wb_valid + 1))
            if [ "$wb_shown" -lt "$WB_SHOW_LIMIT" ]; then
                printf '    %b→%b %s\n' "$NEON_CYAN" "$RESET" "$line"
                wb_shown=$((wb_shown + 1))
            fi
        else
            wb_dropped=$((wb_dropped + 1))
            echo "[DROPPED-MALFORMED] $line" >> "$recon_log"
        fi
    done < "$wb_tmp"
    rm -f "$wb_tmp"

    [ "$wb_valid" -gt "$wb_shown" ] && \
        printf '    %b…%b (+%d more, display truncated — full list in recon.log)\n' "$DIM" "$RESET" $((wb_valid - wb_shown))
    if [ "$wb_dropped" -gt 0 ]; then
        printf '    %b[waybackurls]%b %d valid, %d malformed dropped (logged)\n\n' \
            "${NEON_GREEN}${BOLD}" "$RESET" "$wb_valid" "$wb_dropped"
    else
        printf '    %b[waybackurls]%b found %d valid URLs\n\n' "${NEON_GREEN}${BOLD}" "$RESET" "$wb_valid"
    fi
    echo "[waybackurls] done: $wb_valid valid, $wb_dropped dropped (raw: $wb_raw_total)" >> "$recon_log"
    echo "" >> "$recon_log"

    #-------------------------------------------------------------------------
    # Always include root target for domain-level checks
    #-------------------------------------------------------------------------
    echo "https://${domain}/" >> "$raw_file"
    echo "http://${domain}/"  >> "$raw_file"

    #-------------------------------------------------------------------------
    # Deduplicate
    #-------------------------------------------------------------------------
    sort -u "$raw_file" -o "$raw_file"
    local raw_count
    raw_count=$(wc -l < "$raw_file" | tr -d ' ')
    tz_info "Total unique URLs gathered: $raw_count (recon.log saved)"
    echo "[dedup] unique URLs: $raw_count" >> "$recon_log"
    echo "" >> "$recon_log"
}

#############################################################################
# httpx resolver — find the ProjectDiscovery httpx binary, not Python httpx
# which shares the same command name.
#############################################################################
# Cached after first call
TZ_HTTPX_BIN=""

_tz_resolve_httpx() {
    [ -n "$TZ_HTTPX_BIN" ] && { echo "$TZ_HTTPX_BIN"; return 0; }

    # Candidate paths (order: Homebrew mac → usual Go install dirs → PATH fallback)
    local candidates=(
        "/opt/homebrew/bin/httpx"
        "/usr/local/bin/httpx"
        "$HOME/go/bin/httpx"
        "/root/go/bin/httpx"
    )
    # Also whatever 'which -a' finds in PATH
    local which_hits
    which_hits=$(which -a httpx 2>/dev/null)
    local h
    for h in $which_hits; do
        candidates+=("$h")
    done

    local bin
    for bin in "${candidates[@]}"; do
        [ -z "$bin" ] && continue
        [ ! -x "$bin" ] && continue
        # ProjectDiscovery httpx prints "projectdiscovery.io" in its version banner.
        # Python httpx prints "Usage: httpx..." or similar.
        if "$bin" -version 2>&1 | grep -qi 'projectdiscovery'; then
            TZ_HTTPX_BIN="$bin"
            echo "$bin"
            return 0
        fi
    done
    return 1
}

#############################################################################
# httpx validation — streams URLs as they're found.
# httpx v1+ with -silent outputs each live URL on stdout as it discovers it.
# We read them via a pipe so they appear in real time.
#############################################################################
validate_urls_with_httpx() {
    local domain=$1
    local result_path=$2
    local raw_file="$result_path/urls_raw.txt"
    local alive_file="$result_path/urls.txt"
    local recon_log="$result_path/recon.log"
    : > "$alive_file"

    local raw_count
    raw_count=$(wc -l < "$raw_file" | tr -d ' ')
    if [ "$raw_count" -eq 0 ]; then
        tz_warn "urls_raw.txt is empty — nothing to validate."
        return 0
    fi

    # Install recon-phase interrupt trap
    export TZ_RECON_INTERRUPTED=0
    trap '_tz_recon_interrupt' INT

    # Locate ProjectDiscovery httpx
    local httpx_bin
    httpx_bin=$(_tz_resolve_httpx)
    if [ -z "$httpx_bin" ]; then
        tz_warn "ProjectDiscovery httpx not found (found a different 'httpx' in PATH, likely Python's)."
        tz_warn "Using curl probe instead."
        echo "[httpx] not found (PD httpx absent) — using curl probe" >> "$recon_log"
        _tz_curl_probe_fallback "$raw_file" "$alive_file" "$recon_log"
    else
        tz_info "Validating $raw_count URLs with httpx ($httpx_bin)..."
        tz_info "Live URLs will stream below as they are discovered..."
        echo
        echo "[httpx] $(date '+%H:%M:%S') starting on $raw_count URLs using $httpx_bin" >> "$recon_log"

        local httpx_err
        httpx_err=$(mktemp)
        local alive_from_httpx=0
        local shown=0
        local SHOW_LIMIT=200
        local start_ts
        start_ts=$(date +%s)

        # Pipe httpx stdout directly into a read loop — each URL streams as found.
        # Background the process so we can honour interrupt via trap.
        while IFS= read -r line; do
            [ "${TZ_RECON_INTERRUPTED:-0}" = "1" ] && break
            [ -z "$line" ] && continue
            line="${line%$'\r'}"
            # Strip any ANSI escape sequences
            line=$(echo "$line" | sed -E 's/\x1b\[[0-9;]*[a-zA-Z]//g')
            if _tz_url_is_valid "$line"; then
                echo "$line" >> "$alive_file"
                alive_from_httpx=$((alive_from_httpx + 1))
                if [ "$shown" -lt "$SHOW_LIMIT" ]; then
                    printf '    %b→%b %s\n' "$NEON_GREEN" "$RESET" "$line"
                    shown=$((shown + 1))
                fi
                # Live counter every 25 URLs after display limit
                if [ "$shown" -eq "$SHOW_LIMIT" ]; then
                    printf '    %b…%b (switching to counter mode — full list saved to urls.txt)\n' "$DIM" "$RESET"
                    shown=$((shown + 1))
                fi
                if [ "$shown" -gt "$SHOW_LIMIT" ] && [ $((alive_from_httpx % 25)) -eq 0 ]; then
                    local el=$(( $(date +%s) - start_ts ))
                    printf '    %b[alive: %d / elapsed: %ds]%b\n' "$DIM" "$alive_from_httpx" "$el" "$RESET"
                fi
            fi
        done < <("$httpx_bin" -silent -l "$raw_file" 2>"$httpx_err")

        # Capture stderr for diagnostics
        cat "$httpx_err" >> "$recon_log"
        rm -f "$httpx_err"

        if [ "${TZ_RECON_INTERRUPTED:-0}" = "1" ]; then
            trap - INT
            tz_warn "httpx validation interrupted by user."
            echo "[httpx] interrupted by user after $alive_from_httpx alive" >> "$recon_log"
        elif [ "$alive_from_httpx" -eq 0 ] && [ "$raw_count" -gt 0 ]; then
            tz_warn "httpx returned 0 live URLs out of $raw_count. Falling back to curl probe."
            echo "[httpx] zero results — falling back to curl probe" >> "$recon_log"
            echo
            _tz_curl_probe_fallback "$raw_file" "$alive_file" "$recon_log"
        fi
    fi

    # Remove trap
    trap - INT

    sort -u "$alive_file" -o "$alive_file"
    local alive_count
    alive_count=$(wc -l < "$alive_file" | tr -d ' ')

    echo
    tz_info "Alive URLs after validation: $alive_count / $raw_count"
    echo "[validation] done: $alive_count alive out of $raw_count" >> "$recon_log"
    echo "" >> "$recon_log"
}

#############################################################################
# Recon-phase interrupt handler
#############################################################################
_tz_recon_interrupt() {
    if [ "${TZ_RECON_INTERRUPTED:-0}" = "1" ]; then
        echo
        printf '%b[x]%b Second interrupt — hard exit.\n' "$NEON_RED" "$RESET" >&2
        local pids
        pids=$(jobs -p 2>/dev/null)
        [ -n "$pids" ] && kill -9 $pids 2>/dev/null
        exit 130
    fi
    export TZ_RECON_INTERRUPTED=1
    echo
    printf '%b[!]%b Recon interrupt received — stopping...\n' "$NEON_YELLOW" "$RESET" >&2
    local pids
    pids=$(jobs -p 2>/dev/null)
    [ -n "$pids" ] && kill $pids 2>/dev/null
    sleep 1
}

#############################################################################
# Curl-based fallback probe — used if httpx silently returns zero results.
# Probes with curl using a bash worker pool. Slower than httpx but reliable.
#############################################################################
_tz_curl_probe_fallback() {
    local raw_file=$1
    local alive_file=$2
    local recon_log=$3
    local threads=10
    local tmp_dir
    tmp_dir=$(mktemp -d)

    local total
    total=$(wc -l < "$raw_file" | tr -d ' ')
    tz_info "Curl fallback probe: $total URLs, $threads threads..."

    local i=0
    local probed=0 alive=0
    while IFS= read -r url; do
        [ -z "$url" ] && continue
        # Throttle to $threads concurrent workers
        while [ "$(jobs -r | wc -l)" -ge "$threads" ]; do
            wait -n 2>/dev/null || sleep 0.05
        done
        (
            local code
            code=$(curl -s -o /dev/null -w "%{http_code}" \
                --max-time 10 -k \
                -A "Mozilla/5.0 (TerminatorZ/3.0)" \
                "$url" 2>/dev/null)
            # Anything 2xx/3xx/4xx counts as alive (not 000 = connect failure, not 5xx stays out)
            if [[ "$code" =~ ^[234][0-9]{2}$ ]]; then
                echo "$url" >> "$alive_file"
                echo "$url [$code]" >> "$recon_log"
            fi
        ) &
        probed=$((probed + 1))
        # Light progress indicator every 200 URLs
        if [ $((probed % 200)) -eq 0 ]; then
            printf '    %b[probing]%b %d/%d\n' "$DIM" "$RESET" "$probed" "$total"
        fi
    done < "$raw_file"
    wait

    rm -rf "$tmp_dir"
    alive=$(wc -l < "$alive_file" | tr -d ' ')
    tz_info "Curl fallback complete: $alive / $total alive"
}

export -f tz_install_hint check_dependencies check_internet log_vulnerability
export -f recompute_stats format_time url_base _tz_url_is_valid
export -f tz_curl tz_curl_follow tz_curl_headers
export -f gather_urls_multisource validate_urls_with_httpx _tz_curl_probe_fallback _tz_resolve_httpx _tz_recon_interrupt
