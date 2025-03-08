package com.greensock.layout;

import flash.errors.Error;
import haxe.Constraints.Function;
import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.Graphics;
import flash.display.Shape;
import flash.events.Event;
import flash.geom.Matrix;
import flash.geom.Rectangle;





class AutoFitArea extends Shape
{
    public var previewColor(get, set) : Int;
    public var preview(get, set) : Bool;

    
    private static var _bd : BitmapData;
    
    private static var _rect : Rectangle = new Rectangle(0, 0, 2800, 2800);
    
    private static var _matrix : Matrix = new Matrix();
    
    public static inline var version : Float = 2.54;
    
    
    private var _height : Float;
    
    private var _width : Float;
    
    private var _preview : Bool;
    
    private var _parent : DisplayObjectContainer;
    
    private var _previewColor : Int;
    
    private var _tweenMode : Bool;
    
    private var _hasListener : Bool;
    
    private var _rootItem : AutoFitItem;
    
    public function new(parent : DisplayObjectContainer, x : Float = 0, y : Float = 0, width : Float = 100, height : Float = 100, previewColor : Int = 16711680)
    {
        super();
        super.x = x;
        super.y = y;
        if (parent == null)
        {
            throw new Error("AutoFitArea parent cannot be null");
        }
        _parent = parent;
        _width = width;
        _height = height;
        _redraw(previewColor);
    }
    
    public static function createAround(target : DisplayObject, vars : Dynamic = null, args : Array<Dynamic> = null) : AutoFitArea
    {
        if (vars == null || as3hx.Compat.typeof(vars) == "string")
        {
            vars = {
                        scaleMode : vars || "proportionalInside",
                        hAlign : args[0] || "center",
                        vAlign : args[1] || "center",
                        crop : cast(args[2], Bool),
                        minWidth : args[3] || 0,
                        maxWidth : (!!(Math.isNaN(args[4])) ? 999999999 : args[4]),
                        minHeight : args[5] || 0,
                        maxHeight : (!!(Math.isNaN(args[6])) ? 999999999 : args[6]),
                        calculateVisible : cast(args[8], Bool)
                    };
        }
        var boundsTarget : DisplayObject = (Std.is(vars.customBoundsTarget, DisplayObject)) ? vars.customBoundsTarget : target;
        var previewColor : Int = !!(Math.isNaN(args[7])) ? ((Lambda.has(vars, "previewColor")) ? as3hx.Compat.parseInt(as3hx.Compat.parseInt(vars.previewColor)) : 16711680) : as3hx.Compat.parseInt(args[7]);
        var bounds : Rectangle = (vars.calculateVisible == true) ? getVisibleBounds(boundsTarget, target.parent) : boundsTarget.getBounds(target.parent);
        var afa : AutoFitArea = new AutoFitArea(target.parent, bounds.x, bounds.y, bounds.width, bounds.height, previewColor);
        afa.attach(target, vars);
        return afa;
    }
    
    private static function getVisibleBounds(target : DisplayObject, targetCoordinateSpace : DisplayObject) : Rectangle
    {
        if (_bd == null)
        {
            _bd = new BitmapData(2800, 2800, true, 16777215);
        }
        var msk : DisplayObject = target.mask;
        target.mask = null;
        _bd.fillRect(_rect, 16777215);
        _matrix.tx = _matrix.ty = 0;
        var offset : Rectangle = target.getBounds(targetCoordinateSpace);
        var m : Matrix = (targetCoordinateSpace == target) ? _matrix : target.transform.matrix;
        m.tx -= offset.x;
        m.ty -= offset.y;
        _bd.draw(target, m, null, "normal", _rect, false);
        var bounds : Rectangle = _bd.getColorBoundsRect(4278190080, 0, false);
        bounds.x += offset.x;
        bounds.y += offset.y;
        target.mask = msk;
        return bounds;
    }
    
    private function get_previewColor() : Int
    {
        return _previewColor;
    }
    
