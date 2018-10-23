import os
import sys
def subtract(a, b):                              
    return "".join(a.rsplit(b))

# file_address = sys.argv[2]
# parent = os.path.dirname(file_address)
# c = subtract(file_address,parent)
# d = subtract(c,"/")
# e = file_address+"/"

# print(file_address)
# print(parent)
# print(c)
# print(d)
# print(e)
file_store = sys.argv[2]

print(file_store)
parent = os.path.dirname(file_store)
print(parent)
# if (file_store[-1:] == "/"):
#     file_store = file_store[:-1 ]   
#     parent = os.path.dirname(file_store)
#     parent2 = os.path.dirname(parent)
#     file_ka_name = subtract(file_store,parent)
# # upload_file(file_ka_name,parent)
# else :
#     parent = os.path.dirname(file_store)
#     parent2 = os.path.dirname(parent)
#     file_ka_name = subtract(file_store,parent)

# print(parent)
# print(file_ka_name)
# print(parent2)