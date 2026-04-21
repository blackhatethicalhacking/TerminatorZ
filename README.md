<h1 align="center">BHEH's TerminatorZ</h1>

<p align="center">
<a href="https://www.blackhatethicalhacking.com"><img src="https://www.blackhatethicalhacking.com/wp-content/uploads/2022/06/BHEH_logo.png" width="300px" alt="BHEH"></a>
</p>

<p align="center">
TerminatorZ is written by Chris "SaintDruG" Abou-Chabké from Black Hat Ethical Hacking and is designed for Offensive Security attacks. 
</p>

<h1 align="center"><b>Black Hat Ethical Hacking</b></h1>

<p align="center">
<img src="https://github-readme-stats.vercel.app/api?username=blackhatethicalhacking&show_icons=true&include_all_commits=true">
<br>
<br>
</p>

<!--
**blackhatethicalhacking** is a ✨ _special_ ✨ repository because its `README.md` (this file) appears on your GitHub profile.

Here are some ideas to get you started:

- 🔭 I’m currently working on ...
- 🌱 I’m currently learning ...
- 👯 I’m looking to collaborate on ...
- 🤔 I’m looking for help with ...
- 💬 Ask me about ...
- 📫 How to reach me: ...
- 😄 Pronouns: ...
- ⚡ Fun fact: ...
-->


# Description

TerminatorZ v3.0 is an Offensive CVE Exploitation Framework. It chains reconnaissance across multiple sources, validates which URLs are actually alive, then fires 31 deterministic CVE and vulnerability checks against every live endpoint it finds. Unlike defensive scanners such as Nessus or Qualys which flag configuration drift, TerminatorZ actively exploits known CVEs and confirms them with a proof-of-concept URL and a matched proof signal. It is closer in spirit to Nuclei than to a traditional vulnerability scanner, purpose-built for red teamers, bug bounty hunters, and offensive security professionals who need fast, accurate first-pass exploitation results on a target.

The framework is written in pure Bash, uses a modular architecture, and ships with a brand new neon terminal UI. It is designed around three principles: speed, determinism, and zero false-positives by construction. Every check either proves a vulnerability with a concrete PoC or reports clean — nothing in between.

# What Makes TerminatorZ v3 Unique

- **Active exploitation, not configuration review.** TerminatorZ sends real payloads and confirms real vulnerabilities. Every finding comes with the exact PoC URL it used and the proof signal that matched.
- **Zero false-positives by design.** Every one of the 31 checks uses a deterministic detection signature. SQL injection requires a specific DB error string. XSS requires an unencoded canary reflection. SSTI requires two different arithmetic probes to both evaluate. Command injection requires a unique per-run canary to appear without its literal `echo` string. LFI requires a real `/etc/passwd` layout, not just the word "root".
- **Multi-source recon pipeline.** subfinder pulls subdomains from 40+ passive sources under the hood, waybackurls pulls archived path URLs from the Wayback Machine, then httpx validates which URLs are actually alive before the attack begins.
- **Asset-type intelligence.** URLs ending in `.js`, `.css`, `.png`, `.svg`, `.woff`, `.map` and similar static assets automatically get header-based checks only (10 checks) instead of the full 31. This cuts scan time on real-world targets by 60-70% because most waybackurls output is static content where injection checks are wasted work.
- **Post-recon confirmation gate.** After URL gathering and httpx validation, the framework pauses and shows you everything it found, letting you proceed with Enter or cancel with c. No more wondering what happened.
- **Graceful Ctrl+C handling.** Interrupt the scan any time and TerminatorZ stops cleanly, shows partial results, and offers report generation on whatever was found so far. No lost work, no panic.
- **Neon real-time verbose output.** Every check for every URL prints as it runs, with the full proof-of-concept URL on vulnerable findings, a per-URL progress footer, a running-totals panel, and an overall progress bar with ETA.
- **Production HTML and Markdown reports.** Every finding includes the target URL, the exact PoC URL, and the proof signal that matched — ready for client deliverables.

<div align="center">

**Total checks in v3: 31** (v2 had 24)

