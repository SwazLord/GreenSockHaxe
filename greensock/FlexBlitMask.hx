package com.greensock;

import flash.errors.Error;
import flash.display.BitmapData;
import flash.display.BlendMode;
import flash.display.DisplayObject;
import flash.display.Graphics;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.ColorTransform;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.geom.Transform;
import mx.core.UIComponent;

class FlexBlitMask extends UIComponent
{
    public var scrollX(get, set) : Float;
    public var scrollY(get, set) : Float;
    public var target(get, set) : DisplayObject;
    public var fillColor(get, set) : Int;
    public var wrap(get, set) : Bool;
    public var autoUpdate(get, set) : Bool;
    public var bitmapMode(get, set) : Bool;
    public var smoothing(get, set) : Bool;
    public var wrapOffsetX(get, set) : Float;
    public var wrapOffsetY(get, set) : Float;

    
    private static var _colorTransform : ColorTransform = new ColorTransform();
    
    private static var _mouseEvents : Array<Dynamic> = [MouseEvent.CLICK, MouseEvent.DOUBLE_CLICK, MouseEvent.MOUSE_DOWN, MouseEvent.MOUSE_MOVE, MouseEvent.MOUSE_OUT, MouseEvent.MOUSE_OVER, MouseEvent.MOUSE_UP, MouseEvent.MOUSE_WHEEL, MouseEvent.ROLL_OUT, MouseEvent.ROLL_OVER, "gesturePressAndTap", "gesturePan", "gestureRotate", "gestureSwipe", "gestureZoom", "gestureTwoFingerTap", "touchBegin", "touchEnd", "touchMove", "touchOut", "touchOver", "touchRollOut", "touchRollOver", "touchTap"];
    
    private static var _drawRect : Rectangle = new Rectangle();
    
    private static var _emptyArray : Array<Dynamic> = [];
    
    private static var _destPoint : Point = new Point();
    
    private static var _tempMatrix : Matrix = new Matrix();
    
    private static var _sliceRect : Rectangle = new Rectangle();
    
    public static var version : Float = 0.6;
    
    private static var _tempContainer : Sprite = new Sprite();
    
    
    private var _bitmapMode : Bool;
    
    private var _fillColor : Int;
    
    private var _grid : Array<Dynamic>;
    
    private var _wrap : Bool;
    
    private var _height : Float;
    
    private var _scaleX : Float;
    
    private var _scaleY : Float;
    
    private var _prevMatrix : Matrix;
    
    private var _columns : Int;
    
    private var _target : DisplayObject;
    
    private var _clipRect : Rectangle;
    
    private var _prevRotation : Float;
    
    private var _rows : Int;
    
    private var _wrapOffsetX : Float = 0;
    
    private var _wrapOffsetY : Float = 0;
    
    private var _width : Float;
    
    private var _gridSize : Int = 2879;
    
    private var _bounds : Rectangle;
    
    private var _bd : BitmapData;
    
    private var _transform : Transform;
    
    private var _smoothing : Bool;
    
    private var _autoUpdate : Bool;
    
    public function new(target : DisplayObject = null, x : Float = 0, y : Float = 0, width : Float = 100, height : Float = 100, smoothing : Bool = false, autoUpdate : Bool = true, fillColor : Int = 0, wrap : Bool = false)
    {
        super();
        if (width < 0 || height < 0)
        {
            throw new Error("A FlexBlitMask cannot have a negative width or height.");
        }
        _width = width;
        _height = height;
        _scaleX = _scaleY = 1;
        _smoothing = smoothing;
        _fillColor = fillColor;
        _autoUpdate = autoUpdate;
        _wrap = wrap;
        _grid = [];
        _bounds = new Rectangle();
        if (_smoothing)
        {
            super.x = x;
            super.y = y;
        }
        else
        {
            super.x = (x < 0) ? as3hx.Compat.parseFloat(x - 0.5 >> 0) : as3hx.Compat.parseFloat(x + 0.5 >> 0);
            super.y = (y < 0) ? as3hx.Compat.parseFloat(y - 0.5 >> 0) : as3hx.Compat.parseFloat(y + 0.5 >> 0);
        }
        _clipRect = new Rectangle(0, 0, _gridSize + 1, _gridSize + 1);
        _bd = new BitmapData(width + 1, height + 1, true, _fillColor);
        _bitmapMode = true;
        this.target = target;
    }
    
