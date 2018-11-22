#!/usr/bin/python3
import requests
import getpass
import sys
import re
import os
import pickle
from os.path import isfile, join, isdir
import hashlib
import shutil
import sqlite3
import csv


con = sqlite3.connect("new_int.db")
cur = con.cursor()
cur.execute("DROP TABLE IF EXISTS LOGIN_CHECKER")
cur.execute('''CREATE TABLE LOGIN_CHECKER (username , password , encryption_scheme , encryption_key , url, value);''')

client = 0
hardcode= "/home/kritin/Pictures/spc/new_int.db"
logged_in = False #don't delete this

home="/home/kritin/TESTING/"

# For moodle login

def login_with_input():
	a = input("Username : ")
	b = getpass.getpass("Password : ")
	return login(a,b)


def logout_from_server():
	file_name = hardcode
	fileObject = open(file_name,'wb')
	d = {}
	pickle.dump(d,fileObject)
	fileObject.close()

def login(a,b):
	global client
	global logged_in
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
		logged_in = True
		return True
	# page = client.get('https://127.0.0.1:8000/server/upload').content
	# 	print(page)



def login_config(a,b,c,d,e):
	global client
	global logged_in
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
		# file_name = hardcode
		# fileObject = open(file_name,'wb')
		# d = {'Username_in_pickle' : a, 'Password_in_pickle' : b}
		# pickle.dump(d,fileObject)
		# fileObject.close()
		to_db1 = [ (a,b,c,d,e,"0") ]
		cur.executemany('''INSERT INTO LOGIN_CHECKER (username, password, encryption_scheme, encryption_key, url, value) VALUES (?,?,?,?,?);''',to_db1)
		con.commit()
		logged_in = True
		return True
	# page = client.get('https://127.0.0.1:8000/server/upload').content
	# 	print(page)

# Always mantain folder_name ending with /

def login_for_reading():
	# file_name = hardcode
	# fileObject = open(file_name,'rb')
	# c = pickle.load(fileObject)

	# print(c['Username_in_pickle'],c['Password_in_pickle'])
	a = cur.execute('''SELECT username FROM LOGIN_CHECKER WHERE value = "0";''' )
	b = cur.execute('''SELECT password FROM LOGIN_CHECKER WHERE value = "0";''' )
	f = True
	if (f == True):
		return (a,b)
	else:
		return False

def md5(file_name, folder_name, farji_folder_name=home):
    hash_md5 = hashlib.md5()
    with open(farji_folder_name+folder_name+file_name, "rb") as f:
        for chunk in iter(lambda: f.read(4096), b""):
            hash_md5.update(chunk)
    return hash_md5.hexdigest()

def upload_file(file_name, folder_name, status=1, farji_folder_name=home):
	# client=requests.session()
	if(status==1):
		print("Uploading file "+file_name)
	global client
	checker_for_login = login_for_reading()
	
	if (checker_for_login != False):
		if(not logged_in):
			(a,b)=checker_for_login
			login(a,b)
		url="http://127.0.0.1:8000/server/api/upload_file/"
		# client.get(url)
		csrftoken = client.cookies['csrftoken']
		# print(csrftoken)
		md5sum=md5(file_name, folder_name, farji_folder_name)
		if(folder_name==""):
			files = {'docfile': open(farji_folder_name+file_name,'rb')}
		else:
			files = {'docfile': open(farji_folder_name+folder_name+file_name,'rb')}
		# print(files)
		values = {'description': 'My file','md5sum':md5sum, 'base_folder':folder_name,'csrfmiddlewaretoken':csrftoken}
		# print("DONE")
		resp = client.post(url, files=files, data=values, headers=dict(Referer=url))
		# resp.raise_for_status()
		# print(resp.status_code)
	# else :
		# print("You are not logged in your account")

def add_folder(base_folder, folder_name):
	print("Uploading folder folder_name")
	global client
	checker_for_login = login_for_reading()
	if (checker_for_login != False):	
		# client=requests.session()
		if(not logged_in):
			(a,b)=checker_for_login
			login(a,b)
		url="http://127.0.0.1:8000/server/api/upload_folder/"
		client.get(url)
		csrftoken = client.cookies['csrftoken']
		# print(csrftoken)
		# print(files)
		values = {'base_folder':base_folder, 'name':folder_name, 'csrfmiddlewaretoken':csrftoken}
		# print("FOLDER DONE")
		# print("BASE:", base_folder)
		# print("FOLDER_NAME:", folder_name)
		resp = client.post(url, data=values, headers=dict(Referer=url))
		# resp.raise_for_status()
		# print(resp.status_code)
	else :
		return 0	

