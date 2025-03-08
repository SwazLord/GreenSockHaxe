package com.greensock.plugins;

import com.greensock.TweenLite;
import flash.display.DisplayObject;

class CacheAsBitmapPlugin extends TweenPlugin
{
    
    public static inline var API : Float = 2;
    
    
    private var _target : DisplayObject;
    
    private var _initVal : Bool;
    
    private var _cacheAsBitmap : Bool;
    
    private var _tween : TweenLite;
    
    public function new()
    {
        super("cacheAsBitmap");
    }
    
    override public function setRatio(v : Float) : Void
    {
        if (v == 1 && _tween._duration == _tween._time && _tween.data != "isFromStart" || v == 0 && _tween._time == 0)
        {
            _target.cacheAsBitmap = _initVal;
        }
        else if (_target.cacheAsBitmap != _cacheAsBitmap)
        {
            _target.cacheAsBitmap = _cacheAsBitmap;
        }
    }
    
    override public function _onInitTween(target : Dynamic, value : Dynamic, tween : TweenLite) : Bool
    {
        _target = try cast(target, DisplayObject) catch(e:Dynamic) null;
        _tween = tween;
        _initVal = _target.cacheAsBitmap;
        _cacheAsBitmap = cast(value, Bool);
        return true;
    }
}

