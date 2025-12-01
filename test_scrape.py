import requests
from bs4 import BeautifulSoup

url = "https://judgments.ecourts.gov.in/pdfsearch/index.php"

try:
    # First, get the page to see if we need a session/cookie or if there's a captcha in the form
    session = requests.Session()
    response = session.get(url, headers={'User-Agent': 'Mozilla/5.0'})
    
    print(f"Status Code: {response.status_code}")
    soup = BeautifulSoup(response.content, 'html.parser')
    
    # Check for captcha image
    captcha = soup.find('img', {'id': 'captcha_image'})
    if captcha:
        print("CAPTCHA DETECTED")
    else:
        print("NO CAPTCHA DETECTED IN INITIAL LOAD")
        
    # Check for form fields
    form = soup.find('form')
    if form:
        print("Form found")
        inputs = form.find_all('input')
        for i in inputs:
            print(f"Input: {i.get('name')} - Type: {i.get('type')}")
            
except Exception as e:
    print(f"Error: {e}")
