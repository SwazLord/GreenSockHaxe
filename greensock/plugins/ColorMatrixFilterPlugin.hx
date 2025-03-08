package com.greensock.plugins;

import com.greensock.TweenLite;
import flash.filters.ColorMatrixFilter;

class ColorMatrixFilterPlugin extends FilterPlugin
{
    
    public static inline var API : Float = 2;
    
    private static var _propNames : Array<Dynamic> = [];
    
    private static var _lumG : Float = 0.71516;
    
    private static var _lumR : Float = 0.212671;
    
    private static var _idMatrix : Array<Dynamic> = [1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0];
    
    private static var _lumB : Float = 0.072169;
    
    
    private var _matrix : Array<Dynamic>;
    
    private var _matrixTween : EndArrayPlugin;
    
    public function new()
    {
        super("colorMatrixFilter");
    }
    
    public static function setSaturation(m : Array<Dynamic>, n : Float) : Array<Dynamic>
    {
        if (Math.isNaN(n))
        {
            return m;
        }
        var inv : Float = 1 - n;
        var r : Float = inv * _lumR;
        var g : Float = inv * _lumG;
        var b : Float = inv * _lumB;
        var temp : Array<Dynamic> = [r + n, g, b, 0, 0, r, g + n, b, 0, 0, r, g, b + n, 0, 0, 0, 0, 0, 1, 0];
        return applyMatrix(temp, m);
    }
    
    public static function setHue(m : Array<Dynamic>, n : Float) : Array<Dynamic>
    {
        if (Math.isNaN(n))
        {
            return m;
        }
        n *= Math.PI / 180;
        var c : Float = Math.cos(n);
        var s : Float = Math.sin(n);
        var temp : Array<Dynamic> = [_lumR + c * (1 - _lumR) + s * -_lumR, _lumG + c * -_lumG + s * -_lumG, _lumB + c * -_lumB + s * (1 - _lumB), 0, 0, _lumR + c * -_lumR + s * 0.143, _lumG + c * (1 - _lumG) + s * 0.14, _lumB + c * -_lumB + s * -0.283, 0, 0, _lumR + c * -_lumR + s * -(1 - _lumR), _lumG + c * -_lumG + s * _lumG, _lumB + c * (1 - _lumB) + s * _lumB, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1];
        return applyMatrix(temp, m);
    }
    
    public static function setContrast(m : Array<Dynamic>, n : Float) : Array<Dynamic>
    {
        if (Math.isNaN(n))
        {
            return m;
        }
        n += 0.01;
        var temp : Array<Dynamic> = [n, 0, 0, 0, 128 * (1 - n), 0, n, 0, 0, 128 * (1 - n), 0, 0, n, 0, 128 * (1 - n), 0, 0, 0, 1, 0];
        return applyMatrix(temp, m);
    }
    
    public static function applyMatrix(m : Array<Dynamic>, m2 : Array<Dynamic>) : Array<Dynamic>
    {
        var y : Int = 0;
        var x : Int = 0;
        if (!(Std.is(m, Array)) || !(Std.is(m2, Array)))
        {
            return m2;
        }
        var temp : Array<Dynamic> = [];
        var i : Int = 0;
        var z : Int = 0;
        y = 0;
        while (y < 4)
        {
            x = 0;
            while (x < 5)
            {
                z = (x == 4) ? as3hx.Compat.parseInt(m[i + 4]) : 0;
                temp[i + x] = m[i] * m2[x] + m[i + 1] * m2[x + 5] + m[i + 2] * m2[x + 10] + m[i + 3] * m2[x + 15] + z;
                x += 1;
            }
            i += 5;
            y += 1;
        }
        return temp;
    }
    
    public static function setThreshold(m : Array<Dynamic>, n : Float) : Array<Dynamic>
    {
        if (Math.isNaN(n))
        {
            return m;
        }
        var temp : Array<Dynamic> = [_lumR * 256, _lumG * 256, _lumB * 256, 0, -256 * n, _lumR * 256, _lumG * 256, _lumB * 256, 0, -256 * n, _lumR * 256, _lumG * 256, _lumB * 256, 0, -256 * n, 0, 0, 0, 1, 0];
        return applyMatrix(temp, m);
    }
    
    public static function colorize(m : Array<Dynamic>, color : Float, amount : Float = 1) : Array<Dynamic>
    {
        if (Math.isNaN(color))
        {
            return m;
        }
        if (Math.isNaN(amount))
        {
            amount = 1;
        }
        var r : Float = (as3hx.Compat.parseInt(color >> 16) & 255) / 255;
        var g : Float = (as3hx.Compat.parseInt(color >> 8) & 255) / 255;
        var b : Float = (as3hx.Compat.parseInt(color) & 255) / 255;
        var inv : Float = 1 - amount;
        var temp : Array<Dynamic> = [inv + amount * r * _lumR, amount * r * _lumG, amount * r * _lumB, 0, 0, amount * g * _lumR, inv + amount * g * _lumG, amount * g * _lumB, 0, 0, amount * b * _lumR, amount * b * _lumG, inv + amount * b * _lumB, 0, 0, 0, 0, 0, 1, 0];
        return applyMatrix(temp, m);
    }
    
    public static function setBrightness(m : Array<Dynamic>, n : Float) : Array<Dynamic>
    {
        if (Math.isNaN(n))
        {
            return m;
        }
        n = n * 100 - 100;
        return applyMatrix([1, 0, 0, 0, n, 0, 1, 0, 0, n, 0, 0, 1, 0, n, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1], m);
    }
    
    override public function setRatio(v : Float) : Void
    {
        _matrixTween.setRatio(v);
        cast((_filter), ColorMatrixFilter).matrix = _matrix;
        super.setRatio(v);
    }
    
    override public function _onInitTween(target : Dynamic, value : Dynamic, tween : TweenLite) : Bool
    {
        var cmf : Dynamic = value;
        _initFilter(target, {
                    remove : value.remove,
                    index : value.index,
                    addFilter : value.addFilter
                }, tween, ColorMatrixFilter, new ColorMatrixFilter(_idMatrix.copy()), _propNames);
        if (_filter == null)
        {
            trace("FILTER NULL! ");
            return true;
        }
        _matrix = cast((_filter), ColorMatrixFilter).matrix;
        var endMatrix : Array<Dynamic> = [];
        if (cmf.matrix != null && Std.is(cmf.matrix, Array))
        {
            endMatrix = cmf.matrix;
        }
        else
        {
            if (cmf.relative == true)
            {
                endMatrix = _matrix.copy();
            }
            else
            {
                endMatrix = _idMatrix.copy();
            }
            endMatrix = setBrightness(endMatrix, cmf.brightness);
            endMatrix = setContrast(endMatrix, cmf.contrast);
            endMatrix = setHue(endMatrix, cmf.hue);
            endMatrix = setSaturation(endMatrix, cmf.saturation);
            endMatrix = setThreshold(endMatrix, cmf.threshold);
            if (!Math.isNaN(cmf.colorize))
            {
                endMatrix = colorize(endMatrix, cmf.colorize, cmf.amount);
            }
        }
        _matrixTween = new EndArrayPlugin();
        _matrixTween._init(_matrix, endMatrix);
        return true;
    }
}

