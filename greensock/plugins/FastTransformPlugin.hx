package com.greensock.plugins;

import com.greensock.TweenLite;
import flash.display.DisplayObject;
import flash.geom.Matrix;
import flash.geom.Transform;

class FastTransformPlugin extends TweenPlugin
{
    
    public static inline var API : Float = 2;
    
    private static var _DEG2RAD : Float = Math.PI / 180;
    
    
    private var _cRotation : Float;
    
    private var _sx : Float;
    
    private var _sy : Float;
    
    private var _sRotation : Float;
    
    private var _cx : Float;
    
    private var _cy : Float;
    
    private var _tyStart : Float;
    
    private var _aStart : Float;
    
    private var _target : DisplayObject;
    
    private var _aChange : Float;
    
    private var _angleChange : Float = 0;
    
    private var _cChange : Float;
    
    private var _txChange : Float;
    
    private var _bStart : Float;
    
    private var _cScaleX : Float;
    
    private var _cScaleY : Float;
    
    private var _cStart : Float;
    
    private var _matrix : Matrix;
    
    private var _sScaleX : Float;
    
    private var _sScaleY : Float;
    
    private var _transform : Transform;
    
    private var _bChange : Float;
    
    private var _tyChange : Float;
    
    private var _dChange : Float;
    
    private var _dStart : Float;
    
    private var _txStart : Float;
    
    public function new()
    {
        super("fastTransform,x,y,scaleX,scaleY,width,height,rotation");
    }
    
    override public function setRatio(v : Float) : Void
    {
        _target.x = v * _cx + _sx;
        _target.y = v * _cy + _sy;
        _target.scaleX = v * _cScaleX + _sScaleX;
        _target.scaleY = v * _cScaleY + _sScaleY;
        _target.rotation = v * _cRotation + _sRotation;
    }
    
    override public function _onInitTween(target : Dynamic, value : Dynamic, tween : TweenLite) : Bool
    {
        _target = try cast(target, DisplayObject) catch(e:Dynamic) null;
        _sx = _target.x;
        _cx = as3hx.Compat.parseFloat(value.x - _sx) || 0;
        _sy = _target.y;
        _cy = as3hx.Compat.parseFloat(value.y - _sy) || 0;
        _sScaleX = _target.scaleX;
        _cScaleX = as3hx.Compat.parseFloat(value.scaleX - _sScaleX) || 0;
        _sScaleY = _target.scaleY;
        _cScaleY = as3hx.Compat.parseFloat(value.scaleY - _sScaleY) || 0;
        _sRotation = _target.rotation;
        _cRotation = as3hx.Compat.parseFloat(value.rotation - _sRotation) || 0;
        return true;
    }
}

