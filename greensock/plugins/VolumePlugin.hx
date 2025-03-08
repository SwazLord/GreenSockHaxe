package com.greensock.plugins;

import com.greensock.TweenLite;
import flash.media.SoundTransform;

class VolumePlugin extends TweenPlugin
{
    
    public static inline var API : Float = 2;
    
    
    private var _target : Dynamic;
    
    private var _st : SoundTransform;
    
    public function new()
    {
        super("volume");
    }
    
    override public function setRatio(v : Float) : Void
    {
        super.setRatio(v);
        _target.soundTransform = _st;
    }
    
    override public function _onInitTween(target : Dynamic, value : Dynamic, tween : TweenLite) : Bool
    {
        if (Math.isNaN(value) || target.exists("volume") || !target.exists("soundTransform"))
        {
            return false;
        }
        _target = target;
        _st = _target.soundTransform;
        _addTween(_st, "volume", _st.volume, value, "volume");
        return true;
    }
}

