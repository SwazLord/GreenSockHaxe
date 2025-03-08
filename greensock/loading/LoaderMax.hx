package com.greensock.loading;

import flash.errors.Error;
import com.greensock.events.LoaderEvent;
import com.greensock.loading.core.LoaderCore;
import com.greensock.loading.core.LoaderItem;
import flash.display.DisplayObject;
import flash.events.Event;
import flash.net.URLRequest;
import flash.system.LoaderContext;
import flash.utils.Dictionary;

@:meta(Event(name="securityError",type="com.greensock.events.LoaderEvent"))

@:meta(Event(name="ioError",type="com.greensock.events.LoaderEvent"))

@:meta(Event(name="httpStatus",type="com.greensock.events.LoaderEvent"))

@:meta(Event(name="scriptAccessDenied",type="com.greensock.events.LoaderEvent"))

@:meta(Event(name="childCancel",type="com.greensock.events.LoaderEvent"))

@:meta(Event(name="childFail",type="com.greensock.events.LoaderEvent"))

@:meta(Event(name="childComplete",type="com.greensock.events.LoaderEvent"))

@:meta(Event(name="childProgress",type="com.greensock.events.LoaderEvent"))

@:meta(Event(name="childOpen",type="com.greensock.events.LoaderEvent"))

class LoaderMax extends LoaderCore
{
    public var rawProgress(get, never) : Float;
    public var numChildren(get, never) : Int;

    
    public static var defaultContext : LoaderContext;
    
    public static var contentDisplayClass : Class<Dynamic>;
    
    public static var defaultEstimatedBytes : Int = 20000;
    
    public static inline var version : Float = 1.941;
    
    public static var defaultAuditSize : Bool = true;
    
    
    private var _loaders : Array<Dynamic>;
    
    public var skipPaused : Bool;
    
    public var maxConnections : Int;
    
    private var _activeLoaders : Dictionary;
    
    public var skipFailed : Bool;
    
    public var autoLoad : Bool;
    
    public function new(vars : Dynamic = null)
    {
        var i : Int = 0;
        super(vars);
        _type = "LoaderMax";
        _loaders = [];
        _activeLoaders = new Dictionary();
        this.skipFailed = cast(this.vars.skipFailed != false, Bool);
        this.skipPaused = cast(this.vars.skipPaused != false, Bool);
        this.autoLoad = cast(this.vars.autoLoad == true, Bool);
        this.maxConnections = (Lambda.has(this.vars, "maxConnections")) ? as3hx.Compat.parseInt(as3hx.Compat.parseInt(this.vars.maxConnections)) : 2;
        if (Std.is(this.vars.loaders, Array))
        {
            for (i in 0...this.vars.loaders.length)
            {
                insert(this.vars.loaders[i], i);
            }
        }
    }
    
    public static function getContent(nameOrURL : String) : Dynamic
    {
        return (_globalRootLoader != null) ? _globalRootLoader.getContent(nameOrURL) : null;
    }
    
    public static function getLoader(nameOrURL : String) : Dynamic
    {
        return (_globalRootLoader != null) ? _globalRootLoader.getLoader(nameOrURL) : null;
    }
    
    public static function parse(data : Dynamic, vars : Dynamic = null, childrenVars : Dynamic = null) : Dynamic
    {
        var queue : LoaderMax = null;
        var l : Int = 0;
        var i : Int = 0;
        var s : String = null;
        if (Std.is(data, Array))
        {
            queue = new LoaderMax(vars);
            l = data.length;
            for (i in 0...l)
            {
                queue.append(LoaderMax.parse(Reflect.field(data, Std.string(i)), childrenVars));
            }
            return queue;
        }
        if (Std.is(data, String) || Std.is(data, URLRequest))
        {
            s = (Std.is(data, String)) ? data : cast((data), URLRequest).url;
            s = s.toLowerCase().split("?")[0];
            s = s.substr(s.lastIndexOf(".") + 1);
            if (Lambda.has(_extensions, s))
            {
                return new Extensions()[s](data, vars);
            }
        }
        else if (Std.is(data, LoaderCore))
        {
            return try cast(data, LoaderCore) catch(e:Dynamic) null;
        }
        throw new Error("LoaderMax could not parse " + data + ". Don\'t forget to use LoaderMax.activate() to activate the necessary types of loaders.");
    }
    
    public static function registerFileType(extensions : String, loaderClass : Class<Dynamic>) : Void
    {
        _activateClass("", loaderClass, extensions);
    }
    
