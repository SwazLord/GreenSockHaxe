package com.greensock.plugins;

import com.greensock.TweenLite;

class AutoAlphaPlugin extends TweenPlugin
{
    
    public static inline var API : Float = 2;
    
    
    private var _target : Dynamic;
    
    private var _ignoreVisible : Bool;
    
    public function new()
    {
        super("autoAlpha,alpha,visible");
    }
    
    override public function _kill(lookup : Dynamic) : Bool
    {
        _ignoreVisible = Lambda.has(lookup, "visible");
        return super._kill(lookup);
    }
    
    override public function setRatio(v : Float) : Void
    {
        super.setRatio(v);
        if (!_ignoreVisible)
        {
            _target.visible = _target.alpha != 0;
        }
    }
    
    override public function _onInitTween(target : Dynamic, value : Dynamic, tween : TweenLite) : Bool
    {
        _target = target;
        _addTween(target, "alpha", target.alpha, value, "alpha");
        return true;
    }
}

