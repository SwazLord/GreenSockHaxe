package com.greensock.loading;

import flash.errors.Error;
import com.greensock.events.LoaderEvent;
import com.greensock.loading.core.DisplayObjectLoader;
import com.greensock.loading.core.LoaderCore;
import flash.display.AVM1Movie;
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.MovieClip;
import flash.events.Event;
import flash.media.SoundTransform;

@:meta(Event(name="securityError",type="com.greensock.events.LoaderEvent"))

@:meta(Event(name="httpStatus",type="com.greensock.events.LoaderEvent"))

@:meta(Event(name="scriptAccessDenied",type="com.greensock.events.LoaderEvent"))

@:meta(Event(name="childCancel",type="com.greensock.events.LoaderEvent"))

@:meta(Event(name="childFail",type="com.greensock.events.LoaderEvent"))

@:meta(Event(name="childComplete",type="com.greensock.events.LoaderEvent"))

@:meta(Event(name="childProgress",type="com.greensock.events.LoaderEvent"))

@:meta(Event(name="childOpen",type="com.greensock.events.LoaderEvent"))

class SWFLoader extends DisplayObjectLoader
{
    
    private static var _classActivated : Bool = _activateClass("SWFLoader", SWFLoader, "swf");
    
    
    private var _queue : LoaderMax;
    
    private var _loaderFailed : Bool;
    
    private var _rslAddedCount : Int;
    
    private var _loadOnExitStealth : Bool;
    
    private var _hasRSL : Bool;
    
    private var _loaderCompleted : Bool;
    
    private var _lastPTUncaughtError : Event;
    
    public function new(urlOrRequest : Dynamic, vars : Dynamic = null)
    {
        super(urlOrRequest, vars);
        _preferEstimatedBytesInAudit = true;
        _type = "SWFLoader";
    }
    
    override private function set_url(value : String) : String
    {
        if (_url != value)
        {
            if (_status == LoaderStatus.LOADING && !_initted && !_loaderFailed)
            {
                _loadOnExitStealth = true;
            }
            super.url = value;
        }
        return value;
    }
    
    override private function _errorHandler(event : Event) : Void
    {
        if (!_suppressUncaughtError(event))
        {
            super._errorHandler(event);
        }
    }
    
    override private function _determineScriptAccess() : Void
    {
        var mc : DisplayObject = null;
        try
        {
            mc = _loader.content;
        }
        catch (error : Error)
        {
            _scriptAccessDenied = true;
            dispatchEvent(new LoaderEvent(LoaderEvent.SCRIPT_ACCESS_DENIED, this, error.message));
            return;
        }
        if (Std.is(_loader.content, AVM1Movie))
        {
            _scriptAccessDenied = true;
            dispatchEvent(new LoaderEvent(LoaderEvent.SCRIPT_ACCESS_DENIED, this, "AVM1Movie denies script access"));
        }
    }
    
    override private function _load() : Void
    {
        if (_stealthMode)
        {
            _stealthMode = _loadOnExitStealth;
        }
        else if (!_initted)
        {
            _loader.visible = false;
            _sprite.addChild(_loader);
            super._load();
        }
        else if (_queue != null)
        {
            _changeQueueListeners(true);
            _queue.load(false);
        }
    }
    
    public function getClass(className : String) : Class<Dynamic>
    {
        var result : Dynamic = null;
        var loaders : Array<Dynamic> = null;
        var i : Int = 0;
        if (_content == null || _scriptAccessDenied)
        {
            return null;
        }
        if (_content.loaderInfo.applicationDomain.hasDefinition(className))
        {
            return _content.loaderInfo.applicationDomain.getDefinition(className);
        }
        if (_queue != null)
        {
            loaders = _queue.getChildren(true, true);
            i = loaders.length;
            while (--i > -1)
            {
                if (Std.is(loaders[i], SWFLoader))
                {
                    result = (try cast(loaders[i], SWFLoader) catch(e:Dynamic) null).getClass(className);
                    if (result != null)
                    {
                        return Type.getClass(result);
                    }
                }
            }
        }
        return null;
    }
    