    public static function activate(loaderClasses : Array<Dynamic>) : Void
    {
    }
    
    public static function prioritize(nameOrURL : String, loadNow : Bool = true) : LoaderCore
    {
        var loader : LoaderCore = getLoader(nameOrURL);
        if (loader != null)
        {
            loader.prioritize(loadNow);
        }
        return loader;
    }
    
    public function getChildAt(index : Int) : Dynamic
    {
        return _loaders[index];
    }
    
    public function getContent(nameOrURL : String) : Dynamic
    {
        var loader : LoaderCore = this.getLoader(nameOrURL);
        return (loader != null) ? loader.content : null;
    }
    
    public function remove(loader : LoaderCore) : Void
    {
        _removeLoader(loader, true);
    }
    
    override private function _load() : Void
    {
        _loadNext(null);
    }
    
    private function _cancelActiveLoaders() : Void
    {
        var loader : LoaderCore = null;
        var i : Int = _loaders.length;
        while (--i > -1)
        {
            loader = _loaders[i];
            if (loader.status == LoaderStatus.LOADING)
            {
                This is an intentional compilation error. See the README for handling the delete keyword
                delete _activeLoaders[loader];
                _removeLoaderListeners(loader, false);
                loader.cancel();
            }
        }
    }
    
    private function _removeLoaderListeners(loader : LoaderCore, all : Bool) : Void
    {
        var p : Dynamic = null;
        loader.removeEventListener(LoaderEvent.COMPLETE, _loadNext);
        loader.removeEventListener(LoaderEvent.CANCEL, _loadNext);
        if (all)
        {
            loader.removeEventListener(LoaderEvent.PROGRESS, _progressHandler);
            loader.removeEventListener("prioritize", _prioritizeHandler);
            loader.removeEventListener("dispose", _disposeHandler);
            for (p in Reflect.fields(_listenerTypes))
            {
                if (p != "onProgress" && p != "onInit")
                {
                    loader.removeEventListener(Reflect.field(_listenerTypes, Std.string(p)), _passThroughEvent);
                }
            }
        }
    }
    
    private function _disposeHandler(event : Event) : Void
    {
        _removeLoader(cast((event.target), LoaderCore), false);
    }
    
    override public function auditSize() : Void
    {
        if (!this.auditedSize)
        {
            _auditSize(null);
        }
    }
    
    public function getChildIndex(loader : LoaderCore) : Int
    {
        var i : Int = _loaders.length;
        while (--i > -1)
        {
            if (_loaders[i] == loader)
            {
                return i;
            }
        }
        return 999999999;
    }
    
    public function prepend(loader : LoaderCore) : LoaderCore
    {
        return insert(loader, 0);
    }
    
    public function getLoader(nameOrURL : String) : Dynamic
    {
        var loader : LoaderCore = null;
        var i : Int = _loaders.length;
        while (--i > -1)
        {
            loader = _loaders[i];
            if (loader.name == nameOrURL || Std.is(loader, LoaderItem) && (try cast(loader, LoaderItem) catch(e:Dynamic) null).url == nameOrURL)
            {
                return loader;
            }
            if (loader.exists("getLoader"))
            {
                loader = try cast((try cast(loader, Dynamic) catch(e:Dynamic) null).getLoader(nameOrURL), LoaderCore) catch(e:Dynamic) null;
                if (loader != null)
                {
                    return loader;
                }
            }
        }
        return null;
    }
    
    public function prependURLs(prependText : String, includeNested : Bool = false) : Void
    {
        var loaders : Array<Dynamic> = getChildren(includeNested, true);
        var i : Int = loaders.length;
        while (--i > -1)
        {
            cast((loaders[i]), LoaderItem).url = prependText + cast((loaders[i]), LoaderItem).url;
        }
    }
    
    override private function _dump(scrubLevel : Int = 0, newStatus : Int = 0, suppressEvents : Bool = false) : Void
    {
        var i : Int = 0;
        if (newStatus == LoaderStatus.DISPOSED)
        {
            _status = LoaderStatus.DISPOSED;
            empty(true, cast(scrubLevel == 3, Bool));
            if (Std.is(this.vars.requireWithRoot, DisplayObject))
            {
                ;
            }
            _activeLoaders = null;
        }
        if (scrubLevel <= 1)
        {
            _cancelActiveLoaders();
        }
        if (scrubLevel == 1)
        {
            i = _loaders.length;
            while (--i > -1)
            {
                cast((_loaders[i]), LoaderCore).unload();
            }
        }
        super._dump(scrubLevel, newStatus, suppressEvents);
        _cacheIsDirty = true;
    }
    