<img src="https://user-images.githubusercontent.com/13942386/220471761-3c554abf-ece4-442f-84de-2b28b5f02329.gif" />

</div>


# The Flow & Methodology

Every scan walks the same five phases. The framework is deterministic at every step, which is what makes the zero-false-positive guarantee possible.

**Phase 1 — Reconnaissance**

subfinder discovers subdomains of the target by querying 40+ passive sources (Censys, Shodan, VirusTotal, SecurityTrails, and others). Each subdomain is normalised to both `https://sub/` and `http://sub/` root URLs so that host-based checks can run against every one of them. In parallel, waybackurls queries the Wayback Machine for archived path URLs belonging to the base domain, yielding every endpoint that was ever indexed. Every URL is run through a strict sanitiser that drops malformed entries (concatenated URLs, whitespace-containing strings, non-http(s) schemes, length over 2000 characters) before the list hits disk.

**Phase 2 — Validation**

httpx from ProjectDiscovery probes every gathered URL to determine which are actually alive. Only URLs returning a real response make it into the final scan list. If httpx is missing or returns zero results, the framework automatically falls back to a curl-based parallel probe so validation never silently fails. URLs stream live to the screen as httpx finds them.

**Phase 3 — Confirmation Gate**

After recon and validation complete, the framework shows a summary: target, live URL count, mode, thread count, run label, and file paths for the recon log and URL list. The operator presses Enter to proceed or c to cancel. This is the moment to review what was gathered before any active payloads are sent.

**Phase 4 — Attack**

TerminatorZ spawns a bash worker pool at the requested thread count. Each URL goes through the appropriate check set — 31 checks for dynamic URLs, 10 header-based checks for static assets — with every probe URL and every response evaluated against a specific detection signature. Output is serialised through a mutex so per-URL blocks never interleave across workers. Findings are written to disk immediately under a flock-protected append so that even a mid-scan interrupt preserves everything.

**Phase 5 — Reporting**

Running totals update in real time during the scan. On completion (or interrupt), the operator is offered HTML and Markdown report generation. Every finding in both report formats includes the target URL, the full PoC URL with payload, and the proof signal. The HTML report uses the neon palette with severity-coded finding blocks.

# Features

## 31 Deterministic CVE and Vulnerability Checks

Each check returns a binary result — vulnerable or clean — based on a specific detection signature.

**Critical severity**

- SQL Injection — matches specific DB error signatures (MySQL, PostgreSQL, Oracle, MSSQL, SQLite, PDO)
- Server-Side Template Injection — two-probe confirmation (`{{7*7}}` evaluates to 49 AND `{{8*9}}` evaluates to 72)
- Shellshock RCE — unique per-run canary echoed through a User-Agent payload
- Command Injection — unique per-run canary confirmed without its literal echo string
- Log4Shell (CVE-2021-44228) — JNDI payload in headers, Java/LDAP error signature in response
- NoSQL Injection — `$gt` operator login bypass with baseline comparison
- .git Directory Exposed — `/.git/config` containing real git config headers
- .env File Exposed — `/.env` containing real credential keys (DB_PASSWORD, APP_KEY, AWS_ACCESS_KEY, etc.)

**High severity**

- Local File Inclusion — real `/etc/passwd` layout verification (root line plus shell path plus colon-separated structure)
- Remote File Inclusion — base64 data URI canary rendered back in response
- Server-Side Request Forgery — cloud metadata field names in response (ami-id, instance-id, iam/security-credentials)
- XML External Entity — external entity reading `/etc/passwd` with verified output
- JWT None Algorithm — base64-decoded JWT header showing `"alg":"none"`
- OAuth Redirect Misconfiguration — Location header points to arbitrary canary domain
- Insecure Direct Object Reference — numeric ID manipulation with PII field confirmation
- Sensitive Data Exposure — high-confidence secret regex (AWS keys, Google API keys, Stripe keys, GitHub tokens, Slack tokens, private keys, JWTs)
- Admin Panel Exposed — common admin paths returning 200 with admin/login UI
- Backup File Exposed — common backup file extensions with credential or SQL content

**Medium severity**

