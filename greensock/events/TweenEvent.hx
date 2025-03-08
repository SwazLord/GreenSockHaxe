package com.greensock.events;

import flash.events.Event;

class TweenEvent extends Event
{
    
    public static inline var COMPLETE : String = "complete";
    
    public static inline var START : String = "start";
    
    public static inline var UPDATE : String = "change";
    
    public static inline var REVERSE_COMPLETE : String = "reverseComplete";
    
    public static inline var VERSION : Float = 12;
    
    public static inline var REPEAT : String = "repeat";
    
    
    public function new(type : String, bubbles : Bool = false, cancelable : Bool = false)
    {
        super(type, bubbles, cancelable);
    }
    
    override public function clone() : Event
    {
        return new TweenEvent(this.type, this.bubbles, this.cancelable);
    }
}