    public function empty(disposeChildren : Bool = true, unloadAllContent : Bool = false) : Void
    {
        var i : Int = _loaders.length;
        while (--i > -1)
        {
            if (disposeChildren)
            {
                cast((_loaders[i]), LoaderCore).dispose(unloadAllContent);
            }
            else if (unloadAllContent)
            {
                cast((_loaders[i]), LoaderCore).unload();
            }
            else
            {
                _removeLoader(_loaders[i], true);
            }
        }
    }
    
    private function _removeLoader(loader : LoaderCore, rootLoaderAppend : Bool) : Void
    {
        if (loader == null)
        {
            return;
        }
        if (rootLoaderAppend && this != loader.rootLoader)
        {
            loader.rootLoader.append(loader);
        }
        _removeLoaderListeners(loader, true);
        _loaders.splice(getChildIndex(loader), 1);
        if (Lambda.has(_activeLoaders, loader))
        {
            This is an intentional compilation error. See the README for handling the delete keyword
            delete _activeLoaders[loader];
            loader.cancel();
            if (_status == LoaderStatus.LOADING)
            {
                _loadNext(null);
            }
        }
        _cacheIsDirty = true;
        _progressHandler(null);
    }
    
    private function get_rawProgress() : Float
    {
        var status : Int = 0;
        var loaded : Float = 0;
        var total : Int = 0;
        var i : Int = _loaders.length;
        while (--i > -1)
        {
            status = cast((_loaders[i]), LoaderCore).status;
            if (status != LoaderStatus.DISPOSED && !(status == LoaderStatus.PAUSED && this.skipPaused) && !(status == LoaderStatus.FAILED && this.skipFailed))
            {
                total++;
                loaded += (Std.is(_loaders[i], LoaderMax)) ? cast((_loaders[i]), LoaderMax).rawProgress : cast((_loaders[i]), LoaderCore).progress;
            }
        }
        return (total == 0) ? 0 : as3hx.Compat.parseFloat(loaded / total);
    }
    
    private function _loadNext(event : Event = null) : Void
    {
        var audit : Bool = false;
        var loader : LoaderCore = null;
        var loaders : Array<Dynamic> = null;
        var l : Int = 0;
        var activeCount : Int = 0;
        var i : Int = 0;
        if (event != null && _activeLoaders != null)
        {
            This is an intentional compilation error. See the README for handling the delete keyword
            delete _activeLoaders[null];
            _removeLoaderListeners(cast((event.target), LoaderCore), false);
        }
        if (_status == LoaderStatus.LOADING)
        {
            audit = (Lambda.has(this.vars, "auditSize")) ? cast(cast(this.vars.auditSize, Bool), Bool) : cast(LoaderMax.defaultAuditSize, Bool);
            if (audit && !this.auditedSize)
            {
                _auditSize(null);
                return;
            }
            loaders = _loaders.copy();
            l = loaders.length;
            activeCount = 0;
            _calculateProgress();
            for (i in 0...l)
            {
                loader = loaders[i];
                if (!this.skipPaused && loader.status == LoaderStatus.PAUSED)
                {
                    super._failHandler(new LoaderEvent(LoaderEvent.FAIL, this, "Did not complete LoaderMax because skipPaused was false and " + Std.string(loader) + " was paused."), false);
                    return;
                }
                if (!this.skipFailed && loader.status == LoaderStatus.FAILED)
                {
                    super._failHandler(new LoaderEvent(LoaderEvent.FAIL, this, "Did not complete LoaderMax because skipFailed was false and " + Std.string(loader) + " failed."), false);
                    return;
                }
                if (loader.status <= LoaderStatus.LOADING)
                {
                    activeCount++;
                    if (!(Lambda.has(_activeLoaders, loader)))
                    {
                        Reflect.setField(_activeLoaders, Std.string(loader), true);
                        loader.addEventListener(LoaderEvent.COMPLETE, _loadNext, false, -100, true);
                        loader.addEventListener(LoaderEvent.CANCEL, _loadNext, false, -100, true);
                        loader.load(false);
                    }
                    if (activeCount == this.maxConnections)
                    {
                        break;
                    }
                }
            }
            if (activeCount == 0 && _cachedBytesLoaded == _cachedBytesTotal)
            {
                _completeHandler(null);
            }
        }
    }
    
    public function append(loader : LoaderCore) : LoaderCore
    {
        return insert(loader, _loaders.length);
    }
    
