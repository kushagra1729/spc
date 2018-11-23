#!/usr/bin/python3
import requests
import getpass
import sys
import re
import os
from os.path import isfile, join, isdir
import hashlib
import shutil
import sqlite3
from Crypto.Cipher import AES, ARC4, Blowfish
from Crypto import Random
from struct import pack

client = 0
#hardcode = "/home/kritin/Pictures/spc/new_int.db"
logged_in = False  # don't delete this

home = ""

# For encryption


class OpenBF(object):
    def __init__(self, key, *args, **kwds):
        # do custom stuff here
        self.args = args
        self.kwds = kwds
        self.bs = Blowfish.block_size
        self.key = key
        self.file_obj = open(*self.args, **self.kwds)
        self.closed = self.file_obj.closed
        # self.encoding=self.file_obj.encoding
        self.mode = self.file_obj.mode
        self.name = self.file_obj.name
        # self.newlines=self.file_obj.newlines
        # self.softspace=self.file_obj.softspace
        self.writelines = self.file_obj.writelines

    def read(self):
        r = self.file_obj.read()
        iv = Random.new().read(self.bs)
        cipher = Blowfish.new(self.key, Blowfish.MODE_CBC, iv)
        plen = self.bs - divmod(len(r), self.bs)[1]
        padding = [plen] * plen
        padding = pack('b' * plen, *padding)
        return iv + cipher.encrypt(r + padding)

    # return r

    def write(self, enc):
        iv = enc[:self.bs]
        cipher = Blowfish.new(self.key, Blowfish.MODE_CBC, iv)
        st = cipher.decrypt(enc[self.bs:])
        last_byte = st[-1]
        return self.file_obj.write(st[:- (last_byte if type(last_byte) is int else ord(last_byte))])

    def close(self):
        self.file_obj.close()


class OpenARC(object):
    def __init__(self, key, *args, **kwds):
        # do custom stuff here
        self.args = args
        self.kwds = kwds
        self.bs = 16
        self.key = key.encode()
        self.file_obj = open(*self.args, **self.kwds)
        self.closed = self.file_obj.closed
        # self.encoding=self.file_obj.encoding
        self.mode = self.file_obj.mode
        self.name = self.file_obj.name
        # self.newlines=self.file_obj.newlines
        # self.softspace=self.file_obj.softspace
        self.writelines = self.file_obj.writelines

    def read(self):
        r = self.file_obj.read()
        iv = Random.new().read(self.bs)
        cipher = ARC4.new(hashlib.sha256(self.key + iv).digest())
        return iv + cipher.encrypt(r)

    # return r

    def write(self, enc):
        iv = enc[:self.bs]
        cipher = ARC4.new(hashlib.sha256(self.key + iv).digest())
        return self.file_obj.write(cipher.decrypt(enc[self.bs:]))

    def close(self):
        self.file_obj.close()


class OpenAES(object):
    def __init__(self, key, *args, **kwds):
        # do custom stuff here
        self.args = args
        self.kwds = kwds
        self.bs = 32
        self.key = hashlib.sha256(key.encode()).digest()
        self.file_obj = open(*self.args, **self.kwds)
        self.closed = self.file_obj.closed
        # self.encoding=self.file_obj.encoding
        self.mode = self.file_obj.mode
        self.name = self.file_obj.name
        # self.newlines=self.file_obj.newlines
        # self.softspace=self.file_obj.softspace
        self.writelines = self.file_obj.writelines

    def read(self):
        r = self.file_obj.read()
        r = self._pad(r)
        iv = Random.new().read(AES.block_size)
        cipher = AES.new(self.key, AES.MODE_CBC, iv)
        return iv + cipher.encrypt(r)

    # return r

    def write(self, enc):
        iv = enc[:AES.block_size]
        cipher = AES.new(self.key, AES.MODE_CBC, iv)
        return self.file_obj.write(self._unpad(cipher.decrypt(enc[AES.block_size:])))

    def _pad(self, s):
        return s + (self.bs - len(s) % self.bs) * (chr(self.bs - len(s) % self.bs)).encode('utf-8')

    def close(self):
        self.file_obj.close()

    @staticmethod
    def _unpad(s):
        return s[:-ord(s[len(s) - 1:])]