    public function getContent(nameOrURL : String) : Dynamic
    {
        if (nameOrURL == this.name || nameOrURL == _url)
        {
            return this.content;
        }
        var loader : LoaderCore = this.getLoader(nameOrURL);
        return (loader != null) ? loader.content : null;
    }
    
    override private function _failHandler(event : Event, dispatchError : Bool = true) : Void
    {
        if ((event.type == "ioError" || event.type == "securityError") && event.target == _loader.contentLoaderInfo)
        {
            _loaderFailed = true;
            if (_loadOnExitStealth)
            {
                _dump(1, _status, true);
                _load();
                return;
            }
        }
        if (event.target == _queue)
        {
            _status = LoaderStatus.FAILED;
            _time = Math.round(haxe.Timer.stamp() * 1000) - _time;
            dispatchEvent(new LoaderEvent(LoaderEvent.CANCEL, this));
            dispatchEvent(new LoaderEvent(LoaderEvent.FAIL, this, Std.string(this) + " > " + (try cast(event, Dynamic) catch(e:Dynamic) null).text));
            return;
        }
        super._failHandler(event, dispatchError);
    }
    
    override private function _refreshLoader(unloadContent : Bool = true) : Void
    {
        super._refreshLoader(unloadContent);
        _loaderCompleted = false;
    }
    
    public function getLoader(nameOrURL : String) : Dynamic
    {
        return (_queue != null) ? _queue.getLoader(nameOrURL) : null;
    }
    
    override private function _dump(scrubLevel : Int = 0, newStatus : Int = 0, suppressEvents : Bool = false) : Void
    {
        var content : Dynamic = null;
        _loaderCompleted = false;
        if (_status == LoaderStatus.LOADING && !_initted && !_loaderFailed)
        {
            _stealthMode = true;
            super._dump(scrubLevel, newStatus, suppressEvents);
            return;
        }
        if (_initted && !_scriptAccessDenied && scrubLevel != 2)
        {
            _stopMovieClips(_loader.content);
            if (Lambda.has(_rootLookup, _loader.content))
            {
                _queue = cast((_rootLookup[_loader.content]), LoaderMax);
                _changeQueueListeners(false);
                if (scrubLevel == 0)
                {
                    _queue.cancel();
                }
                else
                {
                    ;
                    _queue.dispose(cast(scrubLevel != 2, Bool));
                }
            }
        }
        if (_stealthMode)
        {
            try
            {
                _loader.close();
            }
            catch (error : Error)
            {
            }
        }
        _loadOnExitStealth = false;
        _stealthMode = _hasRSL = _loaderFailed = false;
        _cacheIsDirty = true;
        if (scrubLevel >= 1)
        {
            _queue = null;
            _initted = false;
            super._dump(scrubLevel, newStatus, suppressEvents);
        }
        else
        {
            content = _content;
            super._dump(scrubLevel, newStatus, suppressEvents);
            _content = content;
        }
    }
    
    private function _stopMovieClips(obj : DisplayObject) : Void
    {
        var mc : MovieClip = try cast(obj, MovieClip) catch(e:Dynamic) null;
        if (mc == null)
        {
            return;
        }
        mc.stop();
        var i : Int = mc.numChildren;
        while (--i > -1)
        {
            _stopMovieClips(mc.getChildAt(i));
        }
    }
    
    private function _checkRequiredLoaders() : Void
    {
        if (_queue == null && this.vars.integrateProgress != false && !_scriptAccessDenied && _content != null)
        {
            _queue = _rootLookup[_content];
            if (_queue != null)
            {
                _changeQueueListeners(true);
                _queue.load(false);
                _cacheIsDirty = true;
            }
        }
    }
    
    override private function _completeHandler(event : Event = null) : Void
    {
        var st : SoundTransform = null;
        _loaderCompleted = true;
        _checkRequiredLoaders();
        _calculateProgress();
        if (this.progress == 1)
        {
            if (!_scriptAccessDenied && this.vars.autoPlay == false && Std.is(_content, MovieClip))
            {
                st = _content.soundTransform;
                st.volume = 1;
                _content.soundTransform = st;
            }
            _changeQueueListeners(false);
            super._determineScriptAccess();
            super._completeHandler(event);
        }
    }
    
