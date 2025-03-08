package com.greensock.loading.core;

import haxe.Constraints.Function;
import com.greensock.events.LoaderEvent;
import com.greensock.loading.LoaderMax;
import com.greensock.loading.LoaderStatus;
import flash.display.DisplayObject;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.ProgressEvent;
import flash.net.LocalConnection;
import flash.system.Capabilities;
import flash.utils.Dictionary;

@:meta(Event(name="unload",type="com.greensock.events.LoaderEvent"))

@:meta(Event(name="error",type="com.greensock.events.LoaderEvent"))

@:meta(Event(name="fail",type="com.greensock.events.LoaderEvent"))

@:meta(Event(name="cancel",type="com.greensock.events.LoaderEvent"))

@:meta(Event(name="complete",type="com.greensock.events.LoaderEvent"))

@:meta(Event(name="progress",type="com.greensock.events.LoaderEvent"))

@:meta(Event(name="open",type="com.greensock.events.LoaderEvent"))

class LoaderCore extends EventDispatcher
{
    public var rootLoader(get, never) : LoaderMax;
    public var bytesTotal(get, never) : Int;
    public var paused(get, set) : Bool;
    public var progress(get, never) : Float;
    public var bytesLoaded(get, never) : Int;
    public var loadTime(get, never) : Float;
    public var auditedSize(get, never) : Bool;
    public var status(get, never) : Int;
    public var content(get, never) : Dynamic;

    
    private static var _types : Dynamic = { };
    
    private static var _listenerTypes : Dynamic = {
            onOpen : "open",
            onInit : "init",
            onComplete : "complete",
            onProgress : "progress",
            onCancel : "cancel",
            onFail : "fail",
            onError : "error",
            onSecurityError : "securityError",
            onHTTPStatus : "httpStatus",
            onHTTPResponseStatus : "httpResponseStatus",
            onIOError : "ioError",
            onScriptAccessDenied : "scriptAccessDenied",
            onChildOpen : "childOpen",
            onChildCancel : "childCancel",
            onChildComplete : "childComplete",
            onChildProgress : "childProgress",
            onChildFail : "childFail",
            onRawLoad : "rawLoad",
            onUncaughtError : "uncaughtError"
        };
    
    private static var _isLocal : Bool;
    
    private static var _extensions : Dynamic = { };
    
    private static var _globalRootLoader : LoaderMax;
    
    public static inline var version : Float = 1.935;
    
    private static var _rootLookup : Dictionary = new Dictionary(false);
    
    private static var _loaderCount : Int = 0;
    
    
    private var _prePauseStatus : Int;
    
    public var name : String;
    
    private var _dispatchChildProgress : Bool;
    
    private var _status : Int;
    
    private var _type : String;
    
    private var _auditedSize : Bool;
    
    private var _dispatchProgress : Bool;
    
    public var vars : Dynamic;
    
    private var _cachedBytesTotal : Int;
    
    private var _time : Int;
    
    private var _content;
    
    private var _rootLoader : LoaderMax;
    
    private var _cacheIsDirty : Bool;
    
    private var _cachedBytesLoaded : Int;
    
    public var autoDispose : Bool;
    
