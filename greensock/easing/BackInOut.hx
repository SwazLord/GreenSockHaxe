package com.greensock.easing;


@:final class BackInOut extends Ease
{
    
    public static var ease : BackInOut = new BackInOut();
    
    
    public function new(overshoot : Float = 1.70158)
    {
        super();
        _p1 = overshoot;
        _p2 = _p1 * 1.525;
    }
    
    public function config(overshoot : Float = 1.70158) : BackInOut
    {
        return new BackInOut(overshoot);
    }
    
    override public function getRatio(p : Float) : Float
    {
        return ((p = p * 2) < 1) ? as3hx.Compat.parseFloat(0.5 * p * p * ((_p2 + 1) * p - _p2)) : as3hx.Compat.parseFloat(0.5 * ((p = p - 2) * p * ((_p2 + 1) * p + _p2) + 2));
    }
}

