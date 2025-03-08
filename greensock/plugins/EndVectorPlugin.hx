package com.greensock.plugins;

import com.greensock.TweenLite;

class EndVectorPlugin extends TweenPlugin
{
    
    public static inline var API : Float = 2;
    
    
    private var _v : Array<Float>;
    
    private var _info : Array<VectorInfo>;
    
    public var _round : Bool;
    
    public function new()
    {
        _info = new Array<VectorInfo>();
        super("endVector");
    }
    
    override public function _roundProps(lookup : Dynamic, value : Bool = true) : Void
    {
        if (Lambda.has(lookup, "endVector"))
        {
            _round = value;
        }
    }
    
    override public function _onInitTween(target : Dynamic, value : Dynamic, tween : TweenLite) : Bool
    {
        if (!(Std.is(target, Array/*Vector.<T> call?*/)) || !(Std.is(value, Array/*Vector.<T> call?*/)))
        {
            return false;
        }
        _init(try cast(target, Array/*Vector.<T> call?*/) catch(e:Dynamic) null, try cast(value, Array/*Vector.<T> call?*/) catch(e:Dynamic) null);
        return true;
    }
    
    public function _init(start : Array<Float>, end : Array<Float>) : Void
    {
        _v = start;
        var i : Int = end.length;
        var cnt : Int = 0;
        while (--i > -1)
        {
            if (_v[i] != end[i])
            {
                var _loc5_ : Dynamic = cnt++;
                Reflect.setField(_info, Std.string(_loc5_), new VectorInfo(i, _v[i], end[i] - _v[i]));
            }
        }
    }
    
    override public function setRatio(v : Float) : Void
    {
        var vi : VectorInfo = null;
        var val : Float = Math.NaN;
        var i : Int = _info.length;
        if (_round)
        {
            while (--i > -1)
            {
                vi = _info[i];
                _v[vi.i] = ((val = vi.c * v + vi.s) > 0) ? as3hx.Compat.parseFloat(val + 0.5 >> 0) : as3hx.Compat.parseFloat(val - 0.5 >> 0);
            }
        }
        else
        {
            while (--i > -1)
            {
                vi = _info[i];
                _v[vi.i] = vi.c * v + vi.s;
            }
        }
    }
}


class VectorInfo
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
