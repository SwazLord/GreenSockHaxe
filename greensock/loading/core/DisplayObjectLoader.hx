package com.greensock.loading.core;

import flash.errors.Error;
import com.greensock.events.LoaderEvent;
import com.greensock.loading.LoaderMax;
import com.greensock.loading.LoaderStatus;
import com.greensock.loading.display.ContentDisplay;
import flash.display.DisplayObject;
import flash.display.Loader;
import flash.display.Sprite;
import flash.events.ErrorEvent;
import flash.events.Event;
import flash.events.ProgressEvent;
import flash.net.LocalConnection;
import flash.net.URLRequest;
import flash.system.ApplicationDomain;
import flash.system.Capabilities;
import flash.system.LoaderContext;
import flash.system.Security;
import flash.system.SecurityDomain;

class DisplayObjectLoader extends LoaderItem
{
    public var rawContent(get, never) : Dynamic;

    
    private static var _gcDispatcher : Sprite;
    
    public static var defaultAutoForceGC : Bool = true;
    
    private static var _gcCycles : Int = 0;
    
    
    private var _initted : Bool;
    
    private var _stealthMode : Bool;
    
    private var _fallbackAudit : Loader;
    
    private var _sprite : Sprite;
    
    private var _context : LoaderContext;
    
    private var _loader : Loader;
    
    public function new(urlOrRequest : Dynamic, vars : Dynamic = null)
    {
        super(urlOrRequest, vars);
        _refreshLoader(false);
        if (Std.is(LoaderMax.contentDisplayClass, Class))
        {
            _sprite = new loaderMax.ContentDisplayClass(this);
            if (!_sprite.exists("rawContent"))
            {
                throw new Error("LoaderMax.contentDisplayClass must be set to a class with a \'rawContent\' property, like com.greensock.loading.display.ContentDisplay");
            }
        }
        else
        {
            _sprite = new ContentDisplay(this);
        }
    }
    
    private static function _forceGCHandler(event : Event) : Void
    {
        if (--_gcCycles <= 0)
        {
            _gcDispatcher.removeEventListener(Event.ENTER_FRAME, _forceGCHandler);
            _gcDispatcher = null;
        }
        try
        {
            new LocalConnection().connect("FORCE_GC");
            new LocalConnection().connect("FORCE_GC");
        }
        catch (error : Error)
        {
        }
    }
    
    public static function forceGC(cycles : Int = 1) : Void
    {
        if (_gcCycles < cycles)
        {
            _gcCycles = cycles;
            if (_gcDispatcher == null)
            {
                _gcDispatcher = new Sprite();
                _gcDispatcher.addEventListener(Event.ENTER_FRAME, _forceGCHandler, false, 0, true);
            }
        }
    }
    
    private function _determineScriptAccess() : Void
    {
        if (!_scriptAccessDenied)
        {
            if (!_loader.contentLoaderInfo.childAllowsParent)
            {
                _scriptAccessDenied = true;
                dispatchEvent(new LoaderEvent(LoaderEvent.SCRIPT_ACCESS_DENIED, this, "Error #2123: Security sandbox violation: " + this + ". No policy files granted access."));
            }
        }
    }
    
    override private function _load() : Void
    {
        _prepRequest();
        if (Std.is(this.vars.context, LoaderContext))
        {
            _context = this.vars.context;
        }
        else if (_context == null)
        {
            if (LoaderMax.defaultContext != null)
            {
                _context = LoaderMax.defaultContext;
                if (_isLocal)
                {
                    _context.securityDomain = null;
                }
            }
            else if (!_isLocal)
            {
                _context = new LoaderContext(true, new ApplicationDomain(ApplicationDomain.currentDomain), SecurityDomain.currentDomain);
            }
        }
        if (Capabilities.playerType != "Desktop")
        {
            Security.allowDomain(_url);
        }
        _loader.load(_request, _context);
    }
    
    public function setContentDisplay(contentDisplay : Sprite) : Void
    {
        _sprite = contentDisplay;
    }
    
    override private function _dump(scrubLevel : Int = 0, newStatus : Int = 0, suppressEvents : Bool = false) : Void
    {
        if (!_stealthMode)
        {
            _refreshLoader(cast(scrubLevel != 2, Bool));
        }
        if (scrubLevel == 1)
        {
            (try cast(_sprite, Dynamic) catch(e:Dynamic) null).rawContent = null;
        }
        else if (scrubLevel == 2)
        {
            (try cast(_sprite, Dynamic) catch(e:Dynamic) null).loader = null;
        }
        else if (scrubLevel == 3)
        {
            (try cast(_sprite, Dynamic) catch(e:Dynamic) null).dispose(false, false);
        }
        super._dump(scrubLevel, newStatus, suppressEvents);
    }
    
