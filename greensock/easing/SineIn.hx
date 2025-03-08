package com.greensock.easing;


@:final class SineIn extends Ease
{
    
    public static var ease : SineIn = new SineIn();
    
    private static var _HALF_PI : Float = Math.PI / 2;
    
    
    public function new()
    {
        super();
    }
    
    override public function getRatio(p : Float) : Float
    {
        return -Math.cos(p * _HALF_PI) + 1;
    }
}

