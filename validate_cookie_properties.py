import sys
from http.cookies import SimpleCookie
# Python3 script performing validation on the cookies present in a HTTP response.
# Expect a complete HTTP response (header + body) to be passed as input via the following piping syntax:
# curl -ski https://www.myapp.com | python3 validate_cookie_properties.py


def extract_cookies(response_content):
    cookies_collection = []
    lines = response_content.split("\n")
    for line in lines:
        if line.lower().startswith("set-cookie:"):
            cookie = SimpleCookie()
            cookie.load(line[12:].strip())
            cookies_collection.append(cookie)
        if line.lower().startswith("set-cookie2:"):
            cookie = SimpleCookie()
            cookie.load(line[13:].strip())
            cookies_collection.append(cookie)
    return cookies_collection


def validate_cookies(cookies_collection):
    issue_detected = False
    for ckie in cookies_collection:
        for cookie_key, morsel in ckie.items():
            cookie_name = cookie_key
            for key, value in morsel.items():
                if key == "secure" and not value:
                    print(
                        f"Cookie '{cookie_name}' do not have the 'Secure' attribute defined.")
                    issue_detected = True
                if key == "httponly" and not value:
                    print(
                        f"Cookie '{cookie_name}' do not have the 'HttpOnly' attribute defined.")
                    issue_detected = True
                if key == "samesite" and value not in ["strict", "lax"]:
                    if len(value) == 0:
                        print(
                            f"Cookie '{cookie_name}' do not have the 'SameSite' attribute defined.")
                    else:
                        print(
                            f"Cookie '{cookie_name}' do not have the 'SameSite' attribute securely defined (value set to '{value}').")
                    issue_detected = True
    return issue_detected


if __name__ == "__main__":
    return_code = 0
    # Gather the response content
    response_text = "\n".join(sys.stdin)
    # Apply validations
    if len(response_text) > 0:
        cookies = extract_cookies(response_text)
        if len(cookies) > 0:
            issue_detected = validate_cookies(cookies)
            if issue_detected:
                return_code = 1
sys.exit(return_code)
