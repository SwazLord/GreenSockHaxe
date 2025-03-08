package com.greensock.easing.core;


@:final class EasePoint
{
    
    
    public var prev : EasePoint;
    
    public var time : Float;
    
    public var change : Float;
    
    public var value : Float;
    
    public var next : EasePoint;
    
    public var gap : Float;
    
    public function new(time : Float, value : Float, next : EasePoint)
    {
        super();
        this.time = time;
        this.value = value;
        if (next != null)
        {
            this.next = next;
            next.prev = this;
            this.change = next.value - value;
            this.gap = next.time - time;
        }
    }
}

