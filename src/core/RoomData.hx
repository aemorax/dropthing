package core;

import haxe.ds.Vector;

enum abstract RoomState(Int) {
    var JoiningPhase;
    var Ready;
    var Player1Turn;
    var Player2Turn;
    var End;
} 

typedef RoomData = {
    var roomID : Int;
    var roomState : RoomState;
    var rowsCount : Int;
    var columnCount : Int;
    var winner : Int;
    var blocks : Vector<Int>;
}