    public function new(vars : Dynamic = null)
    {
        var p : Dynamic = null;
        super();
        this.vars = (vars != null) ? vars : { };
        if (this.vars.isGSVars)
        {
            this.vars = this.vars.vars;
        }
        this.name = (this.vars.name != null && Std.string(this.vars.name) != "") ? this.vars.name : "loader" + _loaderCount++;
        _cachedBytesLoaded = 0;
        _cachedBytesTotal = (as3hx.Compat.parseInt(this.vars.estimatedBytes) != 0) ? as3hx.Compat.parseInt(as3hx.Compat.parseInt(this.vars.estimatedBytes)) : as3hx.Compat.parseInt(LoaderMax.defaultEstimatedBytes);
        this.autoDispose = cast(this.vars.autoDispose == true, Bool);
        _status = (this.vars.paused == true) ? as3hx.Compat.parseInt(LoaderStatus.PAUSED) : as3hx.Compat.parseInt(LoaderStatus.READY);
        _auditedSize = cast(as3hx.Compat.parseInt(this.vars.estimatedBytes) != 0 && this.vars.auditSize != true, Bool);
        if (_globalRootLoader == null)
        {
            if (this.vars.__isRoot == true)
            {
                return;
            }
            _globalRootLoader = new LoaderMax({
                        name : "root",
                        __isRoot : true
                    });
            _isLocal = cast(Capabilities.playerType == "Desktop" || new LocalConnection().domain == "localhost", Bool);
        }
        _rootLoader = (Std.is(this.vars.requireWithRoot, DisplayObject)) ? _rootLookup[this.vars.requireWithRoot] : _globalRootLoader;
        if (_rootLoader == null)
        {
            _rootLookup[this.vars.requireWithRoot] = _rootLoader = new LoaderMax();
            _rootLoader.name = "subloaded_swf_" + ((this.vars.requireWithRoot.loaderInfo != null) ? this.vars.requireWithRoot.loaderInfo.url : Std.string(_loaderCount));
            _rootLoader.skipFailed = false;
        }
        for (p in Reflect.fields(_listenerTypes))
        {
            if (Lambda.has(this.vars, p) && Std.is(this.vars[p], Function))
            {
                this.addEventListener(Reflect.field(_listenerTypes, Std.string(p)), this.vars[p], false, 0, true);
            }
        }
        _rootLoader.append(this);
    }
    
    private static function _activateClass(type : String, loaderClass : Class<Dynamic>, extensions : String) : Bool
    {
        if (type != "")
        {
            Reflect.setField(_types, Std.string(type.toLowerCase()), loaderClass);
        }
        var a : Array<Dynamic> = extensions.split(",");
        var i : Int = a.length;
        while (--i > -1)
        {
            Reflect.setField(_extensions, Std.string(a[i]), loaderClass);
        }
        return true;
    }
    
    private function _errorHandler(event : Event) : Void
    {
        var target : Dynamic = event.target;
        target = (Std.is(event, LoaderEvent) && this.exists("getChildren")) ? event.target : this;
        var text : String = "";
        if (event.exists("error") && Std.is(cast((event), Object).error, Error))
        {
            text = cast((event), Object).error.message;
        }
        else if (event.exists("text"))
        {
            text = cast((event), Object).text;
        }
        if (event.type != LoaderEvent.ERROR && event.type != LoaderEvent.FAIL && this.hasEventListener(event.type))
        {
            dispatchEvent(new LoaderEvent(event.type, target, text, event));
        }
        if (event.type != "uncaughtError")
        {
            trace("----\nError on " + Std.string(this) + ": " + text + "\n----");
            if (this.hasEventListener(LoaderEvent.ERROR))
            {
                dispatchEvent(new LoaderEvent(LoaderEvent.ERROR, target, Std.string(this) + " > " + text, event));
            }
        }
    }
    
    private function _failHandler(event : Event, dispatchError : Bool = true) : Void
    {
        var target : Dynamic = null;
        _dump(0, LoaderStatus.FAILED, true);
        if (dispatchError)
        {
            _errorHandler(event);
        }
        else
        {
            target = event.target;
        }
        dispatchEvent(new LoaderEvent(LoaderEvent.FAIL, (Std.is(event, LoaderEvent) && this.exists("getChildren")) ? event.target : this, Std.string(this) + " > " + (try cast(event, Dynamic) catch(e:Dynamic) null).text, event));
        dispatchEvent(new LoaderEvent(LoaderEvent.CANCEL, this));
    }
    
    private function _completeHandler(event : Event = null) : Void
    {
        _cachedBytesLoaded = _cachedBytesTotal;
        if (_status != LoaderStatus.COMPLETED)
        {
            dispatchEvent(new LoaderEvent(LoaderEvent.PROGRESS, this));
            _status = LoaderStatus.COMPLETED;
            _time = as3hx.Compat.parseInt(Math.round(haxe.Timer.stamp() * 1000) - _time);
        }
        dispatchEvent(new LoaderEvent(LoaderEvent.COMPLETE, this));
        if (this.autoDispose)
        {
            dispose();
        }
    }
    
