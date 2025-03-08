package com.greensock.easing;


@:final class BackIn extends Ease
{
    
    public static var ease : BackIn = new BackIn();
    
    
    public function new(overshoot : Float = 1.70158)
    {
        super();
        _p1 = overshoot;
    }
    
    public function config(overshoot : Float = 1.70158) : BackIn
    {
        return new BackIn(overshoot);
    }
    
    override public function getRatio(p : Float) : Float
    {
        return p * p * ((_p1 + 1) * p - _p1);
    }
}

