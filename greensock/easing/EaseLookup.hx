package com.greensock.easing;


class EaseLookup
{
    
    private static var _lookup : Dynamic;
    
    
    public function new()
    {
        super();
    }
    
    public static function find(name : String) : Ease
    {
        if (_lookup == null)
        {
            _lookup = { };
            _addInOut(Back, ["back"]);
            _addInOut(Bounce, ["bounce"]);
            _addInOut(Circ, ["circ", "circular"]);
            _addInOut(Cubic, ["cubic", "power2"]);
            _addInOut(Elastic, ["elastic"]);
            _addInOut(Expo, ["expo", "exponential"]);
            _addInOut(Power0, ["linear", "power0"]);
            _addInOut(Quad, ["quad", "quadratic", "power1"]);
            _addInOut(Quart, ["quart", "quartic", "power3"]);
            _addInOut(Quint, ["quint", "quintic", "strong", "power4"]);
            _addInOut(Sine, ["sine"]);
            Reflect.setField(_lookup, "linear.easenone", Reflect.setField(_lookup, "lineareasenone", Linear.easeNone));
            _lookup.slowmo = Reflect.setField(_lookup, "slowmo.ease", SlowMo.ease);
        }
        return Reflect.field(_lookup, Std.string(name.toLowerCase()));
    }
    
    private static function _addInOut(easeClass : Class<Dynamic>, names : Array<Dynamic>) : Void
    {
        var name : String = null;
        var i : Int = names.length;
        while (--i > -1)
        {
            name = names[i].toLowerCase();
            Reflect.setField(_lookup, Std.string(name + ".easein"), ".easein");
            Reflect.setField(_lookup, Std.string(name + ".easeout"), ".easeout");
            Reflect.setField(_lookup, Std.string(name + ".easeinout"), ".easeinout");
        }
    }
}

