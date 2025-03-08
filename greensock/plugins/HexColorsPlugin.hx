package com.greensock.plugins;

import com.greensock.TweenLite;

class HexColorsPlugin extends TweenPlugin
{
    
    public static inline var API : Float = 2;
    
    
    private var _colors : Array<Dynamic>;
    
    public function new()
    {
        super("hexColors");
        _overwriteProps = [];
        _colors = [];
    }
    
    public function _initColor(target : Dynamic, p : String, end : Int) : Void
    {
        var r : Int = 0;
        var g : Int = 0;
        var b : Int = 0;
        var isFunc : Bool = as3hx.Compat.typeof(Reflect.field(target, p)) == "function";
        var start : Int = !(isFunc) ? as3hx.Compat.parseInt(Reflect.field(target, p)) : as3hx.Compat.parseInt(Reflect.field(target, Std.string(p.indexOf("set") || !((Lambda.has(target, "get" + p.substr(3)))) ? p : "get" + p.substr(3)))());
        if (start != end)
        {
            r = start >> 16;
            g = as3hx.Compat.parseInt(start >> 8) & 255;
            b = start & 255;
            _colors[_colors.length] = new ColorProp(target, p, isFunc, r, (end >> 16) - r, g, (as3hx.Compat.parseInt(end >> 8) & 255) - g, b, (end & 255) - b);
            _overwriteProps[_overwriteProps.length] = p;
        }
    }
    
    override public function setRatio(v : Float) : Void
    {
        var clr : ColorProp = null;
        var val : Float = Math.NaN;
        var i : Int = _colors.length;
        while (--i > -1)
        {
            clr = _colors[i];
            val = clr.rs + v * clr.rc << 16 | clr.gs + v * clr.gc << 8 | clr.bs + v * clr.bc;
            if (clr.f)
            {
                clr.t[clr.p](val);
            }
            else
            {
                clr.t[clr.p] = val;
            }
        }
    }
    
    override public function _onInitTween(target : Dynamic, value : Dynamic, tween : TweenLite) : Bool
    {
        var p : Dynamic = null;
        for (p in Reflect.fields(value))
        {
            _initColor(target, p, as3hx.Compat.parseInt(Reflect.field(value, Std.string(p))));
        }
        return true;
    }
    
    override public function _kill(lookup : Dynamic) : Bool
    {
        var i : Int = _colors.length;
        while (i--)
        {
            if (Reflect.field(lookup, Std.string(_colors[i].p)) != null)
            {
                _colors.splice(i, 1);
            }
        }
        return super._kill(lookup);
    }
}


class ColorProp
{
    
    
    public var rs : Int;
    
    public var f : Bool;
    
    public var gs : Int;
    
    public var p : String;
    
    public var rc : Int;
    
    public var t : Dynamic;
    
    public var bc : Int;
    
    public var gc : Int;
    
    public var bs : Int;
    
    private function new(t : Dynamic, p : String, f : Bool, rs : Int, rc : Int, gs : Int, gc : Int, bs : Int, bc : Int)
    {
        super();
        this.t = t;
        this.p = p;
        this.f = f;
        this.rs = rs;
        this.rc = rc;
        this.gs = gs;
        this.gc = gc;
        this.bs = bs;
        this.bc = bc;
    }
}
