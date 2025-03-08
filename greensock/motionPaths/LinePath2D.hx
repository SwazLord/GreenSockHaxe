package com.greensock.motionPaths;

import flash.display.Graphics;
import flash.events.Event;
import flash.geom.Matrix;
import flash.geom.Point;


class LinePath2D extends MotionPath
{
    public var points(get, set) : Array<Dynamic>;
    public var totalLength(get, never) : Float;

    
    
    private var _points : Array<Dynamic>;
    
    private var _totalLength : Float;
    
    public var autoUpdatePoints : Bool;
    
    private var _hasAutoRotate : Bool;
    
    private var _first : PathPoint;
    
    private var _prevMatrix : Matrix;
    
    public function new(points : Array<Dynamic> = null, x : Float = 0, y : Float = 0, autoUpdatePoints : Bool = false)
    {
        super();
        _points = [];
        _totalLength = 0;
        this.autoUpdatePoints = autoUpdatePoints;
        if (points != null)
        {
            insertMultiplePoints(points, 0);
        }
        super.x = x;
        super.y = y;
    }
    
    private function _organize() : Void
    {
        var pp : PathPoint = null;
        _totalLength = 0;
        _hasAutoRotate = false;
        var last : Int = as3hx.Compat.parseInt(_points.length - 1);
        if (last == -1)
        {
            _first = null;
        }
        else if (last == 0)
        {
            _first = _points[0];
            _first.progress = _first.xChange = _first.yChange = _first.length = 0;
            return;
        }
        for (i in 0...last + 1)
        {
            if (_points[i] != null)
            {
                pp = _points[i];
                pp.x = pp.point.x;
                pp.y = pp.point.y;
                if (i == last)
                {
                    pp.length = 0;
                    pp.next = null;
                }
                else
                {
                    pp.next = _points[i + 1];
                    pp.xChange = pp.next.x - pp.x;
                    pp.yChange = pp.next.y - pp.y;
                    pp.length = Math.sqrt(pp.xChange * pp.xChange + pp.yChange * pp.yChange);
                    _totalLength += pp.length;
                }
            }
        }
        _first = pp = _points[0];
        var curTotal : Float = 0;
        while (pp)
        {
            pp.progress = curTotal / _totalLength;
            curTotal += pp.length;
            pp = pp.next;
        }
        _updateAngles();
    }
    
    private function set_points(value : Array<Dynamic>) : Array<Dynamic>
    {
        _points = [];
        insertMultiplePoints(value, 0);
        _redrawLine = true;
        update(null);
        return value;
    }
    
    private function _updateAngles() : Void
    {
        var m : Matrix = this.transform.matrix;
        var pp : PathPoint = _first;
        while (pp)
        {
            pp.angle = Math.atan2(pp.xChange * m.b + pp.yChange * m.d, pp.xChange * m.a + pp.yChange * m.c) * _RAD2DEG;
            pp = pp.next;
        }
        _prevMatrix = m;
    }
    
    public function getSegmentProgress(segment : Int, progress : Float) : Float
    {
        if (_first == null)
        {
            return 0;
        }
        if (_points.length <= segment)
        {
            segment = _points.length;
        }
        var pp : PathPoint = _points[segment - 1];
        return pp.progress + progress * pp.length / _totalLength;
    }
    
    public function appendMultiplePoints(points : Array<Dynamic>) : Void
    {
        insertMultiplePoints(points, _points.length);
    }
    
