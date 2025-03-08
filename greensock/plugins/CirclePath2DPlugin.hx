package com.greensock.plugins;

import com.greensock.TweenLite;
import com.greensock.motionPaths.CirclePath2D;
import com.greensock.motionPaths.PathFollower;
import flash.geom.Matrix;

class CirclePath2DPlugin extends TweenPlugin
{
    
    private static var _RAD2DEG : Float = 180 / Math.PI;
    
    public static inline var API : Float = 2;
    
    private static var _2PI : Float = Math.PI * 2;
    
    
    private var _start : Float;
    
    private var _autoRotate : Bool;
    
    private var _circle : CirclePath2D;
    
    private var _target : Dynamic;
    
    private var _autoRemove : Bool;
    
    private var _change : Float;
    
    private var _rotationOffset : Float;
    
    public function new()
    {
        super("circlePath2D,x,y");
    }
    
    override public function _kill(lookup : Dynamic) : Bool
    {
        if (Lambda.has(lookup, "x") || Lambda.has(lookup, "y"))
        {
            _overwriteProps = [];
        }
        return super._kill(lookup);
    }
    
    override public function setRatio(v : Float) : Void
    {
        var angle : Float = (_start + _change * v) * _2PI;
        var radius : Float = _circle.radius;
        var m : Matrix = _circle.transform.matrix;
        var px : Float = Math.cos(angle) * radius;
        var py : Float = Math.sin(angle) * radius;
        _target.x = px * m.a + py * m.c + m.tx;
        _target.y = px * m.b + py * m.d + m.ty;
        if (_autoRotate)
        {
            angle += Math.PI / 2;
            px = Math.cos(angle) * _circle.radius;
            py = Math.sin(angle) * _circle.radius;
            _target.rotation = Math.atan2(px * m.b + py * m.d, px * m.a + py * m.c) * _RAD2DEG + _rotationOffset;
        }
    }
    
    override public function _onInitTween(target : Dynamic, value : Dynamic, tween : TweenLite) : Bool
    {
        if (!(Lambda.has(value, "path")) || !(Std.is(value.path, CirclePath2D)))
        {
            trace("CirclePath2DPlugin error: invalid \'path\' property. Please define a CirclePath2D instance.");
            return false;
        }
        _target = target;
        _circle = try cast(value.path, CirclePath2D) catch(e:Dynamic) null;
        _autoRotate = cast(value.autoRotate == true, Bool);
        _rotationOffset = as3hx.Compat.parseFloat(value.rotationOffset) || 0;
        var f : PathFollower = _circle.getFollower(target);
        if (f != null && !(Lambda.has(value, "startAngle")))
        {
            _start = f.progress;
        }
        else
        {
            _start = _circle.angleToProgress(as3hx.Compat.parseFloat(value.startAngle) || 0, value.useRadians);
            _circle.renderObjectAt(_target, _start);
        }
        _change = as3hx.Compat.parseFloat(_circle.anglesToProgressChange(_circle.progressToAngle(_start), as3hx.Compat.parseFloat(value.endAngle) || 0, value.direction || "clockwise", as3hx.Compat.parseInt(value.extraRevolutions) || 0, cast(value.useRadians, Bool)));
        return true;
    }
}

