package com.greensock.plugins;

import com.greensock.TweenLite;

class VisiblePlugin extends TweenPlugin
{
    
    public static inline var API : Float = 2;
    
    
    private var _progress : Int;
    
    private var _target : Dynamic;
    
    private var _initVal : Bool;
    
    private var _visible : Bool;
    
    private var _tween : TweenLite;
    
    public function new()
    {
        super("visible");
    }
    
    override public function setRatio(v : Float) : Void
    {
        _target.visible = (v == 1 && (_tween._time / _tween._duration == _progress || _tween._duration == 0)) ? _visible : _initVal;
    }
    
    override public function _onInitTween(target : Dynamic, value : Dynamic, tween : TweenLite) : Bool
    {
        _target = target;
        _tween = tween;
        _progress = (cast(_tween.vars.runBackwards, Bool)) ? 0 : 1;
        _initVal = _target.visible;
        _visible = cast(value, Bool);
        return true;
    }
}

