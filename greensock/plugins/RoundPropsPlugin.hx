package com.greensock.plugins;

import com.greensock.TweenLite;
import com.greensock.core.PropTween;

class RoundPropsPlugin extends TweenPlugin
{
    
    public static inline var API : Float = 2;
    
    
    private var _tween : TweenLite;
    
    public function new()
    {
        super("roundProps", -1);
        _overwriteProps.length = 0;
    }
    
    public function _add(target : Dynamic, p : String, s : Float, c : Float) : Void
    {
        _addTween(target, p, s, s + c, p, true);
        _overwriteProps[_overwriteProps.length] = p;
    }
    
    override public function _onInitTween(target : Dynamic, value : Dynamic, tween : TweenLite) : Bool
    {
        _tween = tween;
        return true;
    }
    
    public function _onInitAllProps() : Bool
    {
        var prop : String = null;
        var pt : PropTween = null;
        var next : PropTween = null;
        var rp : Array<Dynamic> = (Std.is(_tween.vars.roundProps, Array)) ? _tween.vars.roundProps : _tween.vars.roundProps.split(",");
        var i : Int = rp.length;
        var lookup : Dynamic = { };
        var rpt : PropTween = _tween._propLookup.roundProps;
        while (--i > -1)
        {
            Reflect.setField(lookup, Std.string(rp[i]), 1);
        }
        i = rp.length;
        while (--i > -1)
        {
            prop = rp[i];
            pt = _tween._firstPT;
            while (pt)
            {
                next = pt._next;
                if (pt.pg)
                {
                    pt.t._roundProps(lookup, true);
                }
                else if (pt.n == prop)
                {
                    _add(pt.t, prop, pt.s, pt.c);
                    if (next != null)
                    {
                        next._prev = pt._prev;
                    }
                    if (pt._prev)
                    {
                        pt._prev._next = next;
                    }
                    else if (_tween._firstPT == pt)
                    {
                        _tween._firstPT = next;
                    }
                    pt._next = pt._prev = null;
                    _tween._propLookup[prop] = rpt;
                }
                pt = next;
            }
        }
        return false;
    }
}