    override private function set_rotation(value : Float) : Float
    {
        if (value != 0)
        {
            throw new Error("Cannot set the rotation of a FlexBlitMask to a non-zero number. FlexBlitMasks should remain unrotated.");
        }
        return value;
    }
    
    public function dispose() : Void
    {
        if (_bd == null)
        {
            return;
        }
        _disposeGrid();
        _bd.dispose();
        _bd = null;
        this.bitmapMode = false;
        this.autoUpdate = false;
        if (_target != null)
        {
            _target.mask = null;
        }
        if (this.parent != null)
        {
            if (this.parent.exists("removeElement"))
            {
                cast((this.parent), Object).removeElement(this);
            }
            else
            {
                this.parent.removeChild(this);
            }
        }
        this.target = null;
    }
    
    override private function get_height() : Float
    {
        return _height;
    }
    
    private function get_scrollX() : Float
    {
        return (super.x - _bounds.x) / (_bounds.width - _width);
    }
    
    private function get_scrollY() : Float
    {
        return (super.y - _bounds.y) / (_bounds.height - _height);
    }
    
    private function set_target(value : DisplayObject) : DisplayObject
    {
        var i : Int = 0;
        if (_target != value)
        {
            i = _mouseEvents.length;
            if (_target != null)
            {
                while (--i > -1)
                {
                    _target.removeEventListener(_mouseEvents[i], _mouseEventPassthrough);
                }
            }
            _target = value;
            if (_target != null)
            {
                i = _mouseEvents.length;
                while (--i > -1)
                {
                    _target.addEventListener(_mouseEvents[i], _mouseEventPassthrough, false, 0, true);
                }
                _prevMatrix = null;
                _transform = _target.transform;
                _bitmapMode = !_bitmapMode;
                this.bitmapMode = !_bitmapMode;
            }
            else
            {
                _bounds = new Rectangle();
            }
        }
        return value;
    }
    
    private function set_fillColor(value : Int) : Int
    {
        if (_fillColor != value)
        {
            _fillColor = value;
            if (_bitmapMode)
            {
                _render();
            }
        }
        return value;
    }
    
    private function _disposeGrid() : Void
    {
        var j : Int = 0;
        var r : Array<Dynamic> = null;
        var i : Int = _grid.length;
        while (--i > -1)
        {
            r = _grid[i];
            j = r.length;
            while (--j > -1)
            {
                cast((r[j]), BitmapData).dispose();
            }
        }
    }
    
    override private function get_scaleY() : Float
    {
        return 1;
    }
    
    private function get_wrap() : Bool
    {
        return _wrap;
    }
    
    override private function get_scaleX() : Float
    {
        return 1;
    }
    
    public function normalizePosition() : Void
    {
        var wrapWidth : Int = 0;
        var wrapHeight : Int = 0;
        var offsetX : Float = Math.NaN;
        var offsetY : Float = Math.NaN;
        if (_target != null && _bounds != null)
        {
            wrapWidth = as3hx.Compat.parseInt(_bounds.width + _wrapOffsetX + 0.5) >> 0;
            wrapHeight = as3hx.Compat.parseInt(_bounds.height + _wrapOffsetY + 0.5) >> 0;
            offsetX = (_bounds.x - this.x) % wrapWidth;
            offsetY = (_bounds.y - this.y) % wrapHeight;
            if (offsetX > (_width + _wrapOffsetX) / 2)
            {
                offsetX -= wrapWidth;
            }
            else if (offsetX < (_width + _wrapOffsetX) / -2)
            {
                offsetX += wrapWidth;
            }
            if (offsetY > (_height + _wrapOffsetY) / 2)
            {
                offsetY -= wrapHeight;
            }
            else if (offsetY < (_height + _wrapOffsetY) / -2)
            {
                offsetY += wrapHeight;
            }
            _target.x += this.x + offsetX - _bounds.x;
            _target.y += this.y + offsetY - _bounds.y;
        }
    }
    