def upload_folder(folder_name, farji_base_folder=home):
	global client
	checker_for_login = login_for_reading()
	if (checker_for_login != False):	
		if(not logged_in):
			(a,b)=checker_for_login
			login(a,b)
		without_slash=folder_name[0:-1]
		# print()
		files=[x for x in os.listdir(farji_base_folder+without_slash) if os.path.isfile(farji_base_folder+folder_name+x)]
		subfolders=[x for x in os.listdir(farji_base_folder+without_slash) if os.path.isdir(farji_base_folder+folder_name+x)]	
		# print(files)
		# print(subfolders)
		for x in files:
			upload_file(x,folder_name, farji_base_folder)
		for x in subfolders:
			add_folder(folder_name, x)
			upload_folder(folder_name+x+"/", farji_base_folder)
	# else :
		# print("You are not logged in your account")
	
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
	

def sign_up_with():
	a = input("Username : ")
	b = getpass.getpass("Password : ")
	c = input("Encryption Scheme : ")
	d = input("Encryption Key : ")
	e = input("URL : ")
	return login_config(a,b,c,d,e)

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


def get_filename_from_cd(cd):
    if not cd:
        return None
    fname = re.findall('filename=(.+)', cd)
    if len(fname) == 0:
        return None
    return fname[0]

def download_file(file_name,base_path,status=1): 
	global client
	# (u,p)=login_for_reading()
	# login(u,p)
	# print(file_name)
	
	url="http://127.0.0.1:8000/files/download/?name="+file_name
	# print(url)
	r=client.get(url,  allow_redirects=True)
	# print(r)
	# filename = get_filename_from_cd(r.headers.get('content-disposition'))
	filename=os.path.basename(file_name)
	if(status==1):
		print("Downloading file "+filename)
	open(home+base_path+filename, 'wb').write(r.content)
	# filename = get_filename_from_cd(r.headers.get('content-disposition'))

def download_folder(base_path):
	global client
	# (u,p)=login_for_reading()
	# login(u,p)
	print("Downloading folder "+base_path)
	data=api(base_path)
	folders=data['folders']
	files=data['files']
	# print(files)
	if not os.path.exists(home+base_path):
		os.makedirs(home+base_path)
	for [file,mysum] in files:
		download_file(file,base_path)
	for folder in folders:
		download_folder(base_path+folder+"/")

def syncup(base_path):
	if(base_path is ""):
		without_slash=base_path
	elif(base_path[-1]=="/"):
		without_slash=base_path[:-1]
	else:
		without_slash=base_path
	if(without_slash is not ""):
		this_base_folder=os.path.dirname(without_slash)
	else:
		this_base_folder=""
	# print("BASE FOLDER"+this_base_folder)
	this_file=os.path.basename(without_slash)
	if not os.path.exists(home+base_path):
		# print("FOLDER....")
		# print(base_path)
		# print(this_base_folder)
		# print(this_file)
		remove_folder(this_base_folder, this_file)
	else:
		data=api(base_path)
		folders=data['folders']
		files=data['files']
		filenames=[]
		for (file,md5sum) in files:
			name=os.path.basename(file)
			filenames.append(name)
			if(not os.path.exists(home+base_path+name)):
				remove_file(base_path,name)
			elif(md5sum!=md5(name,base_path)):
				remove_file(base_path,name,0)
				print("Modifying file "+ name+" in cloud")
				# print("uplading "+base_path+" " +name)
				upload_file(name, base_path,0)
		for folder in folders:
			syncup(base_path+folder+"/")
		clientfiles = [f for f in os.listdir(home+base_path) if isfile(join(home+base_path, f))]
		clientfolders= [f for f in os.listdir(home+base_path) if isdir(join(home+base_path, f))]
		for name in clientfiles:
			if(name not in filenames):
				# print("uploading "+name)
				upload_file(name, base_path)
		for name in clientfolders:
			if(name not in folders):
				add_folder(base_path, name)
				upload_folder(base_path+name+"/")

