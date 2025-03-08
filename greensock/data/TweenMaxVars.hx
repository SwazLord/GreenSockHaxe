package com.greensock.data;

import haxe.Constraints.Function;
import com.greensock.TweenLite;
import com.greensock.motionPaths.MotionPath;
import flash.display.Stage;
import flash.geom.Point;

class TweenMaxVars
{
    public var vars(get, never) : Dynamic;
    public var _isGSVars(get, never) : Bool;

    
    public static inline var version : String = "12.0.0";
    
    
    private var _vars : Dynamic;
    
    public function new(vars : Dynamic = null)
    {
        var p : Dynamic = null;
        super();
        _vars = { };
        if (vars != null)
        {
            for (p in Reflect.fields(vars))
            {
                Reflect.setField(_vars, Std.string(p), Reflect.field(vars, Std.string(p)));
            }
        }
    }
    
    public function visible(value : Bool) : TweenMaxVars
    {
        return _set("visible", value, true);
    }
    
    public function roundProps(propertyNames : Array<Dynamic>) : TweenMaxVars
    {
        return _set("roundProps", propertyNames, true);
    }
    
    public function delay(delay : Float) : TweenMaxVars
    {
        return _set("delay", delay);
    }
    
    public function frameLabel(label : String) : TweenMaxVars
    {
        return _set("frameLabel", label, true);
    }
    
    public function onUpdate(func : Function, params : Array<Dynamic> = null) : TweenMaxVars
    {
        _set("onUpdateParams", params);
        return _set("onUpdate", func);
    }
    
    public function setSize(width : Float = Math.NaN, height : Float = Math.NaN) : TweenMaxVars
    {
        var values : Dynamic = { };
        if (!Math.isNaN(width))
        {
            values.width = width;
        }
        if (!Math.isNaN(height))
        {
            values.height = height;
        }
        return _set("setSize", values, true);
    }
    
    public function onCompleteListener(func : Function) : TweenMaxVars
    {
        return _set("onCompleteListener", func);
    }
    
    public function useFrames(value : Bool) : TweenMaxVars
    {
        return _set("useFrames", value, false);
    }
    
    public function transformAroundCenter(props : Dynamic) : TweenMaxVars
    {
        return _set("transformAroundCenter", props, true);
    }
    
    public function overwrite(value : String) : TweenMaxVars
    {
        return _set("overwrite", value, false);
    }
    
    public function quaternions(values : Dynamic) : TweenMaxVars
    {
        return _set("quaternions", values, true);
    }
    
    public function onStartListener(func : Function) : TweenMaxVars
    {
        return _set("onStartListener", func);
    }
    
    public function frameForward(frame : Int) : TweenMaxVars
    {
        return _set("frameForward", frame, true);
    }
    
    public function bevelFilter(distance : Float = 4, angle : Float = 45, highlightColor : Int = 16777215, highlightAlpha : Float = 0.5, shadowColor : Int = 0, shadowAlpha : Float = 0.5, blurX : Float = 4, blurY : Float = 4, strength : Float = 1, quality : Int = 2, remove : Bool = false, addFilter : Bool = false, index : Int = -1) : TweenMaxVars
    {
        var filter : Dynamic = {
            distance : distance,
            angle : angle,
            highlightColor : highlightColor,
            highlightAlpha : highlightAlpha,
            shadowColor : shadowColor,
            shadowAlpha : shadowAlpha,
            blurX : blurX,
            blurY : blurY,
            strength : strength,
            quality : quality,
            addFilter : addFilter,
            remove : remove
        };
        if (index > -1)
        {
            filter.index = index;
        }
        return _set("bevelFilter", filter, true);
    }
    
    public function shortRotation(values : Dynamic) : TweenMaxVars
    {
        if (as3hx.Compat.typeof(values) == "number")
        {
            values = {
                        rotation : values
                    };
        }
        return _set("shortRotation", values, true);
    }
    
    public function repeat(value : Int) : TweenMaxVars
    {
        return _set("repeat", value);
    }
    