    private function set_scrollY(value : Float) : Float
    {
        var dif : Float = Math.NaN;
        if (_target != null && _target.parent)
        {
            _bounds = _target.getBounds(_target.parent);
            dif = super.y - (_bounds.height - _height) * value - _bounds.y;
            _target.y += dif;
            _bounds.y += dif;
            if (_bitmapMode)
            {
                _render();
            }
        }
        return value;
    }
    
    public function enableBitmapMode(event : Event = null) : Void
    {
        this.bitmapMode = true;
    }
    
    override private function set_height(value : Float) : Float
    {
        setSize(_width, value);
        return value;
    }
    
    override private function measure() : Void
    {
        var bounds : Rectangle = null;
        if (this.parent)
        {
            bounds = this.getBounds(this.parent);
            super.width = bounds.width;
            super.height = bounds.height;
        }
        this.explicitWidth = _width;
        this.explicitHeight = _height;
        super.measure();
    }
    
    private function get_autoUpdate() : Bool
    {
        return _autoUpdate;
    }
    
    private function _mouseEventPassthrough(event : MouseEvent) : Void
    {
        if (this.mouseEnabled && (!_bitmapMode || this.hitTestPoint(event.stageX, event.stageY, false)))
        {
            dispatchEvent(event);
        }
    }
    
    private function set_scrollX(value : Float) : Float
    {
        var dif : Float = Math.NaN;
        if (_target != null && _target.parent)
        {
            _bounds = _target.getBounds(_target.parent);
            dif = super.x - (_bounds.width - _width) * value - _bounds.x;
            _target.x += dif;
            _bounds.x += dif;
            if (_bitmapMode)
            {
                _render();
            }
        }
        return value;
    }
    
    private function get_bitmapMode() : Bool
    {
        return _bitmapMode;
    }
    
    private function get_smoothing() : Bool
    {
        return _smoothing;
    }
    
    public function disableBitmapMode(event : Event = null) : Void
    {
        this.bitmapMode = false;
    }
    
    private function get_wrapOffsetX() : Float
    {
        return _wrapOffsetX;
    }
    
    private function get_wrapOffsetY() : Float
    {
        return _wrapOffsetY;
    }
    
    override private function get_y() : Float
    {
        return super.y;
    }
    
    public function setSize(width : Float, height : Float) : Void
    {
        if (_width == width && _height == height)
        {
            return;
        }
        if (width < 0 || height < 0)
        {
            throw new Error("A FlexBlitMask cannot have a negative width or height.");
        }
        if (_bd != null)
        {
            _bd.dispose();
        }
        _width = width;
        _height = height;
        _bd = new BitmapData(width + 1, height + 1, true, _fillColor);
        _render();
    }
    
    override private function get_x() : Float
    {
        return super.x;
    }
    
    private function get_target() : DisplayObject
    {
        return _target;
    }
    
    private function set_wrap(value : Bool) : Bool
    {
        if (_wrap != value)
        {
            _wrap = value;
            if (_bitmapMode)
            {
                _render();
            }
        }
        return value;
    }
    
    override private function set_width(value : Float) : Float
    {
        setSize(value, _height);
        return value;
    }
    
    override private function set_scaleX(value : Float) : Float
    {
        var oldScaleX : Float = _scaleX;
        _scaleX = value;
        setSize(_width * (_scaleX / oldScaleX), _height);
        return value;
    }
    
    private function get_fillColor() : Int
    {
        return _fillColor;
    }
    
    override private function set_scaleY(value : Float) : Float
    {
        var oldScaleY : Float = _scaleY;
        _scaleY = value;
        setSize(_width, _height * (_scaleY / oldScaleY));
        return value;
    }
    
    override public function setActualSize(w : Float, h : Float) : Void
    {
        setSize(w, h);
        super.setActualSize(w, h);
    }
    
