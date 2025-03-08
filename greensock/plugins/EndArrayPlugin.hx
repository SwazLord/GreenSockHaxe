package com.greensock.plugins;

import com.greensock.TweenLite;

class EndArrayPlugin extends TweenPlugin
{
    
    public static inline var API : Float = 2;
    
    
    private var _a : Array<Dynamic>;
    
    private var _info : Array<Dynamic>;
    
    private var _round : Bool;
    
    public function new()
    {
        _info = [];
        super("endArray");
    }
    
    override public function _roundProps(lookup : Dynamic, value : Bool = true) : Void
    {
        if (Lambda.has(lookup, "endArray"))
        {
            _round = value;
        }
    }
    
    public function _init(start : Array<Dynamic>, end : Array<Dynamic>) : Void
    {
        _a = start;
        var i : Int = end.length;
        var cnt : Int = 0;
        while (--i > -1)
        {
            if (start[i] != end[i] && start[i] != null)
            {
                var _loc5_ : Dynamic = cnt++;
                Reflect.setField(_info, Std.string(_loc5_), new ArrayTweenInfo(i, _a[i], end[i] - _a[i]));
            }
        }
    }
    
    override public function setRatio(v : Float) : Void
    {
        var ti : ArrayTweenInfo = null;
        var val : Float = Math.NaN;
        var i : Int = _info.length;
        if (_round)
        {
            while (--i > -1)
            {
                ti = _info[i];
                _a[ti.i] = ((val = ti.c * v + ti.s) > 0) ? val + 0.5 >> 0 : val - 0.5 >> 0;
            }
        }
        else
        {
            while (--i > -1)
            {
                ti = _info[i];
                _a[ti.i] = ti.c * v + ti.s;
            }
        }
    }
    
    override public function _onInitTween(target : Dynamic, value : Dynamic, tween : TweenLite) : Bool
    {
        if (!(Std.is(target, Array)) || !(Std.is(value, Array)))
        {
            return false;
        }
        _init(try cast(target, Array</*AS3HX WARNING no type*/>) catch(e:Dynamic) null, value);
        return true;
    }
}


class ArrayTweenInfo
{
    
    
    public var s : Float;
    
    public var i : Int;
    
    public var c : Float;
    
    private function new(index : Int, start : Float, change : Float)
    {
        super();
        this.i = index;
        this.s = start;
        this.c = change;
    }
}
