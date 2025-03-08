package com.greensock.loading.data;

import haxe.Constraints.Function;
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;

class VideoLoaderVars
{
    public var vars(get, never) : Dynamic;
    public var isGSVars(get, never) : Bool;

    
    public static inline var version : Float = 1.23;
    
    
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
    
    public function container(value : DisplayObjectContainer) : VideoLoaderVars
    {
        return _set("container", value);
    }
    
    public function autoPlay(value : Bool) : VideoLoaderVars
    {
        return _set("autoPlay", value);
    }
    
    public function rotation(value : Float) : VideoLoaderVars
    {
        return _set("rotation", value);
    }
    
    public function onSecurityError(value : Function) : VideoLoaderVars
    {
        return _set("onSecurityError", value);
    }
    
    public function bufferMode(value : Bool) : VideoLoaderVars
    {
        return _set("bufferMode", value);
    }
    
    public function scaleMode(value : String) : VideoLoaderVars
    {
        return _set("scaleMode", value);
    }
    
    public function onInit(value : Function) : VideoLoaderVars
    {
        return _set("onInit", value);
    }
    
    public function crop(value : Bool) : VideoLoaderVars
    {
        return _set("crop", value);
    }
    
    public function name(value : String) : VideoLoaderVars
    {
        return _set("name", value);
    }
    
    public function blendMode(value : String) : VideoLoaderVars
    {
        return _set("blendMode", value);
    }
    
    public function alternateURL(value : String) : VideoLoaderVars
    {
        return _set("alternateURL", value);
    }
    
    public function bgAlpha(value : Float) : VideoLoaderVars
    {
        return _set("bgAlpha", value);
    }
    
    public function rotationX(value : Float) : VideoLoaderVars
    {
        return _set("rotationX", value);
    }
    
    public function rotationY(value : Float) : VideoLoaderVars
    {
        return _set("rotationY", value);
    }
    
    public function rotationZ(value : Float) : VideoLoaderVars
    {
        return _set("rotationZ", value);
    }
    
    public function allowMalformedURL(value : Bool) : VideoLoaderVars
    {
        return _set("allowMalformedURL", value);
    }
    
    public function bgColor(value : Int) : VideoLoaderVars
    {
        return _set("bgColor", value);
    }
    
    public function volume(value : Float) : VideoLoaderVars
    {
        return _set("volume", value);
    }
    
    public function repeat(value : Int) : VideoLoaderVars
    {
        return _set("repeat", value);
    }
    
    private function _set(property : String, value : Dynamic) : VideoLoaderVars
    {
        if (value == null)
        {
            Reflect.deleteField(_vars, property);
        }
        else
        {
            Reflect.setField(_vars, property, value);
        }
        return this;
    }
    
    public function onFail(value : Function) : VideoLoaderVars
    {
        return _set("onFail", value);
    }
    
    public function estimatedBytes(value : Int) : VideoLoaderVars
    {
        return _set("estimatedBytes", value);
    }
    
    public function onProgress(value : Function) : VideoLoaderVars
    {
        return _set("onProgress", value);
    }
    
    public function bufferTime(value : Float) : VideoLoaderVars
    {
        return _set("bufferTime", value);
    }
    
    public function centerRegistration(value : Bool) : VideoLoaderVars
    {
        return _set("centerRegistration", value);
    }
    
    public function vAlign(value : String) : VideoLoaderVars
    {
        return _set("vAlign", value);
    }
    
    public function deblocking(value : Int) : VideoLoaderVars
    {
        return _set("deblocking", value);
    }
    
    public function onComplete(value : Function) : VideoLoaderVars
    {
        return _set("onComplete", value);
    }
    
    public function onCancel(value : Function) : VideoLoaderVars
    {
        return _set("onCancel", value);
    }
    
    private function get_vars() : Dynamic
    {
        return _vars;
    }
    
    public function height(value : Float) : VideoLoaderVars
    {
        return _set("height", value);
    }
    
    public function onHTTPStatus(value : Function) : VideoLoaderVars
    {
        return _set("onHTTPStatus", value);
    }
    
    public function noCache(value : Bool) : VideoLoaderVars
    {
        return _set("noCache", value);
    }
    
    public function onIOError(value : Function) : VideoLoaderVars
    {
        return _set("onIOError", value);
    }
    
    public function width(value : Float) : VideoLoaderVars
    {
        return _set("width", value);
    }
    
    public function onOpen(value : Function) : VideoLoaderVars
    {
        return _set("onOpen", value);
    }
    
    public function requireWithRoot(value : DisplayObject) : VideoLoaderVars
    {
        return _set("requireWithRoot", value);
    }
    
    public function scaleX(value : Float) : VideoLoaderVars
    {
        return _set("scaleX", value);
    }
    
    public function scaleY(value : Float) : VideoLoaderVars
    {
        return _set("scaleY", value);
    }
    
    public function alpha(value : Float) : VideoLoaderVars
    {
        return _set("alpha", value);
    }
    
    private function get_isGSVars() : Bool
    {
        return true;
    }
    
    public function prop(property : String, value : Dynamic) : VideoLoaderVars
    {
        return _set(property, value);
    }
    
    public function onError(value : Function) : VideoLoaderVars
    {
        return _set("onError", value);
    }
    
    public function autoDispose(value : Bool) : VideoLoaderVars
    {
        return _set("autoDispose", value);
    }
    
    public function visible(value : Bool) : VideoLoaderVars
    {
        return _set("visible", value);
    }
    
    public function smoothing(value : Bool) : VideoLoaderVars
    {
        return _set("smoothing", value);
    }
    
    public function checkPolicyFile(value : Bool) : VideoLoaderVars
    {
        return _set("checkPolicyFile", value);
    }
    
    public function estimatedDuration(value : Float) : VideoLoaderVars
    {
        return _set("estimatedDuration", value);
    }
    
    public function x(value : Float) : VideoLoaderVars
    {
        return _set("x", value);
    }
    
    public function y(value : Float) : VideoLoaderVars
    {
        return _set("y", value);
    }
    
    public function z(value : Float) : VideoLoaderVars
    {
        return _set("z", value);
    }
    
    public function autoDetachNetStream(value : Bool) : VideoLoaderVars
    {
        return _set("autoDetachNetStream", value);
    }
    
    public function hAlign(value : String) : VideoLoaderVars
    {
        return _set("hAlign", value);
    }
    
    public function autoAdjustBuffer(value : Bool) : VideoLoaderVars
    {
        return _set("autoAdjustBuffer", value);
    }
}

