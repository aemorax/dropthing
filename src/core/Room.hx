package core;

import haxe.ds.Vector;
import haxe.Json;
#if sys
import haxe.net.WebSocket;
#end

class Room {
    static var _nextID:Int = 0;
    public var roomID : Int = _nextID++;
    #if sys
    var sock1 : Null<WebSocket>;
    var sock2 : Null<WebSocket>;
    #end
    public var roomData:RoomData;
    
    function syncRoomData() {
        var roomMessage : ServerMessage = {
            type: RoomUpdate,
            data: roomData
        };

        var roomString = Json.stringify(roomMessage);

    #if sys
        if(sock1 != null) {
            sock1.sendString(roomString);
        }
        if(sock2 != null) {
            sock2.sendString(roomString);
        }
    #end
    }

    #if sys
    public function new(player1:WebSocket, rowCount:Int, columnCount:Int) {
        sock1 = player1;
        var backOnClose = sock1.onclose;
        sock1.onclose = function(?e:Null<Dynamic>) {
            Server.openRooms.remove(this);
            backOnClose();
        }
    #else
    public function new(rowCount:Int, columnCount:Int) {
    #end
        var v = new Vector<Int>(rowCount*columnCount);
        for (i in 0...rowCount*columnCount) {
            v.set(i, 0);
        }
        roomData = {
            roomID: roomID,
            roomState: Wait,
            rowsCount: rowCount,
            columnCount: columnCount,
            turn: 0,
            blocks: v
        }
        syncRoomData();
    }

    #if sys
    public function join(player2:WebSocket) {
        this.sock2 = player2;
        roomData.roomState = Ready;
        roomData.turn = Math.random() > 0.5 ? 1 : 0;
        syncRoomData();
    }
    #end

    public function drop(player:Int, column:Int): Int {
        var emptyRow = getEmptyRowOfColumn(column);
        if(emptyRow == -1)
            return -1;

        roomData.turn = player == 1 ? 0 : 1;
        set(player, column, emptyRow, true);

        return emptyRow;
    }

    public function set(value:Int, column:Int, row:Int, ?shouldSync:Bool = true) {
        roomData.blocks.set(row*roomData.columnCount+column, value);
        if(shouldSync)
            syncRoomData();
    }

    public function get(column:Int, row:Int) : Int {
        return roomData.blocks.get(row*roomData.columnCount+column);
    }

    function getEmptyRowOfColumn(column:Int) : Int {
        for(i in -(roomData.rowsCount)+1...1) {
            if(get(column, i) == 0)
                return i;
        }
        return -1;
    }
}