    private function _render(xOffset : Float = 0, yOffset : Float = 0, clear : Bool = true, limitRecursion : Bool = false) : Void
    {
        var xDestReset : Float = Math.NaN;
        var xSliceReset : Float = Math.NaN;
        var columnReset : Int = 0;
        var bd : BitmapData = null;
        if (clear)
        {
            _sliceRect.x = _sliceRect.y = 0;
            _sliceRect.width = _width + 1;
            _sliceRect.height = _height + 1;
            _bd.fillRect(_sliceRect, _fillColor);
            if (_bitmapMode && _target != null)
            {
                this.filters = _target.filters;
                this.transform.colorTransform = _transform.colorTransform;
            }
            else
            {
                this.filters = _emptyArray;
                this.transform.colorTransform = _colorTransform;
            }
        }
        if (_bd == null)
        {
            return;
        }
        if (_rows == 0)
        {
            _captureTargetBitmap();
        }
        var x : Float = super.x + xOffset;
        var y : Float = super.y + yOffset;
        var wrapWidth : Int = as3hx.Compat.parseInt(_bounds.width + _wrapOffsetX + 0.5) >> 0;
        var wrapHeight : Int = as3hx.Compat.parseInt(_bounds.height + _wrapOffsetY + 0.5) >> 0;
        var g : Graphics = this.graphics;
        if (_bounds.width == 0 || _bounds.height == 0 || _wrap && (wrapWidth == 0 || wrapHeight == 0) || !_wrap && (x + _width < _bounds.x || y + _height < _bounds.y || x > _bounds.right || y > _bounds.bottom))
        {
            g.clear();
            g.beginBitmapFill(_bd);
            g.drawRect(0, 0, _width, _height);
            g.endFill();
            return;
        }
        var column : Int = as3hx.Compat.parseInt((x - _bounds.x) / _gridSize);
        if (column < 0)
        {
            column = 0;
        }
        var row : Int = as3hx.Compat.parseInt((y - _bounds.y) / _gridSize);
        if (row < 0)
        {
            row = 0;
        }
        var maxColumn : Int = as3hx.Compat.parseInt((x + _width - _bounds.x) / _gridSize);
        if (maxColumn >= _columns)
        {
            maxColumn = as3hx.Compat.parseInt(_columns - 1);
        }
        var maxRow : Int = as3hx.Compat.parseInt((y + _height - _bounds.y) / _gridSize);
        if (maxRow >= _rows)
        {
            maxRow = as3hx.Compat.parseInt(_rows - 1);
        }
        var xNudge : Float = (_bounds.x - x) % 1;
        var yNudge : Float = (_bounds.y - y) % 1;
        if (y <= _bounds.y)
        {
            _destPoint.y = _bounds.y - y >> 0;
            _sliceRect.y = -1;
        }
        else
        {
            _destPoint.y = 0;
            _sliceRect.y = Math.ceil(y - _bounds.y) - row * _gridSize - 1;
            if (clear && yNudge != 0)
            {
                yNudge += 1;
            }
        }
        if (x <= _bounds.x)
        {
            _destPoint.x = _bounds.x - x >> 0;
            _sliceRect.x = -1;
        }
        else
        {
            _destPoint.x = 0;
            _sliceRect.x = Math.ceil(x - _bounds.x) - column * _gridSize - 1;
            if (clear && xNudge != 0)
            {
                xNudge += 1;
            }
        }
        if (_wrap && clear)
        {
            _render(Math.ceil((_bounds.x - x) / wrapWidth) * wrapWidth, Math.ceil((_bounds.y - y) / wrapHeight) * wrapHeight, false, false);
        }
        else if (_rows != 0)
        {
            xDestReset = _destPoint.x;
            xSliceReset = _sliceRect.x;
            columnReset = column;
            while (row <= maxRow)
            {
                bd = _grid[row][0];
                _sliceRect.height = bd.height - _sliceRect.y;
                _destPoint.x = xDestReset;
                _sliceRect.x = xSliceReset;
                column = columnReset;
                while (column <= maxColumn)
                {
                    bd = _grid[row][column];
                    _sliceRect.width = bd.width - _sliceRect.x;
                    _bd.copyPixels(bd, _sliceRect, _destPoint);
                    _destPoint.x += _sliceRect.width - 1;
                    _sliceRect.x = 0;
                    column++;
                }
                _destPoint.y += _sliceRect.height - 1;
                _sliceRect.y = 0;
                row++;
            }
        }
        if (clear)
        {
            _tempMatrix.tx = xNudge - 1;
            _tempMatrix.ty = yNudge - 1;
            g.clear();
            g.beginBitmapFill(_bd, _tempMatrix, false, _smoothing);
            g.drawRect(0, 0, _width, _height);
            g.endFill();
        }
        else if (_wrap)
        {
            if (x + _width > _bounds.right)
            {
                _render(xOffset - wrapWidth, yOffset, false, true);
            }
            if (!limitRecursion && y + _height > _bounds.bottom)
            {
                _render(xOffset, yOffset - wrapHeight, false, false);
            }
        }
    }
    
