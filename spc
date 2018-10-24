#!/usr/bin/python3
import requests
import getpass
import sys
import re
import os
import pickle


client = 0

logged_in = False #don't delete this

# For moodle login

def login_with_input():
	a = input("Username : ")
	b = getpass.getpass("Password : ")
	return login(a,b)

def logout_from_server():
	file_name = "/home/kritin/Desktop/new_int.p"
	fileObject = open(file_name,'wb')
	d = {}
	pickle.dump(d,fileObject)
	fileObject.close()

def login(a,b):
	global client
	client = requests.session()
	url="http://127.0.0.1:8000/accounts/login/"
	client.get(url)
	csrftoken = client.cookies['csrftoken']
	login_data = {
		'username': a,
		'password': b,
		'submit': 'login',
		'csrfmiddlewaretoken':csrftoken
	}

	r = client.post(url, data=login_data)

	if (r.status_code != 200):
		return False
	else :
		file_name = "/home/kritin/Desktop/new_int.p"
		fileObject = open(file_name,'wb')
		d = {'Username_in_pickle' : a, 'Password_in_pickle' : b}
		pickle.dump(d,fileObject)
		fileObject.close()
		logged_in = True
		return True
	# page = client.get('https://127.0.0.1:8000/server/upload').content
	# 	print(page)

# Always mantain folder_name ending with /

def login_for_reading():
	file_name = "/home/kritin/Desktop/new_int.p"
	fileObject = open(file_name,'rb')
	c = pickle.load(fileObject)
	# print(c['Username_in_pickle'],c['Password_in_pickle'])
	f = bool(c)
	if (f == True):
		return (c['Username_in_pickle'],c['Password_in_pickle'])
	else:
		return False

def upload_file(file_name, folder_name, farji_folder_name=""):
	# client=requests.session()
	global client
	checker_for_login = login_for_reading()
	
	if (checker_for_login != False):
		if(not logged_in):
			(a,b)=checker_for_login
			login(a,b)
		url="http://127.0.0.1:8000/server/upload/"
		client.get(url)
		csrftoken = client.cookies['csrftoken']
		print(csrftoken)
	
		if(folder_name==""):
			files = {'docfile': open(farji_folder_name+file_name,'rb')}
		else:
			files = {'docfile': open(farji_folder_name+folder_name+file_name,'rb')}
		# print(files)
		values = {'description': 'My file', 'base_folder':folder_name,'csrfmiddlewaretoken':csrftoken}
		print("DONE")
		resp = client.post(url, files=files, data=values, headers=dict(Referer=url))
		# resp.raise_for_status()
		print(resp.status_code)
	else :
		print("You are not logged in your account")

def add_folder(base_folder, folder_name):
	global client
	checker_for_login = login_for_reading()
	if (checker_for_login != False):	
		# client=requests.session()
		if(not logged_in):
			(a,b)=checker_for_login
			login(a,b)
		url="http://127.0.0.1:8000/server/add_folder/"
		client.get(url)
		csrftoken = client.cookies['csrftoken']
		print(csrftoken)
		# print(files)
		values = {'base_folder':base_folder, 'name':folder_name, 'csrfmiddlewaretoken':csrftoken}
		print("FOLDER DONE")
		print("BASE:", base_folder)
		print("FOLDER_NAME:", folder_name)
		resp = client.post(url, data=values, headers=dict(Referer=url))
		# resp.raise_for_status()
		print(resp.status_code)
	else :
		return 0	

def upload_folder(folder_name, farji_base_folder=""):
	global client
	checker_for_login = login_for_reading()
	if (checker_for_login != False):	
		if(not logged_in):
			(a,b)=checker_for_login
			login(a,b)
		without_slash=folder_name[0:-1]
		files=[x for x in os.listdir(farji_base_folder+without_slash) if os.path.isfile(farji_base_folder+folder_name+x)]
		subfolders=[x for x in os.listdir(farji_base_folder+without_slash) if os.path.isdir(farji_base_folder+folder_name+x)]	
		print(files)
		print(subfolders)
		for x in files:
			upload_file(x,folder_name, farji_base_folder)
		for x in subfolders:
			add_folder(folder_name, x)
			upload_folder(folder_name+x+"/", farji_base_folder)
	else :
		print("You are not logged in your account")
	
