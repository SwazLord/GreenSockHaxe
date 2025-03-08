package com.greensock.plugins;

import haxe.Constraints.Function;
import com.greensock.TweenLite;
import flash.display.DisplayObject;
import flash.events.Event;

class OnCompleteRenderPlugin extends TweenPlugin
{
    
    public static inline var API : Float = 2;
    
    
    private var _target : DisplayObject;
    
    private var _func : Function;
    
    private var _tween : TweenLite;
    
    public function new()
    {
        super("onCompleteRender,onCompleteRenderParams");
        TweenLite._plugins.onCompleteRenderParams = OnCompleteRenderPlugin;
    }
    
    private function _enterFrameHandler(event : Event) : Void
    {
        _target.removeEventListener("enterFrame", _enterFrameHandler);
        Reflect.callMethod(null, _func, _tween.vars.onCompleteRenderParams);
    }
    
    override public function setRatio(v : Float) : Void
    {
        if (v == 1 || v == 0)
        {
            if (_func != null)
            {
                if (_tween._time == _tween._duration && _tween.data != "isFromStart")
                {
                    _target.addEventListener("enterFrame", _enterFrameHandler, false, 100, true);
                }
            }
        }
    }
    
    override public function _onInitTween(target : Dynamic, value : Dynamic, tween : TweenLite) : Bool
    {
        if (Std.is(value, Array))
        {
            return true;
        }
        if (!(Std.is(target, DisplayObject)))
        {
            trace("Error: onCompleteRender was used on a tween whose target is not a DisplayObject");
            return false;
        }
        _target = try cast(target, DisplayObject) catch(e:Dynamic) null;
        _func = value;
        _tween = tween;
        return true;
    }
}

