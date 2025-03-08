package com.greensock.easing;


@:final class ElasticInOut extends Ease
{
    
    private static var _2PI : Float = Math.PI * 2;
    
    public static var ease : ElasticInOut = new ElasticInOut();
    
    
    public function new(amplitude : Float = 1, period : Float = 0.3)
    {
        super();
        _p1 = amplitude || 1;
        _p2 = period || 0.45;
        _p3 = _p2 / _2PI * (Math.asin(1 / _p1) || 0);
    }
    
    public function config(amplitude : Float = 1, period : Float = 0.3) : ElasticInOut
    {
        return new ElasticInOut(amplitude, period);
    }
    
    override public function getRatio(p : Float) : Float
    {
        return ((p = p * 2) < 1) ? as3hx.Compat.parseFloat(-0.5 * (_p1 * Math.pow(2, 10 * (p = p - 1)) * Math.sin((p - _p3) * _2PI / _p2))) : as3hx.Compat.parseFloat(_p1 * Math.pow(2, -10 * (p = as3hx.Compat.parseFloat(p - 1))) * Math.sin((p - _p3) * _2PI / _p2) * 0.5 + 1);
    }
}