    public function colorMatrixFilter(colorize : Int = 16777215, amount : Float = 1, saturation : Float = 1, contrast : Float = 1, brightness : Float = 1, hue : Float = 0, threshold : Float = -1, remove : Bool = false, addFilter : Bool = false, index : Int = -1) : TweenMaxVars
    {
        var filter : Dynamic = {
            saturation : saturation,
            contrast : contrast,
            brightness : brightness,
            hue : hue,
            addFilter : addFilter,
            remove : remove
        };
        if (colorize != 16777215)
        {
            filter.colorize = colorize;
            filter.amount = amount;
        }
        if (threshold > -1)
        {
            filter.threshold = threshold;
        }
        if (index > -1)
        {
            filter.index = index;
        }
        return _set("colorMatrixFilter", filter, true);
    }
    
    public function soundTransform(volume : Float = 1, pan : Float = 0, leftToLeft : Float = 1, leftToRight : Float = 0, rightToLeft : Float = 0, rightToRight : Float = 1) : TweenMaxVars
    {
        return _set("soundTransform", {
                    volume : volume,
                    pan : pan,
                    leftToLeft : leftToLeft,
                    leftToRight : leftToRight,
                    rightToLeft : rightToLeft,
                    rightToRight : rightToRight
                }, true);
    }
    
    public function orientToBezier(values : Dynamic = null) : TweenMaxVars
    {
        return _set("orientToBezier", (values == null) ? true : values, false);
    }
    
    public function stageQuality(stage : Stage, during : String = "medium", after : String = null) : TweenMaxVars
    {
        if (after == null)
        {
            after = stage.quality;
        }
        return _set("stageQuality", {
                    stage : stage,
                    during : during,
                    after : after
                }, true);
    }
    
    private function _set(property : String, value : Dynamic, requirePlugin : Bool = false) : TweenMaxVars
    {
        if (value == null)
        {
            Reflect.deleteField(_vars, property);
        }
        else
        {
            Reflect.setField(_vars, property, value);
        }
        if (requirePlugin && !(Lambda.has(TweenLite._plugins, property)))
        {
            trace("WARNING: you must activate() the " + property + " plugin in order for the feature to work in TweenMax. See http://www.greensock.com/tweenlite/#plugins for details.");
        }
        return this;
    }
    
    public function runBackwards(value : Bool) : TweenMaxVars
    {
        return _set("runBackwards", value, false);
    }
    
    public function removeTint(remove : Bool = true) : TweenMaxVars
    {
        return _set("removeTint", remove, true);
    }
    
    public function circlePath2D(path : MotionPath, startAngle : Float, endAngle : Float, autoRotate : Bool = false, direction : String = "clockwise", extraRevolutions : Int = 0, rotationOffset : Float = 0, useRadians : Bool = false) : TweenMaxVars
    {
        return _set("circlePath2D", {
                    path : path,
                    startAngle : startAngle,
                    endAngle : endAngle,
                    autoRotate : autoRotate,
                    direction : direction,
                    extraRevolutions : extraRevolutions,
                    rotationOffset : rotationOffset,
                    useRadians : useRadians
                }, true);
    }
    
    public function repeatDelay(value : Float) : TweenMaxVars
    {
        return _set("repeatDelay", value);
    }
    
    public function volume(volume : Float) : TweenMaxVars
    {
        return _set("volume", volume, true);
    }
    
    public function data(data : Dynamic) : TweenMaxVars
    {
        return _set("data", data);
    }
    
    public function yoyo(value : Bool) : TweenMaxVars
    {
        return _set("yoyo", value);
    }
    
    public function immediateRender(value : Bool) : TweenMaxVars
    {
        return _set("immediateRender", value, false);
    }
    
    public function onReverseCompleteListener(func : Function) : TweenMaxVars
    {
        return _set("onReverseCompleteListener", func);
    }
    
    public function throwProps(props : Dynamic) : TweenMaxVars
    {
        return _set("throwProps", props, true);
    }
    
    public function startAt(vars : TweenMaxVars) : TweenMaxVars
    {
        return _set("startAt", vars.vars);
    }
    
    public function height(value : Float, relative : Bool = false) : TweenMaxVars
    {
        return prop("height", value, relative);
    }
    
    public function transformAroundPoint(point : Point, props : Dynamic) : TweenMaxVars
    {
        props.point = point;
        return _set("transformAroundPoint", props, true);
    }
    
    public function onComplete(func : Function, params : Array<Dynamic> = null) : TweenMaxVars
    {
        _set("onCompleteParams", params);
        return _set("onComplete", func);
    }
    
