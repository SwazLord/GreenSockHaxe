package com.greensock.plugins;

import com.greensock.TweenLite;
import flash.filters.BitmapFilter;
import flash.filters.BlurFilter;

class FilterPlugin extends TweenPlugin
{
    
    public static inline var API : Float = 2;
    
    
    private var _remove : Bool;
    
    private var _tween : TweenLite;
    
    private var _target : Dynamic;
    
    private var _index : Int;
    
    private var _filter : BitmapFilter;
    
    private var _type : Class<Dynamic>;
    
    public function new(props : String = "", priority : Float = 0)
    {
        super(props, priority);
    }
    
    private function _initFilter(target : Dynamic, props : Dynamic, tween : TweenLite, type : Class<Dynamic>, defaultFilter : BitmapFilter, propNames : Array<Dynamic>) : Bool
    {
        var p : String = null;
        var i : Int = 0;
        var colorTween : HexColorsPlugin = null;
        _target = target;
        _tween = tween;
        _type = type;
        var filters : Array<Dynamic> = _target.filters;
        var extras : Dynamic = (Std.is(props, BitmapFilter)) ? { } : props;
        if (extras.index != null)
        {
            _index = extras.index;
        }
        else
        {
            _index = filters.length;
            if (extras.addFilter != true)
            {
                while (--_index > -1 && !(Std.is(filters[_index], _type)))
                {
                }
            }
        }
        if (_index < 0 || !(Std.is(filters[_index], _type)))
        {
            if (_index < 0)
            {
                _index = filters.length;
            }
            if (_index > filters.length)
            {
                i = as3hx.Compat.parseInt(filters.length - 1);
                while (++i < _index)
                {
                    filters[i] = new BlurFilter(0, 0, 1);
                }
            }
            filters[_index] = defaultFilter;
            _target.filters = filters;
        }
        _filter = filters[_index];
        _remove = extras.remove == true;
        i = propNames.length;
        while (--i > -1)
        {
            p = propNames[i];
            if (Lambda.has(props, p) && Reflect.field(_filter, p) != Reflect.field(props, p))
            {
                if (p == "color" || p == "highlightColor" || p == "shadowColor")
                {
                    colorTween = new HexColorsPlugin();
                    colorTween._initColor(_filter, p, Reflect.field(props, p));
                    _addTween(colorTween, "setRatio", 0, 1, _propName);
                }
                else if (p == "quality" || p == "inner" || p == "knockout" || p == "hideObject")
                {
                    Reflect.setField(_filter, p, Reflect.field(props, p));
                }
                else
                {
                    _addTween(_filter, p, Reflect.field(_filter, p), Reflect.field(props, p), _propName);
                }
            }
        }
        return true;
    }
    
    override public function setRatio(v : Float) : Void
    {
        super.setRatio(v);
        var filters : Array<Dynamic> = _target.filters;
        if (!(Std.is(filters[_index], _type)))
        {
            _index = filters.length;
            while (--_index > -1 && !(Std.is(filters[_index], _type)))
            {
            }
            if (_index == -1)
            {
                _index = filters.length;
            }
        }
        if (v == 1 && _remove && _tween._time == _tween._duration && _tween.data != "isFromStart")
        {
            if (_index < filters.length)
            {
                filters.splice(_index, 1);
            }
        }
        else
        {
            filters[_index] = _filter;
        }
        _target.filters = filters;
    }
}