- Reflected XSS — unique canary reflected unencoded
- Missing CSRF Protection — POST form present with no anti-CSRF token field
- Open Redirect — Location header points to canary domain via common redirect parameters
- CORS Misconfiguration — `Access-Control-Allow-Origin` reflects arbitrary origin
- GraphQL Introspection — `__schema.types` returned from `/graphql` endpoints
- Web Cache Poisoning — forged X-Forwarded-Host persisted into cached response
- AI Prompt Injection — canary response confirms model followed injected instruction
- Missing Subresource Integrity — external scripts without `integrity=` attribute
- Directory Listing — "Index of /" title present

**Low severity**

- Host Header Injection — forged Host reflected in page links or Location header
- Clickjacking — no X-Frame-Options AND no CSP frame-ancestors
- Missing Security Headers — HSTS, X-Content-Type-Options, Referrer-Policy, Permissions-Policy
- HTTP Plaintext Exposure — plaintext page with HTTPS equivalent available
- Server Version Disclosure — Server or X-Powered-By headers leaking version numbers

## New Neon Terminal UI

- 256-colour ANSI palette (neon pink, cyan, green, yellow, red, orange, purple)
- Live streaming verbose output showing every check for every URL as it runs
- Per-URL completion footer with vulnerability count and elapsed time
- Overall progress bar with URLs completed, percentage, elapsed, and ETA
- Running totals panel updating after every URL
- Severity-coded vulnerable lines with PoC URL and proof signal displayed inline

## Multi-Source Reconnaissance

- subfinder for passive subdomain discovery across 40+ sources
- waybackurls for archived path URL discovery via the Wayback Machine
- httpx from ProjectDiscovery for alive-URL validation
- Automatic curl-based fallback probe if httpx is missing or fails
- Strict URL sanitiser that drops malformed concatenated URLs and invalid schemes

## Asset-Type Intelligence

URLs whose extension identifies them as static assets receive only the 10 header-based checks rather than the full 31. This includes:

- `.js`, `.css`, `.map`
- `.png`, `.jpg`, `.jpeg`, `.gif`, `.svg`, `.webp`, `.ico`
- `.woff`, `.woff2`, `.ttf`, `.eot`
- `.mp4`, `.webm`, `.mp3`
- `.pdf`, `.txt`

On real targets where the majority of waybackurls output is static content, this reduces scan time by 60-70% without reducing coverage on dynamic endpoints.

## Graceful Interrupt Handling

Press Ctrl+C at any point during the scan and TerminatorZ will:

- Stop all in-flight worker processes cleanly
- Preserve all findings gathered up to that point (findings are written to disk immediately, not at the end)
- Display a partial-results summary showing URLs processed so far and severity counts
- Offer HTML and Markdown report generation on the partial findings
- Return to the main menu without losing work

A second Ctrl+C during the handler forces a hard exit as an escape hatch.

Recon phase interrupts work the same way — if you Ctrl+C during subfinder or waybackurls, the framework stops, counts how many URLs were gathered, and asks whether you want to scan with partial results or return to the menu.

## Per-Target Result Management

Every scan creates a results directory at `results/<domain>/`. Re-scanning an existing target prompts for:

- Overwrite — delete existing results and start fresh
- New Run — auto-increment to `<domain>_2`, `<domain>_3`, etc. for comparing scans over time
- Cancel — return to main menu without touching anything

The View Reports menu lists all past scans with timestamps and findings counts, and self-cleans stale entries when the corresponding results directory has been deleted.

## Structured Finding Output

Every finding is written in a machine-parseable format:

```
[CRITICAL] SQL Injection
  target: https://target.com/search.php?q=1
  poc:    https://target.com/search.php?q=1%27
  proof:  DB error signature: You have an error in your SQL syntax
```

This format is grep-friendly, parses cleanly into the HTML and Markdown reports, and is pipeable into downstream tools.

## HTML and Markdown Reports

- Neon-styled HTML report with severity-coded finding blocks
- Every finding shows target URL, full PoC URL, and proof signal
- Executive summary table with total URLs and severity counts
- Markdown report with identical content for pipeline integration
- Reports include author, organisation, and website in the footer

