package core;

import haxe.ds.Vector;

enum abstract RoomState(Int) {
    var Wait;
    var Ready;
} 

typedef RoomData = {
    var roomID : Int;
    var roomState : RoomState;
    var turn : Int;
    var rowsCount : Int;
    var columnCount : Int;
    var blocks : Vector<Int>;
}