# Encryption done


# For moodle login

# def login_with_input():
#     a = input("Username : ")
#     b = getpass.getpass("Password : ")
#     return login(a,b)


# def logout_from_server():
#     file_name = hardcode
#     fileObject = open(file_name,'wb')
#     d = {}
#     pickle.dump(d,fileObject)
#     fileObject.close()

def login(usr, pwd, url):
    global client
    global logged_in
    client = requests.session()
    url = "http://127.0.0.1:8000/accounts/login/"
    client.get(url)
    csrftoken = client.cookies['csrftoken']
    login_data = {
        'username': usr,
        'password': pwd,
        'submit': 'login',
        'csrfmiddlewaretoken': csrftoken
    }

    r = client.post(url, data=login_data)

    if (r.status_code != 200):
        return False
    else:
        logged_in = True
        return True


# page = client.get('https://127.0.0.1:8000/server/upload').content
# 	print(page)


def login_config(usr, pwd, schm, key, url):
    global client
    global logged_in
    url = "http://127.0.0.1:8000/accounts/login/"
    client = requests.session()
    client.get(url)
    csrftoken = client.cookies['csrftoken']
    login_data = {
        'username': usr,
        'password': pwd,
        'submit': 'login',
        'csrfmiddlewaretoken': csrftoken
    }

    r = client.post(url, data=login_data)
    if (r.status_code != 200):
        # cur.execute("DROP TABLE IF EXISTS LOGIN_CHECKER")
        # con.commit()
        print("Unable to login")
        return False
    else:
        to_db1 = [(usr, pwd, schm, key, url, "0")]
        print("HERE")

        con = sqlite3.connect("new_int.db")
        cur = con.cursor()
        cur.execute("DROP TABLE IF EXISTS LOGIN_CHECKER")
        cur.execute(
            '''CREATE TABLE LOGIN_CHECKER (username , password , encryption_scheme , encryption_key , url, value);''')

        cur.executemany(
            '''INSERT INTO LOGIN_CHECKER (username, password, encryption_scheme, encryption_key, url, value) VALUES (?,?,?,?,?,?);''',
            to_db1)
        con.commit()
        con.close()
        logged_in = True
        return True


def login_for_reading():
    # file_name = hardcode
    # fileObject = open(file_name,'rb')
    # c = pickle.load(fileObject)

    # print(c['Username_in_pickle'],c['Password_in_pickle'])
    # usr = cur.execute('''SELECT username FROM LOGIN_CHECKER WHERE value = "0";''' )
    # pwd = cur.execute('''SELECT password FROM LOGIN_CHECKER WHERE value = "0";''' )
    # schm = cur.execute('''SELECT encryption_scheme FROM LOGIN_CHECKER WHERE value = "0";''')
    # key = cur.execute('''SELECT encryption_key FROM LOGIN_CHECKER WHERE value = "0";''')
    # url = cur.execute('''SELECT url FROM LOGIN_CHECKER WHERE value = "0";''')
    # a = usr.fetchall()
    # c = pwd.fetchall()
    con = sqlite3.connect("new_int.db")
    cur = con.cursor()
    usr = cur.execute('''SELECT * FROM LOGIN_CHECKER''')
    for row in usr:
        return (row[0], row[1], row[2], row[3], row[4])


# return (usr, pwd, schm, key, url)

# f = True
# if (f == True):
#     return (a,b)
# else:
#     return False

def md5(file_name, folder_name, farji_folder_name=home):
    hash_md5 = hashlib.md5()
    print(home)
    print(farji_folder_name)
    farji_folder_name =home
    with open(farji_folder_name + folder_name + file_name, "rb") as f:
        for chunk in iter(lambda: f.read(4096), b""):
            hash_md5.update(chunk)
    return hash_md5.hexdigest()


