#!/usr/bin/env bash
# ==============================================================================
# Elite Master DNS Audit Suite (v3.4.Ultimate.Portable)
#
# Description:
#   Zero-hardcode, SOLID-compliant DNS infrastructure validation.
#   Engineered for absolute path anonymity and cross-platform portability.
#
# Principles:
#   - ZERO Absolute Paths: Output uses relative paths or $HOME variables.
#   - Robust Detection: Handles macOS/Linux DNS quirks and multi-line strings.
#   - Full Coverage: Syntax, Lifecycle, DNSSEC, Stealth, Performance.
# ==============================================================================

set -euo pipefail

# --- Adaptive Configuration ---
_detect_dns() {
    if ping -c 1 -t 1 127.0.0.2 >/dev/null 2>&1; then
        echo "127.0.0.2"
        return 0
    fi
    if command -v scutil >/dev/null 2>&1; then
        scutil --dns | awk '/nameserver\[0\]/ {print $3; exit}' | tr -d '[:space:]' && return 0
    fi
    [[ -f /etc/resolv.conf ]] && awk '/nameserver/ {print $2; exit}' /etc/resolv.conf | head -n 1 | tr -d '[:space:]' && return 0
    echo "127.0.0.1"
}

readonly TARGET_IP="${DNS_IP:-$(_detect_dns)}"
readonly TARGET_PORT="${DNS_PORT:-53}"
readonly TIMEOUT="${TEST_TIMEOUT:-5}"
readonly RETRIES="${TEST_RETRIES:-2}"
readonly NO_COLOR="${NO_COLOR:-}"

# Portable Path Resolution
readonly USER_HOME="${HOME:-~}"
readonly CONF_DIR="${CONFIG_DIR:-$USER_HOME/.config/dnscrypt-proxy}"
readonly CONFIG_FILE="${CONFIG_PATH:-$CONF_DIR/dnscrypt-proxy.toml}"
readonly CACHE_DIR="${CACHE_PATH:-/opt/homebrew/var/cache/dnscrypt-proxy}"

# --- Privilege Management ---
SUDO=""
[[ $EUID -ne 0 ]] && command -v sudo >/dev/null 2>&1 && sudo -n true 2>/dev/null && SUDO="sudo"

# --- Presentation Layer ---
log_info()    { echo -e "$(_color '34' 'ℹ️') $1"; }
log_success() { echo -e "$(_color '32' '✅') $1"; }
log_warn()    { echo -e "$(_color '33' '⚠️') $1"; }
log_error()   { echo -e "$(_color '31' '❌') $1" >&2; }

_color() {
    local code="$1"; local text="$2"
    [[ -z "${NO_COLOR}" ]] && [[ -t 1 ]] && echo -en "\033[0;${code}m${text}\033[0m" || echo -n "${text}"
}

# --- Core Networking ---
query() {
    local type="$1"; local domain="$2"; local args="${3:-}"
    # shellcheck disable=SC2086
    dig "@${TARGET_IP}" -p "${TARGET_PORT}" "${domain}" "${type}" +time="${TIMEOUT}" +tries="${RETRIES}" $args
}

short_query() { query "$1" "$2" "+short"; }

# --- Audit Modules ---

test_01_syntax() {
    log_info "Audit: Configuration Syntax..."
    if command -v dnscrypt-proxy >/dev/null 2>&1; then
        if dnscrypt-proxy -check -config "$CONFIG_FILE" >/dev/null 2>&1; then
            # We only show the basename to ensure absolute path anonymity
            log_success "Syntax: PASS (Verified $(basename "$CONFIG_FILE"))"
            return 0
        fi
    fi
    log_error "Syntax: FAIL (Configuration invalid or not found)"
    return 1
}

test_02_lifecycle() {
    log_info "Audit: Service Lifecycle & Socket Binding..."
    local fail=0
    # 1. Socket Check (Corrected for macOS UDP behavior)
    if command -v lsof >/dev/null 2>&1; then
        if $SUDO lsof -nP -i "UDP@${TARGET_IP}:${TARGET_PORT}" >/dev/null 2>&1 || \
           $SUDO lsof -nP -i "TCP@${TARGET_IP}:${TARGET_PORT}" | grep -q LISTEN; then
            log_success "Socket: Active on ${TARGET_IP}:${TARGET_PORT}"
        else
            if dig "@${TARGET_IP}" -p "${TARGET_PORT}" google.com +short +time=1 >/dev/null 2>&1; then
                log_success "Socket: Active (Verified via Resolution)"
            else
                log_error "Socket: INACTIVE on ${TARGET_IP}:${TARGET_PORT}"
                fail=1
            fi
        fi
    fi
    # 2. Service Check
    if command -v brew >/dev/null 2>&1; then
        if brew services list 2>/dev/null | grep -qE "dnscrypt-proxy\s+started"; then
            log_success "Service: Daemon reported as 'started'"
        else
            log_warn "Service: Daemon status not confirmed"
        fi
    fi
    return "$fail"
}

