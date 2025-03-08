package com.greensock.plugins;

import com.greensock.TweenLite;
import flash.geom.Point;
import flash.geom.Rectangle;

class TransformAroundCenterPlugin extends TransformAroundPointPlugin
{
    
    public static inline var API : Float = 2;
    
    
    public function new()
    {
        super();
        _propName = "transformAroundCenter";
    }
    
    override public function _onInitTween(target : Dynamic, value : Dynamic, tween : TweenLite) : Bool
    {
        var bounds : Rectangle = target.getBounds(target);
        value.point = new Point(bounds.x + bounds.width / 2, bounds.y + bounds.height / 2);
        value.pointIsLocal = true;
        return super._onInitTween(target, value, tween);
    }
}

