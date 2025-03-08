package com.greensock.plugins;

import com.greensock.TweenLite;
import flash.filters.BevelFilter;

class BevelFilterPlugin extends FilterPlugin
{
    
    public static inline var API : Float = 2;
    
    private static var _propNames : Array<Dynamic> = ["distance", "angle", "highlightColor", "highlightAlpha", "shadowColor", "shadowAlpha", "blurX", "blurY", "strength", "quality"];
    
    
    public function new()
    {
        super("bevelFilter");
    }
    
    override public function _onInitTween(target : Dynamic, value : Dynamic, tween : TweenLite) : Bool
    {
        return _initFilter(target, value, tween, BevelFilter, new BevelFilter(0, 0, 16777215, 0.5, 0, 0.5, 2, 2, 0, as3hx.Compat.parseInt(value.quality) || 2), _propNames);
    }
}

