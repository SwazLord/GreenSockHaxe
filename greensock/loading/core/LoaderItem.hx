package com.greensock.loading.core;

import flash.errors.Error;
import com.greensock.events.LoaderEvent;
import com.greensock.loading.LoaderMax;
import com.greensock.loading.LoaderStatus;
import flash.events.Event;
import flash.events.ProgressEvent;
import flash.net.URLRequest;
import flash.net.URLStream;
import flash.net.URLVariables;

@:meta(Event(name="ioError",type="com.greensock.events.LoaderEvent"))

class LoaderItem extends LoaderCore
{
    public var scriptAccessDenied(get, never) : Bool;
    public var request(get, never) : URLRequest;
    public var url(get, set) : String;
    public var httpStatus(get, never) : Int;

    
    private static var _underlineExp : as3hx.Compat.Regex = new as3hx.Compat.Regex('%5f', "gi");
    
    private static var _cacheID : Float = Date.now().getTime();
    
    
    private var _auditStream : URLStream;
    
    private var _request : URLRequest;
    
    private var _skipAlternateURL : Bool;
    
    private var _scriptAccessDenied : Bool;
    
    private var _url : String;
    
    private var _preferEstimatedBytesInAudit : Bool;
    
    private var _httpStatus : Int;
    
    public function new(urlOrRequest : Dynamic, vars : Dynamic = null)
    {
        super(vars);
        _request = (Std.is(urlOrRequest, URLRequest)) ? try cast(urlOrRequest, URLRequest) catch(e:Dynamic) null : new URLRequest(urlOrRequest);
        _url = _request.url;
        _setRequestURL(_request, _url);
    }
    
    private function get_scriptAccessDenied() : Bool
    {
        return _scriptAccessDenied;
    }
    
    override private function _failHandler(event : Event, dispatchError : Bool = true) : Void
    {
        if (this.vars.alternateURL != null && this.vars.alternateURL != "" && !_skipAlternateURL)
        {
            _errorHandler(event);
            _skipAlternateURL = true;
            _url = "temp" + Date.now().getTime();
            this.url = this.vars.alternateURL;
        }
        else
        {
            super._failHandler(event, dispatchError);
        }
    }
    
    private function get_request() : URLRequest
    {
        return _request;
    }
    
    private function _httpStatusHandler(event : Event) : Void
    {
        _httpStatus = (try cast(event, Dynamic) catch(e:Dynamic) null).status;
        dispatchEvent(new LoaderEvent(event.type, this, Std.string(_httpStatus), event));
    }
    
    override private function _dump(scrubLevel : Int = 0, newStatus : Int = 0, suppressEvents : Bool = false) : Void
    {
        _closeStream();
        super._dump(scrubLevel, newStatus, suppressEvents);
    }
    
    private function _closeStream() : Void
    {
        if (_auditStream != null)
        {
            _auditStream.removeEventListener(ProgressEvent.PROGRESS, _auditStreamHandler);
            _auditStream.removeEventListener(Event.COMPLETE, _auditStreamHandler);
            _auditStream.removeEventListener("ioError", _auditStreamHandler);
            _auditStream.removeEventListener("securityError", _auditStreamHandler);
            try
            {
                _auditStream.close();
            }
            catch (error : Error)
            {
            }
            _auditStream = null;
        }
    }
    
    private function set_url(value : String) : String
    {
        var isLoading : Bool = false;
        if (_url != value)
        {
            _url = value;
            _setRequestURL(_request, _url);
            isLoading = cast(_status == LoaderStatus.LOADING, Bool);
            _dump(1, LoaderStatus.READY, true);
            _auditedSize = cast(as3hx.Compat.parseInt(this.vars.estimatedBytes) != 0 && this.vars.auditSize != true, Bool);
            _cachedBytesTotal = (as3hx.Compat.parseInt(this.vars.estimatedBytes) != 0) ? as3hx.Compat.parseInt(as3hx.Compat.parseInt(this.vars.estimatedBytes)) : as3hx.Compat.parseInt(LoaderMax.defaultEstimatedBytes);
            _cacheIsDirty = true;
            if (isLoading)
            {
                _load();
            }
        }
        return value;
    }
    
