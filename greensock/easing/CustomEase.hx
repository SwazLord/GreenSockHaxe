package com.greensock.easing;

import haxe.Constraints.Function;

class CustomEase
{
    
    private static var _all : Dynamic = { };
    
    public static inline var VERSION : Float = 1.01;
    
    
    private var _name : String;
    
    private var _segments : Array<Dynamic>;
    
    public function new(name : String, segments : Array<Dynamic>)
    {
        super();
        _name = name;
        _segments = [];
        var l : Int = segments.length;
        for (i in 0...l)
        {
            _segments[_segments.length] = new Segment(segments[i].s, segments[i].cp, segments[i].e);
        }
        Reflect.setField(_all, name, this);
    }
    
    public static function byName(name : String) : Function
    {
        return Reflect.field(_all, name).ease;
    }
    
    public static function create(name : String, segments : Array<Dynamic>) : Function
    {
        var b : CustomEase = new CustomEase(name, segments);
        return b.ease;
    }
    
    public function destroy() : Void
    {
        _segments = null;
        Reflect.deleteField(_all, _name);
    }
    
    public function ease(time : Float, start : Float, change : Float, duration : Float) : Float
    {
        var t : Float = Math.NaN;
        var s : Segment = null;
        var factor : Float = time / duration;
        var qty : Int = _segments.length;
        var i : Int = as3hx.Compat.parseInt(qty * factor);
        t = (factor - i * (1 / qty)) * qty;
        s = _segments[i];
        return start + change * (s.s + t * (2 * (1 - t) * (s.cp - s.s) + t * (s.e - s.s)));
    }
}


class Segment
{
    
    
    public var s : Float;
    
    public var e : Float;
    
    public var cp : Float;
    
    private function new(s : Float, cp : Float, e : Float)
    {
        super();
        this.s = s;
        this.cp = cp;
        this.e = e;
    }
}
