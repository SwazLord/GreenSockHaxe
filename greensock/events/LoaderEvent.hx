package com.greensock.events;

import flash.events.Event;

class LoaderEvent extends Event
{
    
    public static inline var HTTP_RESPONSE_STATUS : String = "httpResponseStatus";
    
    public static inline var CHILD_FAIL : String = "childFail";
    
    public static inline var HTTP_STATUS : String = "httpStatus";
    
    public static inline var OPEN : String = "open";
    
    public static inline var IO_ERROR : String = "ioError";
    
    public static inline var CHILD_PROGRESS : String = "childProgress";
    
    public static inline var INIT : String = "init";
    
    public static inline var CHILD_CANCEL : String = "childCancel";
    
    public static inline var FAIL : String = "fail";
    
    public static inline var CHILD_COMPLETE : String = "childComplete";
    
    public static inline var ERROR : String = "error";
    
    public static inline var SCRIPT_ACCESS_DENIED : String = "scriptAccessDenied";
    
    public static inline var PROGRESS : String = "progress";
    
    public static inline var SECURITY_ERROR : String = "securityError";
    
    public static inline var CHILD_OPEN : String = "childOpen";
    
    public static inline var COMPLETE : String = "complete";
    
    public static inline var CANCEL : String = "cancel";
    
    public static inline var UNCAUGHT_ERROR : String = "uncaughtError";
    
    public static inline var UNLOAD : String = "unload";
    
    
    private var _target : Dynamic;
    
    public var data;
    
    private var _ready : Bool;
    
    public var text : String;
    
    public function new(type : String, target : Dynamic, text : String = "", data : Dynamic = null)
    {
        super(type, false, false);
        _target = target;
        this.text = text;
        this.data = data;
    }
    
    override private function get_target() : Dynamic
    {
        if (_ready)
        {
            return _target;
        }
        _ready = true;
        return null;
    }
    
    override public function clone() : Event
    {
        return new LoaderEvent(this.type, _target, this.text, this.data);
    }
}

