package com.greensock.plugins;

import com.greensock.TweenLite;

class Positions2DPlugin extends TweenPlugin
{
    
    public static inline var API : Float = 2;
    
    
    private var _target : Dynamic;
    
    private var _positions : Array<Dynamic>;
    
    public function new()
    {
        super("positions2D,x,y");
    }
    
    override public function setRatio(v : Float) : Void
    {
        if (v < 0)
        {
            v = 0;
        }
        else if (v >= 1)
        {
            v = 0.999999999;
        }
        var position : Dynamic = _positions[as3hx.Compat.parseInt(_positions.length * v)];
        _target.x = position.x;
        _target.y = position.y;
    }
    
    override public function _onInitTween(target : Dynamic, value : Dynamic, tween : TweenLite) : Bool
    {
        if (!(Std.is(value, Array)))
        {
            return false;
        }
        _target = target;
        _positions = try cast(value, Array</*AS3HX WARNING no type*/>) catch(e:Dynamic) null;
        return true;
    }
}

