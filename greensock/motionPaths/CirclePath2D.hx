package com.greensock.motionPaths;

import flash.display.Graphics;
import flash.events.Event;
import flash.geom.Matrix;

class CirclePath2D extends MotionPath
{
    public var radius(get, set) : Float;

    
    
    private var _radius : Float;
    
    public function new(x : Float, y : Float, radius : Float)
    {
        super();
        _radius = radius;
        super.x = x;
        super.y = y;
    }
    
    private function get_radius() : Float
    {
        return _radius;
    }
    
    override public function renderObjectAt(target : Dynamic, progress : Float, autoRotate : Bool = false, rotationOffset : Float = 0) : Void
    {
        var angle : Float = progress * Math.PI * 2;
        var m : Matrix = this.transform.matrix;
        var px : Float = Math.cos(angle) * _radius;
        var py : Float = Math.sin(angle) * _radius;
        target.x = px * m.a + py * m.c + m.tx;
        target.y = px * m.b + py * m.d + m.ty;
        if (autoRotate)
        {
            angle += Math.PI / 2;
            px = Math.cos(angle) * _radius;
            py = Math.sin(angle) * _radius;
            target.rotation = Math.atan2(px * m.b + py * m.d, px * m.a + py * m.c) * _RAD2DEG + rotationOffset;
        }
    }
    
    override public function update(event : Event = null) : Void
    {
        var angle : Float = Math.NaN;
        var px : Float = Math.NaN;
        var py : Float = Math.NaN;
        var g : Graphics = null;
        var m : Matrix = this.transform.matrix;
        var a : Float = m.a;
        var b : Float = m.b;
        var c : Float = m.c;
        var d : Float = m.d;
        var tx : Float = m.tx;
        var ty : Float = m.ty;
        var f : PathFollower = _rootFollower;
        while (f)
        {
            angle = f.cachedProgress * Math.PI * 2;
            px = Math.cos(angle) * _radius;
            py = Math.sin(angle) * _radius;
            f.target.x = px * a + py * c + tx;
            f.target.y = px * b + py * d + ty;
            if (f.autoRotate)
            {
                angle += Math.PI / 2;
                px = Math.cos(angle) * _radius;
                py = Math.sin(angle) * _radius;
                f.target.rotation = Math.atan2(px * m.b + py * m.d, px * m.a + py * m.c) * _RAD2DEG + f.rotationOffset;
            }
            f = f.cachedNext;
        }
        if (_redrawLine)
        {
            g = this.graphics;
            g.clear();
            g.lineStyle(_thickness, _color, _lineAlpha, _pixelHinting, _scaleMode, _caps, _joints, _miterLimit);
            g.drawCircle(0, 0, _radius);
            _redrawLine = false;
        }
    }
    
    public function progressToAngle(progress : Float, useRadians : Bool = false) : Float
    {
        var revolution : Float = !!(useRadians) ? as3hx.Compat.parseFloat(Math.PI * 2) : 360;
        return progress * revolution;
    }
    
    public function angleToProgress(angle : Float, useRadians : Bool = false) : Float
    {
        var revolution : Float = !!(useRadians) ? as3hx.Compat.parseFloat(Math.PI * 2) : 360;
        if (angle < 0)
        {
            angle += (as3hx.Compat.parseInt(-angle / revolution) + 1) * revolution;
        }
        else if (angle > revolution)
        {
            angle -= as3hx.Compat.parseInt(angle / revolution) * revolution;
        }
        return angle / revolution;
    }
    
    private function set_radius(value : Float) : Float
    {
        _radius = value;
        _redrawLine = true;
        update();
        return value;
    }
    
    public function followerTween(follower : Dynamic, endAngle : Float, direction : String = "clockwise", extraRevolutions : Int = 0, useRadians : Bool = false) : String
    {
        var revolution : Float = !!(useRadians) ? as3hx.Compat.parseFloat(Math.PI * 2) : 360;
        return Std.string(anglesToProgressChange(getFollower(follower).progress * revolution, endAngle, direction, extraRevolutions, useRadians));
    }
    
    public function anglesToProgressChange(startAngle : Float, endAngle : Float, direction : String = "clockwise", extraRevolutions : Int = 0, useRadians : Bool = false) : Float
    {
        var revolution : Float = !!(useRadians) ? as3hx.Compat.parseFloat(Math.PI * 2) : 360;
        var dif : Float = endAngle - startAngle;
        if (dif < 0 && direction == "clockwise")
        {
            dif += (as3hx.Compat.parseInt(-dif / revolution) + 1) * revolution;
        }
        else if (dif > 0 && direction == "counterClockwise")
        {
            dif -= (as3hx.Compat.parseInt(dif / revolution) + 1) * revolution;
        }
        else if (direction == "shortest")
        {
            dif %= revolution;
            if (dif != dif % (revolution * 0.5))
            {
                dif = (dif < 0) ? as3hx.Compat.parseFloat(dif + revolution) : as3hx.Compat.parseFloat(dif - revolution);
            }
        }
        if (dif < 0 || dif == 0 && direction == "counterClockwise")
        {
            dif -= extraRevolutions * revolution;
        }
        else
        {
            dif += extraRevolutions * revolution;
        }
        return dif / revolution;
    }
}

