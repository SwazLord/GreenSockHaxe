package com.greensock.loading.data;

import haxe.Constraints.Function;
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.system.LoaderContext;

class ImageLoaderVars
{
    public var isGSVars(get, never) : Bool;
    public var vars(get, never) : Dynamic;

    
    public static inline var version : Float = 1.22;
    
    
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
    
    public function onCancel(value : Function) : ImageLoaderVars
    {
        return _set("onCancel", value);
    }
    
    public function noCache(value : Bool) : ImageLoaderVars
    {
        return _set("noCache", value);
    }
    
    public function onIOError(value : Function) : ImageLoaderVars
    {
        return _set("onIOError", value);
    }
    
    public function width(value : Float) : ImageLoaderVars
    {
        return _set("width", value);
    }
    
    public function container(value : DisplayObjectContainer) : ImageLoaderVars
    {
        return _set("container", value);
    }
    
    public function onOpen(value : Function) : ImageLoaderVars
    {
        return _set("onOpen", value);
    }
    
    public function requireWithRoot(value : DisplayObject) : ImageLoaderVars
    {
        return _set("requireWithRoot", value);
    }
    
    public function scaleX(value : Float) : ImageLoaderVars
    {
        return _set("scaleX", value);
    }
    
    public function estimatedBytes(value : Int) : ImageLoaderVars
    {
        return _set("estimatedBytes", value);
    }
    
    public function crop(value : Bool) : ImageLoaderVars
    {
        return _set("crop", value);
    }
    
    public function y(value : Float) : ImageLoaderVars
    {
        return _set("y", value);
    }
    
    public function name(value : String) : ImageLoaderVars
    {
        return _set("name", value);
    }
    
    public function blendMode(value : String) : ImageLoaderVars
    {
        return _set("blendMode", value);
    }
    
    public function alternateURL(value : String) : ImageLoaderVars
    {
        return _set("alternateURL", value);
    }
    
    public function onSecurityError(value : Function) : ImageLoaderVars
    {
        return _set("onSecurityError", value);
    }
    
    public function bgAlpha(value : Float) : ImageLoaderVars
    {
        return _set("bgAlpha", value);
    }
    
    public function rotationX(value : Float) : ImageLoaderVars
    {
        return _set("rotationX", value);
    }
    
    public function rotationY(value : Float) : ImageLoaderVars
    {
        return _set("rotationY", value);
    }
    
    public function rotationZ(value : Float) : ImageLoaderVars
    {
        return _set("rotationZ", value);
    }
    
    public function allowMalformedURL(value : Bool) : ImageLoaderVars
    {
        return _set("allowMalformedURL", value);
    }
    
    public function bgColor(value : Int) : ImageLoaderVars
    {
        return _set("bgColor", value);
    }
    
    private function get_isGSVars() : Bool
    {
        return true;
    }
    
    private function _set(property : String, value : Dynamic) : ImageLoaderVars
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
    
    public function onFail(value : Function) : ImageLoaderVars
    {
        return _set("onFail", value);
    }
    
    public function alpha(value : Float) : ImageLoaderVars
    {
        return _set("alpha", value);
    }
    
    public function height(value : Float) : ImageLoaderVars
    {
        return _set("height", value);
    }
    
    public function onError(value : Function) : ImageLoaderVars
    {
        return _set("onError", value);
    }
    
    public function prop(property : String, value : Dynamic) : ImageLoaderVars
    {
        return _set(property, value);
    }
    
    public function onProgress(value : Function) : ImageLoaderVars
    {
        return _set("onProgress", value);
    }
    
    public function z(value : Float) : ImageLoaderVars
    {
        return _set("z", value);
    }
    
    public function centerRegistration(value : Bool) : ImageLoaderVars
    {
        return _set("centerRegistration", value);
    }
    
    public function context(value : LoaderContext) : ImageLoaderVars
    {
        return _set("context", value);
    }
    
    public function autoDispose(value : Bool) : ImageLoaderVars
    {
        return _set("autoDispose", value);
    }
    
    public function scaleY(value : Float) : ImageLoaderVars
    {
        return _set("scaleY", value);
    }
    
    public function visible(value : Bool) : ImageLoaderVars
    {
        return _set("visible", value);
    }
    
    public function smoothing(value : Bool) : ImageLoaderVars
    {
        return _set("smoothing", value);
    }
    
    public function vAlign(value : String) : ImageLoaderVars
    {
        return _set("vAlign", value);
    }
    
    public function onComplete(value : Function) : ImageLoaderVars
    {
        return _set("onComplete", value);
    }
    
    public function onHTTPStatus(value : Function) : ImageLoaderVars
    {
        return _set("onHTTPStatus", value);
    }
    
    public function scaleMode(value : String) : ImageLoaderVars
    {
        return _set("scaleMode", value);
    }
    
    private function get_vars() : Dynamic
    {
        return _vars;
    }
    
    public function hAlign(value : String) : ImageLoaderVars
    {
        return _set("hAlign", value);
    }
    
    public function rotation(value : Float) : ImageLoaderVars
    {
        return _set("rotation", value);
    }
    
    public function x(value : Float) : ImageLoaderVars
    {
        return _set("x", value);
    }
}

