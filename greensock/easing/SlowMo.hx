package com.greensock.easing;


class SlowMo extends Ease
{
    
    public static var ease : SlowMo = new SlowMo();
    
    
    private var _p : Float;
    
    public function new(linearRatio : Float = 0.7, power : Float = 0.7, yoyoMode : Bool = false)
    {
        super();
        if (linearRatio > 1)
        {
            linearRatio = 1;
        }
        _p = (linearRatio != 1) ? power : 0;
        _p1 = (1 - linearRatio) / 2;
        _p2 = linearRatio;
        _p3 = _p1 + _p2;
        _calcEnd = yoyoMode;
    }
    
    public function config(linearRatio : Float = 0.7, power : Float = 0.7, yoyoMode : Bool = false) : SlowMo
    {
        return new SlowMo(linearRatio, power, yoyoMode);
    }
    
    override public function getRatio(p : Float) : Float
    {
        var r : Float = p + (0.5 - p) * _p;
        if (p < _p1)
        {
            return !!(_calcEnd) ? as3hx.Compat.parseFloat(1 - (p = 1 - p / _p1) * p) : as3hx.Compat.parseFloat(r - (p = as3hx.Compat.parseFloat(1 - p / _p1)) * p * p * p * r);
        }
        if (p > _p3)
        {
            return !!(_calcEnd) ? as3hx.Compat.parseFloat(1 - (p = (p - _p3) / _p1) * p) : as3hx.Compat.parseFloat(r + (p - r) * (p = as3hx.Compat.parseFloat((p - _p3) / _p1)) * p * p * p);
        }
        return !!(_calcEnd) ? 1 : r;
    }
}

