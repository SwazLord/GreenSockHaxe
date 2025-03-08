package com.greensock.motionPaths;

import flash.display.Shape;
import flash.events.Event;

class MotionPath extends Shape
{
    public var targets(get, never) : Array<Dynamic>;
    public var rawProgress(get, set) : Float;
    public var followers(get, never) : Array<Dynamic>;
    public var progress(get, set) : Float;

    
    private static var _RAD2DEG : Float = 180 / Math.PI;
    
    private static var _DEG2RAD : Float = Math.PI / 180;
    
    
    private var _progress : Float;
    
    private var _scaleMode : String;
    
    private var _redrawLine : Bool;
    
    private var _rawProgress : Float;
    
    private var _caps : String;
    
    private var _lineAlpha : Float;
    
    private var _joints : String;
    
    private var _miterLimit : Float;
    
    private var _color : Int;
    
    private var _pixelHinting : Bool;
    
    private var _thickness : Float;
    
    private var _rootFollower : PathFollower;
    
    public function new()
    {
        super();
        _progress = _rawProgress = 0;
        lineStyle(1, 6710886, 1, false, "none", null, null, 3, true);
        this.addEventListener(Event.ADDED_TO_STAGE, onAddedToStage, false, 0, true);
    }
    
    override private function set_y(value : Float) : Float
    {
        super.y = value;
        update();
        return value;
    }
    
    private function get_targets() : Array<Dynamic>
    {
        var a : Array<Dynamic> = [];
        var cnt : Int = 0;
        var f : PathFollower = _rootFollower;
        while (f)
        {
            var _loc4_ : Dynamic = cnt++;
            Reflect.setField(a, Std.string(_loc4_), f.target);
            f = f.cachedNext;
        }
        return a;
    }
    
    private function get_rawProgress() : Float
    {
        return _rawProgress;
    }
    
    public function renderObjectAt(target : Dynamic, progress : Float, autoRotate : Bool = false, rotationOffset : Float = 0) : Void
    {
    }
    
    override private function set_width(value : Float) : Float
    {
        super.width = value;
        update();
        return value;
    }
    
    public function getFollower(target : Dynamic) : PathFollower
    {
        if (Std.is(target, PathFollower))
        {
            return try cast(target, PathFollower) catch(e:Dynamic) null;
        }
        var f : PathFollower = _rootFollower;
        while (f)
        {
            if (f.target == target)
            {
                return f;
            }
            f = f.cachedNext;
        }
        return null;
    }
    
    private function _normalize(num : Float) : Float
    {
        if (num > 1)
        {
            num -= as3hx.Compat.parseInt(num);
        }
        else if (num < 0)
        {
            num -= as3hx.Compat.parseInt(num) - 1;
        }
        return num;
    }
    
    public function lineStyle(thickness : Float = 1, color : Int = 6710886, alpha : Float = 1, pixelHinting : Bool = false, scaleMode : String = "none", caps : String = null, joints : String = null, miterLimit : Float = 3, skipRedraw : Bool = false) : Void
    {
        _thickness = thickness;
        _color = color;
        _lineAlpha = alpha;
        _pixelHinting = pixelHinting;
        _scaleMode = scaleMode;
        _caps = caps;
        _joints = joints;
        _miterLimit = miterLimit;
        _redrawLine = true;
        if (!skipRedraw)
        {
            update();
        }
    }
    
    override private function set_scaleY(value : Float) : Float
    {
        super.scaleY = value;
        update();
        return value;
    }
    
    public function removeAllFollowers() : Void
    {
        var next : PathFollower = null;
        var f : PathFollower = _rootFollower;
        while (f)
        {
            next = f.cachedNext;
            f.cachedNext = f.cachedPrev = null;
            f.path = null;
            f = next;
        }
        _rootFollower = null;
    }
    
    private function onAddedToStage(event : Event) : Void
    {
        update();
    }
    
    override private function set_scaleX(value : Float) : Float
    {
        super.scaleX = value;
        update();
        return value;
    }
    
    private function get_followers() : Array<Dynamic>
    {
        var a : Array<Dynamic> = [];
        var cnt : Int = 0;
        var f : PathFollower = _rootFollower;
        while (f)
        {
            var _loc4_ : Dynamic = cnt++;
            Reflect.setField(a, Std.string(_loc4_), f);
            f = f.cachedNext;
        }
        return a;
    }
    
    override private function get_height() : Float
    {
        return super.height;
    }
    
