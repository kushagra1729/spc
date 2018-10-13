import requests
import getpass
import sys
import re
import os

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

# Always mantain folder_name ending with /
def upload_file(file_name, folder_name):
	client=requests.session()
	url="http://127.0.0.1:8000/server/upload/"
	client.get(url)
	csrftoken = client.cookies['csrftoken']
	print(csrftoken)
	if(folder_name==""):
		files = {'docfile': open(file_name,'rb')}
	else:
		files = {'docfile': open(folder_name+file_name,'rb')}
	# print(files)
	values = {'description': 'My file', 'base_folder':folder_name,'csrfmiddlewaretoken':csrftoken}
	print("DONE")
	resp = requests.post(url, files=files, data=values, headers=dict(Referer=url))
	# resp.raise_for_status()
	print(resp.status_code)

def add_folder(base_folder, folder_name):
	client=requests.session()
	url="http://127.0.0.1:8000/server/add_folder/"
	client.get(url)
	csrftoken = client.cookies['csrftoken']
	print(csrftoken)
	# print(files)
	values = {'base_folder':base_folder, 'name':folder_name, 'csrfmiddlewaretoken':csrftoken}
	print("FOLDER DONE")
	resp = requests.post(url, data=values, headers=dict(Referer=url))
	# resp.raise_for_status()
	print(resp.status_code)

def upload_folder(folder_name):
	without_slash=folder_name[0:-1]
	files=[x for x in os.listdir(without_slash) if os.path.isfile(folder_name+x)]
	subfolders=[x for x in os.listdir(without_slash) if os.path.isdir(folder_name+x)]	
	print(files)
	print(subfolders)
	for x in files:
		upload_file(x,folder_name)
	for x in subfolders:
		add_folder(folder_name, x)
		upload_folder(folder_name+x+"/")

if(__name__=="__main__"):
	# login()
	add_folder("","newfolder")
	upload_folder("newfolder/")
	# upload_file("README.md","")