    public function attach(target : DisplayObject, vars : Dynamic = null, args : Array<Dynamic> = null) : Void
    {
        var shape : Shape = null;
        var bounds : Rectangle = null;
        if (target.parent != _parent)
        {
            throw new Error("The parent of the DisplayObject " + target.name + " added to AutoFitArea " + this.name + " doesn\'t share the same parent.");
        }
        if (vars == null || as3hx.Compat.typeof(vars) == "string")
        {
            vars = {
                        scaleMode : vars || "proportionalInside",
                        hAlign : args[0] || "center",
                        vAlign : args[1] || "center",
                        crop : cast(args[2], Bool),
                        minWidth : args[3] || 0,
                        maxWidth : (!!(Math.isNaN(args[4])) ? 999999999 : args[4]),
                        minHeight : args[5] || 0,
                        maxHeight : (!!(Math.isNaN(args[6])) ? 999999999 : args[6]),
                        calculateVisible : cast(args[7], Bool),
                        customAspectRatio : as3hx.Compat.parseFloat(args[8]),
                        roundPosition : cast(args[9], Bool)
                    };
        }
        release(target);
        _rootItem = new AutoFitItem(target, vars, _rootItem);
        if (vars != null && vars.crop == true)
        {
            shape = new Shape();
            bounds = this.getBounds(this);
            shape.graphics.beginFill(_previewColor, 1);
            shape.graphics.drawRect(bounds.x, bounds.y, bounds.width, bounds.height);
            shape.graphics.endFill();
            shape.visible = false;
            _parent.addChild(shape);
            _rootItem.mask = shape;
            target.mask = shape;
        }
        if (_preview)
        {
            this.preview = true;
        }
        update(null);
    }
    
    private function get_preview() : Bool
    {
        return _preview;
    }
    
    override public function addEventListener(type : String, listener : Function, useCapture : Bool = false, priority : Int = 0, useWeakReference : Bool = false) : Void
    {
        _hasListener = true;
        super.addEventListener(type, listener, useCapture, priority, useWeakReference);
    }
    
