package com.greensock.easing;


@:final class BounceInOut extends Ease
{
    
    public static var ease : BounceInOut = new BounceInOut();
    
    
    public function new()
    {
        super();
    }
    
    override public function getRatio(p : Float) : Float
    {
        var invert : Bool = false;
        if (p < 0.5)
        {
            invert = true;
            p = 1 - p * 2;
        }
        else
        {
            p = p * 2 - 1;
        }
        if (p < 1 / 2.75)
        {
            p = 7.5625 * p * p;
        }
        else if (p < 2 / 2.75)
        {
            p = 7.5625 * (p = p - 1.5 / 2.75) * p + 0.75;
        }
        else if (p < 2.5 / 2.75)
        {
            p = 7.5625 * (p = p - 2.25 / 2.75) * p + 0.9375;
        }
        else
        {
            p = 7.5625 * (p = p - 2.625 / 2.75) * p + 0.984375;
        }
        return !!(invert) ? as3hx.Compat.parseFloat((1 - p) * 0.5) : as3hx.Compat.parseFloat(p * 0.5 + 0.5);
    }
}