    private function get_rootLoader() : LoaderMax
    {
        return _rootLoader;
    }
    
    private function _progressHandler(event : Event) : Void
    {
        if (Std.is(event, ProgressEvent))
        {
            _cachedBytesLoaded = (try cast(event, ProgressEvent) catch(e:Dynamic) null).bytesLoaded;
            _cachedBytesTotal = (try cast(event, ProgressEvent) catch(e:Dynamic) null).bytesTotal;
            if (!_auditedSize)
            {
                _auditedSize = true;
                dispatchEvent(new Event("auditedSize"));
            }
        }
        if (_dispatchProgress && _status == LoaderStatus.LOADING && _cachedBytesLoaded != _cachedBytesTotal)
        {
            dispatchEvent(new LoaderEvent(LoaderEvent.PROGRESS, this));
        }
    }
    
    public function dispose(flushContent : Bool = false) : Void
    {
        _dump(!!(flushContent) ? 3 : 2, LoaderStatus.DISPOSED);
    }
    
    private function get_bytesTotal() : Int
    {
        if (_cacheIsDirty)
        {
            _calculateProgress();
        }
        return _cachedBytesTotal;
    }
    
    public function resume() : Void
    {
        this.paused = false;
        load(false);
    }
    
    private function get_paused() : Bool
    {
        return cast(_status == LoaderStatus.PAUSED, Bool);
    }
    
    private function _calculateProgress() : Void
    {
    }
    
    private function get_progress() : Float
    {
        return (this.bytesTotal != 0) ? as3hx.Compat.parseFloat(_cachedBytesLoaded / _cachedBytesTotal) : ((_status == LoaderStatus.COMPLETED) ? 1 : 0);
    }
    
    public function prioritize(loadNow : Bool = true) : Void
    {
        dispatchEvent(new Event("prioritize"));
        if (loadNow && _status != LoaderStatus.COMPLETED && _status != LoaderStatus.LOADING)
        {
            load(false);
        }
    }
    
    override public function addEventListener(type : String, listener : Function, useCapture : Bool = false, priority : Int = 0, useWeakReference : Bool = false) : Void
    {
        if (type == LoaderEvent.PROGRESS)
        {
            _dispatchProgress = true;
        }
        else if (type == LoaderEvent.CHILD_PROGRESS && Std.is(this, LoaderMax))
        {
            _dispatchChildProgress = true;
        }
        super.addEventListener(type, listener, useCapture, priority, useWeakReference);
    }
    
    private function get_bytesLoaded() : Int
    {
        if (_cacheIsDirty)
        {
            _calculateProgress();
        }
        return _cachedBytesLoaded;
    }
    
    private function _dump(scrubLevel : Int = 0, newStatus : Int = 0, suppressEvents : Bool = false) : Void
    {
        var p : Dynamic = null;
        _content = null;
        var isLoading : Bool = cast(_status == LoaderStatus.LOADING, Bool);
        if (_status == LoaderStatus.PAUSED && newStatus != LoaderStatus.PAUSED && newStatus != LoaderStatus.FAILED)
        {
            _prePauseStatus = newStatus;
        }
        else if (_status != LoaderStatus.DISPOSED)
        {
            _status = newStatus;
        }
        if (isLoading)
        {
            _time = as3hx.Compat.parseInt(Math.round(haxe.Timer.stamp() * 1000) - _time);
        }
        _cachedBytesLoaded = 0;
        if (_status < LoaderStatus.FAILED)
        {
            if (Std.is(this, LoaderMax))
            {
                _calculateProgress();
            }
            if (_dispatchProgress && !suppressEvents)
            {
                dispatchEvent(new LoaderEvent(LoaderEvent.PROGRESS, this));
            }
        }
        if (!suppressEvents)
        {
            if (isLoading)
            {
                dispatchEvent(new LoaderEvent(LoaderEvent.CANCEL, this));
            }
            if (scrubLevel != 2)
            {
                dispatchEvent(new LoaderEvent(LoaderEvent.UNLOAD, this));
            }
        }
        if (newStatus == LoaderStatus.DISPOSED)
        {
            if (!suppressEvents)
            {
                dispatchEvent(new Event("dispose"));
            }
            for (p in Reflect.fields(_listenerTypes))
            {
                if (Lambda.has(this.vars, p) && Std.is(this.vars[p], Function))
                {
                    this.removeEventListener(Reflect.field(_listenerTypes, Std.string(p)), this.vars[p]);
                }
            }
        }
    }
    