    public function update(event : Event = null) : Void
    {
        var w : Float = Math.NaN;
        var h : Float = Math.NaN;
        var tx : Float = Math.NaN;
        var ty : Float = Math.NaN;
        var target : DisplayObject = null;
        var innerBounds : Rectangle = null;
        var outerBounds : Rectangle = null;
        var tRatio : Float = Math.NaN;
        var scaleMode : String = null;
        var ratio : Float = Math.NaN;
        var angle : Float = Math.NaN;
        var sin : Float = Math.NaN;
        var cos : Float = Math.NaN;
        var m : Matrix = null;
        var wScale : Float = Math.NaN;
        var hScale : Float = Math.NaN;
        var mPrev : Matrix = null;
        var width : Float = this.width;
        var height : Float = this.height;
        var x : Float = this.x;
        var y : Float = this.y;
        var matrix : Matrix = this.transform.matrix;
        var item : AutoFitItem = _rootItem;
        while (item)
        {
            target = item.target;
            scaleMode = item.scaleMode;
            if (scaleMode != ScaleMode.NONE)
            {
                if (scaleMode != ScaleMode.HEIGHT_ONLY && target.width == 0)
                {
                    target.width = 1;
                }
                if (scaleMode != ScaleMode.WIDTH_ONLY && target.height == 0)
                {
                    target.height = 1;
                }
                if (item.calculateVisible)
                {
                    innerBounds = item.bounds = getVisibleBounds(item.boundsTarget, target);
                    outerBounds = getVisibleBounds(item.boundsTarget, _parent);
                }
                else
                {
                    innerBounds = item.boundsTarget.getBounds(target);
                    outerBounds = item.boundsTarget.getBounds(_parent);
                }
                tRatio = !!(item.hasCustomRatio) ? as3hx.Compat.parseFloat(item.aspectRatio) : as3hx.Compat.parseFloat(innerBounds.width / innerBounds.height);
                m = target.transform.matrix;
                if (m.b != 0 || m.a == 0 || m.d == 0)
                {
                    if (m.a == 0 || m.d == 0)
                    {
                        m = target.transform.matrix = item.matrix;
                    }
                    else
                    {
                        mPrev = item.matrix;
                        mPrev.a = m.a;
                        mPrev.b = m.b;
                        mPrev.c = m.c;
                        mPrev.d = m.d;
                        mPrev.tx = m.tx;
                        mPrev.ty = m.ty;
                    }
                    angle = Math.atan2(m.b, m.a);
                    if (m.a < 0 && m.d >= 0)
                    {
                        if (angle <= 0)
                        {
                            angle += Math.PI;
                        }
                        else
                        {
                            angle -= Math.PI;
                        }
                    }
                    sin = Math.sin(angle);
                    if (sin < 0)
                    {
                        sin = -sin;
                    }
                    cos = Math.cos(angle);
                    if (cos < 0)
                    {
                        cos = -cos;
                    }
                    tRatio = (tRatio * cos + sin) / (tRatio * sin + cos);
                }
                w = (width > item.maxWidth) ? as3hx.Compat.parseFloat(item.maxWidth) : ((width < item.minWidth) ? as3hx.Compat.parseFloat(item.minWidth) : width);
                h = (height > item.maxHeight) ? as3hx.Compat.parseFloat(item.maxHeight) : ((height < item.minHeight) ? as3hx.Compat.parseFloat(item.minHeight) : height);
                ratio = w / h;
                if (tRatio < ratio && scaleMode == ScaleMode.PROPORTIONAL_INSIDE || tRatio > ratio && scaleMode == ScaleMode.PROPORTIONAL_OUTSIDE)
                {
                    w = h * tRatio;
                    if (w == 0)
                    {
                        h = 0;
                    }
                    else if (w > item.maxWidth)
                    {
                        w = item.maxWidth;
                        h = w / tRatio;
                    }
                    else if (w < item.minWidth)
                    {
                        w = item.minWidth;
                        h = w / tRatio;
                    }
                }
                if (tRatio > ratio && scaleMode == ScaleMode.PROPORTIONAL_INSIDE || tRatio < ratio && scaleMode == ScaleMode.PROPORTIONAL_OUTSIDE)
                {
                    h = w / tRatio;
                    if (h > item.maxHeight)
                    {
                        h = item.maxHeight;
                        w = h * tRatio;
                    }
                    else if (h < item.minHeight)
                    {
                        h = item.minHeight;
                        w = h * tRatio;
                    }
                }
                if (w != 0 && h != 0)
                {
                    wScale = w / outerBounds.width;
                    hScale = h / outerBounds.height;
                }
                else
                {
                    wScale = hScale = 0;
                }
                if (scaleMode != ScaleMode.HEIGHT_ONLY)
                {
                    if (item.calculateVisible)
                    {
                        item.scaleVisibleWidth(wScale);
                    }
                    else if (m.b != 0)
                    {
                        m.a *= wScale;
                        m.c *= wScale;
                        target.transform.matrix = m;
                    }
                    else
                    {
                        target.width *= wScale;
                    }
                }
                if (scaleMode != ScaleMode.WIDTH_ONLY)
                {
                    if (item.calculateVisible)
                    {
                        item.scaleVisibleHeight(hScale);
                    }
                    else if (m.b != 0)
                    {
                        m.d *= hScale;
                        m.b *= hScale;
                        target.transform.matrix = m;
                    }
                    else
                    {
                        target.height *= hScale;
                    }
                }
            }
            if (item.hasDrawNow)
            {
                cast((target), Object).drawNow();
            }
            if (scaleMode != ScaleMode.NONE && innerBounds.x == 0 && innerBounds.y == 0)
            {
                if (scaleMode != ScaleMode.HEIGHT_ONLY)
                {
                    outerBounds.width = w;
                }
                if (scaleMode != ScaleMode.WIDTH_ONLY)
                {
                    outerBounds.height = h;
                }
            }
            else
            {
                outerBounds = !!(item.calculateVisible) ? getVisibleBounds(item.boundsTarget, _parent) : item.boundsTarget.getBounds(_parent);
            }
            tx = target.x;
            ty = target.y;
            if (item.hAlign == AlignMode.LEFT)
            {
                tx += x - outerBounds.x;
            }
            else if (item.hAlign == AlignMode.CENTER)
            {
                tx += x - outerBounds.x + (width - outerBounds.width) * 0.5;
            }
            else if (item.hAlign == AlignMode.RIGHT)
            {
                tx += x - outerBounds.x + (width - outerBounds.width);
            }
            if (item.vAlign == AlignMode.TOP)
            {
                ty += y - outerBounds.y;
            }
            else if (item.vAlign == AlignMode.CENTER)
            {
                ty += y - outerBounds.y + (height - outerBounds.height) * 0.5;
            }
            else if (item.vAlign == AlignMode.BOTTOM)
            {
                ty += y - outerBounds.y + (height - outerBounds.height);
            }
            if (item.roundPosition)
            {
                tx = tx + 0.5 >> 0;
                ty = ty + 0.5 >> 0;
            }
            target.x = tx;
            target.y = ty;
            if (item.mask)
            {
                item.mask.transform.matrix = matrix;
            }
            item = item.next;
        }
        if (_hasListener)
        {
            dispatchEvent(new Event(Event.CHANGE));
        }
    }
    
