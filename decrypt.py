import requests
import getpass
import sys
import os
import pickle
import hashlib
from Crypto.Cipher import AES,ARC4,Blowfish
from Crypto.Hash import SHA
from Crypto import Random
from struct import pack

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
    def __init__(self,key, *args, **kwds):
        # do custom stuff here
        self.args = args
        self.kwds = kwds
        self.bs = 16
        self.key = key.encode()
        self.file_obj = open(*self.args, **self.kwds)
        self.closed=self.file_obj.closed
        #self.encoding=self.file_obj.encoding
        self.mode=self.file_obj.mode
        self.name=self.file_obj.name
        #self.newlines=self.file_obj.newlines
        #self.softspace=self.file_obj.softspace
        self.writelines=self.file_obj.writelines
    def read(self):
        r = self.file_obj.read()
        iv = Random.new().read(self.bs)
        #cipher = ARC4.new(SHA.new(self.key+iv).digest())
        cipher = ARC4.new(hashlib.sha256(self.key + iv).digest())
        return iv + cipher.encrypt(r)
        #return r
    def write(self,enc):
        iv = enc[:self.bs]
        cipher = ARC4.new(hashlib.sha256(self.key+iv).digest())
        print(hashlib.sha256(self.key+iv).digest())
        return self.file_obj.write(cipher.decrypt(enc[self.bs:]))
    def close(self):
        self.file_obj.close()


class OpenAES(object):
    def __init__(self,key, *args, **kwds):
        # do custom stuff here
        self.args = args
        self.kwds = kwds
        self.bs = 32
        self.key = hashlib.sha256(key.encode()).digest()
        self.file_obj = open(*self.args, **self.kwds)
        self.closed=self.file_obj.closed
        #self.encoding=self.file_obj.encoding
        self.mode=self.file_obj.mode
        self.name=self.file_obj.name
        #self.newlines=self.file_obj.newlines
        #self.softspace=self.file_obj.softspace
        self.writelines=self.file_obj.writelines
    def read(self):
        r = self.file_obj.read()
        r = self._pad(r)
        iv = Random.new().read(AES.block_size)
        cipher = AES.new(self.key, AES.MODE_CBC, iv)
        return iv + cipher.encrypt(r)
        #return r
    def write(self,enc):
        iv = enc[:AES.block_size]
        cipher = AES.new(self.key, AES.MODE_CBC, iv)
        return self.file_obj.write(self._unpad(cipher.decrypt(enc[AES.block_size:])))
    def _pad(self, s):
        return s + (self.bs - len(s) % self.bs) * (chr(self.bs - len(s) % self.bs)).encode('utf-8')
    def close(self):
        self.file_obj.close()
    @staticmethod
    def _unpad(s):
        return s[:-ord(s[len(s)-1:])]



# f=OpenBF('onkar','kj_test.txt','rb')
# ff=OpenBF('onkar','enckj_test.txt','wb')
# ff.write(f.read())
# f.close()
# ff.close()


#
# f=open('encf.txt','rb')
# ff=OpenARC('onkar','/home/onkar/Downloads/decf.txt','wb')
# ff.write(f.read())
# f.close()
# ff.close()
#print(Blowfish.block_size)
#
# f=OpenARC('onkar','newtest.txt','rb')
# ff=open('encnew.txt','wb')
# ff.write(f.read())
# f.close()
# ff.close()
# #
# f=open('encimageARC','rb')
# ff=OpenARC('onkar','decimageARC.jpg','wb')
# ff.write(f.read())
# f.close()
# ff.close()

#
f=open('ench.txt','rb')
ff=OpenBF('onkar','/home/onkar/Downloads/decf.txt','wb')
ff.write(f.read())
f.close()
ff.close()