    override private function _progressHandler(event : Event) : Void
    {
        var bl : Int = 0;
        var bt : Int = 0;
        if (_dispatchChildProgress && event != null)
        {
            dispatchEvent(new LoaderEvent(LoaderEvent.CHILD_PROGRESS, event.target));
        }
        if (_dispatchProgress && _status != LoaderStatus.DISPOSED)
        {
            bl = _cachedBytesLoaded;
            bt = _cachedBytesTotal;
            _calculateProgress();
            if (!(bl == 0 && _cachedBytesLoaded == 0))
            {
                if ((_cachedBytesLoaded != _cachedBytesTotal || _status != LoaderStatus.LOADING) && (bl != _cachedBytesLoaded || bt != _cachedBytesTotal))
                {
                    dispatchEvent(new LoaderEvent(LoaderEvent.PROGRESS, this));
                }
            }
        }
        else
        {
            _cacheIsDirty = true;
        }
    }
    
    private function _prioritizeHandler(event : Event) : Void
    {
        var prevMaxConnections : Int = 0;
        var loader : LoaderCore = try cast(event.target, LoaderCore) catch(e:Dynamic) null;
        _loaders.splice(getChildIndex(loader), 1);
        _loaders.unshift(loader);
        if (_status == LoaderStatus.LOADING && loader.status <= LoaderStatus.LOADING && !(Lambda.has(_activeLoaders, loader)))
        {
            _cancelActiveLoaders();
            prevMaxConnections = this.maxConnections;
            this.maxConnections = 1;
            _loadNext(null);
            this.maxConnections = prevMaxConnections;
        }
    }
    
    override private function _passThroughEvent(event : Event) : Void
    {
        super._passThroughEvent(event);
        if (!this.skipFailed && (event.type == "fail" || event.type == "childFail") && this.status == LoaderStatus.LOADING)
        {
            super._failHandler(new LoaderEvent(LoaderEvent.FAIL, this, "Did not complete LoaderMax because skipFailed was false and " + Std.string(event.target) + " failed."), false);
        }
    }
    
    override private function get_content() : Dynamic
    {
        var a : Array<Dynamic> = [];
        var i : Int = _loaders.length;
        while (--i > -1)
        {
            a[i] = cast((_loaders[i]), LoaderCore).content;
        }
        return a;
    }
    
    public function replaceURLText(fromText : String, toText : String, includeNested : Bool = false) : Void
    {
        var loader : LoaderItem = null;
        var loaders : Array<Dynamic> = getChildren(includeNested, true);
        var i : Int = loaders.length;
        while (--i > -1)
        {
            loader = loaders[i];
            loader.url = loader.url.split(fromText).join(toText);
            if (Lambda.has(loader.vars, "alternateURL"))
            {
                loader.vars.alternateURL = loader.vars.alternateURL.split(fromText).join(toText);
            }
        }
    }
    
    private function get_numChildren() : Int
    {
        return _loaders.length;
    }
    
    override private function get_auditedSize() : Bool
    {
        var maxStatus : Int = !!(this.skipPaused) ? as3hx.Compat.parseInt(LoaderStatus.COMPLETED) : as3hx.Compat.parseInt(LoaderStatus.PAUSED);
        var i : Int = _loaders.length;
        while (--i > -1)
        {
            if (!cast((_loaders[i]), LoaderCore).auditedSize && cast((_loaders[i]), LoaderCore).status <= maxStatus && _loaders[i].vars.auditSize != false)
            {
                return false;
            }
        }
        return true;
    }
    
    override private function get_status() : Int
    {
        var statusCounts : Array<Dynamic> = null;
        var i : Int = 0;
        if (_status == LoaderStatus.COMPLETED)
        {
            statusCounts = [0, 0, 0, 0, 0, 0];
            i = _loaders.length;
            while (--i > -1)
            {
                ++statusCounts[cast((_loaders[i]), LoaderCore).status];
            }
            if (!this.skipFailed && statusCounts[4] != 0 || !this.skipPaused && statusCounts[3] != 0)
            {
                _status = LoaderStatus.FAILED;
            }
            else if (statusCounts[0] + statusCounts[1] != 0)
            {
                _status = LoaderStatus.READY;
                _cacheIsDirty = true;
            }
        }
        return _status;
    }
    
