package com.greensock.easing;


@:final class CircIn extends Ease
{
    
    public static var ease : CircIn = new CircIn();
    
    
    public function new()
    {
        super();
    }
    
    override public function getRatio(p : Float) : Float
    {
        return -(Math.sqrt(1 - p * p) - 1);
    }
}

