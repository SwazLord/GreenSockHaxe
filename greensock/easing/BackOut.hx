package com.greensock.easing;


@:final class BackOut extends Ease
{
    
    public static var ease : BackOut = new BackOut();
    
    
    public function new(overshoot : Float = 1.70158)
    {
        super();
        _p1 = overshoot;
    }
    
    public function config(overshoot : Float = 1.70158) : BackOut
    {
        return new BackOut(overshoot);
    }
    
    override public function getRatio(p : Float) : Float
    {
        return (p = p - 1) * p * ((_p1 + 1) * p + _p1) + 1;
    }
}

