package com.greensock.plugins;

import com.greensock.TweenLite;

class ScalePlugin extends TweenPlugin
{
    
    public static inline var API : Float = 2;
    
    
    public function new()
    {
        super("scale,scaleX,scaleY,width,height");
    }
    
    override public function _onInitTween(target : Dynamic, value : Dynamic, tween : TweenLite) : Bool
    {
        if (!target.exists("scaleX"))
        {
            return false;
        }
        _addTween(target, "scaleX", target.scaleX, value, "scaleX");
        _addTween(target, "scaleY", target.scaleY, value, "scaleY");
        return true;
    }
}

