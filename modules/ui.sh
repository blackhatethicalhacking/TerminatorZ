#!/bin/bash
#############################################################################
# TerminatorZ v3.0 - UI Module
# Neon palette, banners, progress bars, live verbose display.
# Bash 3.2+ compatible.
#############################################################################

export NEON_PINK=$'\033[38;5;201m'
export NEON_CYAN=$'\033[38;5;51m'
export NEON_GREEN=$'\033[38;5;46m'
export NEON_YELLOW=$'\033[38;5;226m'
export NEON_RED=$'\033[38;5;196m'
export NEON_PURPLE=$'\033[38;5;135m'
export NEON_ORANGE=$'\033[38;5;208m'
export NEON_BLUE=$'\033[38;5;39m'
export NEON_WHITE=$'\033[38;5;231m'
export DIM=$'\033[2m'
export BOLD=$'\033[1m'
export RESET=$'\033[0m'

TZ_CYCLE=("$NEON_PINK" "$NEON_PURPLE" "$NEON_CYAN" "$NEON_GREEN" "$NEON_YELLOW" "$NEON_ORANGE")

tz_neon_echo() {
    local line="$1"
    if command -v lolcat &>/dev/null; then
        echo "$line" | lolcat
        return
    fi
    local c="${TZ_CYCLE[$RANDOM % ${#TZ_CYCLE[@]}]}"
    printf '%b%s%b\n' "$c" "$line" "$RESET"
}

tz_rule() {
    local color="${1:-$NEON_PINK}"
    local char="${2:-━}"
    local width="${3:-70}"
    local line
    line=$(printf "%${width}s" "" | tr ' ' "$char")
    printf '%b%s%b\n' "$color" "$line" "$RESET"
}

tz_section() {
    local title="$1"
    local color="${2:-$NEON_CYAN}"
    echo
    tz_rule "$color"
    printf '%b  %s%b\n' "${color}${BOLD}" "$title" "$RESET"
    tz_rule "$color"
}

tz_info() { printf '%b[*]%b %s\n' "$NEON_CYAN"   "$RESET" "$*"; }
tz_ok()   { printf '%b[+]%b %s\n' "$NEON_GREEN"  "$RESET" "$*"; }
tz_warn() { printf '%b[!]%b %s\n' "$NEON_YELLOW" "$RESET" "$*"; }
tz_err()  { printf '%b[x]%b %s\n' "$NEON_RED"    "$RESET" "$*"; }

tz_url_header() {
    local url=$1
    local ts
    ts=$(date '+%H:%M:%S')
    echo
    tz_rule "$NEON_CYAN" "━" 70
    printf '  %b[%s]%b  %bTarget:%b %b%s%b\n' \
        "$DIM" "$ts" "$RESET" \
        "${NEON_PURPLE}${BOLD}" "$RESET" \
        "${NEON_CYAN}${BOLD}" "$url" "$RESET"
    tz_rule "$NEON_CYAN" "━" 70
}

tz_check_line() {
    local idx=$1
    local total=$2
    local name=$3
    local status=$4
    local sev=${5:-}
    local poc=${6:-}
    local proof=${7:-}

    local idx_str
    idx_str=$(printf "[%02d/%02d]" "$idx" "$total")

    case "$status" in
        testing)
            printf '  %b%s%b  %s\n' \
                "$NEON_PURPLE" "$idx_str" "$RESET" "$name"
            printf '           %btesting...%b\n' "$DIM" "$RESET"
            ;;
        clean)
            printf '  %b%s%b  %s  %b✗ clean%b\n' \
                "$NEON_PURPLE" "$idx_str" "$RESET" \
                "$name" \
                "$DIM" "$RESET"
            ;;
        vuln)
            local sev_color
            sev_color=$(tz_sev_color "$sev")
            printf '  %b%s%b  %b%s%b  %b✓ VULNERABLE%b  %b[%s]%b\n' \
                "$NEON_PURPLE" "$idx_str" "$RESET" \
                "${NEON_WHITE}${BOLD}" "$name" "$RESET" \
                "${NEON_GREEN}${BOLD}" "$RESET" \
                "${sev_color}${BOLD}" "$sev" "$RESET"
            if [ -n "$poc" ]; then
                printf '           %bpoc:%b   %b%s%b\n' \
                    "${NEON_CYAN}" "$RESET" \
                    "$NEON_YELLOW" "$poc" "$RESET"
            fi
            if [ -n "$proof" ]; then
                printf '           %bproof:%b %b%s%b\n' \
                    "${NEON_CYAN}" "$RESET" \
                    "$DIM" "$proof" "$RESET"
            fi
            ;;
        error)
            printf '  %b%s%b  %s  %b- skipped%b\n' \
                "$NEON_PURPLE" "$idx_str" "$RESET" \
                "$name" \
                "$DIM" "$RESET"
            ;;
    esac
}

