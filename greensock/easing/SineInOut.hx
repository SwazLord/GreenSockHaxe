package com.greensock.easing;


@:final class SineInOut extends Ease
{
    
    public static var ease : SineInOut = new SineInOut();
    
    
    public function new()
    {
        super();
    }
    
    override public function getRatio(p : Float) : Float
    {
        return -0.5 * (Math.cos(Math.PI * p) - 1);
    }
}

