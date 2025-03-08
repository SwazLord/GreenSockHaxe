package com.greensock.plugins;

import com.greensock.TweenLite;
import flash.filters.DropShadowFilter;

class DropShadowFilterPlugin extends FilterPlugin
{
    
    public static inline var API : Float = 2;
    
    private static var _propNames : Array<Dynamic> = ["distance", "angle", "color", "alpha", "blurX", "blurY", "strength", "quality", "inner", "knockout", "hideObject"];
    
    
    public function new()
    {
        super("dropShadowFilter");
    }
    
    override public function _onInitTween(target : Dynamic, value : Dynamic, tween : TweenLite) : Bool
    {
        return _initFilter(target, value, tween, DropShadowFilter, new DropShadowFilter(0, 45, 0, 0, 0, 0, 1, as3hx.Compat.parseInt(value.quality) || 2, value.inner, value.knockout, value.hideObject), _propNames);
    }
}

