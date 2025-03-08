package com.greensock.plugins;

import com.greensock.TweenLite;
import flash.display.DisplayObject;
import flash.geom.ColorTransform;

class ColorTransformPlugin extends TintPlugin
{
    
    public static inline var API : Float = 2;
    
    
    public function new()
    {
        super();
        _propName = "colorTransform";
    }
    
    override public function _onInitTween(target : Dynamic, value : Dynamic, tween : TweenLite) : Bool
    {
        var start : ColorTransform = null;
        var p : Dynamic = null;
        var ratio : Float = Math.NaN;
        var end : ColorTransform = new ColorTransform();
        if (Std.is(target, DisplayObject))
        {
            _transform = cast((target), DisplayObject).transform;
            start = _transform.colorTransform;
        }
        else
        {
            if (!(Std.is(target, ColorTransform)))
            {
                return false;
            }
            start = try cast(target, ColorTransform) catch(e:Dynamic) null;
        }
        if (Std.is(value, ColorTransform))
        {
            end.concat(value);
        }
        else
        {
            end.concat(start);
        }
        for (p in Reflect.fields(value))
        {
            if (p == "tint" || p == "color")
            {
                if (Reflect.field(value, Std.string(p)) != null)
                {
                    end.color = as3hx.Compat.parseInt(Reflect.field(value, Std.string(p)));
                }
            }
            else if (!(p == "tintAmount" || p == "exposure" || p == "brightness"))
            {
                Reflect.setField(end, Std.string(p), Reflect.field(value, Std.string(p)));
            }
        }
        if (!(Std.is(value, ColorTransform)))
        {
            if (!Math.isNaN(value.tintAmount))
            {
                ratio = value.tintAmount / (1 - (end.redMultiplier + end.greenMultiplier + end.blueMultiplier) / 3);
                end.redOffset *= ratio;
                end.greenOffset *= ratio;
                end.blueOffset *= ratio;
                end.redMultiplier = end.greenMultiplier = end.blueMultiplier = 1 - value.tintAmount;
            }
            else if (!Math.isNaN(value.exposure))
            {
                end.redOffset = end.greenOffset = end.blueOffset = 255 * (value.exposure - 1);
                end.redMultiplier = end.greenMultiplier = end.blueMultiplier = 1;
            }
            else if (!Math.isNaN(value.brightness))
            {
                end.redOffset = end.greenOffset = end.blueOffset = Math.max(0, (value.brightness - 1) * 255);
                end.redMultiplier = end.greenMultiplier = end.blueMultiplier = 1 - Math.abs(value.brightness - 1);
            }
        }
        _init(start, end);
        return true;
    }
}

