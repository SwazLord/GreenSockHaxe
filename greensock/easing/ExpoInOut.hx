package com.greensock.easing;


@:final class ExpoInOut extends Ease
{
    
    public static var ease : ExpoInOut = new ExpoInOut();
    
    
    public function new()
    {
        super();
    }
    
    override public function getRatio(p : Float) : Float
    {
        return ((p = p * 2) < 1) ? as3hx.Compat.parseFloat(0.5 * Math.pow(2, 10 * (p - 1))) : as3hx.Compat.parseFloat(0.5 * (2 - Math.pow(2, -10 * (p - 1))));
    }
}

