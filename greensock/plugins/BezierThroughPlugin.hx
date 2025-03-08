package com.greensock.plugins;

import com.greensock.TweenLite;

class BezierThroughPlugin extends BezierPlugin
{
    
    public static inline var API : Float = 2;
    
    
    public function new()
    {
        super();
        _propName = "bezierThrough";
    }
    
    override public function _onInitTween(target : Dynamic, value : Dynamic, tween : TweenLite) : Bool
    {
        if (Std.is(value, Array))
        {
            value = {
                        values : value
                    };
        }
        value.type = "thru";
        return super._onInitTween(target, value, tween);
    }
}

