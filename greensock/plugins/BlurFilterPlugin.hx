package com.greensock.plugins;

import com.greensock.TweenLite;
import flash.filters.BlurFilter;

class BlurFilterPlugin extends FilterPlugin
{
    
    public static inline var API : Float = 2;
    
    private static var _propNames : Array<Dynamic> = ["blurX", "blurY", "quality"];
    
    
    public function new()
    {
        super("blurFilter");
    }
    
    override public function _onInitTween(target : Dynamic, value : Dynamic, tween : TweenLite) : Bool
    {
        return _initFilter(target, value, tween, BlurFilter, new BlurFilter(0, 0, as3hx.Compat.parseInt(value.quality) || 2), _propNames);
    }
}

