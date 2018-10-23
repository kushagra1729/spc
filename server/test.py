import pickle

file_name = "new_int.p"
fileObject = open(file_name,'wb')
d = {'Username_in_pickle' : "", 'Password_in_pickle' : ""}
pickle.dump(d,fileObject)
fileObject.close()