    private function _load() : Void
    {
    }
    
    private function get_loadTime() : Float
    {
        if (_status == LoaderStatus.READY)
        {
            return 0;
        }
        if (_status == LoaderStatus.LOADING)
        {
            return (Math.round(haxe.Timer.stamp() * 1000) - _time) / 1000;
        }
        return _time / 1000;
    }
    
    private function get_auditedSize() : Bool
    {
        return _auditedSize;
    }
    
    private function set_paused(value : Bool) : Bool
    {
        if (value && _status != LoaderStatus.PAUSED)
        {
            _prePauseStatus = _status;
            if (_status == LoaderStatus.LOADING)
            {
                _dump(0, LoaderStatus.PAUSED);
            }
            _status = LoaderStatus.PAUSED;
        }
        else if (!value && _status == LoaderStatus.PAUSED)
        {
            if (_prePauseStatus == LoaderStatus.LOADING)
            {
                load(false);
            }
            else
            {
                _status = (_prePauseStatus || as3hx.Compat.parseInt(LoaderStatus.READY)) ? 1 : 0;
            }
        }
        return value;
    }
    
    private function _passThroughEvent(event : Event) : Void
    {
        var type : String = event.type;
        var target : Dynamic = this;
        if (this.exists("getChildren"))
        {
            if (Std.is(event, LoaderEvent))
            {
                target = event.target;
            }
            if (type == "complete")
            {
                type = "childComplete";
            }
            else if (type == "open")
            {
                type = "childOpen";
            }
            else if (type == "cancel")
            {
                type = "childCancel";
            }
            else if (type == "fail")
            {
                type = "childFail";
            }
        }
        if (this.hasEventListener(type))
        {
            dispatchEvent(new LoaderEvent(type, target, !!(event.exists("text")) ? cast((event), Object).text : "", (Std.is(event, LoaderEvent) && cast((event), LoaderEvent).data != null) ? cast((event), LoaderEvent).data : event));
        }
    }
    
    public function load(flushContent : Bool = false) : Void
    {
        var time : Int = Math.round(haxe.Timer.stamp() * 1000);
        if (this.status == LoaderStatus.PAUSED)
        {
            _status = (_prePauseStatus <= LoaderStatus.LOADING) ? as3hx.Compat.parseInt(LoaderStatus.READY) : _prePauseStatus;
            if (_status == LoaderStatus.READY && Std.is(this, LoaderMax))
            {
                time -= _time;
            }
        }
        if (flushContent || _status == LoaderStatus.FAILED)
        {
            _dump(1, LoaderStatus.READY);
        }
        if (_status == LoaderStatus.READY)
        {
            _status = LoaderStatus.LOADING;
            _time = time;
            _load();
            if (this.progress < 1)
            {
                dispatchEvent(new LoaderEvent(LoaderEvent.OPEN, this));
            }
        }
        else if (_status == LoaderStatus.COMPLETED)
        {
            _completeHandler(null);
        }
    }
    
    override public function toString() : String
    {
        return _type + " \'" + this.name + "\'" + ((Std.is(this, LoaderItem)) ? " (" + (try cast(this, LoaderItem) catch(e:Dynamic) null).url + ")" : "");
    }
    
    private function get_status() : Int
    {
        return _status;
    }
    
    public function pause() : Void
    {
        this.paused = true;
    }
    
    private function get_content() : Dynamic
    {
        return _content;
    }
    
    public function cancel() : Void
    {
        if (_status == LoaderStatus.LOADING)
        {
            _dump(0, LoaderStatus.READY);
        }
    }
    
    public function auditSize() : Void
    {
    }
    
    public function unload() : Void
    {
        _dump(1, LoaderStatus.READY);
    }
}

