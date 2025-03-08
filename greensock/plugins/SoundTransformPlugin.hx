package com.greensock.plugins;

import com.greensock.TweenLite;
import flash.media.SoundTransform;

class SoundTransformPlugin extends TweenPlugin
{
    
    public static inline var API : Float = 2;
    
    
    private var _target : Dynamic;
    
    private var _st : SoundTransform;
    
    public function new()
    {
        super("soundTransform,volume");
    }
    
    override public function setRatio(v : Float) : Void
    {
        super.setRatio(v);
        _target.soundTransform = _st;
    }
    
    override public function _onInitTween(target : Dynamic, value : Dynamic, tween : TweenLite) : Bool
    {
        var p : Dynamic = null;
        if (!target.exists("soundTransform"))
        {
            return false;
        }
        _target = target;
        _st = _target.soundTransform;
        for (p in Reflect.fields(value))
        {
            _addTween(_st, p, Reflect.field(_st, Std.string(p)), Reflect.field(value, Std.string(p)), p);
        }
        return true;
    }
}