    override public function renderObjectAt(target : Dynamic, progress : Float, autoRotate : Bool = false, rotationOffset : Float = 0) : Void
    {
        var pathProg : Float = Math.NaN;
        var px : Float = Math.NaN;
        var py : Float = Math.NaN;
        var m : Matrix = null;
        if (progress > 1)
        {
            progress -= as3hx.Compat.parseInt(progress);
        }
        else if (progress < 0)
        {
            progress -= as3hx.Compat.parseInt(progress) - 1;
        }
        if (_first == null)
        {
            return;
        }
        var pp : PathPoint = _first;
        while (pp.next != null && pp.next.progress < progress)
        {
            pp = pp.next;
        }
        if (pp != null)
        {
            pathProg = (progress - pp.progress) / (pp.length / _totalLength);
            px = pp.x + pathProg * pp.xChange;
            py = pp.y + pathProg * pp.yChange;
            m = this.transform.matrix;
            target.x = px * m.a + py * m.c + m.tx;
            target.y = px * m.b + py * m.d + m.ty;
            if (autoRotate)
            {
                if (_prevMatrix.a != m.a || _prevMatrix.b != m.b || _prevMatrix.c != m.c || _prevMatrix.d != m.d)
                {
                    _updateAngles();
                }
                target.rotation = pp.angle + rotationOffset;
            }
        }
    }
    
    override public function update(event : Event = null) : Void
    {
        var px : Float = Math.NaN;
        var py : Float = Math.NaN;
        var pp : PathPoint = null;
        var followerProgress : Float = Math.NaN;
        var pathProg : Float = Math.NaN;
        var g : Graphics = null;
        if (_first == null || _points.length <= 1)
        {
            return;
        }
        var updatedAngles : Bool = false;
        var m : Matrix = this.transform.matrix;
        var a : Float = m.a;
        var b : Float = m.b;
        var c : Float = m.c;
        var d : Float = m.d;
        var tx : Float = m.tx;
        var ty : Float = m.ty;
        var f : PathFollower = _rootFollower;
        if (autoUpdatePoints)
        {
            pp = _first;
            while (pp)
            {
                if (pp.point.x != pp.x || pp.point.y != pp.y)
                {
                    _organize();
                    _redrawLine = true;
                    update();
                    return;
                }
                pp = pp.next;
            }
        }
        while (f)
        {
            followerProgress = f.cachedProgress;
            pp = _first;
            while (pp != null && pp.next.progress < followerProgress)
            {
                pp = pp.next;
            }
            if (pp != null)
            {
                pathProg = (followerProgress - pp.progress) / (pp.length / _totalLength);
                px = pp.x + pathProg * pp.xChange;
                py = pp.y + pathProg * pp.yChange;
                f.target.x = px * a + py * c + tx;
                f.target.y = px * b + py * d + ty;
                if (f.autoRotate)
                {
                    if (!updatedAngles && (_prevMatrix.a != a || _prevMatrix.b != b || _prevMatrix.c != c || _prevMatrix.d != d))
                    {
                        _updateAngles();
                        updatedAngles = true;
                    }
                    f.target.rotation = pp.angle + f.rotationOffset;
                }
            }
            f = f.cachedNext;
        }
        if (_redrawLine)
        {
            g = this.graphics;
            g.clear();
            g.lineStyle(_thickness, _color, _lineAlpha, _pixelHinting, _scaleMode, _caps, _joints, _miterLimit);
            pp = _first;
            g.moveTo(pp.x, pp.y);
            while (pp)
            {
                g.lineTo(pp.x, pp.y);
                pp = pp.next;
            }
            _redrawLine = false;
        }
    }
    
    public function appendPoint(point : Point) : Void
    {
        _insertPoint(point, _points.length, false);
    }
    
    public function insertPoint(point : Point, index : Int = 0) : Void
    {
        _insertPoint(point, index, false);
    }
    
    private function _insertPoint(point : Point, index : Int, skipOrganize : Bool) : Void
    {
        as3hx.Compat.arraySplice(_points, index, 0, [new PathPoint(point)]);
        if (!skipOrganize)
        {
            _organize();
        }
    }
    
    public function snap(target : Dynamic, autoRotate : Bool = false, rotationOffset : Float = 0) : PathFollower
    {
        return this.addFollower(target, getClosestProgress(target), autoRotate, rotationOffset);
    }
    
    private function get_points() : Array<Dynamic>
    {
        var a : Array<Dynamic> = [];
        var l : Int = _points.length;
        for (i in 0...l)
        {
            a[i] = _points[i].point;
        }
        return a;
    }
    
