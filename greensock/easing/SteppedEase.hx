package com.greensock.easing;


class SteppedEase extends Ease
{
    public var steps(get, never) : Int;

    
    
    private var _steps : Int;
    
    public function new(steps : Int)
    {
        super();
        _p1 = 1 / steps;
        _steps = as3hx.Compat.parseInt(steps + 1);
    }
    
    public static function config(steps : Int) : SteppedEase
    {
        return new SteppedEase(steps);
    }
    
    public static function create(steps : Int) : SteppedEase
    {
        return new SteppedEase(steps);
    }
    
    override public function getRatio(p : Float) : Float
    {
        if (p < 0)
        {
            p = 0;
        }
        else if (p >= 1)
        {
            p = 0.999999999;
        }
        return (_steps * p >> 0) * _p1;
    }
    
    private function get_steps() : Int
    {
        return as3hx.Compat.parseInt(_steps - 1);
    }
}

