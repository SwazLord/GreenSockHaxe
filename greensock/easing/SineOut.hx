package com.greensock.easing;


@:final class SineOut extends Ease
{
    
    public static var ease : SineOut = new SineOut();
    
    private static var _HALF_PI : Float = Math.PI / 2;
    
    
    public function new()
    {
        super();
    }
    
    override public function getRatio(p : Float) : Float
    {
        return Math.sin(p * _HALF_PI);
    }
}

