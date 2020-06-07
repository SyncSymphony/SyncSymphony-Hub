All the files needed for configuring a raspberry pi as a hub
Each file contains a comment at the top or near the top
explaining where to put each file and if any other commands need to be run

This will broadcast a new WiFi network with 
SSID:SyncSymphonyHub
Password: syncingandswimming
 
Connect with any device and open
http://sync.symphony/ to view the interface


Other configuration needed:
1. Put this repository in the folder /home/pi/SyncSymphony
so that the path to get to the root directory is
/home/pi/SyncSymphony/SyncSymphony

2. Install all depencies in python-server/requirments.txt 
you can use pip3 install -r requirments.txt to speed this up

3. Install an ntp time server with sudo apt install sntp

4. (optional) install elm if you want to update the code with
sudo apt install elm
