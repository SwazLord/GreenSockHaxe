package com.greensock.loading.data;

import haxe.Constraints.Function;
import flash.display.DisplayObject;

class LoaderMaxVars
{
    public var vars(get, never) : Dynamic;
    public var isGSVars(get, never) : Bool;

    
    public static inline var version : Float = 1.1;
    
    
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
    
    public function loaders(value : Array<Dynamic>) : LoaderMaxVars
    {
        return _set("loaders", value);
    }
    
    public function onIOError(value : Function) : LoaderMaxVars
    {
        return _set("onIOError", value);
    }
    
    private function get_vars() : Dynamic
    {
        return _vars;
    }
    
    public function onCancel(value : Function) : LoaderMaxVars
    {
        return _set("onCancel", value);
    }
    
    public function onOpen(value : Function) : LoaderMaxVars
    {
        return _set("onOpen", value);
    }
    
    public function onChildProgress(value : Function) : LoaderMaxVars
    {
        return _set("onChildProgress", value);
    }
    
    public function skipPaused(value : Bool) : LoaderMaxVars
    {
        return _set("skipPaused", value);
    }
    
    public function onScriptAccessDenied(value : Function) : LoaderMaxVars
    {
        return _set("onScriptAccessDenied", value);
    }
    
    public function maxConnections(value : Int) : LoaderMaxVars
    {
        return _set("maxConnections", value);
    }
    
    public function name(value : String) : LoaderMaxVars
    {
        return _set("name", value);
    }
    
    public function requireWithRoot(value : DisplayObject) : LoaderMaxVars
    {
        return _set("requireWithRoot", value);
    }
    
    public function onChildComplete(value : Function) : LoaderMaxVars
    {
        return _set("onChildComplete", value);
    }
    
    public function onChildCancel(value : Function) : LoaderMaxVars
    {
        return _set("onChildCancel", value);
    }
    
    public function skipFailed(value : Bool) : LoaderMaxVars
    {
        return _set("skipFailed", value);
    }
    
    private function get_isGSVars() : Bool
    {
        return true;
    }
    
    private function _set(property : String, value : Dynamic) : LoaderMaxVars
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
    
    public function onFail(value : Function) : LoaderMaxVars
    {
        return _set("onFail", value);
    }
    
    public function onChildOpen(value : Function) : LoaderMaxVars
    {
        return _set("onChildOpen", value);
    }
    
    public function onError(value : Function) : LoaderMaxVars
    {
        return _set("onError", value);
    }
    
    public function prop(property : String, value : Dynamic) : LoaderMaxVars
    {
        return _set(property, value);
    }
    
    public function onProgress(value : Function) : LoaderMaxVars
    {
        return _set("onProgress", value);
    }
    
    public function autoDispose(value : Bool) : LoaderMaxVars
    {
        return _set("autoDispose", value);
    }
    
    public function autoLoad(value : Bool) : LoaderMaxVars
    {
        return _set("autoLoad", value);
    }
    
    public function onComplete(value : Function) : LoaderMaxVars
    {
        return _set("onComplete", value);
    }
    
    public function onHTTPStatus(value : Function) : LoaderMaxVars
    {
        return _set("onHTTPStatus", value);
    }
    
    public function onChildFail(value : Function) : LoaderMaxVars
    {
        return _set("onChildFail", value);
    }
    
    public function auditSize(value : Bool) : LoaderMaxVars
    {
        return _set("auditSize", value);
    }
}

