package com.greensock.plugins;

import com.greensock.TweenLite;
import com.greensock.core.PropTween;
import flash.display.DisplayObject;
import flash.geom.ColorTransform;
import flash.geom.Transform;

class TintPlugin extends TweenPlugin
{
    
    private static var _props : Array<Dynamic> = ["redMultiplier", "greenMultiplier", "blueMultiplier", "alphaMultiplier", "redOffset", "greenOffset", "blueOffset", "alphaOffset"];
    
    public static inline var API : Float = 2;
    
    
    private var _transform : Transform;
    
    public function new()
    {
        super("tint,colorTransform,removeTint");
    }
    
    override public function setRatio(v : Float) : Void
    {
        var ct : ColorTransform = _transform.colorTransform;
        var pt : PropTween = _firstPT;
        while (pt)
        {
            ct[pt.p] = pt.c * v + pt.s;
            pt = pt._next;
        }
        _transform.colorTransform = ct;
    }
    
    override public function _onInitTween(target : Dynamic, value : Dynamic, tween : TweenLite) : Bool
    {
        if (!(Std.is(target, DisplayObject)))
        {
            return false;
        }
        var end : ColorTransform = new ColorTransform();
        if (value != null && tween.vars.removeTint != true)
        {
            end.color = as3hx.Compat.parseInt(value);
        }
        _transform = cast((target), DisplayObject).transform;
        var ct : ColorTransform = _transform.colorTransform;
        end.alphaMultiplier = ct.alphaMultiplier;
        end.alphaOffset = ct.alphaOffset;
        _init(ct, end);
        return true;
    }
    
    public function _init(start : ColorTransform, end : ColorTransform) : Void
    {
        var p : String = null;
        var i : Int = _props.length;
        while (--i > -1)
        {
            p = _props[i];
            if (Reflect.field(start, p) != Reflect.field(end, p))
            {
                _addTween(start, p, Reflect.field(start, p), Reflect.field(end, p), "tint");
            }
        }
    }
}

