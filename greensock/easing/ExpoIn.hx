package com.greensock.easing;


@:final class ExpoIn extends Ease
{
    
    public static var ease : ExpoIn = new ExpoIn();
    
    
    public function new()
    {
        super();
    }
    
    override public function getRatio(p : Float) : Float
    {
        return Math.pow(2, 10 * (p - 1)) - 0.001;
    }
}