## Cross-Platform Compatibility

- Kali Linux and Debian/Ubuntu — runs directly with no extra setup
- macOS — auto-detects missing Bash 4+ and flock at startup with clear install hints; automatically re-executes under Homebrew's bash once installed
- Auto-detection of ProjectDiscovery httpx binary versus Python httpx library that may share the same command name


# Screenshots

**TZ Menu 1**

<img width="1910" height="1068" alt="TZ_Requ_Menu" src="https://github.com/user-attachments/assets/c0eb737d-c28c-4afc-b4e2-3419f29bb242" />

<br>

**TZ Menu 2**

<img width="1910" height="1068" alt="TZ_Main_Menu" src="https://github.com/user-attachments/assets/2971fa3f-0121-47eb-b554-7966d4fde748" />
<br>

**TZ 31 Vulnerabilities**

<img width="1910" height="1068" alt="TZ_31_Vulns" src="https://github.com/user-attachments/assets/95275c74-1b54-4d27-949e-75ecf7c2cfab" />
<br>

**TZ Recon in Progress**

<img width="1910" height="1068" alt="TZ_Recon_In_Progress" src="https://github.com/user-attachments/assets/49a8d7dd-9134-4350-aaa4-412008f83e56" />
<br>

**TZ Issues Found**

<img width="1910" height="1068" alt="TZ_Issues_Found" src="https://github.com/user-attachments/assets/2a977d4f-4846-4a13-b42f-337faa4218ff" />
<br>

**TZ Attacks in Progress**

<img width="1910" height="1068" alt="TZ_Attacks_In_Progress" src="https://github.com/user-attachments/assets/ca39ae08-1f92-4596-9796-9ea8c7d9528f" />
<br>

**TZ Generate Report**

<img width="1910" height="1068" alt="TZ_Generate_Report" src="https://github.com/user-attachments/assets/f8df0ac6-98aa-4aab-9c29-7ed9ea280946" />
<br>

**TZ Report 1**

<img width="1910" height="1068" alt="TZ_Report_1" src="https://github.com/user-attachments/assets/a3f340bc-7bcd-4f6b-8b9d-1df25329817e" />
<br>

**TZ Report 2**

<img width="1910" height="1068" alt="TZ_Report_2" src="https://github.com/user-attachments/assets/88259244-dc92-4168-895d-727727ab64f4" />


# Video Demo

https://github.com/user-attachments/assets/287186c7-a620-42a9-ae14-b57c63f4a309

# Expansion

Feel free to expand more POCs and integrate them. The idea is speed: one curl, one deterministic signature, one confirmed finding. If you want to contribute new checks, fork the repository and open a pull request — see the Contribution section below.


# Requirements

**Required tools**

- **Bash 4+** — pre-installed on Linux. macOS ships Bash 3.2 and needs Homebrew bash: `brew install bash`
- **flock** — pre-installed on Linux. macOS needs Homebrew flock: `brew install flock`
- **curl** — pre-installed on almost every system
- **subfinder** — ProjectDiscovery's subdomain enumeration tool. Install via `go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest` or `apt install subfinder` on Kali, `brew install subfinder` on macOS
- **waybackurls** — Wayback Machine URL extractor. Install via `go install github.com/tomnomnom/waybackurls@latest`
- **httpx** — ProjectDiscovery's HTTP toolkit. Install via `go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest` (note: this is NOT the Python `httpx` library — TerminatorZ auto-detects which one you have and warns if the wrong one is on your PATH)

**Optional tools**

- **figlet** — ASCII banner rendering. `apt install figlet` or `brew install figlet`
- **lolcat** — rainbow colour output. `apt install lolcat` or `brew install lolcat`
- **toilet** — decorative text borders. `apt install toilet` or `brew install toilet`

TerminatorZ ships with a built-in neon colour fallback, so the optional tools are purely cosmetic. The tool runs with full functionality whether they are installed or not.

**macOS-specific notes**

macOS default Bash is version 3.2 and cannot run TerminatorZ directly because the framework relies on Bash 4+ features. Install modern Bash and flock via Homebrew:

```
brew install bash flock
```

After installation, TerminatorZ will auto-detect Homebrew's bash at `/opt/homebrew/bin/bash` (Apple Silicon) or `/usr/local/bin/bash` (Intel) and re-execute itself under it. Users can simply run `./terminatorz.sh` as normal.


# Installation

```
git clone https://github.com/blackhatethicalhacking/TerminatorZ.git
cd TerminatorZ
chmod +x terminatorz.sh modules/*.sh
./terminatorz.sh
```

The directory layout after cloning:

```
TerminatorZ/
├── terminatorz.sh          Entry point
├── payloads.conf           Check definitions, severity map, canaries
├── modules/
│   ├── ui.sh               Neon UI, progress bars, menus
│   ├── utils.sh            Recon pipeline, dependency check, logging
│   ├── scanner.sh          All 31 check functions + worker pool
│   └── reporter.sh         HTML and Markdown report generation
├── results/                Created on first scan
│   └── <domain>/
│       ├── urls_raw.txt    All URLs gathered during recon
│       ├── urls.txt        Alive URLs after httpx validation
│       ├── recon.log       Full recon trace with dropped URL log
│       ├── <domain>.txt    Findings in structured format
│       ├── report.md       Markdown report
│       └── report.html     Neon HTML report
└── .scan_history           One line per completed scan
```


# Usage

Run the script with no arguments. The main menu presents four options:

- **Full Scan** — all 31 CVE and vulnerability checks against every live URL
- **Custom Scan** — select any subset of the 31 checks by number
- **View Reports** — browse previous scan history and open past HTML reports
- **Exit**

On a full scan, the framework will prompt for a target domain and concurrent thread count, run the multi-source recon pipeline, validate alive URLs with httpx, pause at the confirmation gate, then execute the attack phase with live streaming output. At completion it offers report generation on all findings.


# Compatibility

Tested on Kali Linux, Debian/Ubuntu, and macOS (Apple Silicon and Intel, with Homebrew bash). Windows is not supported — WSL2 with an Ubuntu or Kali distribution works.


# Latest Version & Updates

## Version 3.0 — Major Rewrite

A complete rewrite from v2. The architecture is now fully modular with separate files for UI, utilities, scanning, and reporting. The v2 monolithic script has been retired.

**New features**