def upload_file(schm, key, file_name, folder_name, status=1, farji_folder_name=home):
    # client=requests.session()
    farji_folder_name = home
    if (status == 1):
        print("Uploading file " + file_name)
    global client
    checker_for_login = login_for_reading()

    if (checker_for_login != False):
        if (not logged_in):
            (usr, pwd, schm, key, url) = checker_for_login
            login(usr, pwd, url)
        url = "http://127.0.0.1:8000/server/api/upload_file/"
        # client.get(url)
        csrftoken = client.cookies['csrftoken']
        # print(csrftoken)
        print(farji_folder_name, "vgvuhkjl")
        md5sum = md5(file_name, folder_name, farji_folder_name)
        if schm == "AES":
            if (folder_name == ""):
                files = {'docfile': OpenAES(key, farji_folder_name + file_name, 'rb')}
            else:
                files = {'docfile': OpenAES(key, farji_folder_name + folder_name + file_name, 'rb')}
        if schm == "ARC":
            if (folder_name == ""):
                files = {'docfile': OpenARC(key, farji_folder_name + file_name, 'rb')}
            else:
                files = {'docfile': OpenARC(key, farji_folder_name + folder_name + file_name, 'rb')}
        if schm == "Blowfish":
            if (folder_name == ""):
                files = {'docfile': OpenBF(key, farji_folder_name + file_name, 'rb')}
            else:
                files = {'docfile': OpenBF(key, farji_folder_name + folder_name + file_name, 'rb')}
        # print(files)
        values = {'description': 'My file', 'md5sum': md5sum, 'base_folder': folder_name,
                  'csrfmiddlewaretoken': csrftoken}
        # print("DONE")
        resp = client.post(url, files=files, data=values, headers=dict(Referer=url))
    # resp.raise_for_status()
    # print(resp.status_code)


# else :
# print("You are not logged in your account")

def add_folder(base_folder, folder_name):
    print("Uploading folder " + folder_name)
    global client
    checker_for_login = login_for_reading()
    if (checker_for_login != False):
        # client=requests.session()
        if (not logged_in):
            (usr, pwd, schm, key, url) = checker_for_login
            login(usr, pwd, schm, key, url)
        url = "http://127.0.0.1:8000/server/api/upload_folder/"
        client.get(url)
        csrftoken = client.cookies['csrftoken']
        # print(csrftoken)
        # print(files)
        values = {'base_folder': base_folder, 'name': folder_name, 'csrfmiddlewaretoken': csrftoken}
        # print("FOLDER DONE")
        # print("BASE:", base_folder)
        # print("FOLDER_NAME:", folder_name)
        resp = client.post(url, data=values, headers=dict(Referer=url))
    # resp.raise_for_status()
    # print(resp.status_code)
    else:
        return 0


def upload_folder(schm, key, folder_name, farji_base_folder=home):
    global client
    farji_base_folder = home
    checker_for_login = login_for_reading()
    if (checker_for_login != False):
        if (not logged_in):
            (usr, pwd, schm, key, url) = checker_for_login
            login(usr, pwd, url)
        without_slash = folder_name[0:-1]
        # print()
        files = [x for x in os.listdir(farji_base_folder + without_slash) if
                 os.path.isfile(farji_base_folder + folder_name + x)]
        subfolders = [x for x in os.listdir(farji_base_folder + without_slash) if
                      os.path.isdir(farji_base_folder + folder_name + x)]
        # print(files)
        # print(subfolders)
        for x in files:
            upload_file(schm, key, x, folder_name, farji_base_folder)
        for x in subfolders:
            add_folder(folder_name, x)
            upload_folder(schm, key, folder_name + x + "/", farji_base_folder)


# else :
# print("You are not logged in your account")

# def edit_password_with_input():
#     global client
#     c = getpass.getpass("Enter Old password : ")
#     a = getpass.getpass("Enter New password : ")
#     b = getpass.getpass("Confirm New password : ")
#     if (a != b):
#         print("The two passwords don't match")
#         return False
#     checker_for_login = login_for_reading()
#     (usr, pwd, schm, key, url) = checker_for_login
#     exit_status = login(usr, pwd, url)
#     if (exit_status is False):
#         print("You need to be logged in before changing password")
#         return False
#     if (c != e):
#         print("You entered incorrect password")
#         return False
#     edit_password(e, a)


# def edit_password(c, a):
#     global client
#     url = "http://127.0.0.1:8000/accounts/change-password/"
#     client.get(url)
#     csrftoken = client.cookies['csrftoken']
#     login_data = {
#         'old_password': c,
#         'new_password1': a,
#         'new_password2': a,
#         'submit': "Change my password",
#         'csrfmiddlewaretoken': csrftoken
#     }