    private function _changeQueueListeners(add : Bool) : Void
    {
        var p : Dynamic = null;
        if (_queue != null)
        {
            if (add && this.vars.integrateProgress != false)
            {
                for (p in Reflect.fields(_listenerTypes))
                {
                    if (p != "onProgress" && p != "onInit")
                    {
                        _queue.addEventListener(Reflect.field(_listenerTypes, Std.string(p)), _passThroughEvent, false, -100, true);
                    }
                }
                _queue.addEventListener(LoaderEvent.COMPLETE, _completeHandler, false, -100, true);
                _queue.addEventListener(LoaderEvent.PROGRESS, _progressHandler, false, -100, true);
                _queue.addEventListener(LoaderEvent.FAIL, _failHandler, false, -100, true);
            }
            else
            {
                _queue.removeEventListener(LoaderEvent.COMPLETE, _completeHandler);
                _queue.removeEventListener(LoaderEvent.PROGRESS, _progressHandler);
                _queue.removeEventListener(LoaderEvent.FAIL, _failHandler);
                for (p in Reflect.fields(_listenerTypes))
                {
                    if (p != "onProgress" && p != "onInit")
                    {
                        _queue.removeEventListener(Reflect.field(_listenerTypes, Std.string(p)), _passThroughEvent);
                    }
                }
            }
        }
    }
    
    override private function _initHandler(event : Event) : Void
    {
        var awaitingLoad : Bool = false;
        var tempContent : DisplayObject = null;
        var className : String = null;
        var rslPreloader : Dynamic = null;
        if (_stealthMode)
        {
            _initted = true;
            awaitingLoad = _loadOnExitStealth;
            _dump((_status == LoaderStatus.DISPOSED) ? 3 : 1, _status, true);
            if (awaitingLoad)
            {
                _load();
            }
            return;
        }
        _hasRSL = false;
        try
        {
            tempContent = _loader.content;
            className = Type.getClassName(tempContent);
            if (className.substr(-13) == "__Preloader__")
            {
                rslPreloader = Reflect.field(tempContent, "__rslPreloader");
                if (rslPreloader != null)
                {
                    className = Type.getClassName(rslPreloader);
                    if (className == "fl.rsl::RSLPreloader")
                    {
                        _hasRSL = true;
                        _rslAddedCount = 0;
                        tempContent.addEventListener(Event.ADDED, _rslAddedHandler);
                    }
                }
            }
        }
        catch (error : Error)
        {
        }
        if (!_hasRSL)
        {
            _init();
        }
    }
    
    private function _rslAddedHandler(event : Event) : Void
    {
        if (Std.is(event.target, DisplayObject) && Std.is(event.currentTarget, DisplayObjectContainer) && event.target.parent == event.currentTarget)
        {
            ++_rslAddedCount;
        }
        if (_rslAddedCount > 1)
        {
            event.currentTarget.removeEventListener(Event.ADDED, _rslAddedHandler);
            if (_status == LoaderStatus.LOADING)
            {
                _content = event.target;
                _init();
                _calculateProgress();
                dispatchEvent(new LoaderEvent(LoaderEvent.PROGRESS, this));
                _completeHandler(null);
            }
        }
    }
    
    override private function _passThroughEvent(event : Event) : Void
    {
        if (!(event.type == "uncaughtError" && _suppressUncaughtError(event)) && event.target != _queue)
        {
            super._passThroughEvent(event);
        }
    }
    
    override private function _progressHandler(event : Event) : Void
    {
        var bl : Int = 0;
        var bt : Int = 0;
        if (_status == LoaderStatus.LOADING)
        {
            if (_queue == null && _initted)
            {
                _checkRequiredLoaders();
            }
            if (_dispatchProgress)
            {
                bl = _cachedBytesLoaded;
                bt = _cachedBytesTotal;
                _calculateProgress();
                if (_cachedBytesLoaded != _cachedBytesTotal && (bl != _cachedBytesLoaded || bt != _cachedBytesTotal))
                {
                    dispatchEvent(new LoaderEvent(LoaderEvent.PROGRESS, this));
                }
            }
            else
            {
                _cacheIsDirty = true;
            }
        }
    }
    
