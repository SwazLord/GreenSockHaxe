package com.greensock.plugins;

import com.greensock.TweenLite;
import flash.display.MovieClip;

class FrameLabelPlugin extends FramePlugin
{
    
    public static inline var API : Float = 2;
    
    
    public function new()
    {
        super();
        _propName = "frameLabel";
    }
    
    override public function _onInitTween(target : Dynamic, value : Dynamic, tween : TweenLite) : Bool
    {
        if (Std.is(!tween.target, MovieClip))
        {
            return false;
        }
        _target = try cast(target, MovieClip) catch(e:Dynamic) null;
        this.frame = _target.currentFrame;
        var labels : Array<Dynamic> = _target.currentLabels;
        var label : String = value;
        var endFrame : Int = _target.currentFrame;
        var i : Int = labels.length;
        while (--i > -1)
        {
            if (labels[i].name == label)
            {
                endFrame = labels[i].frame;
                break;
            }
        }
        if (this.frame != endFrame)
        {
            _addTween(this, "frame", this.frame, endFrame, "frame", true);
        }
        return true;
    }
}

