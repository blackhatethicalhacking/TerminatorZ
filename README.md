# BHEH's TerminatorZ


<p align="center">
<a href="https://www.blackhatethicalhacking.com"><img src="https://www.blackhatethicalhacking.com/wp-content/uploads/2022/06/BHEH_logo.png" width="300px" alt="BHEH"></a>
</p>

<p align="center">
TerminatorZ is written by Chris "SaintDruG" Abou-Chabke from Black Hat Ethical Hacking and is designed for Offensive Security attacks. 
</p>

<h1 align="center"><b>Black Hat Ethical Hacking</b></h1>

<p align="center">
<img src="https://github-readme-stats.vercel.app/api?username=blackhatethicalhacking&show_icons=true&include_all_commits=true">
<br>
<br>
</p>

Shout out and thanks to <a href="https://github.com/shadowdevnotreal"> ShadowDevnotreal

📫 How to reach me: chris@blackhatethicalhacking.com

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

TerminatorZ is a highly sophisticated and efficient web security tool that scans for potential vulnerabilities in your web applications. It uses a combination of advanced techniques, including using popular tools like waybackurls and curl, to scan your web applications and highlight any potential vulnerabilities. The results are displayed in an easy-to-read format in the terminal, and only vulnerable results are saved for further investigation. With its lightweight and fast nature, TerminatorZ is the perfect tool for any security professional who wants to keep their web applications secure.


# What Makes TerminatorZ Unique:

TerminatorZ is special because it's a highly customized for quick and speed high priority known CVES. The script then reads each URL from urls.txt and checks for various vulnerabilities including RCE, CSRF, LFI, open redirect, Log4J, RFI, path traversal, and SQL injection. For each vulnerability, the script performs a test by sending a specific HTTP request and looking for a specific response.

If the vulnerability is detected, the script will write a message to the domain.txt file indicating that the URL is vulnerable. If the vulnerability is not detected, the script will write a message indicating that the URL is not vulnerable.

**Total Vulnerabilities so far: 16**
  
It is also Special well, because:
  
![giphy](https://user-images.githubusercontent.com/13942386/220471761-3c554abf-ece4-442f-84de-2b28b5f02329.gif)


# The Flow & Methodology

The tool starts by asking the user to input the domain they wish to scan. It then creates a folder to store the results and starts the scan. The scan utilizes curl to make HTTP requests to the target domain and checks for various vulnerabilities by injecting known payloads. The tool then checks the responses for indicators of exploitation and validates the results to determine if the target is vulnerable.

The tool's methodology is carefully designed to ensure that each type of vulnerability is checked specifically and thoroughly. The tool employs a highly analytical and methodical approach to the scanning process, which results in the identification of even the most elusive vulnerabilities. The tool's logic is designed to be highly efficient and effective, making it the ultimate choice for red team security experts and web security professionals.

In conclusion, TerminatorZ is a game-changer in the world of web security. Its combination of technology, methodology, and expert logic makes it the ultimate tool for identifying and mitigating web application vulnerabilities. Speed is sometimes needed, if you want more tools that do not focus on speed, please make sure to check our other ones :)

# Latest Version & Updates:

V1.1:

- Enhancement in the output, Red for not vulnerable, Green for vulnerable.
- Counts URLs before starting the attack, which gives you an estimate, based on final URLs.
- Added 5 more new Vulnerabilities with exploits:

• XSS (Cross-site scripting)

• SSRF (Server-side request forgery)

• XXE (XML external entity)

• Insecure deserialization

• Remote Code Execution via Shellshock (RCE)


# Features:

Scans for various web application vulnerabilities, including:

- XSS (Cross-site scripting)

- SSRF (Server-side request forgery)

- XXE (XML external entity)

- Insecure deserialization

- Remote Code Execution via Shellshock (RCE)

- SQL Injection (SQLi)

- Cross-Site Scripting (XSS)

- Cross-Site Request Forgery (CSRF)

- Remote Code Execution (RCE)

- Log4J

- Directory Traversal (DT)

- File Inclusion (FI)

- Sensitive Data Exposure (SDE)

- Server Side Request Forgery (SSRF)

- Shell Injection (SI)

- Broken Access Control (BAC)

- Generates Random Sun Tzu Quote for Red Teamers, Checks if you are connected to the Internet too!

- Utilizes tools such as waybackurls, curl, and others for comprehensive vulnerability assessments

- Lightweight and fast, delivering results in real-time directly to the terminal

- Only reports vulnerabilities, making it easy to prioritize and remediate vulnerabilities in a timely manner

# Expansion

Feel free to expand more Pocs, and integrate it, the idea is speed, and sending 1 curl, send a push!


# Requirements:

- waybackurls: This tool can be installed by running `go install github.com/tomnomnom/waybackurls@latest`

- cURL: This tool is commonly pre-installed on Kali Linux and Ubuntu, but can be installed by running `apt-get install curl` on Ubuntu or `brew install curl` on MacOS

- httpx: is a fast and multi-purpose HTTP toolkit that allows running multiple probes using the retryable http library. To install it: `go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest`

- lolcat: `pip install lolcat` for rainbow beauty

# Installation

`git clone https://github.com/blackhatethicalhacking/TerminatorZ.git`

`cd TerminatorZ`

`chmod +x TerminatorZ.sh`

`./TerminatorZ.sh`

# Screenshot

<img width="958" alt="menu" src="https://user-images.githubusercontent.com/13942386/222258110-a0c83c4c-80b1-4be2-83b9-06afb7b175b7.png">

<img width="958" alt="urls" src="https://user-images.githubusercontent.com/13942386/222258143-fc094a5f-2e83-4316-a7bd-65be1adcc704.png">


# Compatibility: 

This tool has been tested on Kali Linux, Ubuntu and MacOS.

# To Do

A lot will be done and added to it, this is the starting point. If you want to contribute, send me a commit explaining what more / better you are doing, and will credit you if it fits the model of design in mind!

# Disclaimer

This tool is provided for educational and research purpose only. The author of this project are no way responsible for any misuse of this tool. 
We use it to test under NDA agreements with clients and their consents for pentesting purposes and we never encourage to misuse or take responsibility for any damage caused !

# Support

If you would like to support us, you can always buy us coffee(s)! :blush:

<a href="https://www.buymeacoffee.com/bheh" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/default-orange.png" alt="Buy Me A Coffee" height="41" width="174"></a>
