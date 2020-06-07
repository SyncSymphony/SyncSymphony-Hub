#!/usr/bin/env python3
from bottle import request, Bottle, abort, static_file
from gevent import monkey; monkey.patch_all()
import time


app = Bottle()

rootDir = "/home/pi/SyncSymphony/SyncSymphony" #CHANGE FOR YOUR SETUP

#web control panel request 

@app.route('/', methods=["GET"]) 
def UI():
    return static_file('index.html',root=rootDir) 

@app.route('/elm.js', methods=["GET"]) 
def elmJS():
    return static_file('elm.js',root=rootDir) 


#elm depends 
@app.route('/elm-mdc/material-components-web.css')
def mdcCss():
    return static_file('material-components-web.css',root=rootDir + '/elm-mdc')

@app.route('/elm-mdc/elm-mdc.js')
def mdcJs():
    return static_file('elm-mdc.js',root=rootDir + '/elm-mdc')

#end elm depends


#end web control panel request
global sockets
open_sockets = [] 


@app.route('/websocket')
def handle_websocket():
    global open_sockets

    print('getting new websocket connection')
    wsock = request.environ.get('wsgi.websocket')
    open_sockets.append(wsock)
    if not wsock:
        abort(400, 'Expected WebSocket request.')

    while True:
        try:
            time.sleep(1) #sleep in a loop to keep the socket open
        except WebSocketError:
            open_sockets.remove(wsock)
            print("socket connection ended")
            break


@app.route('/hub', method="post") 
def hub():
    global open_sockets
    
    timeSig = request.forms.get("timeSig")
    tempo = request.forms.get("tempo")
    
    try:
        timeSig = int(timeSig)
    except ValueError:
        return 400 #timeSig not an int
    
    if timeSig <= 0:
        return 400 #0 beats per second doesn't make sense
    
    timeSig= str(timeSig)
    #convert back to str to add to message

    try:
        if int(tempo) not in range(30,240 + 1 ): 
            # +1 to account for upper value not being included
            return 400 #too high or too low
    except ValueError:
        return 400 #tempo not an int
    
    tempo = str(int(tempo))
    #same reason as timeSig for str to int to str conversion

    StartTime = int(time.time()) # remove the decmials
    StartTime += 1 # 1 second delay
    StartTime = str(StartTime) #convert to str to add into message

    for conn in open_sockets:
            try:
                conn.send(timeSig + " " + tempo + " " + StartTime)
            except WebSocketError:
                print("removing dead socket connection")
                open_sockets.remove(conn)
                

    return " "

from gevent.pywsgi import WSGIServer
from geventwebsocket import WebSocketError
from geventwebsocket.handler import WebSocketHandler
server = WSGIServer(("0.0.0.0", 80), app,
                    handler_class=WebSocketHandler)
server.serve_forever()
