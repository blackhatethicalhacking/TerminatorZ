#!/bin/bash
#############################################################################
# TerminatorZ v3.0 - Offensive CVE Exploitation Framework
# Author: Chris 'SaintDruG' Abou-Chabké
# Organization: Black Hat Ethical Hacking
# Website: https://www.blackhatethicalhacking.com
#############################################################################

# Bash 4+ guard — auto re-exec under a newer bash if needed.
if [ -z "$TZ_BASH_REEXEC" ] && [ "${BASH_VERSINFO[0]:-0}" -lt 4 ]; then
    for b in /opt/homebrew/bin/bash /usr/local/bin/bash /usr/bin/bash; do
        if [ -x "$b" ] && "$b" -c '[ "${BASH_VERSINFO[0]}" -ge 4 ]' 2>/dev/null; then
            export TZ_BASH_REEXEC=1
            exec "$b" "$0" "$@"
        fi
    done
    echo ""
    echo "TerminatorZ requires bash 4+ (you have ${BASH_VERSION})."
    echo ""
    echo "On macOS: brew install bash flock"
    echo "On Linux: your bash should already be new enough — check \$PATH."
    echo ""
    exit 1
fi

# flock guard
if ! command -v flock >/dev/null 2>&1; then
    echo ""
    echo "TerminatorZ requires 'flock'."
    echo ""
    echo "On macOS: brew install flock"
    echo "On Linux (Debian/Ubuntu/Kali): apt install util-linux"
    echo "On RHEL/Fedora: dnf install util-linux"
    echo ""
    exit 1
fi

VERSION="3.0"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export TZ_RESULTS_DIR="$SCRIPT_DIR/results"
mkdir -p "$TZ_RESULTS_DIR"

source "$SCRIPT_DIR/payloads.conf"
source "$SCRIPT_DIR/modules/ui.sh"
source "$SCRIPT_DIR/modules/utils.sh"
source "$SCRIPT_DIR/modules/scanner.sh"
source "$SCRIPT_DIR/modules/reporter.sh"

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; MAGENTA='\033[0;35m'; WHITE='\033[1;37m'
NC='\033[0m'

#############################################################################
# Small helper: any error path calls this so user can read the output
#############################################################################
_tz_wait_enter() {
    echo
    printf '  %bPress Enter to return to main menu...%b' "${NEON_YELLOW}${BOLD}" "$RESET"
    read -r _
}

