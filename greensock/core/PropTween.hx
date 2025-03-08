package com.greensock.core;


@:final class PropTween
{
    
    
    public var _prev : PropTween;
    
    public var pr : Int;
    
    public var c : Float;
    
    public var f : Bool;
    
    public var p : String;
    
    public var r : Bool;
    
    public var s : Float;
    
    public var t : Dynamic;
    
    public var pg : Bool;
    
    public var _next : PropTween;
    
    public var n : String;
    
    public function new(target : Dynamic, property : String, start : Float, change : Float, name : String, isPlugin : Bool, next : PropTween = null, priority : Int = 0)
    {
        super();
        this.t = target;
        this.p = property;
        this.s = start;
        this.c = change;
        this.n = name;
        this.f = Std.is(Reflect.field(target, property), Function);
        this.pg = isPlugin;
        if (next != null)
        {
            next._prev = this;
            this._next = next;
        }
        this.pr = priority;
    }
}

