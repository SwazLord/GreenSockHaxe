package com.greensock.easing;


@:final class CircInOut extends Ease
{
    
    public static var ease : CircInOut = new CircInOut();
    
    
    public function new()
    {
        super();
    }
    
    override public function getRatio(p : Float) : Float
    {
        return ((p = p * 2) < 1) ? as3hx.Compat.parseFloat(-0.5 * (Math.sqrt(1 - p * p) - 1)) : as3hx.Compat.parseFloat(0.5 * (Math.sqrt(1 - (p = p - 2) * p) + 1));
    }
}