    private function _init() : Void
    {
        var st : SoundTransform = null;
        _determineScriptAccess();
        if (!_scriptAccessDenied)
        {
            if (!_hasRSL)
            {
                _content = _loader.content;
            }
            if (_content != null)
            {
                if (this.vars.autoPlay == false && Std.is(_content, MovieClip))
                {
                    st = _content.soundTransform;
                    st.volume = 0;
                    _content.soundTransform = st;
                    _content.stop();
                }
                _checkRequiredLoaders();
            }
            if (_loader.parent == _sprite)
            {
                if (_sprite.stage != null && this.vars.suppressInitReparentEvents == true)
                {
                    _sprite.addEventListener(Event.ADDED_TO_STAGE, _captureFirstEvent, true, 1000, true);
                    _loader.addEventListener(Event.REMOVED_FROM_STAGE, _captureFirstEvent, true, 1000, true);
                }
                _sprite.removeChild(_loader);
            }
        }
        else
        {
            _content = _loader;
            _loader.visible = true;
        }
        super._initHandler(null);
    }
    
    private function _captureFirstEvent(event : Event) : Void
    {
        event.stopImmediatePropagation();
        event.currentTarget.removeEventListener(event.type, _captureFirstEvent);
    }
    
    override private function _calculateProgress() : Void
    {
        _cachedBytesLoaded = !!(_stealthMode) ? 0 : as3hx.Compat.parseInt(_loader.contentLoaderInfo.bytesLoaded);
        if (_loader.contentLoaderInfo.bytesTotal != 0)
        {
            _cachedBytesTotal = _loader.contentLoaderInfo.bytesTotal;
        }
        if (_cachedBytesTotal < _cachedBytesLoaded || _loaderCompleted)
        {
            _cachedBytesTotal = _cachedBytesLoaded;
        }
        if (this.vars.integrateProgress != false)
        {
            if (_queue != null && (as3hx.Compat.parseInt(this.vars.estimatedBytes) < _cachedBytesLoaded || _queue.auditedSize))
            {
                if (_queue.status <= LoaderStatus.COMPLETED)
                {
                    _cachedBytesLoaded += _queue.bytesLoaded;
                    _cachedBytesTotal += _queue.bytesTotal;
                }
            }
            else if (as3hx.Compat.parseInt(this.vars.estimatedBytes) > _cachedBytesLoaded && (!_initted || _queue != null && _queue.status <= LoaderStatus.COMPLETED && !_queue.auditedSize))
            {
                _cachedBytesTotal = as3hx.Compat.parseInt(this.vars.estimatedBytes);
            }
        }
        if (_hasRSL && _content == null || !_initted && _cachedBytesLoaded == _cachedBytesTotal)
        {
            _cachedBytesLoaded = as3hx.Compat.parseInt(_cachedBytesLoaded * 0.99);
        }
        _cacheIsDirty = false;
    }
    
    public function getChildren(includeNested : Bool = false, omitLoaderMaxes : Bool = false) : Array<Dynamic>
    {
        return (_queue != null) ? _queue.getChildren(includeNested, omitLoaderMaxes) : [];
    }
    
    public function getSWFChild(name : String) : DisplayObject
    {
        return !(_scriptAccessDenied && Std.is(_content, DisplayObjectContainer)) ? cast((_content), DisplayObjectContainer).getChildByName(name) : null;
    }
    
    private function _suppressUncaughtError(event : Event) : Bool
    {
        if (Std.is(event, LoaderEvent) && Std.is(cast((event), LoaderEvent).data, Event))
        {
            event = try cast(cast((event), LoaderEvent).data, Event) catch(e:Dynamic) null;
        }
        if (event.type == "uncaughtError")
        {
            if (_lastPTUncaughtError == (_lastPTUncaughtError = event))
            {
                return true;
            }
            if (this.vars.suppressUncaughtErrors == true)
            {
                event.preventDefault();
                event.stopImmediatePropagation();
                return true;
            }
        }
        return false;
    }
}

