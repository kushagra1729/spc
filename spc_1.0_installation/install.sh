#!/bin/bash
echo "Starting installation"
sudo cp spc /usr/bin/spc
sudo chmod +x /usr/bin/spc
sudo touch ~/.spc.db
sudo chmod 777 ~/.spc.db
sudo cp spc.1 /usr/share/man/man1/
sudo mandb
# gcc spc_daemon.c -o spc_daemon
# sudo cp spc_daemon /usr/bin/spc_daemon
sudo cp spc_service.sh /usr/bin/spc_service.sh
sudo cp spc.service /lib/systemd/system/spc.service
sudo systemctl daemon-reload
sudo systemctl enable spc
echo "Installation complete"