    private function _refreshLoader(unloadContent : Bool = true) : Void
    {
        if (_loader != null)
        {
            if (_status == LoaderStatus.LOADING)
            {
                try
                {
                    _loader.close();
                }
                catch (error : Error)
                {
                }
            }
            _loader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS, _progressHandler);
            _loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, _completeHandler);
            _loader.contentLoaderInfo.removeEventListener("ioError", _failHandler);
            _loader.contentLoaderInfo.removeEventListener("securityError", _securityErrorHandler);
            _loader.contentLoaderInfo.removeEventListener("httpStatus", _httpStatusHandler);
            _loader.contentLoaderInfo.removeEventListener("httpResponseStatus", _httpStatusHandler);
            _loader.contentLoaderInfo.removeEventListener(Event.INIT, _initHandler);
            if (_loader.exists("uncaughtErrorEvents"))
            {
                cast((_loader), Object).uncaughtErrorEvents.removeEventListener("uncaughtError", _errorHandler);
            }
            if (unloadContent)
            {
                try
                {
                    if (_loader.parent == null && _sprite != null)
                    {
                        _sprite.addChild(_loader);
                    }
                    if (_loader.exists("unloadAndStop"))
                    {
                        (try cast(_loader, Dynamic) catch(e:Dynamic) null).unloadAndStop();
                    }
                    else
                    {
                        _loader.unload();
                    }
                }
                catch (error : Error)
                {
                }
                if (_loader.parent)
                {
                    _loader.parent.removeChild(_loader);
                }
                if ((Lambda.has(this.vars, "autoForceGC")) ? cast(this.vars.autoForceGC, Bool) : cast(defaultAutoForceGC, Bool))
                {
                    forceGC(!!(this.exists("getClass")) ? 3 : 1);
                }
            }
        }
        _initted = false;
        _loader = new Loader();
        _loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, _progressHandler, false, 0, true);
        _loader.contentLoaderInfo.addEventListener(Event.COMPLETE, _completeHandler, false, 0, true);
        _loader.contentLoaderInfo.addEventListener("ioError", _failHandler, false, 0, true);
        _loader.contentLoaderInfo.addEventListener("securityError", _securityErrorHandler, false, 0, true);
        _loader.contentLoaderInfo.addEventListener("httpStatus", _httpStatusHandler, false, 0, true);
        _loader.contentLoaderInfo.addEventListener("httpResponseStatus", _httpStatusHandler, false, 0, true);
        _loader.contentLoaderInfo.addEventListener(Event.INIT, _initHandler, false, 0, true);
        if (_loader.exists("uncaughtErrorEvents"))
        {
            cast((_loader), Object).uncaughtErrorEvents.addEventListener("uncaughtError", _errorHandler, false, 0, true);
        }
    }
    
    override private function _closeStream() : Void
    {
        _closeFallbackAudit();
        super._closeStream();
    }
    
    private function _initHandler(event : Event) : Void
    {
        if (!_initted)
        {
            _initted = true;
            if (_content == null)
            {
                _content = !!(_scriptAccessDenied) ? _loader : _loader.content;
            }
            (try cast(_sprite, Dynamic) catch(e:Dynamic) null).rawContent = try cast(_content, DisplayObject) catch(e:Dynamic) null;
            dispatchEvent(new LoaderEvent(LoaderEvent.INIT, this));
        }
    }
    
    private function _securityErrorHandler(event : ErrorEvent) : Void
    {
        if (_context != null && _context.checkPolicyFile && !(Std.is(this.vars.context, LoaderContext)))
        {
            _context = new LoaderContext(false);
            _scriptAccessDenied = true;
            dispatchEvent(new LoaderEvent(LoaderEvent.SCRIPT_ACCESS_DENIED, this, event.text));
            _errorHandler(event);
            _load();
        }
        else
        {
            _failHandler(event);
        }
    }
    
    private function _closeFallbackAudit() : Void
    {
        if (_fallbackAudit != null)
        {
            _fallbackAudit.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, _auditStreamHandler, false, 0, true);
            _fallbackAudit.contentLoaderInfo.addEventListener(Event.COMPLETE, _auditStreamHandler, false, 0, true);
            _fallbackAudit.contentLoaderInfo.addEventListener("ioError", _auditStreamHandler, false, 0, true);
            _fallbackAudit.contentLoaderInfo.addEventListener("securityError", _auditStreamHandler, false, 0, true);
            try
            {
                _fallbackAudit.close();
            }
            catch (error : Error)
            {
            }
            _fallbackAudit = null;
        }
    }
    
    override private function _auditStreamHandler(event : Event) : Void
    {
        var request : URLRequest = null;
        if (event.type == "securityError")
        {
            if (_fallbackAudit == null)
            {
                _context = new LoaderContext(false);
                _scriptAccessDenied = true;
                dispatchEvent(new LoaderEvent(LoaderEvent.SCRIPT_ACCESS_DENIED, this, cast((event), ErrorEvent).text));
                _errorHandler(event);
                _fallbackAudit = new Loader();
                _fallbackAudit.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, _auditStreamHandler, false, 0, true);
                _fallbackAudit.contentLoaderInfo.addEventListener(Event.COMPLETE, _auditStreamHandler, false, 0, true);
                _fallbackAudit.contentLoaderInfo.addEventListener("ioError", _auditStreamHandler, false, 0, true);
                _fallbackAudit.contentLoaderInfo.addEventListener("securityError", _auditStreamHandler, false, 0, true);
                request = new URLRequest();
                request.data = _request.data;
                request.method = _request.method;
                _setRequestURL(request, _url, !(_isLocal || _url.substr(0, 4) == "http") ? "gsCacheBusterID=" + _cacheID++ + "&purpose=audit" : "");
                if (Capabilities.playerType != "Desktop")
                {
                    Security.allowDomain(_url);
                }
                _fallbackAudit.load(request, _context);
                return;
            }
            _closeFallbackAudit();
        }
        super._auditStreamHandler(event);
    }
    
    private function get_rawContent() : Dynamic
    {
        return _content;
    }
    
    override private function get_content() : Dynamic
    {
        return _sprite;
    }
    
    override public function auditSize() : Void
    {
        if (Capabilities.playerType != "Desktop")
        {
            Security.allowDomain(_url);
        }
        super.auditSize();
    }
}