def edit_password_with_input():
	global client
	c= getpass.getpass("Enter Old password : ")
	a = getpass.getpass("Enter New password : ")
	b = getpass.getpass("Confirm New password : ")
	if(a!=b):
		print("The two passwords don't match")
		return False
	checker_for_login = login_for_reading()
	(d,e)=checker_for_login
	exit_status=login(d,e)
	if(exit_status is False):
		print("You need to be logged in before changing password")
		return False
	if(c!=e):
		print("You entered incorrect password")
		return False
	edit_password(e,a)

def edit_password(c,a):
	global client
	url="http://127.0.0.1:8000/accounts/change-password/"
	client.get(url)
	csrftoken = client.cookies['csrftoken']
	login_data = {
		'old_password': c,
		'new_password1': a,
		'new_password2': a,
		'submit':"Change my password",
		'csrfmiddlewaretoken':csrftoken
	}

	r = client.post(url, data=login_data)

	if (r.status_code != 200):
		return False
	else :
		return True
	

def sign_up_with_input():
	a = input("Username : ")
	b = getpass.getpass("Password : ")
	c = getpass.getpass("Confirm New passowrd : ")
	if(b!=c):
		print("Sorry the passwords don't match")
		return False
	return sign_up(a,b,c)

def sign_up(a,b,c):
	global client
	client = requests.session()
	url="http://127.0.0.1:8000/accounts/signup/"
	client.get(url)
	csrftoken = client.cookies['csrftoken']
	login_data = {
		'username': a,
		'password1': b,
		'password2': c,
		'submit':'signup',
		'csrfmiddlewaretoken':csrftoken
	}

	r = client.post(url, data=login_data)

	if (r.status_code != 200):
		return False
	else:
		return True


def subtract(a, b):                              
    return "".join(a.rsplit(b))


if(__name__=="__main__"):
	if (sys.argv[1] == 'login'):
	# login_for_reading()
		login_with_input()
	elif (sys.argv[1] == 'config'):
		a=sign_up_with_input()
		if(not a):
			print("Sorry there was some error while sign up. Please retry.")
		else:
			print("Signup completed")
	elif (sys.argv[1] == 'logout'):
		logout_from_server()
	# You must be already logged in to change your password
	# Not working currently
	elif (sys.argv[1] == 'edit'):
		a=edit_password_with_input()
		if(not a):
			print("Sorry, could not change your password")
		else:
			print("Password change successful")
	elif (sys.argv[1] == 'upload'):
		if (os.path.isfile(sys.argv[2])):
			if "/" not in sys.argv[2]:
				upload_file(sys.argv[2],"")
			else :
				file_store = sys.argv[2]
				parent = os.path.dirname(file_store)
				parent = parent+"/"
				file_ka_name = subtract(file_store,parent)
				upload_file(file_ka_name,"",parent)
		else :
			if "/" not in sys.argv[2]:
				file_address = sys.argv[2]
				add_folder("",sys.argv[2])
				upload_folder(file_address+"/")
			else :
				# print("YO")
				file_store = sys.argv[2]
				if (file_store[-1:] == "/"):
					file_store = file_store[:-1]
					if "/" not in file_store:
						add_folder("",file_store)
						upload_folder(file_store+"/")
					else :
						# print("HERE")
						parent = os.path.dirname(file_store)
						file_store=file_store+"/"
						c = subtract(file_store,parent+"/")
						d = subtract(c,"/")
						add_folder("",d)
						# e = file_store+"/"
						upload_folder(c,parent+"/")
				else :
					parent = os.path.dirname(file_store)
					file_store=file_store+"/"
					c = subtract(file_store,parent+"/")
					d = subtract(c,"/")
					# print("ADDING", d)
					add_folder("",d)
					# e = file_store+"/"
					# print("UPLOADING", c, parent+"/")
					upload_folder(c, parent+"/")


				# file_address = sys.argv[2]
				# parent = os.path.dirname(file_address)
				# c = subtract(file_address,parent)
				# d = subtract(c,"/")
				# add_folder(parent,c)
				# e = file_address+"/"
				# upload_folder(e)
			# add_folder("","newfolder")
		# upload_folder("newfolder/")
		# upload_file("hey.txt","")



# a = input()
# b = os.path.dirname(a)
# c = subtract(a,b)
# print(b)

# print(c)
# print(os.path.dirname(a))