tz_progress_overall() {
    local current=$1
    local total=$2
    local start=$3
    local width=40

    [ "$total" -le 0 ] && total=1
    local pct=$((current * 100 / total))
    [ "$pct" -gt 100 ] && pct=100
    local filled=$((width * current / total))
    [ "$filled" -gt "$width" ] && filled=$width
    local empty=$((width - filled))

    local bar_filled bar_empty
    bar_filled=$(printf "%${filled}s" "" | tr ' ' '█')
    bar_empty=$(printf "%${empty}s" "" | tr ' ' '░')

    local elapsed=$(( $(date +%s) - start ))
    local eta="calculating"
    if [ "$current" -gt 0 ]; then
        local rate_per_url=$(( elapsed / current ))
        [ "$rate_per_url" -lt 1 ] && rate_per_url=1
        local remaining=$((total - current))
        local eta_s=$(( rate_per_url * remaining ))
        eta=$(printf "%dm%02ds" $((eta_s/60)) $((eta_s%60)))
    fi
    local elapsed_fmt
    elapsed_fmt=$(printf "%dm%02ds" $((elapsed/60)) $((elapsed%60)))

    printf '  %b[%s%s]%b %3d%%  %burls:%b %d/%d  %belapsed:%b %s  %beta:%b %s\n' \
        "$NEON_PINK" "$bar_filled" "$bar_empty" "$RESET" \
        "$pct" \
        "$DIM" "$RESET" "$current" "$total" \
        "$DIM" "$RESET" "$elapsed_fmt" \
        "$DIM" "$RESET" "$eta"
}

tz_url_summary() {
    local url_vulns=$1
    local url_elapsed=$2
    local done_count=$3
    local total=$4
    local overall_start=$5

    printf '\n  %b┌─ url complete ─%b\n' "$NEON_PINK" "$RESET"
    if [ "$url_vulns" -gt 0 ]; then
        printf '  %b│%b  found: %b%d vuln(s)%b  time: %ds\n' \
            "$NEON_PINK" "$RESET" \
            "${NEON_GREEN}${BOLD}" "$url_vulns" "$RESET" \
            "$url_elapsed"
    else
        printf '  %b│%b  found: %bnone%b  time: %ds\n' \
            "$NEON_PINK" "$RESET" \
            "$DIM" "$RESET" \
            "$url_elapsed"
    fi
    printf '  %b└─%b\n' "$NEON_PINK" "$RESET"
    tz_progress_overall "$done_count" "$total" "$overall_start"
}

tz_stats_panel() {
    echo
    tz_rule "$NEON_PURPLE" "─" 70
    printf '  %brunning totals%b   ' "${NEON_PURPLE}${BOLD}" "$RESET"
    printf '%b[CRITICAL: %d]%b  ' "$NEON_RED"    "$VULN_CRITICAL" "$RESET"
    printf '%b[HIGH: %d]%b  '     "$NEON_ORANGE" "$VULN_HIGH"     "$RESET"
    printf '%b[MEDIUM: %d]%b  '   "$NEON_YELLOW" "$VULN_MEDIUM"   "$RESET"
    printf '%b[LOW: %d]%b\n'      "$NEON_CYAN"   "$VULN_LOW"      "$RESET"
    tz_rule "$NEON_PURPLE" "─" 70
}

