package com.greensock.plugins;

import haxe.Constraints.Function;
import com.greensock.TweenLite;

class OnChangeRatioPlugin extends TweenPlugin
{
    
    public static inline var API : Float = 2;
    
    
    private var _func : Function;
    
    private var _tween : TweenLite;
    
    private var _ratio : Float;
    
    public function new()
    {
        super("onChangeRatio");
        _ratio = 0;
    }
    
    override public function setRatio(v : Float) : Void
    {
        if (_ratio != v)
        {
            _func(_tween);
            _ratio = v;
        }
    }
    
    override public function _onInitTween(target : Dynamic, value : Dynamic, tween : TweenLite) : Bool
    {
        if (!(Std.is(value, Function)))
        {
            return false;
        }
        _func = try cast(value, Function) catch(e:Dynamic) null;
        _tween = tween;
        return true;
    }
}