    public function insertMultiplePoints(points : Array<Dynamic>, index : Int = 0) : Void
    {
        var l : Int = points.length;
        for (i in 0...l)
        {
            _insertPoint(points[i], index + i, true);
        }
        _organize();
    }
    
    public function removePointByIndex(index : Int) : Void
    {
        _points.splice(index, 1);
        _organize();
    }
    
    public function getClosestProgress(target : Dynamic) : Float
    {
        var closestPath : PathPoint = null;
        var dxTarg : Float = Math.NaN;
        var dyTarg : Float = Math.NaN;
        var dxNext : Float = Math.NaN;
        var dyNext : Float = Math.NaN;
        var dTarg : Float = Math.NaN;
        var angle : Float = Math.NaN;
        var next : PathPoint = null;
        var curDist : Float = Math.NaN;
        if (_first == null || _points.length == 1)
        {
            return 0;
        }
        var closest : Float = 9999999999;
        var length : Float = 0;
        var halfPI : Float = Math.PI / 2;
        var xTarg : Float = target.x;
        var yTarg : Float = target.y;
        var pp : PathPoint = _first;
        while (pp)
        {
            dxTarg = xTarg - pp.x;
            dyTarg = yTarg - pp.y;
            next = (pp.next != null) ? pp.next : pp;
            dxNext = next.x - pp.x;
            dyNext = next.y - pp.y;
            dTarg = Math.sqrt(dxTarg * dxTarg + dyTarg * dyTarg);
            angle = Math.atan2(dyTarg, dxTarg) - Math.atan2(dyNext, dxNext);
            if (angle < 0)
            {
                angle = -angle;
            }
            if (angle > halfPI)
            {
                if (dTarg < closest)
                {
                    closest = dTarg;
                    closestPath = pp;
                    length = 0;
                }
            }
            else
            {
                curDist = Math.cos(angle) * dTarg;
                if (curDist < 0)
                {
                    curDist = -curDist;
                }
                if (curDist > pp.length)
                {
                    dxNext = xTarg - next.x;
                    dyNext = yTarg - next.y;
                    curDist = Math.sqrt(dxNext * dxNext + dyNext * dyNext);
                    if (curDist < closest)
                    {
                        closest = curDist;
                        closestPath = pp;
                        length = pp.length;
                    }
                }
                else
                {
                    curDist = Math.sin(angle) * dTarg;
                    if (curDist < closest)
                    {
                        closest = curDist;
                        closestPath = pp;
                        length = Math.cos(angle) * dTarg;
                    }
                }
            }
            pp = pp.next;
        }
        return closestPath.progress + length / _totalLength;
    }
    
    private function get_totalLength() : Float
    {
        return _totalLength;
    }
    
    public function removePoint(point : Point) : Void
    {
        var i : Int = _points.length;
        while (--i > -1)
        {
            if (_points[i].point == point)
            {
                _points.splice(i, 1);
            }
        }
        _organize();
    }
    
    public function getSegment(progress : Float = Math.NaN) : Int
    {
        if (!(progress || progress == 0))
        {
            progress = _progress;
        }
        if (_points.length < 2)
        {
            return 0;
        }
        var l : Int = _points.length;
        for (i in 1...l)
        {
            if (progress < (try cast(_points[i], PathPoint) catch(e:Dynamic) null).progress)
            {
                return i;
            }
        }
        return as3hx.Compat.parseInt(_points.length - 1);
    }
}



class PathPoint
{
    
    
    public var next : PathPoint;
    
    public var length : Float;
    
    public var y : Float;
    
    public var yChange : Float;
    
    public var progress : Float;
    
    public var xChange : Float;
    
    public var angle : Float;
    
    public var point : Point;
    
    public var x : Float;
    
    private function new(point : Point)
    {
        super();
        this.x = point.x;
        this.y = point.y;
        this.point = point;
    }
}
