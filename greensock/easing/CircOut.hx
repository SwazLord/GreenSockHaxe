package com.greensock.easing;


@:final class CircOut extends Ease
{
    
    public static var ease : CircOut = new CircOut();
    
    
    public function new()
    {
        super();
    }
    
    override public function getRatio(p : Float) : Float
    {
        return Math.sqrt(1 - (p = p - 1) * p);
    }
}