    override private function _calculateProgress() : Void
    {
        var loader : LoaderCore = null;
        var s : Int = 0;
        _cachedBytesLoaded = 0;
        _cachedBytesTotal = 0;
        var i : Int = _loaders.length;
        while (--i > -1)
        {
            loader = _loaders[i];
            s = loader.status;
            if (s <= LoaderStatus.COMPLETED || !this.skipPaused && s == LoaderStatus.PAUSED || !this.skipFailed && s == LoaderStatus.FAILED)
            {
                _cachedBytesLoaded += loader.bytesLoaded;
                _cachedBytesTotal += loader.bytesTotal;
            }
        }
        _cacheIsDirty = false;
    }
    
    public function insert(loader : LoaderCore, index : Int = 999999999) : LoaderCore
    {
        var p : Dynamic = null;
        if (loader == null || loader == this || _status == LoaderStatus.DISPOSED)
        {
            return null;
        }
        if (this != loader.rootLoader)
        {
            _removeLoader(loader, false);
        }
        if (loader.rootLoader == _globalRootLoader)
        {
            loader.rootLoader.remove(loader);
        }
        if (index > _loaders.length)
        {
            index = _loaders.length;
        }
        as3hx.Compat.arraySplice(_loaders, index, 0, [loader]);
        if (this != _globalRootLoader)
        {
            for (p in Reflect.fields(_listenerTypes))
            {
                if (p != "onProgress" && p != "onInit")
                {
                    loader.addEventListener(Reflect.field(_listenerTypes, Std.string(p)), _passThroughEvent, false, -100, true);
                }
            }
            loader.addEventListener(LoaderEvent.PROGRESS, _progressHandler, false, -100, true);
            loader.addEventListener("prioritize", _prioritizeHandler, false, -100, true);
        }
        loader.addEventListener("dispose", _disposeHandler, false, -100, true);
        _cacheIsDirty = true;
        if (_status != LoaderStatus.LOADING)
        {
            if (_status != LoaderStatus.PAUSED)
            {
                _status = LoaderStatus.READY;
            }
            else if (_prePauseStatus == LoaderStatus.COMPLETED)
            {
                _prePauseStatus = LoaderStatus.READY;
            }
        }
        if (this.autoLoad && loader.status == LoaderStatus.READY)
        {
            if (_status != LoaderStatus.LOADING)
            {
                this.load(false);
            }
            else
            {
                _loadNext(null);
            }
        }
        return loader;
    }
    
    public function getChildren(includeNested : Bool = false, omitLoaderMaxes : Bool = false) : Array<Dynamic>
    {
        var a : Array<Dynamic> = [];
        var l : Int = _loaders.length;
        for (i in 0...l)
        {
            if (!omitLoaderMaxes || !(Std.is(_loaders[i], LoaderMax)))
            {
                a.push(_loaders[i]);
            }
            if (includeNested && _loaders[i].exists("getChildren"))
            {
                a = a.concat(_loaders[i].getChildren(true, omitLoaderMaxes));
            }
        }
        return a;
    }
    
    private function _auditSize(event : Event = null) : Void
    {
        var loader : LoaderCore = null;
        var found : Bool = false;
        if (event != null)
        {
            event.target.removeEventListener("auditedSize", _auditSize);
            event.target.removeEventListener(LoaderEvent.FAIL, _auditSize);
        }
        var l : Int = _loaders.length;
        var maxStatus : Int = !!(this.skipPaused) ? as3hx.Compat.parseInt(LoaderStatus.COMPLETED) : as3hx.Compat.parseInt(LoaderStatus.PAUSED);
        for (i in 0...l)
        {
            loader = _loaders[i];
            if (!loader.auditedSize && loader.status <= maxStatus && loader.vars.auditSize != false)
            {
                if (!found)
                {
                    loader.addEventListener("auditedSize", _auditSize, false, -100, true);
                    loader.addEventListener(LoaderEvent.FAIL, _auditSize, false, -100, true);
                }
                found = true;
                loader.auditSize();
            }
        }
        if (!found)
        {
            if (_status == LoaderStatus.LOADING)
            {
                _loadNext(null);
            }
            dispatchEvent(new Event("auditedSize"));
        }
    }
    
    public function getChildrenByStatus(status : Int, includeNested : Bool = false, omitLoaderMaxes : Bool = false) : Array<Dynamic>
    {
        var a : Array<Dynamic> = [];
        var loaders : Array<Dynamic> = getChildren(includeNested, omitLoaderMaxes);
        var l : Int = loaders.length;
        for (i in 0...l)
        {
            if (cast((loaders[i]), LoaderCore).status == status)
            {
                a.push(loaders[i]);
            }
        }
        return a;
    }
}

