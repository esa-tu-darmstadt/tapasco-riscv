@0x997b72335b9c6aaf;

struct Request {
    type @0 :RequestType;
    isRead @1 :Bool;
    addr @2 :UInt32;
    data @3 :UInt32;
    ctrlType @4 :ControlType;

    enum RequestType{
        dtm @0;
        dm @1;
        register @2;
        memory @3;
        systemBus @4;
        control @5;
    }
    enum ControlType {
        halt @0;
        resume @1;
        step @2;
        reset @3;
    }
}

struct Response {
    isRead @0 :Bool;
    data @1 :UInt32;
    success @2 :Bool;
}
