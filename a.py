import sqlite3
import csv
import sys

con = sqlite3.connect("new_int.db")
cur = con.cursor()
cur.execute("DROP TABLE IF EXISTS LOGIN_CHECKER")
cur.execute('''CREATE TABLE LOGIN_CHECKER (username , password , encryption_scheme , encryption_key , url);''')


def sign_up_with():
	a = input("Username : ")
	b = input ("Password : ")
	c = input("Encryption Scheme : ")
	d = input("Encryption Key : ")
	return login(a,b,c,d)

def login(a,b,c,d):
	to_db1 = [ (a,b,c,d) ]
	cur.executemany('''INSERT INTO LOGIN_CHECKER (username, password, encryption_scheme, encryption_key) VALUES (?,?,?,?);''',to_db1)
	con.commit()
if sys.argv[1] == "config":
	sign_up_with()
