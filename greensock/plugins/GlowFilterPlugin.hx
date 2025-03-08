package com.greensock.plugins;

import com.greensock.TweenLite;
import flash.filters.GlowFilter;

class GlowFilterPlugin extends FilterPlugin
{
    
    public static inline var API : Float = 2;
    
    private static var _propNames : Array<Dynamic> = ["color", "alpha", "blurX", "blurY", "strength", "quality", "inner", "knockout"];
    
    
    public function new()
    {
        super("glowFilter");
    }
    
    override public function _onInitTween(target : Dynamic, value : Dynamic, tween : TweenLite) : Bool
    {
        return _initFilter(target, value, tween, GlowFilter, new GlowFilter(16777215, 0, 0, 0, as3hx.Compat.parseFloat(value.strength) || 1, as3hx.Compat.parseInt(value.quality) || 2, value.inner, value.knockout), _propNames);
    }
}