- New tagline: Offensive CVE Exploitation Framework (v2 called it a vulnerability scanner, which undersold what it does)
- Neon terminal UI with 256-colour ANSI palette
- Multi-source recon pipeline (subfinder + waybackurls + httpx) replacing v2's waybackurls-only approach
- Post-recon confirmation gate — no more scans starting before you have seen what was gathered
- Graceful Ctrl+C handling with partial-result reporting at both recon and attack phases
- Asset-type filter — static asset URLs get 10 header checks instead of 31, cutting scan time by 60-70%
- Every finding now includes the exact PoC URL and the proof signal — v2 only recorded the target URL
- HTML report with neon styling and severity-coded finding blocks
- Structured findings format parseable by downstream tooling
- Auto-incrementing run labels (`domain_2`, `domain_3`) for comparing scans over time
- Scan history auto-prunes entries when result directories are deleted
- Bash 4+ auto-detection and re-execution under Homebrew bash on macOS
- flock dependency check at startup with install hints per OS
- ProjectDiscovery httpx auto-detection (disambiguates from Python's httpx library)
- Custom scan picker with numeric multi-select (no more interactive dependency on gum)

**New checks added in v3**

- SSTI (Server-Side Template Injection) with two-probe arithmetic confirmation
- IDOR (Insecure Direct Object Reference) with PII field verification
- GraphQL Introspection Enabled
- JWT None Algorithm
- Web Cache Poisoning
- OAuth Redirect Misconfiguration
- NoSQL Injection with baseline comparison
- AI Prompt Injection with canary response confirmation
- Missing Subresource Integrity
- HTTP Plaintext Exposure
- Directory Listing Enabled
- Server Version Disclosure
- Admin Panel Exposed with UI confirmation
- .git Directory Exposed
- .env File Exposed with credential key verification

**Checks dropped from v2**

Several v2 checks were unreliable in practice and have been removed or merged:

- Path Traversal — merged into LFI since they use identical payloads
- RCE (generic) — was a duplicate of Shellshock
- File Upload — v2 check was testing against the scanner's own filesystem, which could not work remotely
- HPP — v2 check matched any URL that reflected query parameters, producing false positives on most of the web
- Session Fixation — v2 check hardcoded a sessionid no server would ever set
- Insecure Deserialization — v2 check looked for `/tmp/pwned` on the scanner's filesystem
- Prototype Pollution — no reliable passive detection method exists
- HTTP Request Smuggling — cannot be reliably tested passively with curl

**Detection quality improvements**

- CSRF check now parses HTML forms and flags POST forms missing anti-CSRF token fields (v2 echoed its own payload back and false-positived on any search page)
- Clickjacking check now requires BOTH missing X-Frame-Options AND missing CSP frame-ancestors (v2 only checked X-Frame-Options)
- Sensitive Data check now uses specific secret regex patterns (AWS keys, API tokens, JWTs, private key blocks) instead of matching the bare string "api" (v2 triggered on every website)
- XSS check requires unencoded canary reflection rather than just presence of `<script>` in the response
- SSTI requires two different arithmetic probes to both evaluate correctly to confirm real template execution
- Command Injection uses unique per-run canaries and confirms the canary appears without its `echo` prefix string

## Version 2.0

- Added 8 new vulnerabilities with exploits: File Upload, Command Injection, Host Header Injection, HTTP Parameter Pollution, Clickjacking, CORS Misconfiguration, Sensitive Data Exposure, Session Fixation

## Version 1.1

- Enhancement in the output, Red for not vulnerable, Green for vulnerable
- Counts URLs before starting the attack for estimation
- Added 5 new vulnerabilities with exploits: XSS, SSRF, XXE, Insecure deserialization, Shellshock RCE


# Contribution

Contributions are welcome. The modular v3 architecture makes it easy to add new checks without touching the scan flow:

- Each check is a single bash function in `modules/scanner.sh` with the signature `check_<NAME>(url, domain)` that sets `TZ_HIT_POC` and `TZ_HIT_PROOF` on a positive finding and returns 1, or returns 0 for clean
- Add the check key to `TZ_CHECK_ORDER` in `payloads.conf`
- Add severity and display name mappings in the `tz_severity` and `tz_display_name` functions in `payloads.conf`
- If the check is header-only, also add the key to `TZ_HEADER_ONLY_CHECKS` in `modules/scanner.sh`

Detection logic must be deterministic — no heuristic guessing, no matching on overly generic strings. Every new check must include a proof signal that is specific enough to avoid false positives in the wild.

Open a pull request with your check and a brief description of the detection signature used. Contributions that fit the design philosophy will be credited.


# Disclaimer

This tool is provided for educational and research purposes only. The authors of this project are in no way responsible for any misuse of this tool. TerminatorZ is used under NDA agreements with clients and with their explicit consent for penetration testing purposes. We never encourage nor take responsibility for any damage caused by unauthorised use.

Unauthorised scanning of infrastructure you do not own or have not been contracted to test is illegal in most jurisdictions. Always obtain written authorisation before running this or any other offensive security tool against a target.


<h2 align="center">
  <a href="https://store.blackhatethicalhacking.com/" target="_blank">BHEH Official Merch</a>
</h2>

<p align="center">
Introducing our Merch Store, designed for the Offensive Security community. Explore a curated collection of apparel and drinkware, perfect for both professionals and enthusiasts. Our selection includes premium t-shirts, hoodies, and mugs, each featuring bold hacking-themed slogans and graphics that embody the spirit of red teaming and offensive security. 
Hack with style and showcase your dedication to hacker culture with gear that’s as dynamic and resilient as you are. 😊
</p>

<p align="center">

<img src="https://github.com/blackhatethicalhacking/blackhatethicalhacking/blob/main/Merch_Promo.gif" width="540px" height="540">
  </p>
