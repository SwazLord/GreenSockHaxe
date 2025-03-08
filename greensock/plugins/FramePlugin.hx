package com.greensock.plugins;

import com.greensock.TweenLite;
import flash.display.MovieClip;

class FramePlugin extends TweenPlugin
{
    
    public static inline var API : Float = 2;
    
    
    private var _target : MovieClip;
    
    public var frame : Int;
    
    public function new()
    {
        super("frame,frameLabel,frameForward,frameBackward");
    }
    
    override public function setRatio(v : Float) : Void
    {
        super.setRatio(v);
        if (this.frame != _target.currentFrame)
        {
            _target.gotoAndStop(this.frame);
        }
    }
    
    override public function _onInitTween(target : Dynamic, value : Dynamic, tween : TweenLite) : Bool
    {
        if (!(Std.is(target, MovieClip)) || Math.isNaN(value))
        {
            return false;
        }
        _target = try cast(target, MovieClip) catch(e:Dynamic) null;
        this.frame = _target.currentFrame;
        _addTween(this, "frame", this.frame, value, "frame", true);
        return true;
    }
}

