package com.greensock.motionPaths;

import flash.display.Graphics;
import flash.events.Event;
import flash.geom.Matrix;

class RectanglePath2D extends MotionPath
{
    public var rawHeight(get, set) : Float;
    public var centerOrigin(get, set) : Bool;
    public var rawWidth(get, set) : Float;

    
    
    private var _centerOrigin : Bool;
    
    private var _rawHeight : Float;
    
    private var _rawWidth : Float;
    
    public function new(x : Float, y : Float, rawWidth : Float, rawHeight : Float, centerOrigin : Bool = false)
    {
        super();
        _rawWidth = rawWidth;
        _rawHeight = rawHeight;
        _centerOrigin = centerOrigin;
        super.x = x;
        super.y = y;
    }
    
    private function set_rawHeight(value : Float) : Float
    {
        _rawHeight = value;
        _redrawLine = true;
        update();
        return value;
    }
    
    override public function renderObjectAt(target : Dynamic, progress : Float, autoRotate : Bool = false, rotationOffset : Float = 0) : Void
    {
        var length : Float = Math.NaN;
        var xFactor : Float = Math.NaN;
        var yFactor : Float = Math.NaN;
        if (progress > 1)
        {
            progress -= as3hx.Compat.parseInt(progress);
        }
        else if (progress < 0)
        {
            progress -= as3hx.Compat.parseInt(progress) - 1;
        }
        var px : Float = !!(_centerOrigin) ? as3hx.Compat.parseFloat(_rawWidth / -2) : 0;
        var py : Float = !!(_centerOrigin) ? as3hx.Compat.parseFloat(_rawHeight / -2) : 0;
        if (progress < 0.5)
        {
            length = progress * (_rawWidth + _rawHeight) * 2;
            if (length > _rawWidth)
            {
                px += _rawWidth;
                py += length - _rawWidth;
                xFactor = 0;
                yFactor = _rawHeight;
            }
            else
            {
                px += length;
                xFactor = _rawWidth;
                yFactor = 0;
            }
        }
        else
        {
            length = (progress - 0.5) / 0.5 * (_rawWidth + _rawHeight);
            if (length <= _rawWidth)
            {
                px += _rawWidth - length;
                py += _rawHeight;
                xFactor = -_rawWidth;
                yFactor = 0;
            }
            else
            {
                py += _rawHeight - (length - _rawWidth);
                xFactor = 0;
                yFactor = -_rawHeight;
            }
        }
        var m : Matrix = this.transform.matrix;
        target.x = px * m.a + py * m.c + m.tx;
        target.y = px * m.b + py * m.d + m.ty;
        if (autoRotate)
        {
            target.rotation = Math.atan2(xFactor * m.b + yFactor * m.d, xFactor * m.a + yFactor * m.c) * _RAD2DEG + rotationOffset;
        }
    }
    
    override public function update(event : Event = null) : Void
    {
        var length : Float = Math.NaN;
        var px : Float = Math.NaN;
        var py : Float = Math.NaN;
        var xFactor : Float = Math.NaN;
        var yFactor : Float = Math.NaN;
        var g : Graphics = null;
        var xOffset : Float = !!(_centerOrigin) ? as3hx.Compat.parseFloat(_rawWidth / -2) : 0;
        var yOffset : Float = !!(_centerOrigin) ? as3hx.Compat.parseFloat(_rawHeight / -2) : 0;
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
            px = xOffset;
            py = yOffset;
            if (f.cachedProgress < 0.5)
            {
                length = f.cachedProgress * (_rawWidth + _rawHeight) * 2;
                if (length > _rawWidth)
                {
                    px += _rawWidth;
                    py += length - _rawWidth;
                    xFactor = 0;
                    yFactor = _rawHeight;
                }
                else
                {
                    px += length;
                    xFactor = _rawWidth;
                    yFactor = 0;
                }
            }
            else
            {
                length = (f.cachedProgress - 0.5) / 0.5 * (_rawWidth + _rawHeight);
                if (length <= _rawWidth)
                {
                    px += _rawWidth - length;
                    py += _rawHeight;
                    xFactor = -_rawWidth;
                    yFactor = 0;
                }
                else
                {
                    py += _rawHeight - (length - _rawWidth);
                    xFactor = 0;
                    yFactor = -_rawHeight;
                }
            }
            f.target.x = px * a + py * c + tx;
            f.target.y = px * b + py * d + ty;
            if (f.autoRotate)
            {
                f.target.rotation = Math.atan2(xFactor * b + yFactor * d, xFactor * a + yFactor * c) * _RAD2DEG + f.rotationOffset;
            }
            f = f.cachedNext;
        }
        if (_redrawLine)
        {
            g = this.graphics;
            g.clear();
            g.lineStyle(_thickness, _color, _lineAlpha, _pixelHinting, _scaleMode, _caps, _joints, _miterLimit);
            g.drawRect(xOffset, yOffset, _rawWidth, _rawHeight);
            _redrawLine = false;
        }
    }
    
    private function get_rawHeight() : Float
    {
        return _rawHeight;
    }
    
    private function set_centerOrigin(value : Bool) : Bool
    {
        _centerOrigin;
        _redrawLine = true;
        update();
        return value;
    }
    
    private function get_centerOrigin() : Bool
    {
        return _centerOrigin;
    }
    
    private function set_rawWidth(value : Float) : Float
    {
        _rawWidth = value;
        _redrawLine = true;
        update();
        return value;
    }
    
    private function get_rawWidth() : Float
    {
        return _rawWidth;
    }
}

