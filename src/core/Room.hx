package core;

import core.ServerMessage.ServerMessageType;
import core.ClientMessage.ClientMessageType;
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
    public var p1Id : Int = -1;
    public var p2Id : Int = -1;
    #end
    public var roomData:RoomData;
    
    function syncRoomData(messageType:ServerMessageType) {
        var roomMessage : ServerMessage = {
            type: messageType,
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
            roomState: JoiningPhase,
            rowsCount: rowCount,
            columnCount: columnCount,
            blocks: v,
            winner: 0
        }
        syncRoomData(RoomReady);
    }

    #if js
    public static function fromRoomData(data:RoomData):Room {
        var room = new Room(data.rowsCount, data.columnCount);
        room.roomData = data;
        return room;
    }
    #end

    #if sys
    public function join(player2:WebSocket) {
        this.sock2 = player2;
        roomData.roomState = Ready;
        syncRoomData(RoomReady);

        this.sock1.onmessageString = handleRequests;
        this.sock2.onmessageString = handleRequests;

        roomData.roomState = Math.random() > 0.5 ? Player1Turn : Player2Turn;
        syncRoomData(RoomUpdate);
    }

    function handleRequests(e:String) {
        var data : ClientMessage = Json.parse(e);
        var type : ClientMessageType = data.type;

        switch (type) {
            case Drop:
                tryDrop(data);
            case _:
                trace("Unknown");
        }
    }

    function tryDrop(data:ClientMessage) {
        var player = data.playerId;
        var dropData : DropData = data.data;
        if(player == p1Id && roomData.roomState == Player1Turn) {
            drop(1, dropData.column);
        } else if(player == p2Id && roomData.roomState == Player2Turn) {
            drop(2, dropData.column);
        }
    }

    #end

    public function drop(player:Int, column:Int): Int {
        var emptyRow = getEmptyRowOfColumn(column);
        if(emptyRow == -1)
            return -1;

        roomData.roomState = player == 1 ? Player2Turn : Player1Turn;
        set(player, column, emptyRow, false);
        roomData.winner = checkWinningCondition();
        syncRoomData(RoomUpdate);

        return emptyRow;
    }

    public function set(value:Int, column:Int, row:Int, ?shouldSync:Bool = true) {
        roomData.blocks.set(row*roomData.columnCount+column, value);
        if(shouldSync)
            syncRoomData(RoomUpdate);
    }

    public function get(column:Int, row:Int) : Int {
        return roomData.blocks.get(row*roomData.columnCount+column);
    }

    function getEmptyRowOfColumn(column:Int) : Int {
        for(i in 0...roomData.rowsCount) {
            if(get(column, i) == 0)
                return i;
        }
        return -1;
    }

    /*
        Checks if players win or not.
        returns number corresponding to player number and 0 if none.
    */
    function checkWinningCondition() : Int {
        var value = 0;
        value = checkDiagonals();
        if(value != 0)
            return value;
        value = checkHorizontals();
        if(value != 0)
            return value;
        value = checkVerticals();
        if(value != 0)
            return value;
        return 0;
    }

    function checkDiagonals() {
        var rc = roomData.rowsCount;
        var cc = roomData.columnCount;

        var a = 0;
        var b = 0;
        var c = 0;
        var d = 0;
        var eval = 0;

        for (row in 0...rc-3) {
            for(column in 0...cc-3) {
                a = get(column, row);
                b = get(column+1, row+1);
                c = get(column+2, row+2);
                d = get(column+3, row+3);
                eval = a & b & c & d;
                eval = filterEvaluated(eval);
                if(eval != 0)
                    return eval;

                a = get(column, row+3);
                b = get(column+1, row+2);
                c = get(column+2, row+1);
                d = get(column+3, row);
                eval = a & b & c & d;
                eval = filterEvaluated(eval);
                if(eval != 0)
                    return eval;
            }
        }
        return 0;
    }

    function checkHorizontals() {
        var rc = roomData.rowsCount;
        var cc = roomData.columnCount;

        var a = 0;
        var b = 0;
        var c = 0;
        var d = 0;
        var eval = 0;

        for (col in 0...cc-3) {
            for (row in 0...rc) {
                a = get(col, row);
                b = get(col+1, row);
                c = get(col+2, row);
                d = get(col+3, row);
                eval = a & b & c & d;
                eval = filterEvaluated(eval);
                if(eval != 0)
                    return eval;
            }
        }
        return 0;
    }

    function checkVerticals() {
        var rc = roomData.rowsCount;
        var cc = roomData.columnCount;

        var a = 0;
        var b = 0;
        var c = 0;
        var d = 0;
        var eval = 0;

        for (col in 0...cc) {
            for (row in 0...rc-3) {
                a = get(col, row);
                b = get(col, row+1);
                c = get(col, row+2);
                d = get(col, row+3);
                eval = a & b & c & d;
                eval = filterEvaluated(eval);
                if(eval != 0)
                    return eval;
            }
        }
        return 0;
    }

    function filterEvaluated(eval:Int):Int {
        if(eval == 1)
            return 1;
        if(eval == 2)
            return 2;

        return 0;
    }
}