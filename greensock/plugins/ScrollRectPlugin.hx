package com.greensock.plugins;

import com.greensock.TweenLite;
import flash.display.DisplayObject;
import flash.geom.Rectangle;

class ScrollRectPlugin extends TweenPlugin
{
    
    public static inline var API : Float = 2;
    
    
    private var _target : DisplayObject;
    
    private var _rect : Rectangle;
    
    public function new()
    {
        super("scrollRect");
    }
    
    override public function setRatio(v : Float) : Void
    {
        super.setRatio(v);
        _target.scrollRect = _rect;
    }
    
    override public function _onInitTween(target : Dynamic, value : Dynamic, tween : TweenLite) : Bool
    {
        var p : Dynamic = null;
        var r : Rectangle = null;
        if (!(Std.is(target, DisplayObject)))
        {
            return false;
        }
        _target = try cast(target, DisplayObject) catch(e:Dynamic) null;
        if (_target.scrollRect != null)
        {
            _rect = _target.scrollRect;
        }
        else
        {
            r = _target.getBounds(_target);
            _rect = new Rectangle(0, 0, r.width + r.x, r.height + r.y);
        }
        for (p in Reflect.fields(value))
        {
            _addTween(_rect, p, Reflect.field(_rect, Std.string(p)), Reflect.field(value, Std.string(p)), "scrollRect");
        }
        return true;
    }
}

