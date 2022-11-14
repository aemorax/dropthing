package core;

enum abstract ClientMessageType(Int) {
    var Drop;
}

typedef ClientMessage = {
    var room : Int;
    var playerId: Int;
    var type : ClientMessageType;
    var data : Dynamic;
}