#############################################################################
# Opening sequence
#############################################################################
opening_sequence() {
    clear
    curl --silent "https://raw.githubusercontent.com/blackhatethicalhacking/Subdomain_Bruteforce_bheh/main/ascii.sh" 2>/dev/null \
        | { command -v lolcat &>/dev/null && lolcat || cat; }
    echo

    local quotes=(
        "The supreme art of war is to subdue the enemy without fighting."
        "All warfare is based on deception."
        "He who knows when he can fight and when he cannot, will be victorious."
        "The whole secret lies in confusing the enemy, so that he cannot fathom our real intent."
        "To win one hundred victories in one hundred battles is not the acme of skill. To subdue the enemy without fighting is the acme of skill."
        "Opportunities multiply as they are seized."
        "In the midst of chaos, there is also opportunity."
        "Victorious warriors win first and then go to war, while defeated warriors go to war first and then seek to win."
    )
    local random_quote=${quotes[$RANDOM % ${#quotes[@]}]}
    tz_neon_echo "Offensive Security Tip: $random_quote - Sun Tzu"
    sleep 1
    tz_neon_echo "MEANS, IT'S 1337 TIME, 369"
    sleep 1

    if command -v figlet &>/dev/null; then
        figlet -w 80 -f small TerminatorZ | { command -v lolcat &>/dev/null && lolcat || cat; }
    else
        tz_neon_echo "████████╗███████╗██████╗ ███╗   ███╗██╗███╗   ██╗ █████╗ ████████╗ ██████╗ ██████╗ ███████╗"
        tz_neon_echo "╚══██╔══╝██╔════╝██╔══██╗████╗ ████║██║████╗  ██║██╔══██╗╚══██╔══╝██╔═══██╗██╔══██╗╚══███╔╝"
        tz_neon_echo "   ██║   █████╗  ██████╔╝██╔████╔██║██║██╔██╗ ██║███████║   ██║   ██║   ██║██████╔╝  ███╔╝ "
        tz_neon_echo "   ██║   ██╔══╝  ██╔══██╗██║╚██╔╝██║██║██║╚██╗██║██╔══██║   ██║   ██║   ██║██╔══██╗ ███╔╝  "
        tz_neon_echo "   ██║   ███████╗██║  ██║██║ ╚═╝ ██║██║██║ ╚████║██║  ██║   ██║   ╚██████╔╝██║  ██║███████╗"
    fi
    echo
    tz_neon_echo "[YOU ARE USING TerminatorZ v$VERSION] - CODED BY Chris 'SaintDruG' Abou-Chabké WITH LOVE FOR blackhatethicalhacking.com"
    tz_neon_echo "Educational Purposes Only - Authorised Testing Required!"
    sleep 1
    tz_neon_echo "This Version 3.0 checks for a total of 31 vulnerabilities"
    echo

    tz_neon_echo "CHECKING IF YOU ARE CONNECTED TO THE INTERNET!"
    if ! check_internet; then
        tz_err "CONNECT TO THE INTERNET BEFORE RUNNING TerminatorZ!"
        exit 1
    fi
    tz_neon_echo "CONNECTION FOUND, LET'S GO!"
    sleep 1

    check_dependencies
}

#############################################################################
# Matrix countdown
#############################################################################
matrix_countdown() {
    if command -v toilet &>/dev/null; then
        echo "Let us Terminate them in 5 seconds - Matrix Mode ON:" | toilet --metal -f term -F border 2>/dev/null \
            || tz_neon_echo "Let us Terminate them in 5 seconds - Matrix Mode ON:"
    else
        tz_neon_echo "Let us Terminate them in 5 seconds - Matrix Mode ON:"
    fi
    local R=$NEON_RED G=$NEON_GREEN Y=$NEON_YELLOW B=$NEON_BLUE
    local P=$NEON_PURPLE C=$NEON_CYAN W=$NEON_WHITE
    for ((i=0; i<5; i++)); do
        echo -ne "${R}10 ${G}01 ${Y}11 ${B}00 ${P}01 ${C}10 ${W}00 ${G}11 ${P}01 ${B}10 ${Y}11 ${C}00\r"
        sleep 0.2
        echo -ne "${R}01 ${G}10 ${Y}00 ${B}11 ${P}10 ${C}01 ${W}11 ${G}00 ${P}10 ${B}01 ${Y}00 ${C}11\r"
        sleep 0.2
        echo -ne "${R}11 ${G}00 ${Y}10 ${B}01 ${P}00 ${C}11 ${W}01 ${G}10 ${P}00 ${B}11 ${Y}10 ${C}01\r"
        sleep 0.2
        echo -ne "${R}00 ${G}11 ${Y}01 ${B}10 ${P}11 ${C}00 ${W}10 ${G}01 ${P}11 ${B}00 ${Y}01 ${C}10\r"
        sleep 0.2
    done
    echo -e "$RESET"
}

#############################################################################
# Main menu
#############################################################################
show_main_menu() {
    tz_main_menu
    printf '  %bEnter choice [1-4]:%b ' "${NEON_CYAN}${BOLD}" "$RESET"
    local choice
    read -r choice
    case "$choice" in
        1) start_scan "full" ;;
        2) start_scan "custom" ;;
        3) view_reports ;;
        4) tz_neon_echo "Goodbye!"; exit 0 ;;
        *)
            tz_err "Invalid choice."
            sleep 1
            show_main_menu
            ;;
    esac
}

#############################################################################
# Resolve result directory — overwrite / new run / cancel
#############################################################################
resolve_result_path() {
    local domain=$1
    local base="$TZ_RESULTS_DIR/$domain"
    if [ ! -d "$base" ]; then
        echo "$base"
        return 0
    fi
    {
        tz_warn "Directory already exists for $domain"
        echo
        printf '    %b1%b  Overwrite (delete existing results)\n' "$NEON_YELLOW" "$RESET"
        printf '    %b2%b  New Run (create %s_2 / _3 / etc.)\n'    "$NEON_GREEN"  "$RESET" "$domain"
        printf '    %b3%b  Cancel (return to menu)\n\n'            "$NEON_PINK"   "$RESET"
        printf '  %bChoice [1-3]:%b ' "${NEON_CYAN}${BOLD}" "$RESET"
    } >&2
    local choice
    read -r choice
    case "$choice" in
        1) rm -rf "$base"; echo "$base" ;;
        2)
            local n=2
            while [ -d "${base}_${n}" ]; do n=$((n + 1)); done
            echo "${base}_${n}"
            ;;
        *) echo "" ;;
    esac
}

