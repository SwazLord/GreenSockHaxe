package com.greensock.loading.data;

import haxe.Constraints.Function;
import flash.display.DisplayObject;
import flash.media.SoundLoaderContext;

class MP3LoaderVars
{
    public var vars(get, never) : Dynamic;
    public var isGSVars(get, never) : Bool;

    
    public static inline var version : Float = 1.2;
    
    
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
    
    public function onCancel(value : Function) : MP3LoaderVars
    {
        return _set("onCancel", value);
    }
    
    public function noCache(value : Bool) : MP3LoaderVars
    {
        return _set("noCache", value);
    }
    
    public function autoPlay(value : Bool) : MP3LoaderVars
    {
        return _set("autoPlay", value);
    }
    
    private function get_vars() : Dynamic
    {
        return _vars;
    }
    
    public function onOpen(value : Function) : MP3LoaderVars
    {
        return _set("onOpen", value);
    }
    
    public function onIOError(value : Function) : MP3LoaderVars
    {
        return _set("onIOError", value);
    }
    
    public function requireWithRoot(value : DisplayObject) : MP3LoaderVars
    {
        return _set("requireWithRoot", value);
    }
    
    public function estimatedBytes(value : Int) : MP3LoaderVars
    {
        return _set("estimatedBytes", value);
    }
    
    public function name(value : String) : MP3LoaderVars
    {
        return _set("name", value);
    }
    
    public function alternateURL(value : String) : MP3LoaderVars
    {
        return _set("alternateURL", value);
    }
    
    public function volume(value : Float) : MP3LoaderVars
    {
        return _set("volume", value);
    }
    
    public function repeat(value : Int) : MP3LoaderVars
    {
        return _set("repeat", value);
    }
    
    public function allowMalformedURL(value : Bool) : MP3LoaderVars
    {
        return _set("allowMalformedURL", value);
    }
    
    private function get_isGSVars() : Bool
    {
        return true;
    }
    
    private function _set(property : String, value : Dynamic) : MP3LoaderVars
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
    
    public function onFail(value : Function) : MP3LoaderVars
    {
        return _set("onFail", value);
    }
    
    public function onError(value : Function) : MP3LoaderVars
    {
        return _set("onError", value);
    }
    
    public function prop(property : String, value : Dynamic) : MP3LoaderVars
    {
        return _set(property, value);
    }
    
    public function onProgress(value : Function) : MP3LoaderVars
    {
        return _set("onProgress", value);
    }
    
    public function context(value : SoundLoaderContext) : MP3LoaderVars
    {
        return _set("context", value);
    }
    
    public function autoDispose(value : Bool) : MP3LoaderVars
    {
        return _set("autoDispose", value);
    }
    
    public function onComplete(value : Function) : MP3LoaderVars
    {
        return _set("onComplete", value);
    }
    
    public function onHTTPStatus(value : Function) : MP3LoaderVars
    {
        return _set("onHTTPStatus", value);
    }
    
    public function initThreshold(value : Int) : MP3LoaderVars
    {
        return _set("initThreshold", value);
    }
}