def syncdown(base_path):
	if(base_path is ""):
		without_slash=base_path
	elif(base_path[-1]=="/"):
		without_slash=base_path[:-1]
	else:
		without_slash=base_path
	this_base_folder=os.path.dirname(without_slash)+"/"
	# print("BASE FOLDER "+this_base_folder)
	this_file=os.path.basename(without_slash)
	# print("SYNCING "+this_file)
	if not os.path.exists(home+base_path):
		# download_folder(base_path)
		print("WRONG") #always ensure that this case never occurs
	else:
		data=api(base_path)
		folders=data['folders']
		files=data['files']
		filenames=[]
		for (file,md5sum) in files:
			name=os.path.basename(file)
			filenames.append(name)
			if(not os.path.exists(home+base_path+name)):
				download_file(file,base_path)
			elif(md5sum!=md5(name,base_path)):
				print("Modifying file "+ name+" in client")
				os.remove(home+base_path+name)
				download_file(file,base_path,0)
		for folder in folders:
			if(not os.path.exists(home+base_path+folder)):
				download_folder(base_path+folder+"/")
			else:
				syncdown(base_path+folder+"/")
		# print(os.listdir(home+base_path))
		# for f in os.listdir(home+base_path):
		# 	print(join(base_path,f))
		# 	print(isfile(join(base_path, f)) or isdir(join(base_path, f)))
		clientfiles = [f for f in os.listdir(home+base_path) if isfile(join(home+base_path, f))]
		clientfolders= [f for f in os.listdir(home+base_path) if isdir(join(home+base_path, f))]
		# print(clientfiles)
		# print(filenames)
		for name in clientfiles:
			if(name not in filenames):
				# print("uploading "+name)
				print("Deleting file "+ name+" in client")
				os.remove(home+base_path+name)
		for name in clientfolders:
			if(name not in folders):
				print("Deleting folder "+name+" in client")
				shutil.rmtree(home+base_path+name)

def remove_folder(base_folder, name):
	print("Deleting folder "+name+" in cloud")
	global client
	# (u,p)=login_for_reading()
	# login(u,p)
	csrftoken = client.cookies['csrftoken']
	values={'base_folder':base_folder, 'name':name, 'csrfmiddlewaretoken':csrftoken}
	url="http://127.0.0.1:8000/server/api/remove_folder/"
	client.post(url, data=values, headers=dict(Referer=url))
	# print(resp.status_code)

def remove_file(base_folder, name,status=1):
	if status==1:
		print("Deleting file "+name+" in cloud")
	global client
	# (u,p)=login_for_reading()
	# login(u,p)
	csrftoken = client.cookies['csrftoken']
	values={'base_folder':base_folder, 'name':name, 'csrfmiddlewaretoken':csrftoken}
	url="http://127.0.0.1:8000/server/api/remove_file/"
	client.post(url, data=values, headers=dict(Referer=url))

def syncup_start(folder):
	global client
	# (u,p)=login_for_reading()
	# login(u,p)
	data=api("")
	# name=folder[:-1]
	folders=data['folders']
	# print(folders)
	print("Starting sync")
	syncup(folder)
	print("Sync complete")

def syncdown_start(folder):
	# print("REACHED")
	global client
	# (u,p)=login_for_reading()
	# login(u,p)
	# data=api("")
	name=folder[:-1]
	# folders=data['folders']
	# print(folders)
	print("Starting sync")
	if(not os.path.exists(home+folder)):
		# print("DOWNLOADING")
		download_folder(name+"/")
	else:
		# print("PRESENT")
		syncdown(folder)
	print("Sync complete")

def api(folder_path):
	url="http://127.0.0.1:8000/server/api/files/"+folder_path
	response=client.get(url)
	data = response.json()
	return data

if(__name__=="__main__"):
	# global client
	if(len(sys.argv)<2):
		print("Invalid arguments")
	elif (sys.argv[1] == 'login'):
	# login_for_reading()
		login_with_input()
	elif (sys.argv[1] == 'config'):
		a=sign_up_with()
		if(not a):
			print("Sorry there was some error while sign up. Please retry.")
		else:
			print("Config completed")
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
		(u,p)=login_for_reading()
		a=login(u,p)
		if(not a):
			print("Sorry you are not currently logged in")
			exit()
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
	# elif (sys.argv[1] == 'download'):
	# 	download_folder("kj/") 
	# elif (sys.argv[1] == 'sync'):
	# 	with_slash=sys.argv[2]
	# 	if(with_slash[-1] is not "/"):
	# 		with_slash=with_slash+"/"
	# 	sync_start(with_slash)
	elif(sys.argv[1]=='syncup'): #change its name, same as Rohan's
		# global client
		(u,p)=login_for_reading()
		a=login(u,p)
		if(not a):
			print("Sorry you are not currently logged in")
			exit()
		# with_slash=sys.argv[2]
		# if(with_slash[-1] is not "/"):
		# 	with_slash=with_slash+"/"
		syncup_start("")
	elif(sys.argv[1]=='syncdown'): #change its name, same as Rohan's
		# global client
		(u,p)=login_for_reading()
		a=login(u,p)
		if(not a):
			print("Sorry you are not currently logged in")
			exit()
		# with_slash=sys.argv[2]
		# if(with_slash[-1] is not "/"):
		# 	with_slash=with_slash+"/"
		syncdown_start("")
	else:
		# upload_file("s18.txt","there/")
		print("Invalid arguments")
		


# a = input()
# b = os.path.dirname(a)
# c = subtract(a,b)
# print(b)

# print(c)
# print(os.path.dirname(a))