    private function get_progress() : Float
    {
        return _progress;
    }
    
    public function removeFollower(target : Dynamic) : Void
    {
        var f : PathFollower = getFollower(target);
        if (f == null)
        {
            return;
        }
        if (f.cachedNext)
        {
            f.cachedNext.cachedPrev = f.cachedPrev;
        }
        if (f.cachedPrev)
        {
            f.cachedPrev.cachedNext = f.cachedNext;
        }
        else if (_rootFollower == f)
        {
            _rootFollower = f.cachedNext;
        }
        f.cachedNext = f.cachedPrev = null;
        f.path = null;
    }
    
    override private function get_width() : Float
    {
        return super.width;
    }
    
    public function update(event : Event = null) : Void
    {
    }
    
    override private function get_scaleX() : Float
    {
        return super.scaleX;
    }
    
    override private function get_scaleY() : Float
    {
        return super.scaleY;
    }
    
    private function set_progress(value : Float) : Float
    {
        if (value > 1)
        {
            _rawProgress = value;
            value -= as3hx.Compat.parseInt(value);
            if (value == 0)
            {
                value = 1;
            }
        }
        else if (value < 0)
        {
            _rawProgress = value;
            value -= as3hx.Compat.parseInt(value) - 1;
        }
        else
        {
            _rawProgress = as3hx.Compat.parseInt(_rawProgress) + value;
        }
        var dif : Float = value - _progress;
        var f : PathFollower = _rootFollower;
        while (f)
        {
            f.cachedProgress += dif;
            f.cachedRawProgress += dif;
            if (f.cachedProgress > 1)
            {
                f.cachedProgress -= as3hx.Compat.parseInt(f.cachedProgress);
                if (f.cachedProgress == 0)
                {
                    f.cachedProgress = 1;
                }
            }
            else if (f.cachedProgress < 0)
            {
                f.cachedProgress -= as3hx.Compat.parseInt(f.cachedProgress) - 1;
            }
            f = f.cachedNext;
        }
        _progress = value;
        update();
        return value;
    }
    
    override private function set_height(value : Float) : Float
    {
        super.height = value;
        update();
        return value;
    }
    
    public function addFollower(target : Dynamic, progress : Float = 0, autoRotate : Bool = false, rotationOffset : Float = 0) : PathFollower
    {
        var f : PathFollower = getFollower(target);
        if (f == null)
        {
            f = new PathFollower(target);
        }
        f.autoRotate = autoRotate;
        f.rotationOffset = rotationOffset;
        if (f.path != this)
        {
            if (_rootFollower != null)
            {
                _rootFollower.cachedPrev = f;
            }
            f.cachedNext = _rootFollower;
            _rootFollower = f;
            f.path = this;
            f.progress = progress;
        }
        return f;
    }
    
    public function distribute(targets : Array<Dynamic> = null, min : Float = 0, max : Float = 1, autoRotate : Bool = false, rotationOffset : Float = 0) : Void
    {
        var f : PathFollower = null;
        if (targets == null)
        {
            targets = this.followers;
        }
        min = _normalize(min);
        max = _normalize(max);
        var i : Int = targets.length;
        var space : Float = (i > 1) ? as3hx.Compat.parseFloat((max - min) / (i - 1)) : 1;
        while (--i > -1)
        {
            f = getFollower(targets[i]);
            if (f == null)
            {
                f = this.addFollower(targets[i], 0, autoRotate, rotationOffset);
            }
            f.cachedProgress = f.cachedRawProgress = min + space * i;
            this.renderObjectAt(f.target, f.cachedProgress, autoRotate, rotationOffset);
        }
    }
    
    override private function set_visible(value : Bool) : Bool
    {
        super.visible = value;
        _redrawLine = true;
        update();
        return value;
    }
    
    override private function set_x(value : Float) : Float
    {
        super.x = value;
        update();
        return value;
    }
    
    private function set_rawProgress(value : Float) : Float
    {
        this.progress = value;
        return value;
    }
    
    override private function get_visible() : Bool
    {
        return super.visible;
    }
    
    override private function get_x() : Float
    {
        return super.x;
    }
    
    override private function get_y() : Float
    {
        return super.y;
    }
    
    override private function set_rotation(value : Float) : Float
    {
        super.rotation = value;
        update();
        return value;
    }
    
    override private function get_rotation() : Float
    {
        return super.rotation;
    }
}