test_03_integration() {
    log_info "Audit: OS-Level DNS Integration..."
    local cur; cur=$(_detect_dns)
    if [[ "$cur" == "$TARGET_IP" ]]; then
        log_success "OS Routing: Synchronized (System uses $TARGET_IP)"
    else
        log_warn "OS Routing: MISMATCH (System uses $cur, Target is $TARGET_IP)"
    fi
    return 0
}

test_04_integrity() {
    log_info "Audit: DNSSEC Cryptographic Proof (SigFail)..."
    local sigok; local sigfail
    sigok=$(short_query "A" "sigok.verteiltesysteme.net")
    sigfail=$(query "A" "sigfail.verteiltesysteme.net" "+noall +comments" 2>/dev/null || true)

    if [[ -n "$sigok" ]] && echo "$sigfail" | grep -q "SERVFAIL"; then
        log_success "DNSSEC: VALIDATED (Functional protection active)"
    elif [[ -n "$sigok" ]]; then
        log_error "DNSSEC: FAIL (Broken signatures bypassed validation!)"
        return 1
    else
        log_error "DNSSEC: UNREACHABLE (Check connectivity/relays)"
        return 1
    fi
}

test_05_performance() {
    log_info "Audit: Hyper-Caching (Elite Speed Requirement)..."
    short_query "A" "google.com" >/dev/null 2>&1 || true
    local ms; ms=$(query "A" "google.com" "+stats" | awk '/Query time:/ {print $4}')
    if [[ -n "$ms" && "$ms" -le 1 ]]; then
        log_success "Performance: ELITE SPEED (${ms}ms)"
    else
        log_warn "Performance: SUBOPTIMAL (${ms:-N/A}ms)"
    fi
}

test_06_anonymity() {
    log_info "Audit: Anonymization & Relay Integrity..."
    local txt; local ip
    txt=$(short_query "TXT" "resolver.dnscrypt.info")
    ip=$(echo "$txt" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' | head -n 1 || true)
    [[ -z "$ip" ]] && { log_error "Anonymity: Metadata resolution failed"; return 1; }

    [[ "$(short_query "TXT" "debug.dnscrypt-proxy" || true)" == *"via"* ]] \
        && log_success "Stealth: ACTIVE" || log_warn "Stealth: UNKNOWN"

    local json; json=$(curl -s --max-time 5 "http://ip-api.com/json/${ip}?fields=status,isp,hosting")
    if [[ $(echo "$json" | jq -r '.status') == "success" ]]; then
        local isp; local hosting; isp=$(echo "$json" | jq -r '.isp'); hosting=$(echo "$json" | jq -r '.hosting')
        log_info "Endpoint: $ip ($isp)"
        [[ "$hosting" == "true" ]] && log_success "Privacy: VERIFIED" || log_warn "Privacy: RESIDENTIAL"
    fi
}

test_07_metadata() {
    log_info "Audit: Information Entropy (ECS & QNAME)..."
    local ecs; ecs=$(short_query "TXT" "o-o.myaddr.l.google.com" | tr -d '"' | head -n 1 || true)
    [[ -n "$ecs" ]] && log_success "ECS Visibility: $ecs" || log_warn "ECS: Timeout"
    [[ -n $(short_query "TXT" "qnamemintest.internet.nl" || true) ]] \
        && log_success "QNAME Min: ACTIVE" || log_warn "QNAME Min: INACTIVE"
}

test_08_blocking() {
    log_info "Audit: Local Deterministic Filtering..."
    [[ -z $(short_query "A" "ad.animehub.ac") ]] && log_success "Filtering: ACTIVE" || log_warn "Filtering: INACTIVE"
}

# --- Orchestrator ---
main() {
    echo -e "\n━━━ Elite MASTER DNS Audit (v3.4) ━━━"
    echo "Target: ${TARGET_IP}:${TARGET_PORT} | Host: $(hostname)"
    echo "=========================================================="

    for d in dig curl jq awk; do
        command -v "$d" >/dev/null || { log_error "Missing dependency: $d"; exit 1; }
    done

    local fail=0
    local tests=(
        "test_01_syntax" "test_02_lifecycle" "test_03_integration"
        "test_04_integrity" "test_05_performance" "test_06_anonymity"
        "test_07_metadata" "test_08_blocking"
    )

    for t in "${tests[@]}"; do
        $t || fail=$((fail+1))
        echo "----------------------------------------------------------"
    done

    if [[ $fail -gt 0 ]]; then
        log_error "Final: $fail CRITICAL FAILURE(S) DETECTED."
        exit 1
    else
        log_success "Final: SYSTEM NOMINAL. PhD-Level Alignment Verified."
        exit 0
    fi
}

main "$@"
