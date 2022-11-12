package;

import python.Exceptions.KeyboardInterrupt;
import core.Room;
import haxe.Json;
import core.ServerMessage;
import core.JoinData;
#if python

import haxe.CallStack;
import haxe.io.Bytes;
import haxe.net.WebSocket;
import haxe.net.WebSocketServer;
import sys.thread.Thread;
import sys.net.Host;

class WebSocketHandler {
  static var _nextId = 0;
  var _id = _nextId++;
  var _websocket:WebSocket;
  
  public function new(websocket:WebSocket) {
    _websocket = websocket;
    _websocket.onopen = onopen;
    _websocket.onclose = onclose;
    _websocket.onerror = onerror;
    _websocket.onmessageString = onmessageString;
  }
  
  public function update():Bool {
    _websocket.process();
    return _websocket.readyState != Closed;
  }
  
    function onopen():Void {
        trace('$_id: open');

        var joinData : JoinData = {
            id: _id
        };

        var message : ServerMessage = {
            type: Connected,
            data: joinData
        };
        
        _websocket.sendString(Json.stringify(message));

        var room : Room;
        if(Server.openRooms.length == 0) {
            room = new Room(_websocket, 5, 7);
            Server.openRooms.push(room);
        } else {
            room = Server.openRooms.pop();
            room.join(_websocket);
            
        }
    }

    function onerror(message:String):Void {
        trace('$_id: error: $message');
    }

    function onmessageString(message:String):Void {
        trace('$_id: message: $message');
        _websocket.sendString(message);
    }

    function onclose(?e:Null<Dynamic>):Void {
        trace('$_id: close');
    }
}

class Server {
    public static var openRooms : Array<Room> = new Array<Room>();
    static var server : WebSocketServer;
    static var serverListening : Bool = true;
    static var handlers = [];

    static function initSocket() {
        server = WebSocketServer.create("127.0.0.1", 8000, 29, true, false);
    }

    static function serve() {
        while (true) {
            try {
                var websocket = server.accept();
                if (websocket != null) {
                handlers.push(new WebSocketHandler(websocket));
                }
                
                var toRemove = [];
                for (handler in handlers) {
                if (!handler.update()) {
                    toRemove.push(handler);
                }
                }
                
                while (toRemove.length > 0)
                handlers.remove(toRemove.pop());
                
                Sys.sleep(0.1);
            }
            catch (e:Dynamic) {
                trace('Error', e);
                trace(CallStack.exceptionStack());
                if(Std.isOfType(e, KeyboardInterrupt)){
                    @:privateAccess
                    server._listenSocket.close();
                    Sys.exit(0);
                }
            }
        }
    }

    static function main() {
        initSocket();
        serve();
    }
}

#end