    override private function set_width(value : Float) : Float
    {
        super.width = value;
        if (!_tweenMode)
        {
            update();
        }
        return value;
    }
    
    override private function set_height(value : Float) : Float
    {
        super.height = value;
        if (!_tweenMode)
        {
            update();
        }
        return value;
    }
    
    public function release(target : DisplayObject) : Bool
    {
        var item : AutoFitItem = getItem(target);
        if (item == null)
        {
            return false;
        }
        if (item.mask != null)
        {
            if (item.mask.parent)
            {
                item.mask.parent.removeChild(item.mask);
            }
            target.mask = null;
            item.mask = null;
        }
        if (item.next)
        {
            item.next.prev = item.prev;
        }
        if (item.prev)
        {
            item.prev.next = item.next;
        }
        else if (item == _rootItem)
        {
            _rootItem = item.next;
        }
        item.next = item.prev = null;
        item.boundsTarget = null;
        item.target = null;
        return true;
    }
    
    private function set_preview(value : Bool) : Bool
    {
        var level : Int = 0;
        var index : Int = 0;
        var item : AutoFitItem = null;
        _preview = value;
        if (this.parent == _parent)
        {
            _parent.removeChild(this);
        }
        if (value)
        {
            level = (_rootItem == null) ? 0 : 999999999;
            item = _rootItem;
            while (item)
            {
                if (item.target.parent == _parent)
                {
                    index = _parent.getChildIndex(item.target);
                    if (index < level)
                    {
                        level = index;
                    }
                }
                item = item.next;
            }
            _parent.addChildAt(this, level);
            this.visible = true;
        }
        return value;
    }
    
    public function getAttachedObjects() : Array<Dynamic>
    {
        var a : Array<Dynamic> = [];
        var cnt : Int = 0;
        var item : AutoFitItem = _rootItem;
        while (item)
        {
            var _loc4_ : Dynamic = cnt++;
            Reflect.setField(a, Std.string(_loc4_), item.target);
            item = item.next;
        }
        return a;
    }
    
    override private function set_scaleX(value : Float) : Float
    {
        super.scaleX = value;
        update();
        return value;
    }
    
    private function _redraw(color : Int) : Void
    {
        _previewColor = color;
        var g : Graphics = this.graphics;
        g.clear();
        g.beginFill(_previewColor, 1);
        g.drawRect(0, 0, _width, _height);
        g.endFill();
    }
    
    private function getItem(target : DisplayObject) : AutoFitItem
    {
        var item : AutoFitItem = _rootItem;
        while (item)
        {
            if (item.target == target)
            {
                return item;
            }
            item = item.next;
        }
        return null;
    }
    
    public function disableTweenMode() : Void
    {
        _tweenMode = false;
    }
    
    public function enableTweenMode() : Void
    {
        _tweenMode = true;
    }
    
    override private function set_scaleY(value : Float) : Float
    {
        super.scaleY = value;
        update();
        return value;
    }
    
    override private function set_x(value : Float) : Float
    {
        super.x = value;
        if (!_tweenMode)
        {
            update();
        }
        return value;
    }
    
    override private function set_y(value : Float) : Float
    {
        super.y = value;
        if (!_tweenMode)
        {
            update();
        }
        return value;
    }
    
    public function destroy() : Void
    {
        var nxt : AutoFitItem = null;
        if (_preview)
        {
            this.preview = false;
        }
        var item : AutoFitItem = _rootItem;
        while (item)
        {
            nxt = item.next;
            release(item.target);
            item = nxt;
        }
        if (_bd != null)
        {
            _bd.dispose();
            _bd = null;
        }
        _parent = null;
    }
    
    override private function set_rotation(value : Float) : Float
    {
        trace("Warning: AutoFitArea instances should not be rotated.");
        return value;
    }
    
    private function set_previewColor(value : Int) : Int
    {
        _redraw(value);
        return value;
    }
}



class AutoFitItem
{
    
    
    public var matrix : Matrix;
    
    public var maxWidth : Float;
    
    public var prev : AutoFitItem;
    
    public var scaleMode : String;
    
    public var target : DisplayObject;
    
    public var aspectRatio : Float;
    
    public var minWidth : Float;
    
    public var roundPosition : Bool;
    
    public var minHeight : Float;
    
