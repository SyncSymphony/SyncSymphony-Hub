This is the code for SyncSymphony that goes on the hub.

When all configured properly it will broadcast out a new WiFi with
SSID:SyncSymphonyHub
Password: syncingandswimming

Connect to it with any device and open
http://sync.symphony/ in a browser to view the interface

Packs will automatically connect to this WiFi

The folders are structured as follows
* python-server 
  * python that host the web interface and communication with packs
* src
  * elm code for the web interface
* RPI-config-files
  * The config files for the raspberry pi to broadcast a network and automatically start the server on boot
* elm-mdc
  * Dependency for the elm code to make the material design work properly

Files:
* elm.js 
  * the compiled code from elm
* index.html
  * the html of the web page interface. Brings in all decencies
* TODO
  * A file with a TODO item