#############################################################################
# Launch a scan
#############################################################################
start_scan() {
    local mode=$1

    echo
    printf '  %bEnter target domain (example.com):%b ' "${NEON_CYAN}${BOLD}" "$RESET"
    local domain
    read -r domain
    printf '  %bConcurrent threads [5]:%b ' "${NEON_CYAN}${BOLD}" "$RESET"
    local threads
    read -r threads
    threads=${threads:-5}

    if [ -z "$domain" ]; then
        tz_err "Domain cannot be empty!"
        _tz_wait_enter
        show_main_menu
        return
    fi

    domain=$(echo "$domain" | sed -E 's#^https?://##; s#/.*$##')

    local result_path
    result_path=$(resolve_result_path "$domain")
    if [ -z "$result_path" ]; then
        tz_info "Cancelled."
        _tz_wait_enter
        show_main_menu
        return
    fi
    mkdir -p "$result_path"
    export TZ_CURRENT_RESULT_PATH="$result_path"
    local run_label
    run_label=$(basename "$result_path")

    if [[ "$mode" == "custom" ]]; then
        tz_custom_picker
        if [ "${#TZ_CUSTOM_SELECTION[@]}" -eq 0 ]; then
            tz_err "No checks selected."
            _tz_wait_enter
            show_main_menu
            return
        fi
    fi

    echo
    tz_section "Reconnaissance — URL Gathering" "$NEON_CYAN"
    echo

    gather_urls_multisource "$domain" "$result_path"

    echo
    tz_section "Validation — httpx (alive check)" "$NEON_CYAN"
    echo
    validate_urls_with_httpx "$domain" "$result_path"

    local count
    count=$(wc -l < "$result_path/urls.txt" 2>/dev/null | tr -d ' ')
    count=${count:-0}

    # If recon was interrupted, ask whether to scan with partial results
    if [ "${TZ_RECON_INTERRUPTED:-0}" = "1" ]; then
        echo
        tz_warn "Recon was interrupted — $count URLs gathered so far."
        echo
        printf '  %b[y]%b scan with what we have\n' "${NEON_GREEN}${BOLD}" "$RESET"
        printf '  %b[N]%b return to main menu (keep recon results on disk)\n' "${NEON_YELLOW}${BOLD}" "$RESET"
        echo
        printf '  > '
        local partial_choice
        read -r partial_choice
        export TZ_RECON_INTERRUPTED=0
        if [[ "$partial_choice" != "y" && "$partial_choice" != "Y" ]]; then
            tz_info "Recon results saved in $result_path"
            _tz_wait_enter
            show_main_menu
            return
        fi
        if [ "$count" -eq 0 ]; then
            tz_err "No URLs to scan."
            _tz_wait_enter
            show_main_menu
            return
        fi
    fi

    if [ "$count" -eq 0 ]; then
        echo
        tz_err "No live URLs found for $domain after httpx validation."
        tz_warn "Review recon output above and $result_path/recon.log"
        _tz_wait_enter
        show_main_menu
        return
    fi

    # Post-recon confirmation prompt
    echo
    tz_rule "$NEON_GREEN" "═" 70
    printf '  %bRecon Complete — Ready To Attack%b\n' "${NEON_GREEN}${BOLD}" "$RESET"
    tz_rule "$NEON_GREEN" "═" 70
    echo
    printf '  %bTarget:%b %s\n'        "$DIM" "$RESET" "$domain"
    printf '  %bLive URLs:%b %d\n'     "$DIM" "$RESET" "$count"
    printf '  %bMode:%b %s\n'          "$DIM" "$RESET" "$mode"
    printf '  %bThreads:%b %d\n'       "$DIM" "$RESET" "$threads"
    printf '  %bRun label:%b %s\n'     "$DIM" "$RESET" "$run_label"
    printf '  %bRecon log:%b %s/recon.log\n'  "$DIM" "$RESET" "$result_path"
    printf '  %bURL list:%b %s/urls.txt\n'    "$DIM" "$RESET" "$result_path"
    echo
    printf '  %bNote:%b static assets (.js/.css/.png/etc.) get header-based checks only\n' "$DIM" "$RESET"
    printf '  %b     (injection checks skipped on those — major speed-up)%b\n' "$DIM" "$RESET"
    printf '  %bNote:%b press Ctrl+C during the scan to stop and jump to the report prompt\n' "$DIM" "$RESET"
    echo
    printf '  %b[Enter]%b to proceed with the attack\n' "${NEON_GREEN}${BOLD}" "$RESET"
    printf '  %b[c]%b     to cancel and return to main menu\n' "${NEON_YELLOW}${BOLD}" "$RESET"
    echo
    printf '  > '
    local confirm
    read -r confirm
    if [[ "$confirm" == "c" || "$confirm" == "C" ]]; then
        tz_info "Attack cancelled. Recon results kept in $result_path"
        _tz_wait_enter
        show_main_menu
        return
    fi

    echo
    matrix_countdown
    echo

    tz_rule "$NEON_PINK" "═" 70
    printf '  %bTerminatorZ v%s — Attack in Progress%b\n' "${NEON_PINK}${BOLD}" "$VERSION" "$RESET"
    printf '  %bTarget:%b %s  %b|%b  %bURLs:%b %d  %b|%b  %bThreads:%b %d  %b|%b  %bMode:%b %s  %b|%b  %bRun:%b %s\n' \
        "$DIM" "$RESET" "$domain" \
        "$DIM" "$RESET" \
        "$DIM" "$RESET" "$count" \
        "$DIM" "$RESET" \
        "$DIM" "$RESET" "$threads" \
        "$DIM" "$RESET" \
        "$DIM" "$RESET" "$mode" \
        "$DIM" "$RESET" \
        "$DIM" "$RESET" "$run_label"
    tz_rule "$NEON_PINK" "═" 70
    echo

    export TOTAL_URLS=$count
    export VULN_CRITICAL=0 VULN_HIGH=0 VULN_MEDIUM=0 VULN_LOW=0
    export START_TIME=$(date +%s)
    touch "$result_path/$domain.txt"

    case "$mode" in
        full)   scan_all    "$domain" "$threads" ;;
        custom) scan_custom "$domain" "$threads" ;;
    esac

    recompute_stats "$domain"
    local total_elapsed=$(( $(date +%s) - START_TIME ))
    local was_interrupted="${TZ_INTERRUPTED:-0}"
    export TZ_INTERRUPTED=0

    # Work out how many URLs were actually scanned before any interrupt
    local urls_done=0
    if [ -f "$result_path/.done_count" ]; then
        urls_done=$(<"$result_path/.done_count")
    fi

    echo
    if [ "$was_interrupted" = "1" ]; then
        tz_rule "$NEON_YELLOW" "═" 70
        printf '  %bScan Interrupted — Showing Partial Results%b\n' "${NEON_YELLOW}${BOLD}" "$RESET"
        tz_rule "$NEON_YELLOW" "═" 70
    else
        tz_rule "$NEON_GREEN" "═" 70
        printf '  %bAttack Complete%b\n' "${NEON_GREEN}${BOLD}" "$RESET"
        tz_rule "$NEON_GREEN" "═" 70
    fi
    echo
    printf '  %bElapsed:%b %s\n' "$DIM" "$RESET" "$(format_time "$total_elapsed")"
    if [ "$was_interrupted" = "1" ]; then
        printf '  %bURLs processed:%b %d / %d (interrupted)\n' "$DIM" "$RESET" "$urls_done" "$TOTAL_URLS"
    else
        printf '  %bURLs processed:%b %d / %d\n' "$DIM" "$RESET" "$urls_done" "$TOTAL_URLS"
    fi
    printf '  %bCRITICAL:%b %d   %bHIGH:%b %d   %bMEDIUM:%b %d   %bLOW:%b %d\n' \
        "$NEON_RED"    "$RESET" "$VULN_CRITICAL" \
        "$NEON_ORANGE" "$RESET" "$VULN_HIGH" \
        "$NEON_YELLOW" "$RESET" "$VULN_MEDIUM" \
        "$NEON_CYAN"   "$RESET" "$VULN_LOW"
    echo

    printf '  Generate detailed report? [Y/n]: '
    local gen
    read -r gen
    if [[ "$gen" != "n" && "$gen" != "N" ]]; then
        generate_report "$domain"
    fi

    printf '  View findings now? [y/N]: '
    local view_now
    read -r view_now
    if [[ "$view_now" == "y" || "$view_now" == "Y" ]]; then
        echo
        if command -v lolcat &>/dev/null; then
            cat "$result_path/$domain.txt" | lolcat
        else
            cat "$result_path/$domain.txt"
        fi
    fi

    rm -f "$result_path"/.done_count* "$result_path"/.admin_checked_* \
          "$result_path"/.git_checked_*  "$result_path"/.env_checked_*  \
          "$result_path"/*.lock 2>/dev/null

    echo "$(date '+%Y-%m-%d %H:%M:%S') | $run_label | $count URLs | C:$VULN_CRITICAL H:$VULN_HIGH M:$VULN_MEDIUM L:$VULN_LOW" \
        >> "$SCRIPT_DIR/.scan_history"

    echo
    tz_neon_echo "Targets have been T3rm1nat3d... I'll be back!"
    _tz_wait_enter
    show_main_menu
}

#############################################################################
# View scan history — only shows runs whose result directories still exist.
# Also prunes stale lines from .scan_history so wiping results/ cleans it up.
#############################################################################
view_reports() {
    clear
    tz_section "Previous Scan History" "$NEON_PURPLE"
    echo

    local history_file="$SCRIPT_DIR/.scan_history"

    # If history file missing OR results dir doesn't exist at all, nothing to show
    if [ ! -f "$history_file" ] && [ ! -d "$TZ_RESULTS_DIR" ]; then
        tz_info "No previous scans found."
        _tz_wait_enter
        show_main_menu
        return
    fi

    # Prune history: drop lines whose result dir no longer exists
    if [ -f "$history_file" ]; then
        local tmp
        tmp=$(mktemp)
        local pruned=0 kept=0
        while IFS= read -r line; do
            local label
            label=$(echo "$line" | awk -F'|' '{gsub(/ /, "", $2); print $2}')
            if [ -n "$label" ] && [ -d "$TZ_RESULTS_DIR/$label" ]; then
                echo "$line" >> "$tmp"
                kept=$((kept + 1))
            else
                pruned=$((pruned + 1))
            fi
        done < "$history_file"
        mv "$tmp" "$history_file"
        [ "$pruned" -gt 0 ] && tz_info "Pruned $pruned stale entries from scan history."
    fi

    # Now check what's left
    local line_count=0
    [ -f "$history_file" ] && line_count=$(wc -l < "$history_file" | tr -d ' ')
    if [ "$line_count" -eq 0 ]; then
        tz_info "No scans with intact results directories."
        _tz_wait_enter
        show_main_menu
        return
    fi

    tail -20 "$history_file" | { command -v lolcat &>/dev/null && lolcat || cat; }
    echo
    printf '  %bEnter run label to view report (e.g. vulnweb.com or vulnweb.com_2, blank to go back):%b ' \
        "${NEON_CYAN}${BOLD}" "$RESET"
    local view_label
    read -r view_label
    if [ -n "$view_label" ] && [ -d "$TZ_RESULTS_DIR/$view_label" ]; then
        if [ -f "$TZ_RESULTS_DIR/$view_label/report.html" ]; then
            tz_info "Report location: $TZ_RESULTS_DIR/$view_label/report.html"
            if command -v xdg-open &>/dev/null; then
                xdg-open "$TZ_RESULTS_DIR/$view_label/report.html" &>/dev/null &
            elif command -v open &>/dev/null; then
                open "$TZ_RESULTS_DIR/$view_label/report.html" &>/dev/null &
            fi
        else
            local findings
            findings=$(ls "$TZ_RESULTS_DIR/$view_label"/*.txt 2>/dev/null | head -1)
            [ -n "$findings" ] && cat "$findings" || tz_warn "No report or findings file found."
        fi
    elif [ -n "$view_label" ]; then
        tz_err "Run label '$view_label' not found in results directory."
    fi
    _tz_wait_enter
    show_main_menu
}

opening_sequence
show_main_menu
