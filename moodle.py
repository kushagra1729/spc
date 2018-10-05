import requests
import getpass
import sys
import re

# For moodle login
def login():
	session = requests.session()
	# page=session.get(URL).content
	
	URL="https://moodle.iitb.ac.in/login/index.php"

	a = input("Username : ")
	b = getpass.getpass("Password : ")
	login_data = {
		'username': a,
		'password': b,
		'submit': 'login',
	}
	
	r = session.post(URL, data=login_data)

	if r.status_code != 200:
		print('Failed to log in')

	page = session.get('https://moodle.iitb.ac.in/course/view.php?id=7704').content
	print(page)

def upload():
	client=requests.session()
	url="http://127.0.0.1:8000/server/upload"
	client.get(url)
	csrftoken = client.cookies['csrftoken']
	print(csrftoken)
	files = {'docfile': open('README.md','rb')}
	# print(files)
	values = {'description': 'My file','csrfmiddlewaretoken':csrftoken}
	print("DONE")
	resp = requests.post(url, files=files, data=values, headers=dict(Referer=url))
	# resp.raise_for_status()
	print(resp.status_code)

if(__name__=="__main__"):
	# login()
	upload()