    public var hasCustomRatio : Bool;
    
    public var maxHeight : Float;
    
    public var mask : Shape;
    
    public var vAlign : String;
    
    public var next : AutoFitItem;
    
    public var hasDrawNow : Bool;
    
    public var calculateVisible : Bool;
    
    public var bounds : Rectangle;
    
    public var hAlign : String;
    
    public var boundsTarget : DisplayObject;
    
    private function new(target : DisplayObject, vars : Dynamic, next : AutoFitItem)
    {
        super();
        this.target = target;
        if (vars == null)
        {
            vars = { };
        }
        this.scaleMode = vars.scaleMode || "proportionalInside";
        this.hAlign = vars.hAlign || "center";
        this.vAlign = vars.vAlign || "center";
        this.minWidth = as3hx.Compat.parseFloat(as3hx.Compat.parseFloat(vars.minWidth)) || 0;
        this.maxWidth = !!(Math.isNaN(vars.maxWidth)) ? 999999999 : as3hx.Compat.parseFloat(as3hx.Compat.parseFloat(vars.maxWidth));
        this.minHeight = as3hx.Compat.parseFloat(as3hx.Compat.parseFloat(vars.minHeight)) || 0;
        this.maxHeight = !!(Math.isNaN(vars.maxHeight)) ? 999999999 : as3hx.Compat.parseFloat(as3hx.Compat.parseFloat(vars.maxHeight));
        this.roundPosition = cast(vars.roundPosition, Bool);
        this.boundsTarget = (Std.is(vars.customBoundsTarget, DisplayObject)) ? vars.customBoundsTarget : this.target;
        this.matrix = target.transform.matrix;
        this.calculateVisible = cast(vars.calculateVisible, Bool);
        this.hasDrawNow = this.target.exists("drawNow");
        if (this.hasDrawNow)
        {
            cast((this.target), Object).drawNow();
        }
        if (!Math.isNaN(vars.customAspectRatio))
        {
            this.aspectRatio = vars.customAspectRatio;
            this.hasCustomRatio = true;
        }
        if (next != null)
        {
            next.prev = this;
            this.next = next;
        }
    }
    
    public function scaleVisibleHeight(value : Float) : Void
    {
        var m : Matrix = this.target.transform.matrix;
        m.b *= value;
        m.d *= value;
        this.target.transform.matrix = m;
        if (value != 0)
        {
            this.matrix = m;
        }
    }
    
    public function scaleVisibleWidth(value : Float) : Void
    {
        var m : Matrix = this.target.transform.matrix;
        m.a *= value;
        m.c *= value;
        this.target.transform.matrix = m;
        if (value != 0)
        {
            this.matrix = m;
        }
    }
    
    public function setVisibleWidth(value : Float) : Void
    {
        var scale : Float = Math.NaN;
        var m : Matrix = this.target.transform.matrix;
        if (m.a == 0 && m.c == 0 || m.d == 0 && m.b == 0)
        {
            m.a = this.matrix.a;
            m.c = this.matrix.c;
        }
        var curWidth : Float = (m.a < 0) ? as3hx.Compat.parseFloat(-m.a * this.bounds.width) : as3hx.Compat.parseFloat(m.a * this.bounds.width);
        curWidth += (m.c < 0) ? -m.c * this.bounds.height : m.c * this.bounds.height;
        if (curWidth != 0)
        {
            scale = value / curWidth;
            m.a *= scale;
            m.c *= scale;
            this.target.transform.matrix = m;
            if (value != 0)
            {
                this.matrix = m;
            }
        }
    }
    
    public function setVisibleHeight(value : Float) : Void
    {
        var scale : Float = Math.NaN;
        var m : Matrix = this.target.transform.matrix;
        if (m.a == 0 && m.c == 0 || m.d == 0 && m.b == 0)
        {
            m.b = this.matrix.b;
            m.d = this.matrix.d;
        }
        var curHeight : Float = (m.b < 0) ? as3hx.Compat.parseFloat(-m.b * this.bounds.width) : as3hx.Compat.parseFloat(m.b * this.bounds.width);
        curHeight += (m.d < 0) ? -m.d * this.bounds.height : m.d * this.bounds.height;
        if (curHeight != 0)
        {
            scale = value / curHeight;
            m.b *= scale;
            m.d *= scale;
            this.target.transform.matrix = m;
            if (value != 0)
            {
                this.matrix = m;
            }
        }
    }
}