    private function set_autoUpdate(value : Bool) : Bool
    {
        if (_autoUpdate != value)
        {
            _autoUpdate = value;
            if (_bitmapMode && _autoUpdate)
            {
                this.addEventListener(Event.ENTER_FRAME, update, false, -10, true);
            }
            else
            {
                this.removeEventListener(Event.ENTER_FRAME, update);
            }
        }
        return value;
    }
    
    public function update(event : Event = null, forceRecaptureBitmap : Bool = false) : Void
    {
        var m : Matrix = null;
        if (_bd == null)
        {
            return;
        }
        if (_target == null)
        {
            _render();
        }
        else if (_target.parent)
        {
            _bounds = _target.getBounds(_target.parent);
            if (this.parent != _target.parent)
            {
                if (_target.parent.exists("addElementAt"))
                {
                    cast((_target.parent), Object).addElementAt(this, cast((_target.parent), Object).getChildIndex(_target));
                }
                else
                {
                    _target.parent.addChildAt(this, _target.parent.getChildIndex(_target));
                }
            }
        }
        if (_bitmapMode || forceRecaptureBitmap)
        {
            m = _transform.matrix;
            if (forceRecaptureBitmap || _prevMatrix == null || m.a != _prevMatrix.a || m.b != _prevMatrix.b || m.c != _prevMatrix.c || m.d != _prevMatrix.d)
            {
                _captureTargetBitmap();
                _render();
            }
            else if (m.tx != _prevMatrix.tx || m.ty != _prevMatrix.ty)
            {
                _render();
            }
            else if (_bitmapMode && _target != null)
            {
                this.filters = _target.filters;
                this.transform.colorTransform = _transform.colorTransform;
            }
            _prevMatrix = m;
        }
    }
    