#     r = client.post(url, data=login_data)

#     if (r.status_code != 200):
#         return False
#     else:
#         return True


def sign_up_with():
    usr = input("Username : ")
    pwd = getpass.getpass("Password : ")
    schm = input("Encryption Scheme['AES','ARC' or 'Blowfish' only] : ")
    if schm != "AES" and schm != "ARC" and schm != "Blowfish":
        print("Invalid Encryption Scheme")
        return False
    key = input("Encryption Key : ")
    url = input("URL[https://127.0.0.1:8000] : ")
    return login_config(usr, pwd, schm, key, url)


def sign_up(a, b, c):
    global client
    client = requests.session()
    url = "http://127.0.0.1:8000/accounts/signup/"
    client.get(url)
    csrftoken = client.cookies['csrftoken']
    login_data = {
        'username': a,
        'password1': b,
        'password2': c,
        'submit': 'signup',
        'csrfmiddlewaretoken': csrftoken
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


def download_file(schm, key, file_name, base_path, status=1):
    global client
    # (u,p)=login_for_reading()
    # login(u,p)
    # print(file_name)

    url = "http://127.0.0.1:8000/files/download/?name=" + file_name
    # print(url)
    r = client.get(url, allow_redirects=True)
    # print(r)
    # filename = get_filename_from_cd(r.headers.get('content-disposition'))
    filename = os.path.basename(file_name)
    if (status == 1):
        print("Downloading file " + filename)
    if schm == "AES":
        f = OpenAES(key, home + base_path + filename, 'wb')
        f.write(r.content)
        f.close()
    if schm == "ARC":
        f = OpenARC(key, home + base_path + filename, 'wb')
        f.write(r.content)
        f.close()
    if schm == "Blowfish":
        f = OpenBF(key, home + base_path + filename, 'wb')
        f.write(r.content)
        f.close()


# filename = get_filename_from_cd(r.headers.get('content-disposition'))

def download_folder(schm, key, base_path):
    global client
    # (u,p)=login_for_reading()
    # login(u,p)
    print("Downloading folder " + base_path)
    data = api(base_path)
    folders = data['folders']
    files = data['files']
    # print(files)
    if not os.path.exists(home + base_path):
        os.makedirs(home + base_path)
    for [file, mysum] in files:
        download_file(schm, key, file, base_path)
    for folder in folders:
        download_folder(schm, key, base_path + folder + "/")


def syncup(schm, key, base_path):

    if (base_path is ""):
        without_slash = base_path
    elif (base_path[-1] == "/"):
        without_slash = base_path[:-1]
    else:
        without_slash = base_path
    if (without_slash is not ""):
        this_base_folder = os.path.dirname(without_slash)
    else:
        this_base_folder = ""
    # print("BASE FOLDER"+this_base_folder)
    this_file = os.path.basename(without_slash)
    if not os.path.exists(home + base_path):
        # print("FOLDER....")
        # print(base_path)
        # print(this_base_folder)
        # print(this_file)
        remove_folder(this_base_folder, this_file)
    else:
        data = api(base_path)
        folders = data['folders']
        files = data['files']
        filenames = []
        for (file, md5sum) in files:
            name = os.path.basename(file)
            filenames.append(name)
            if (not os.path.exists(home + base_path + name)):
                remove_file(base_path, name)
            elif (md5sum != md5(name, base_path)):
                remove_file(base_path, name, 0)
                print("Modifying file " + name + " in cloud")
                # print("uplading "+base_path+" " +name)
                upload_file(schm, key, name, base_path, 0)
        for folder in folders:
            syncup(schm, key, base_path + folder + "/")
        clientfiles = [f for f in os.listdir(home + base_path) if isfile(join(home + base_path, f))]
        clientfolders = [f for f in os.listdir(home + base_path) if isdir(join(home + base_path, f))]
        for name in clientfiles:
            if (name not in filenames):
                # print("uploading "+name)
                upload_file(schm, key, name, base_path)
        for name in clientfolders:
            if (name not in folders):
                add_folder(base_path, name)
                upload_folder(schm, key, base_path + name + "/")


def syncdown(schm, key, base_path):
    if (base_path is ""):
        without_slash = base_path
    elif (base_path[-1] == "/"):
        without_slash = base_path[:-1]
    else:
        without_slash = base_path
    this_base_folder = os.path.dirname(without_slash) + "/"
    # print("BASE FOLDER "+this_base_folder)
    this_file = os.path.basename(without_slash)
    # print("SYNCING "+this_file)
    if not os.path.exists(home + base_path):
        # download_folder(base_path)
        print("WRONG")  # always ensure that this case never occurs
    else:
        data = api(base_path)
        folders = data['folders']
        files = data['files']
        filenames = []
        for (file, md5sum) in files:
            name = os.path.basename(file)
            filenames.append(name)
            if (not os.path.exists(home + base_path + name)):
                download_file(schm, key, file, base_path)
            elif (md5sum != md5(name, base_path)):
                print("Modifying file " + name + " in client")
                os.remove(home + base_path + name)
                download_file(schm, key, file, base_path, 0)
        for folder in folders:
            if (not os.path.exists(home + base_path + folder)):
                download_folder(schm, key, base_path + folder + "/")
            else:
                syncdown(schm, key, base_path + folder + "/")
        # print(os.listdir(home+base_path))
        # for f in os.listdir(home+base_path):
        # 	print(join(base_path,f))
        # 	print(isfile(join(base_path, f)) or isdir(join(base_path, f)))
        clientfiles = [f for f in os.listdir(home + base_path) if isfile(join(home + base_path, f))]
        clientfolders = [f for f in os.listdir(home + base_path) if isdir(join(home + base_path, f))]
        # print(clientfiles)
        # print(filenames)
        for name in clientfiles:
            if (name not in filenames):
                # print("uploading "+name)
                print("Deleting file " + name + " in client")
                os.remove(home + base_path + name)
        for name in clientfolders:
            if (name not in folders):
                print("Deleting folder " + name + " in client")
                shutil.rmtree(home + base_path + name)


def remove_folder(base_folder, name):
    print("Deleting folder " + name + " in cloud")
    global client
    # (u,p)=login_for_reading()
    # login(u,p)
    csrftoken = client.cookies['csrftoken']
    values = {'base_folder': base_folder, 'name': name, 'csrfmiddlewaretoken': csrftoken}
    url = "http://127.0.0.1:8000/server/api/remove_folder/"
    client.post(url, data=values, headers=dict(Referer=url))


# print(resp.status_code)

def remove_file(base_folder, name, status=1):
    if status == 1:
        print("Deleting file " + name + " in cloud")
    global client
    # (u,p)=login_for_reading()
    # login(u,p)
    csrftoken = client.cookies['csrftoken']
    values = {'base_folder': base_folder, 'name': name, 'csrfmiddlewaretoken': csrftoken}
    url = "http://127.0.0.1:8000/server/api/remove_file/"
    client.post(url, data=values, headers=dict(Referer=url))


def syncup_start(schm, key, folder):
    global client
    # (u,p)=login_for_reading()
    # login(u,p)
    data = api("")
    # name=folder[:-1]
    folders = data['folders']
    # print(folders)
    print("Starting sync")
    syncup(schm, key, folder)
    print("Sync complete")


def syncdown_start(schm, key, folder):
    # print("REACHED")
    global client
    # (u,p)=login_for_reading()
    # login(u,p)
    # data=api("")
    name = folder[:-1]
    # folders=data['folders']
    # print(folders)
    print("Starting sync")
    if (not os.path.exists(home + folder)):
        # print("DOWNLOADING")
        download_folder(schm, key, name + "/")
    else:
        # print("PRESENT")
        syncdown(schm, key, folder)
    print("Sync complete")


def api(folder_path):
    url = "http://127.0.0.1:8000/server/api/files/" + folder_path
    print(client)
    response = client.get(url)
    # print(response.content)
    data = response.json()
    return data

def printclientfolder(base_path):
    print("<<" + base_path)
    clientfiles = [f for f in os.listdir(home + base_path) if isfile(join(home + base_path, f))]
    clientfolders = [f for f in os.listdir(home + base_path) if isdir(join(home + base_path, f))]
    for name in clientfolders:
        printclientfolder(base_path + name)
    for name in clientfiles:
        print("<<" + base_path + name)

def status(base_path):
    global client
    if (not os.path.exists(home + base_path)):
        print(">>" + base_path)
        data = api(base_path)
        folders = data['folders']
        files = data['files']
        for folder in folders:
            status(base_path + folder + "/")
        for (file, md5sum) in files:
            name = os.path.basename(file)
            print(">>" + base_path + name)
    else:
        data = api(base_path)
        folders = data['folders']
        files = data['files']
        filenames = []
        for folder in folders:
            status(base_path + folder + "/")
        clientfolders = [f for f in os.listdir(home + base_path) if isdir(join(home + base_path, f))]
        for name in clientfolders:
            if (name not in folders):
                printclientfolder(base_path + name)
        for (file, md5sum) in files:
            name = os.path.basename(file)
            filenames.append(name)
            if (not os.path.exists(home + base_path + name)):
                print(">>" + base_path + name)
            elif (md5sum != md5(name, base_path)):
                print("||" + base_path + name)
        clientfiles = [f for f in os.listdir(home + base_path) if isfile(join(home + base_path, f))]
        for name in clientfiles:
            if (name not in filenames):
                print("<<" + base_path + name)
        

if (__name__ == "__main__"):
    # global client
    con = sqlite3.connect("home.db")
    cur = con.cursor()
    usr = cur.execute(''' SELECT * FROM HOME ; ''' )
    for row in usr:
        home = row[0]
    print(home)
    if (len(sys.argv) < 2):
        print("Invalid arguments")
    # elif (sys.argv[1] == 'login'):
    # # login_for_reading()
    #     login_with_input()
    elif (sys.argv[1] == 'config'):
        a = sign_up_with()
        if (a == False):
            print("Please try again")
        else:
            print("Config completed")
    # elif (sys.argv[1] == 'logout'):
    #     logout_from_server()
    # You must be already logged in to change your password
    # Not working currently
    # elif (sys.argv[1] == 'edit'):
    #     a=edit_password_with_input()
    #     if(not a):
    #         print("Sorry, could not change your password")
    #     else:
    #         print("Password change successful")
    elif (sys.argv[1] == 'upload'):
        (usr, pwd, schm, key, url) = login_for_reading()
        a = login(usr, pwd, url)
        if (not a):
            print("Sorry you are not currently logged in")
            exit()
        if (os.path.isfile(sys.argv[2])):
            if "/" not in sys.argv[2]:
                upload_file(sys.argv[2], "")
            else:
                file_store = sys.argv[2]
                parent = os.path.dirname(file_store)
                parent = parent + "/"
                file_ka_name = subtract(file_store, parent)
                upload_file(file_ka_name, "", parent)
        else:
            if "/" not in sys.argv[2]:
                file_address = sys.argv[2]
                add_folder("", sys.argv[2])
                upload_folder(file_address + "/")
            else:
                # print("YO")
                file_store = sys.argv[2]
                if (file_store[-1:] == "/"):
                    file_store = file_store[:-1]
                    if "/" not in file_store:
                        add_folder("", file_store)
                        upload_folder(file_store + "/")
                    else:
                        # print("HERE")
                        parent = os.path.dirname(file_store)
                        file_store = file_store + "/"
                        c = subtract(file_store, parent + "/")
                        d = subtract(c, "/")
                        add_folder("", d)
                        # e = file_store+"/"
                        upload_folder(c, parent + "/")
                else:
                    parent = os.path.dirname(file_store)
                    file_store = file_store + "/"
                    c = subtract(file_store, parent + "/")
                    d = subtract(c, "/")
                    # print("ADDING", d)
                    add_folder("", d)
                    # e = file_store+"/"
                    # print("UPLOADING", c, parent+"/")
                    upload_folder(c, parent + "/")
    # elif (sys.argv[1] == 'download'):
    # 	download_folder("kj/")
    # elif (sys.argv[1] == 'sync'):
    # 	with_slash=sys.argv[2]
    # 	if(with_slash[-1] is not "/"):
    # 		with_slash=with_slash+"/"
    # 	sync_start(with_slash)
    elif (sys.argv[1] == 'syncup'):  # change its name, same as Rohan's
        # global client
        (usr, pwd, schm, key, url) = login_for_reading()
        a = login(usr, pwd, url)
        if (not a):
            print("Sorry you are not currently logged in")
            exit()
        # with_slash=sys.argv[2]
        # if(with_slash[-1] is not "/"):
        # 	with_slash=with_slash+"/"
        syncup_start(schm, key, "")
    elif(sys.argv[1]=='version'):
        print("Version 1.0")
    elif(sys.argv[1] == 'server'):
        print("IP : http://127.0.0.0.1:")
        print("Port Number : 8000")
    elif(sys.argv[1] == "help"):
        print("spc version : Gives information about version")
        print("spc server : prints IP and socket on the terminal")
        print("spc config : User needs to do setup at the beginning and every time they change their password")
        print("spc en-de list : Lists out possible envryption schemes")
        print("spc dump <file-path> : Used to change encrytion decryption schemes again")
        print("spc syncup : Gives major priority to linux client and sync data between server and client")
        print("spc syncdown : Gives major priority to server and sync data between server and client")
        print("spc observe : Stores home/root directory at the beginning")
    elif(sys.argv[1] == "dump"):
        (usr, pwd, schm, key, url) = login_for_reading()
        e = login(usr, pwd, url)
        if (not e):
            print("Sorry you are not currently logged in")
            exit()
        crs = open(sys.argv[2], "r")
        a = []
        for columns in ( raw.strip().split() for raw in crs ):
            a.insert(0,columns[0])
        new_key = a[0]
        new_scheme = a[1]
        con = sqlite3.connect("new_int.db")
        cur = con.cursor()
        usr = cur.execute('''SELECT * FROM LOGIN_CHECKER''' )
        for row in usr:
            old_scheme = row[2]
            old_key = row[3]
        syncdown_start(old_scheme, old_key, "")
        print(new_scheme)
        print(new_key)
        cur.execute('''UPDATE LOGIN_CHECKER set encryption_scheme = ?, encryption_key = ? WHERE value ="0"''' , (new_scheme, new_key))
        con.commit()
        syncup_start(new_scheme,new_key,"")

    elif(sys.argv[1] == "observe"):
        con = sqlite3.connect("home.db")
        cur = con.cursor()
        cur.execute("DROP TABLE IF EXISTS HOME")
        cur.execute('''CREATE TABLE HOME (url,value);''')
        if (os.path.isabs(sys.argv[2])):
            to_db1 = [ (sys.argv[2] , "0")]
            home = sys.argv[2]
        else :
            cwd = os.getcwd()
            if (sys.argv[2][1] == "/"):
                c = cwd + sys.argv[2]
                home = c
                to_db1 = [ (c,"0") ]
            else :
                c = cwd + "/" + sys.argv[2]
                to_db1 = [ (c,"0") ]
                home = c
        print(to_db1)
        print(to_db1[0])
        cur.executemany('''INSERT INTO HOME (url,value) VALUES (?,?);''',to_db1)
        con.commit()
        con.close()
        print(home)

    elif(sys.argv[1] == "en-de" and sys.argv[2] == "list"):
        print("AES , ARC4 , Blowfish")
    elif (sys.argv[1] == 'syncdown'):  # change its name, same as Rohan's
        # global client
        (usr, pwd, schm, key, url) = login_for_reading()
        a = login(usr, pwd, url)
        if (not a):
            print("Sorry you are not currently logged in")
            exit()
        # with_slash=sys.argv[2]
        # if(with_slash[-1] is not "/"):
        # 	with_slash=with_slash+"/"
        syncdown_start(schm, key, "")
    elif (sys.argv[1] == 'status'):
        (usr, pwd, schm, key, url) = login_for_reading()
        a = login(usr, pwd, url)
        if (not a):
            print("Sorry you are not currently logged in")
            exit()
        status("")
    else:
        # upload_file("s18.txt","there/")
        print("Invalid arguments")

# a = input()
# b = os.path.dirname(a)
# c = subtract(a,b)
# print(b)

# print(c)
# print(os.path.dirname(a))


