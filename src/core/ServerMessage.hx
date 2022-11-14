package core;

enum abstract ServerMessageType(Int) {
    var Connected;
    var RoomReady;
    var RoomUpdate;
}

typedef ServerMessage = {
    var type : ServerMessageType;
    var data : Dynamic;
}