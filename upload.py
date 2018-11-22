import urllib.request
import hashlib
from Crypto.Cipher import AES,ARC4,Blowfish
from Crypto.Hash import SHA
fileurl = ''
scheme = ''
key = ''
fp = urllib.request.urlopen(fileurl)
enc = fp.read()
if scheme == "AES":
    iv = enc[:AES.block_size]
    key = hashlib.sha256(key.encode()).digest()
    cipher = AES.new(key, AES.MODE_CBC, iv)
    s = cipher.decrypt(enc[AES.block_size:])
    s = s[:-ord(s[len(s) - 1:])]
elif scheme == "ARC":
    iv = enc[:16]
    key = key.encode()
    cipher = ARC4.new(SHA.new(key + iv).digest())
    s = cipher.decrypt(enc[16:])
elif scheme == "BF":
    iv = enc[:Blowfish.block_size]
    cipher = Blowfish.new(key, Blowfish.MODE_CBC, iv)
    st = cipher.decrypt(enc[Blowfish.block_size:])
    last_byte = st[-1]
    s = st[:- (last_byte if type(last_byte) is int else ord(last_byte))]

print(s)





































var prog = "import urllib.request\n" +
                    "import hashlib\n" +
                    "from Crypto.Cipher import AES,ARC4,Blowfish\n" +
                    "from Crypto.Hash import SHA\n" +
                    "fileurl = '" + fileurl + "'\n" +
                    "scheme = '" + scheme + "'\n" +
                    "key = '" + key + "'\n" +
                    "fp = urllib.request.urlopen(fileurl)\n" +
                    "enc = fp.read()\n" +
                    "if scheme == \"AES\":\n" +
                    "    iv = enc[:AES.block_size]\n" +
                    "    key = hashlib.sha256(key.encode()).digest()\n" +
                    "    cipher = AES.new(key, AES.MODE_CBC, iv)\n" +
                    "    s = cipher.decrypt(enc[AES.block_size:])\n" +
                    "    s = s[:-ord(s[len(s) - 1:])]\n" +
                    "elif scheme == \"ARC\":\n" +
                    "    iv = enc[:16]\n" +
                    "    key = key.encode()\n" +
                    "    cipher = ARC4.new(SHA.new(key + iv).digest())\n" +
                    "    s = cipher.decrypt(enc[16:])\n" +
                    "elif scheme == \"BF\":\n" +
                    "    iv = enc[:Blowfish.block_size]\n" +
                    "    cipher = Blowfish.new(key, Blowfish.MODE_CBC, iv)\n" +
                    "    st = cipher.decrypt(enc[Blowfish.block_size:])\n" +
                    "    last_byte = st[-1]\n" +
                    "    s = st[:- (last_byte if type(last_byte) is int else ord(last_byte))]\n" +
                    "    \n" +
                    "print(s)";
                function outf(text) {
                    document.getElementById("mcont").innerText = text;
                }

                function builtinRead(x) {
                    if (Sk.builtinFiles === undefined || Sk.builtinFiles["files"][x] === undefined)
                            throw "File not found: '" + x + "'";
                    return Sk.builtinFiles["files"][x];
                }
                Sk.configure({output:outf, read:builtinRead});
                var myPromise = Sk.misceval.asyncToPromise(function() {
                   return Sk.importMainWithBody("<stdin>", false, prog, true);
               });
               myPromise.then(function(mod) {
                   console.log('success');
               },
                   function(err) {
                   console.log(err.toString());
               });