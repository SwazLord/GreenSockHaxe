package com.greensock.plugins;

import com.greensock.TweenLite;

class ScrambleTextPlugin extends TweenPlugin
{
    
    private static var _upper : String = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    
    private static var _charsLookup : Dynamic;
    
    private static var _lower : String = _upper.toLowerCase();
    
    public static inline var API : Float = 2;
    
    
    private var _lengthDif : Int;
    
    private var _length : Float;
    
    private var _delimiter : String;
    
    private var _text : Array<Dynamic>;
    
    private var _speed : Float;
    
    private var _chars : String;
    
    private var _tween : TweenLite;
    
    private var _charSet : CharSet;
    
    private var _setIndex : Int;
    
    private var _original : Array<Dynamic>;
    
    private var _tweenLength : Bool;
    
    private var _prevScrambleTime : Float;
    
    private var _revealDelay : Float;
    
    private var _target : Dynamic;
    
    public function new()
    {
        var p : Dynamic = null;
        super("scrambleText");
        if (_charsLookup == null)
        {
            _charsLookup = {
                        upperCase : new CharSet(_upper),
                        lowerCase : new CharSet(_lower),
                        upperAndLowerCase : new CharSet(_upper + _lower)
                    };
            for (p in Reflect.fields(_charsLookup))
            {
                Reflect.setField(_charsLookup, Std.string(p.toLowerCase()), Reflect.field(_charsLookup, Std.string(p)));
                Reflect.setField(_charsLookup, Std.string(p.toUpperCase()), Reflect.field(_charsLookup, Std.string(p)));
            }
        }
    }
    
    override public function setRatio(ratio : Float) : Void
    {
        var i : Int = 0;
        var newText : String = null;
        var oldText : String = null;
        var l : Int = _text.length;
        var delim : String = _delimiter;
        var time : Float = _tween._time;
        var timeDif : Float = time - _prevScrambleTime;
        if (_revealDelay != 0)
        {
            if (_tween.vars.runBackwards)
            {
                time = _tween._duration - time;
            }
            ratio = (time == 0) ? 0 : ((time < _revealDelay) ? 0.000001 : ((time == _tween._duration) ? 1 : as3hx.Compat.parseFloat(_tween._ease.getRatio((time - _revealDelay) / (_tween._duration - _revealDelay)))));
        }
        if (ratio < 0)
        {
            ratio = 0;
        }
        else if (ratio > 1)
        {
            ratio = 1;
        }
        i = as3hx.Compat.parseInt(ratio * l + 0.5) | 0;
        newText = _text.slice(0, i).join(delim);
        oldText = _original.slice(i).join(delim);
        if (ratio != 0 && !Math.isNaN(ratio))
        {
            if (timeDif > _speed || timeDif < -_speed)
            {
                _setIndex = as3hx.Compat.parseInt((_setIndex + (Math.random() * 19 | 0)) % 20);
                _chars = _charSet.sets[_setIndex];
                _prevScrambleTime += timeDif;
            }
            oldText = _chars.substr(newText.length, _length + (!!(_tweenLength) ? 1 - (ratio = 1 - ratio) * ratio * ratio * ratio : 1) * _lengthDif - newText.length + 0.5 | 0);
        }
        _target.text = newText + delim + oldText;
    }
    
    override public function _onInitTween(target : Dynamic, value : Dynamic, tween : TweenLite) : Bool
    {
        var delim : String = null;
        var i : Int = 0;
        var maxLength : Int = 0;
        var charset : CharSet = null;
        if (target.text == null)
        {
            trace("scrambleText only works on objects with a \'text\' property.");
            return false;
        }
        _target = target;
        if (as3hx.Compat.typeof(value) != "object")
        {
            value = {
                        text : value
                    };
        }
        var scramble : String = value.scramble;
        _original = target.text.split(_delimiter = value.delimiter || "");
        _text = Std.string(value.text || value.value || "").split(delim);
        i = as3hx.Compat.parseInt(_text.length - _original.length);
        _length = _original.join(delim).length;
        _lengthDif = as3hx.Compat.parseInt(_text.join(delim).length - _length);
        _charSet = charset = Reflect.field(_charsLookup, Std.string(value.chars || "upperCase")) || new CharSet(value.chars);
        _speed = 0.016 / (value.speed || 1);
        _prevScrambleTime = 0;
        _setIndex = as3hx.Compat.parseInt(Math.random() * 20) | 0;
        maxLength = as3hx.Compat.parseInt(_length + Math.max(_lengthDif, 0));
        if (maxLength > charset.length)
        {
            charset.grow(maxLength);
        }
        _chars = charset.sets[_setIndex];
        _revealDelay = as3hx.Compat.parseFloat(value.revealDelay) || 0;
        _tweenLength = value.tweenLength != false;
        _tween = tween;
        return true;
    }
}


class CharSet
{
    
    
    public var sets : Array<Dynamic>;
    
    public var length : Int;
    
    public var chars : Array<Dynamic>;
    
    private function new(chars : String)
    {
        var i : Int = 0;
        super();
        this.chars = chars.split("");
        this.sets = [];
        this.length = 50;
        for (i in 0...20)
        {
            sets[i] = _scrambleText(80, this.chars);
        }
    }
    
    private static function _scrambleText(length : Float, chars : Array<Dynamic>) : String
    {
        var l : Int = chars.length;
        var s : String = "";
        while (--length > -1)
        {
            s += chars[Math.random() * l | 0];
        }
        return s;
    }
    
    public function grow(newLength : Int) : Void
    {
        var i : Int = 0;
        for (i in 0...20)
        {
            sets[i] += _scrambleText(newLength - length, chars);
        }
        length = newLength;
    }
}