    private function _captureTargetBitmap() : Void
    {
        var bd : BitmapData = null;
        var cumulativeWidth : Float = Math.NaN;
        var column : Int = 0;
        if (_bd == null || _target == null)
        {
            return;
        }
        _disposeGrid();
        var prevMask : DisplayObject = _target.mask;
        if (prevMask != null)
        {
            _target.mask = null;
        }
        var prevScrollRect : Rectangle = _target.scrollRect;
        if (prevScrollRect != null)
        {
            _target.scrollRect = null;
        }
        var prevFilters : Array<Dynamic> = _target.filters;
        if (prevFilters.length != 0)
        {
            _target.filters = _emptyArray;
        }
        _grid = [];
        if (_target.parent == null)
        {
            _tempContainer.addChild(_target);
        }
        _bounds = _target.getBounds(_target.parent);
        var w : Float = 0;
        var h : Float = 0;
        _columns = Math.ceil(_bounds.width / _gridSize);
        _rows = Math.ceil(_bounds.height / _gridSize);
        var cumulativeHeight : Float = 0;
        var matrix : Matrix = _transform.matrix;
        var xOffset : Float = matrix.tx - _bounds.x;
        var yOffset : Float = matrix.ty - _bounds.y;
        if (!_smoothing)
        {
            xOffset = xOffset + 0.5 >> 0;
            yOffset = yOffset + 0.5 >> 0;
        }
        for (row in 0..._rows)
        {
            h = (_bounds.height - cumulativeHeight > _gridSize) ? _gridSize : as3hx.Compat.parseFloat(_bounds.height - cumulativeHeight);
            matrix.ty = -cumulativeHeight + yOffset;
            cumulativeWidth = 0;
            _grid[row] = [];
            for (column in 0..._columns)
            {
                w = (_bounds.width - cumulativeWidth > _gridSize) ? _gridSize : as3hx.Compat.parseFloat(_bounds.width - cumulativeWidth);
                _grid[row][column] = bd = new BitmapData(w + 1, h + 1, true, _fillColor);
                matrix.tx = -cumulativeWidth + xOffset;
                bd.draw(_target, matrix, null, null, _clipRect, _smoothing);
                cumulativeWidth += w;
            }
            cumulativeHeight += h;
        }
        if (_target.parent == _tempContainer)
        {
            _tempContainer.removeChild(_target);
        }
        if (prevMask != null)
        {
            _target.mask = prevMask;
        }
        if (prevScrollRect != null)
        {
            _target.scrollRect = prevScrollRect;
        }
        if (prevFilters.length != 0)
        {
            _target.filters = prevFilters;
        }
    }
    
    override private function get_width() : Float
    {
        return _width;
    }
    
    private function set_bitmapMode(value : Bool) : Bool
    {
        if (_bitmapMode != value)
        {
            _bitmapMode = value;
            if (_target != null)
            {
                _target.visible = !_bitmapMode;
                update(null);
                if (_bitmapMode)
                {
                    this.filters = _target.filters;
                    this.transform.colorTransform = _transform.colorTransform;
                    if (_target.blendMode == "auto")
                    {
                        this.blendMode = (_target.alpha == 0 || _target.alpha == 1) ? BlendMode.NORMAL : BlendMode.LAYER;
                    }
                    else
                    {
                        this.blendMode = _target.blendMode;
                    }
                    _target.mask = null;
                }
                else
                {
                    this.filters = _emptyArray;
                    this.transform.colorTransform = _colorTransform;
                    this.blendMode = "normal";
                    this.cacheAsBitmap = false;
                    _target.mask = this;
                    if (_wrap)
                    {
                        normalizePosition();
                    }
                }
                if (_bitmapMode && _autoUpdate)
                {
                    this.addEventListener(Event.ENTER_FRAME, update, false, -10, true);
                }
                else
                {
                    this.removeEventListener(Event.ENTER_FRAME, update);
                }
            }
        }
        return value;
    }
    
    private function set_smoothing(value : Bool) : Bool
    {
        if (_smoothing != value)
        {
            _smoothing = value;
            _captureTargetBitmap();
            if (_bitmapMode)
            {
                _render();
            }
        }
        return value;
    }
    
    override private function set_x(value : Float) : Float
    {
        if (_smoothing)
        {
            super.x = value;
        }
        else if (value >= 0)
        {
            super.x = value + 0.5 >> 0;
        }
        else
        {
            super.x = value - 0.5 >> 0;
        }
        if (_bitmapMode)
        {
            _render();
        }
        return value;
    }
    
    override private function set_y(value : Float) : Float
    {
        if (_smoothing)
        {
            super.y = value;
        }
        else if (value >= 0)
        {
            super.y = value + 0.5 >> 0;
        }
        else
        {
            super.y = value - 0.5 >> 0;
        }
        if (_bitmapMode)
        {
            _render();
        }
        return value;
    }
    
    private function set_wrapOffsetX(value : Float) : Float
    {
        if (_wrapOffsetX != value)
        {
            _wrapOffsetX = value;
            if (_bitmapMode)
            {
                _render();
            }
        }
        return value;
    }
    
    private function set_wrapOffsetY(value : Float) : Float
    {
        if (_wrapOffsetY != value)
        {
            _wrapOffsetY = value;
            if (_bitmapMode)
            {
                _render();
            }
        }
        return value;
    }
}

