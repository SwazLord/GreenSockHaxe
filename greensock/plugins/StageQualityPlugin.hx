package com.greensock.plugins;

import com.greensock.TweenLite;
import flash.display.Stage;
import flash.display.StageQuality;

class StageQualityPlugin extends TweenPlugin
{
    
    public static inline var API : Float = 2;
    
    
    private var _during : String;
    
    private var _tween : TweenLite;
    
    private var _after : String;
    
    private var _stage : Stage;
    
    public function new()
    {
        super("stageQuality");
    }
    
    override public function _onInitTween(target : Dynamic, value : Dynamic, tween : TweenLite) : Bool
    {
        if (!(Std.is(value.stage, Stage)))
        {
            trace("You must define a \'stage\' property for the stageQuality object in your tween.");
            return false;
        }
        _stage = try cast(value.stage, Stage) catch(e:Dynamic) null;
        _tween = tween;
        _during = (Lambda.has(value, "during")) ? value.during : StageQuality.MEDIUM;
        _after = (Lambda.has(value, "after")) ? value.after : _stage.quality;
        return true;
    }
    
    override public function setRatio(v : Float) : Void
    {
        if (v == 1 && _tween._duration == _tween._time && _tween.data != "isFromStart" || v == 0 && _tween._time == 0)
        {
            _stage.quality = _after;
        }
        else if (_stage.quality != _during)
        {
            _stage.quality = _during;
        }
    }
}