    private function get_vars() : Dynamic
    {
        return _vars;
    }
    
    public function paused(value : Bool) : TweenMaxVars
    {
        return _set("paused", value, false);
    }
    
    public function endArray(values : Array<Dynamic>) : TweenMaxVars
    {
        return _set("endArray", values, true);
    }
    
    public function blurFilter(blurX : Float, blurY : Float, quality : Int = 2, remove : Bool = false, addFilter : Bool = false, index : Int = -1) : TweenMaxVars
    {
        var filter : Dynamic = {
            blurX : blurX,
            blurY : blurY,
            quality : quality,
            addFilter : addFilter,
            remove : remove
        };
        if (index > -1)
        {
            filter.index = index;
        }
        return _set("blurFilter", filter, true);
    }
    
    private function get__isGSVars() : Bool
    {
        return true;
    }
    
    public function reversed(value : Bool) : TweenMaxVars
    {
        return _set("reversed", value);
    }
    
    public function onStart(func : Function, params : Array<Dynamic> = null) : TweenMaxVars
    {
        _set("onStartParams", params);
        return _set("onStart", func);
    }
    
    public function motionBlur(strength : Float = 1, fastMode : Bool = false, quality : Int = 2, padding : Int = 10) : TweenMaxVars
    {
        return _set("motionBlur", {
                    strength : strength,
                    fastMode : fastMode,
                    quality : quality,
                    padding : padding
                }, true);
    }
    
    public function width(value : Float, relative : Bool = false) : TweenMaxVars
    {
        return prop("width", value, relative);
    }
    
    public function dropShadowFilter(distance : Float = 4, blurX : Float = 4, blurY : Float = 4, alpha : Float = 1, angle : Float = 45, color : Int = 0, strength : Float = 2, inner : Bool = false, knockout : Bool = false, hideObject : Bool = false, quality : Int = 2, remove : Bool = false, addFilter : Bool = false, index : Int = -1) : TweenMaxVars
    {
        var filter : Dynamic = {
            distance : distance,
            blurX : blurX,
            blurY : blurY,
            alpha : alpha,
            angle : angle,
            color : color,
            strength : strength,
            inner : inner,
            knockout : knockout,
            hideObject : hideObject,
            quality : quality,
            addFilter : addFilter,
            remove : remove
        };
        if (index > -1)
        {
            filter.index = index;
        }
        return _set("dropShadowFilter", filter, true);
    }
    
    public function colorTransform(tint : Float = Math.NaN, tintAmount : Float = Math.NaN, exposure : Float = Math.NaN, brightness : Float = Math.NaN, redMultiplier : Float = Math.NaN, greenMultiplier : Float = Math.NaN, blueMultiplier : Float = Math.NaN, alphaMultiplier : Float = Math.NaN, redOffset : Float = Math.NaN, greenOffset : Float = Math.NaN, blueOffset : Float = Math.NaN, alphaOffset : Float = Math.NaN) : TweenMaxVars
    {
        var p : Dynamic = null;
        var values : Dynamic = {
            tint : tint,
            tintAmount : (!!(Math.isNaN(tint)) ? Math.NaN : tintAmount),
            exposure : exposure,
            brightness : brightness,
            redMultiplier : redMultiplier,
            greenMultiplier : greenMultiplier,
            blueMultiplier : blueMultiplier,
            alphaMultiplier : alphaMultiplier,
            redOffset : redOffset,
            greenOffset : greenOffset,
            blueOffset : blueOffset,
            alphaOffset : alphaOffset
        };
        for (p in Reflect.fields(values))
        {
            if (Math.isNaN(Reflect.field(values, Std.string(p))))
            {
                Reflect.deleteField(values, Std.string(p));
            }
        }
        return _set("colorTransform", values, true);
    }
    
    public function scale(value : Float, relative : Bool = false) : TweenMaxVars
    {
        prop("scaleX", value, relative);
        return prop("scaleY", value, relative);
    }
    
    public function transformMatrix(properties : Dynamic) : TweenMaxVars
    {
        return _set("transformMatrix", properties, true);
    }
    
    public function scaleX(value : Float, relative : Bool = false) : TweenMaxVars
    {
        return prop("scaleX", value, relative);
    }
    
    public function scaleY(value : Float, relative : Bool = false) : TweenMaxVars
    {
        return prop("scaleY", value, relative);
    }
    
