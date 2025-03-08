package com.greensock.plugins;

import com.greensock.TweenLite;

class SetActualSizePlugin extends TweenPlugin
{
    
    public static inline var API : Float = 2;
    
    
    private var _setWidth : Bool;
    
    public var width : Float;
    
    public var height : Float;
    
    private var _hasSetSize : Bool;
    
    private var _setHeight : Bool;
    
    private var _target : Dynamic;
    
    public function new()
    {
        super("setActualSize,setSize,width,height,scaleX,scaleY");
    }
    
    override public function _kill(lookup : Dynamic) : Bool
    {
        if (Lambda.has(lookup, "width") || Lambda.has(lookup, "scaleX"))
        {
            _setWidth = false;
        }
        if (Lambda.has(lookup, "height") || Lambda.has(lookup, "scaleY"))
        {
            _setHeight = false;
        }
        return super._kill(lookup);
    }
    
    override public function setRatio(v : Float) : Void
    {
        super.setRatio(v);
        if (_hasSetSize)
        {
            _target.setActualSize(!!(_setWidth) ? this.width : _target.width, !!(_setHeight) ? this.height : _target.height);
        }
    }
    
    override public function _onInitTween(target : Dynamic, value : Dynamic, tween : TweenLite) : Bool
    {
        _target = target;
        _hasSetSize = cast(Lambda.has(_target, "setActualSize"), Bool);
        if (Lambda.has(value, "width") && _target.width != value.width)
        {
            _addTween(!!(_hasSetSize) ? this : _target, "width", _target.width, value.width, "width", true);
            _setWidth = _hasSetSize;
        }
        if (Lambda.has(value, "height") && _target.height != value.height)
        {
            _addTween(!!(_hasSetSize) ? this : _target, "height", _target.height, value.height, "height", true);
            _setHeight = _hasSetSize;
        }
        if (_firstPT == null)
        {
            _hasSetSize = false;
        }
        return true;
    }
}