# Main menu — updated description mentions subfinder + waybackurls
tz_main_menu() {
    clear
    echo
    tz_neon_echo "╔══════════════════════════════════════════════════════════════════════╗"
    tz_neon_echo "║                                                                      ║"
    tz_neon_echo "║                          TerminatorZ v3.0                            ║"
    tz_neon_echo "║               Offensive CVE Exploitation Framework                   ║"
    tz_neon_echo "║                                                                      ║"
    tz_neon_echo "║              Author: Chris 'SaintDruG' Abou-Chabké                   ║"
    tz_neon_echo "║              Organization: Black Hat Ethical Hacking                 ║"
    tz_neon_echo "║              Website: www.blackhatethicalhacking.com                 ║"
    tz_neon_echo "║                                                                      ║"
    tz_neon_echo "╚══════════════════════════════════════════════════════════════════════╝"
    echo
    printf '  %bTerminatorZ is a targeted Web Exploitation Framework that chains Recon%b\n'  "$NEON_CYAN" "$RESET"
    printf '  %busing subfinder for subdomain discovery and waybackurls for archived path%b\n' "$NEON_CYAN" "$RESET"
    printf '  %bcollection, then fires 31 deterministic CVE and vulnerability checks%b\n'   "$NEON_CYAN" "$RESET"
    printf '  %bagainst every live URL. Fast, passive-to-active, zero false-positive by design.%b\n' "$NEON_CYAN" "$RESET"
    echo
    printf '  %bSelect Attack Mode:%b\n\n' "${NEON_PINK}${BOLD}" "$RESET"
    printf '    %b1%b  Full Scan          %bAll 31 CVE & Vulnerability Checks%b\n' \
        "$NEON_GREEN"  "$RESET" "$DIM" "$RESET"
    printf '    %b2%b  Custom Scan        %bChoose Which CVEs To Scan%b\n' \
        "$NEON_CYAN"   "$RESET" "$DIM" "$RESET"
    printf '    %b3%b  View Reports       %bPrevious Scan History%b\n' \
        "$NEON_PURPLE" "$RESET" "$DIM" "$RESET"
    printf '    %b4%b  Exit\n\n' "$NEON_PINK" "$RESET"
}

tz_custom_picker() {
    clear
    tz_section "Custom Scan — Select Checks" "$NEON_CYAN"
    echo
    local i=1
    local key
    for key in "${TZ_CHECK_ORDER[@]}"; do
        local sev
        sev=$(tz_severity "$key")
        local sev_color
        sev_color=$(tz_sev_color "$sev")
        local display
        display=$(tz_display_name "$key")
        printf '  %b%2d.%b  %-40s %b[%s]%b\n' \
            "$NEON_PURPLE" "$i" "$RESET" \
            "$display" \
            "$sev_color" "$sev" "$RESET"
        i=$((i + 1))
    done
    echo
    printf '  %bEnter numbers separated by spaces (e.g. 1 3 5 12), or "all":%b\n' \
        "${NEON_CYAN}${BOLD}" "$RESET"
    printf '  > '
    local selection
    read -r selection

    TZ_CUSTOM_SELECTION=()
    if [[ "$selection" == "all" ]]; then
        TZ_CUSTOM_SELECTION=("${TZ_CHECK_ORDER[@]}")
    else
        local num
        for num in $selection; do
            if [[ "$num" =~ ^[0-9]+$ ]] && [ "$num" -ge 1 ] && [ "$num" -le "${#TZ_CHECK_ORDER[@]}" ]; then
                TZ_CUSTOM_SELECTION+=("${TZ_CHECK_ORDER[$((num-1))]}")
            fi
        done
    fi
    export TZ_CUSTOM_SELECTION
}

export -f tz_neon_echo tz_rule tz_section tz_info tz_ok tz_warn tz_err
export -f tz_url_header tz_check_line tz_progress_overall tz_url_summary tz_stats_panel
export -f tz_main_menu tz_custom_picker