    public function move(x : Float, y : Float, relative : Bool = false) : TweenMaxVars
    {
        prop("x", x, relative);
        return prop("y", y, relative);
    }
    
    public function scrollRect(props : Dynamic) : TweenMaxVars
    {
        return _set("scrollRect", props, true);
    }
    
    public function physics2D(velocity : Float, angle : Float, acceleration : Float = 0, accelerationAngle : Float = 90, friction : Float = 0) : TweenMaxVars
    {
        return _set("physics2D", {
                    velocity : velocity,
                    angle : angle,
                    acceleration : acceleration,
                    accelerationAngle : accelerationAngle,
                    friction : friction
                }, true);
    }
    
    public function onRepeat(func : Function, params : Array<Dynamic> = null) : TweenMaxVars
    {
        _set("onRepeatParams", params);
        return _set("onRepeat", func);
    }
    
    public function onReverseComplete(func : Function, params : Array<Dynamic> = null) : TweenMaxVars
    {
        _set("onReverseCompleteParams", params);
        return _set("onReverseComplete", func);
    }
    
    public function bezier(values : Array<Dynamic>) : TweenMaxVars
    {
        return _set("bezier", values, true);
    }
    
    public function prop(property : String, value : Float, relative : Bool = false) : TweenMaxVars
    {
        return _set(property, !(relative) ? value : ((value < 0) ? "-=" + -value : "+=" + value));
    }
    
    public function glowFilter(blurX : Float = 10, blurY : Float = 10, color : Int = 16777215, alpha : Float = 1, strength : Float = 2, inner : Bool = false, knockout : Bool = false, quality : Int = 2, remove : Bool = false, addFilter : Bool = false, index : Int = -1) : TweenMaxVars
    {
        var filter : Dynamic = {
            blurX : blurX,
            blurY : blurY,
            color : color,
            alpha : alpha,
            strength : strength,
            inner : inner,
            knockout : knockout,
            quality : quality,
            addFilter : addFilter,
            remove : remove
        };
        if (index > -1)
        {
            filter.index = index;
        }
        return _set("glowFilter", filter, true);
    }
    
    public function bezierThrough(values : Array<Dynamic>) : TweenMaxVars
    {
        return _set("bezierThrough", values, true);
    }
    
    public function physicsProps(values : Dynamic) : TweenMaxVars
    {
        return _set("physicsProps", values, true);
    }
    
    public function onUpdateListener(func : Function) : TweenMaxVars
    {
        return _set("onUpdateListener", func);
    }
    
    public function frame(value : Int, relative : Bool = false) : TweenMaxVars
    {
        return _set("frame", !!(relative) ? Std.string(value) : value, true);
    }
    
    public function onCompleteRender(func : Function, params : Array<Dynamic> = null) : TweenMaxVars
    {
        _set("onCompleteRenderParams", params);
        return _set("onCompleteRender", func, true);
    }
    
    public function autoAlpha(alpha : Float) : TweenMaxVars
    {
        return _set("autoAlpha", alpha, true);
    }
    
    public function frameBackward(frame : Int) : TweenMaxVars
    {
        return _set("frameBackward", frame, true);
    }
    
    public function dynamicProps(props : Dynamic, params : Dynamic = null) : TweenMaxVars
    {
        if (params != null)
        {
            props.params = params;
        }
        return _set("dynamicProps", props, true);
    }
    
    public function hexColors(values : Dynamic) : TweenMaxVars
    {
        return _set("hexColors", values, true);
    }
    
    public function ease(ease : Dynamic, easeParams : Array<Dynamic> = null) : TweenMaxVars
    {
        _set("easeParams", easeParams);
        return _set("ease", ease);
    }
    
    public function x(value : Float, relative : Bool = false) : TweenMaxVars
    {
        return prop("x", value, relative);
    }
    
    public function y(value : Float, relative : Bool = false) : TweenMaxVars
    {
        return prop("y", value, relative);
    }
    
    public function tint(color : Int) : TweenMaxVars
    {
        return _set("tint", color, true);
    }
    
    public function timeScale(value : Float) : TweenMaxVars
    {
        return _set("timeScale", value, false);
    }
    
    public function rotation(value : Float, relative : Bool = false) : TweenMaxVars
    {
        return prop("rotation", value, relative);
    }
}

