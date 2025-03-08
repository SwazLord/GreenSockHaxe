package com.greensock.easing;

import haxe.Constraints.Function;

class Ease
{
    
    private static var _baseParams : Array<Dynamic> = [0, 0, 1, 1];
    
    
    private var _p1 : Float;
    
    private var _p2 : Float;
    
    private var _func : Function;
    
    private var _params : Array<Dynamic>;
    
    private var _p3 : Float;
    
    public var _power : Int;
    
    public var _calcEnd : Bool;
    
    public var _type : Int;
    
    public function new(func : Function = null, extraParams : Array<Dynamic> = null, type : Float = 0, power : Float = 0)
    {
        super();
        _func = func;
        _params = (cast(extraParams, Bool)) ? _baseParams.concat(extraParams) : _baseParams;
        _type = as3hx.Compat.parseInt(type);
        _power = as3hx.Compat.parseInt(power);
    }
    
    public function getRatio(p : Float) : Float
    {
        var r : Float = Math.NaN;
        if (_func != null)
        {
            _params[0] = p;
            return Reflect.callMethod(null, _func, _params);
        }
        r = (_type == 1) ? as3hx.Compat.parseFloat(1 - p) : ((_type == 2) ? p : ((p < 0.5) ? as3hx.Compat.parseFloat(p * 2) : as3hx.Compat.parseFloat((1 - p) * 2)));
        if (_power == 1)
        {
            r *= r;
        }
        else if (_power == 2)
        {
            r *= r * r;
        }
        else if (_power == 3)
        {
            r *= r * r * r;
        }
        else if (_power == 4)
        {
            r *= r * r * r * r;
        }
        return (_type == 1) ? as3hx.Compat.parseFloat(1 - r) : ((_type == 2) ? r : ((p < 0.5) ? as3hx.Compat.parseFloat(r / 2) : as3hx.Compat.parseFloat(1 - r / 2)));
    }
}