    private function get_httpStatus() : Int
    {
        return _httpStatus;
    }
    
    private function _prepRequest() : Void
    {
        _scriptAccessDenied = false;
        _httpStatus = 0;
        _closeStream();
        if (this.vars.noCache && (!_isLocal || _url.substr(0, 4) == "http"))
        {
            _setRequestURL(_request, _url, "gsCacheBusterID=" + _cacheID++);
        }
    }
    
    private function _setRequestURL(request : URLRequest, url : String, extraParams : String = "") : Void
    {
        var data : URLVariables = null;
        var pair : Array<Dynamic> = null;
        var a : Array<Dynamic> = (cast(this.vars.allowMalformedURL, Bool)) ? [url] : url.split("?");
        var s : String = a[0];
        var parsedURL : String = "";
        for (i in 0...s.length)
        {
            parsedURL += s.charAt(i);
        }
        request.url = parsedURL;
        if (a.length >= 2)
        {
            extraParams += (extraParams == "") ? a[1] : "&" + a[1];
        }
        if (extraParams != "")
        {
            data = new URLVariables((Std.is(request.data, URLVariables)) ? Std.string(request.data) : null);
            a = extraParams.split("&");
            i = a.length;
            while (--i > -1)
            {
                pair = a[i].split("=");
                data[pair.shift()] = pair.join("=");
            }
            request.data = Std.string(data).replace(_underlineExp, "_");
            if (this.vars.allowMalformedURL)
            {
                request.url += (request.url.indexOf("?") == -(1) ? "?" : "&") + Std.string(request.data);
                request.data = null;
            }
        }
        if (_isLocal && this.vars.allowMalformedURL != true && _request.data != null && _request.url.substr(0, 4) != "http")
        {
            _request.method = "POST";
        }
    }
    
    private function _auditStreamHandler(event : Event) : Void
    {
        var request : URLRequest = null;
        if (Std.is(event, ProgressEvent))
        {
            _cachedBytesTotal = (try cast(event, ProgressEvent) catch(e:Dynamic) null).bytesTotal;
            if (_preferEstimatedBytesInAudit && as3hx.Compat.parseInt(this.vars.estimatedBytes) > _cachedBytesTotal)
            {
                _cachedBytesTotal = as3hx.Compat.parseInt(this.vars.estimatedBytes);
            }
        }
        else if (event.type == "ioError" || event.type == "securityError")
        {
            if (this.vars.alternateURL != null && this.vars.alternateURL != "" && this.vars.alternateURL != _url)
            {
                _errorHandler(event);
                if (_status != LoaderStatus.DISPOSED)
                {
                    _url = this.vars.alternateURL;
                    _setRequestURL(_request, _url);
                    request = new URLRequest();
                    request.data = _request.data;
                    request.method = _request.method;
                    _setRequestURL(request, _url, !(_isLocal || _url.substr(0, 4) == "http") ? "gsCacheBusterID=" + _cacheID++ + "&purpose=audit" : "");
                    _auditStream.load(request);
                }
                return;
            }
            super._failHandler(event);
        }
        _auditedSize = true;
        _closeStream();
        dispatchEvent(new Event("auditedSize"));
    }
    
    private function get_url() : String
    {
        return _url;
    }
    
    override public function auditSize() : Void
    {
        var request : URLRequest = null;
        if (_auditStream == null)
        {
            _auditStream = new URLStream();
            _auditStream.addEventListener(ProgressEvent.PROGRESS, _auditStreamHandler, false, 0, true);
            _auditStream.addEventListener(Event.COMPLETE, _auditStreamHandler, false, 0, true);
            _auditStream.addEventListener("ioError", _auditStreamHandler, false, 0, true);
            _auditStream.addEventListener("securityError", _auditStreamHandler, false, 0, true);
            request = new URLRequest();
            request.data = _request.data;
            request.method = _request.method;
            _setRequestURL(request, _url, !(_isLocal || _url.substr(0, 4) == "http") ? "gsCacheBusterID=" + _cacheID++ + "&purpose=audit" : "");
            _auditStream.load(request);
        }
    }
}

