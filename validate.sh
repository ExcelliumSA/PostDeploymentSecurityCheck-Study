#!/bin/bash
# Prevent any debugging call to see the web hook url
set +x
# Quick startup check
USER_AGENT="Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:96.0)"
APP_BASE_URL=$1
if [ -z $APP_BASE_URL ]
then
    echo "[!] Web app url is empty!"
    exit 1
fi
# Security validations utility functions:
# Every security check is implemented in a dedicated function 
# including tools installation as well as the check
validate_http_security_response_headers () {
    # Install tools
    wget -q -O /tmp/venom https://github.com/ovh/venom/releases/download/v1.0.1/venom.linux-amd64
    wget -q -O /tmp/venom_security_headers_tests_suite.yml https://gist.githubusercontent.com/righettod/f63548ebd96bed82269dcc3dfea27056/raw/93cbc0a393094eb7dbdacf8c252d7eab8a4c8b2f/venom_security_headers_tests_suite.yml
    chmod +x /tmp/venom
    /tmp/venom update
    # Run the tool against the app using the dedicated test plan
    /tmp/venom run --var="target_site=$APP_BASE_URL" /tmp/venom_security_headers_tests_suite.yml 
}

validate_secure_protocol_usage () {
    # Replace HTTPS protocol by HTTP one
    url=$(echo "$APP_BASE_URL" | sed "s/https/http/")
    # Ensure that either a redirection to HTTPS is in place or that connection is rejected
    curl -I -A $USER_AGENT --connect-timeout 10 -sk $url > /tmp/buffer.txt
    if [ $? -ne 0 ];
    then
        # Connection rejected so it's OK
        echo "Connection rejected to $url so it's OK."
        return 0
    else
        redirection=$(grep -ic "Moved Permanently" /tmp/buffer.txt)
        secure_protocol_used=$(grep -ic "location: $APP_BASE_URL" /tmp/buffer.txt)
        # Redirection to a secure protocol is in place
        if [ $redirection -ne 0 -a $secure_protocol_used -ne 0 ];
        then
            echo "Permanent redirection to a HTTPS protocol is in place so it's OK."
            return 0
        else
            echo "Permanent redirection to a HTTPS protocol is NOT in place."
            return 1
        fi
    fi
}

validate_tls_configuration () {
    # Install tools
    rm -rf /tmp/testssl 2>/dev/null
    git clone --quiet --depth 1 https://github.com/drwetter/testssl.sh.git /tmp/testssl
    chmod +x -R /tmp/testssl
    # Run the tool against the app
    bash /tmp/testssl/testssl.sh --overwrite --severity LOW --jsonfile /tmp/testssl.json --quiet -s -p -U $APP_BASE_URL
    # Count issue excluding warnings
    issue_count=$(cat /tmp/testssl.json | jq '[.[] | select(.severity != "WARN")] | length')
    echo "$issue_count issue(s) found."
    return $issue_count
}

validate_exposed_content () {
    issue_count=0
    # Install tools
    wget -q -O /tmp/ffuf.tgz https://github.com/ffuf/ffuf/releases/download/v1.3.1/ffuf_1.3.1_linux_amd64.tar.gz
    cd /tmp; tar xf ffuf.tgz; chmod +x /tmp/ffuf; cd -
    # Run the tool against the app using the dictionary of content that must be excluded from the deployment
    /tmp/ffuf -u $APP_BASE_URL/FUZZ -w content_excluded_from_deployment.txt -r -recursion -recursion-depth 3 -t 10 -mc 200 -o /tmp/ffuf.json -of json
    excluded_item_found=$(cat /tmp/ffuf.json| jq ".results | length")
    echo "$excluded_item_found excluded item(s) found."
    issue_count=$((issue_count + $excluded_item_found))
    # Search for different kind of information disclosure
    express_framework_usage_disclosed=$(curl -A $USER_AGENT -skI $APP_BASE_URL | grep -ic "X-Powered-By: Express")
    echo "Expression framework usage disclosed (0 = no): $express_framework_usage_disclosed"
    issue_count=$((issue_count + $express_framework_usage_disclosed))
    error_handling_misconfiguration=$(curl -A $USER_AGENT -skI $APP_BASE_URL/hello | grep -ic "SendStream\.emit")
    echo "Error handling misconfiguration (0 = no): $error_handling_misconfiguration"
    issue_count=$((issue_count + $error_handling_misconfiguration))
    return $issue_count
}

validate_securitytxt_file_presence () {
    file_is_present=$(curl -L -sk $APP_BASE_URL/security.txt | grep -iFc "mailto:emergency@excellium-services.com")
    echo "File is present (0 = no): $file_is_present"
    if [ $file_is_present -eq 0 ];
    then
        return 1
    else
        return 0
    fi
}

cleanup () {
    rm /tmp/venom* 2>/dev/null
    rm /tmp/buffer.txt 2>/dev/null
    rm -rf /tmp/testssl 2>/dev/null
    rm /tmp/testssl.json 2>/dev/null
    rm /tmp/ffuf* 2>/dev/null
}


# Main processing
## Print a global state and fail only at the end
failure=0
## Execute all validation functions
security_functions=("validate_http_security_response_headers" "validate_secure_protocol_usage" "validate_tls_configuration" "validate_exposed_content" "validate_securitytxt_file_presence")
for security_function in ${security_functions[@]}; do
    echo -e "\e[94m[+] Execute '$security_function'\e[0m"
    $security_function
    failure=$((failure + $?))  
done
## Final cleanup
echo -e "\e[94m[+] Cleanup\e[0m"
cleanup
# Final result code indicating the validate state
echo -e "\e[94m[+] RC\e[0m"
echo $failure



