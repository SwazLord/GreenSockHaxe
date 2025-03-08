package com.greensock.easing;


@:final class BounceOut extends Ease
{
    
    public static var ease : BounceOut = new BounceOut();
    
    
    public function new()
    {
        super();
    }
    
    override public function getRatio(p : Float) : Float
    {
        if (p < 1 / 2.75)
        {
            return 7.5625 * p * p;
        }
        if (p < 2 / 2.75)
        {
            return 7.5625 * (p = p - 1.5 / 2.75) * p + 0.75;
        }
        if (p < 2.5 / 2.75)
        {
            return 7.5625 * (p = p - 2.25 / 2.75) * p + 0.9375;
        }
        return 7.5625 * (p = p - 2.625 / 2.75) * p + 0.984375;
    }
}

