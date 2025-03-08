package com.greensock.easing;


@:final class ExpoOut extends Ease
{
    
    public static var ease : ExpoOut = new ExpoOut();
    
    
    public function new()
    {
        super();
    }
    
    override public function getRatio(p : Float) : Float
    {
        return 1 - Math.pow(2, -10 * p);
    }
}

