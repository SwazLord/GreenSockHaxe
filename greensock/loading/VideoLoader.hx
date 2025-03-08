package com.greensock.loading;

import flash.errors.Error;
import haxe.Constraints.Function;
import com.greensock.events.LoaderEvent;
import com.greensock.loading.core.LoaderItem;
import com.greensock.loading.display.ContentDisplay;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.NetStatusEvent;
import flash.events.ProgressEvent;
import flash.events.TimerEvent;
import flash.media.SoundTransform;
import flash.media.Video;
import flash.net.NetConnection;
import flash.net.NetStream;
import flash.net.URLRequest;
import flash.utils.Timer;

@:meta(Event(name="netStatus",type="com.greensock.events.LoaderEvent"))

@:meta(Event(name="httpStatus",type="com.greensock.events.LoaderEvent"))

class VideoLoader extends LoaderItem
{
    public var playProgress(get, set) : Float;
    public var bufferMode(get, set) : Bool;
    public var videoPaused(get, set) : Bool;
    public var volume(get, set) : Float;
    public var soundTransform(get, set) : SoundTransform;
    public var stageVideo(get, set) : Dynamic;
    public var rawContent(get, never) : Video;
    public var autoDetachNetStream(get, set) : Bool;
    public var netStream(get, never) : NetStream;
    public var bufferProgress(get, never) : Float;
    public var duration(get, never) : Float;
    public var videoTime(get, set) : Float;

    
    public static inline var VIDEO_CUE_POINT : String = "videoCuePoint";
    
    public static inline var PLAY_PROGRESS : String = "playProgress";
    
    public static inline var VIDEO_BUFFER_FULL : String = "videoBufferFull";
    
    public static inline var VIDEO_BUFFER_EMPTY : String = "videoBufferEmpty";
    
    public static inline var VIDEO_PLAY : String = "videoPlay";
    
    public static inline var VIDEO_PAUSE : String = "videoPause";
    
    public static inline var VIDEO_COMPLETE : String = "videoComplete";
    
    private static var _classActivated : Bool = _activateClass("VideoLoader", VideoLoader, "flv,f4v,mp4,mov");
    
    
    private var _dispatchPlayProgress : Bool;
    
    private var _sound : SoundTransform;
    
    private var _prevCueTime : Float;
    
    private var _finalFrame : Bool;
    
    private var _volume : Float;
    
    public var metaData : Dynamic;
    
    private var _nc : NetConnection;
    
    private var _ns : NetStream;
    
    private var _repeatCount : Int;
    
    private var _video : Video;
    
    private var _bufferFull : Bool;
    
    private var _renderTimer : Timer;
    
    private var _pausePending : Bool;
    
    private var _auditNS : NetStream;
    
    private var _bufferMode : Bool;
    
    private var _renderedOnce : Bool;
    
    private var _stageVideo : Dynamic;
    
    private var _autoDetachNetStream : Bool;
    
    private var _initted : Bool;
    
    private var _videoPaused : Bool;
    
    private var _videoComplete : Bool;
    
    private var _forceTime : Float;
    
    private var _sprite : Sprite;
    
    private var _playStarted : Bool;
    
    private var _duration : Float;
    
    private var _firstCuePoint : CuePoint;
    
    public var autoAdjustBuffer : Bool;
    
    private var _prevTime : Float;
    
    public function new(urlOrRequest : Dynamic, vars : Dynamic = null)
    {
        super(urlOrRequest, vars);
        _type = "VideoLoader";
        _nc = new NetConnection();
        _nc.connect(null);
        _nc.addEventListener("asyncError", _failHandler, false, 0, true);
        _nc.addEventListener("securityError", _failHandler, false, 0, true);
        _renderTimer = new Timer(80, 0);
        _renderTimer.addEventListener(TimerEvent.TIMER, _renderHandler, false, 0, true);
        _video = new Video(as3hx.Compat.parseInt(this.vars.width) || 320, as3hx.Compat.parseInt(this.vars.height) || 240);
        _video.smoothing = cast(this.vars.smoothing != false, Bool);
        _video.deblocking = as3hx.Compat.parseInt(this.vars.deblocking);
        _video.addEventListener(Event.ADDED_TO_STAGE, _videoAddedToStage, false, 0, true);
        _video.addEventListener(Event.REMOVED_FROM_STAGE, _videoRemovedFromStage, false, 0, true);
        _stageVideo = this.vars.stageVideo;
        _autoDetachNetStream = cast(this.vars.autoDetachNetStream == true, Bool);
        _refreshNetStream();
        _duration = !!(Math.isNaN(this.vars.estimatedDuration)) ? 200 : as3hx.Compat.parseFloat(as3hx.Compat.parseFloat(this.vars.estimatedDuration));
        _bufferMode = _preferEstimatedBytesInAudit = cast(this.vars.bufferMode == true, Bool);
        _videoPaused = _pausePending = cast(this.vars.autoPlay == false, Bool);
        this.autoAdjustBuffer = this.vars.autoAdjustBuffer != false;
        this.volume = (Lambda.has(this.vars, "volume")) ? as3hx.Compat.parseFloat(as3hx.Compat.parseFloat(this.vars.volume)) : 1;
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
        cast((_sprite), Object).rawContent = null;
    }
    
    public function getCuePointTime(name : String) : Float
    {
        var i : Int = 0;
        if (this.metaData != null && Std.is(this.metaData.cuePoints, Array))
        {
            i = this.metaData.cuePoints.length;
            while (--i > -1)
            {
                if (name == this.metaData.cuePoints[i].name)
                {
                    return as3hx.Compat.parseFloat(this.metaData.cuePoints[i].time);
                }
            }
        }
        var cp : CuePoint = _firstCuePoint;
        while (cp)
        {
            if (cp.name == name)
            {
                return cp.time;
            }
            cp = cp.next;
        }
        return Math.NaN;
    }
    
    private function set_playProgress(value : Float) : Float
    {
        if (_duration != 0)
        {
            gotoVideoTime(value * _duration, !_videoPaused, true);
        }
        return value;
    }
    
    private function get_bufferMode() : Bool
    {
        return _bufferMode;
    }
    
    private function set_bufferMode(value : Bool) : Bool
    {
        _bufferMode = value;
        _preferEstimatedBytesInAudit = _bufferMode;
        _calculateProgress();
        if (_cachedBytesLoaded < _cachedBytesTotal && _status == LoaderStatus.COMPLETED)
        {
            _status = LoaderStatus.LOADING;
            _sprite.addEventListener(Event.ENTER_FRAME, _loadingProgressCheck);
        }
        return value;
    }
    
    public function setContentDisplay(contentDisplay : Sprite) : Void
    {
        _sprite = contentDisplay;
    }
    
    private function _onBufferFull() : Void
    {
        if (!_renderedOnce && !_renderTimer.running)
        {
            _waitForRender();
            return;
        }
        if (_pausePending)
        {
            if (!_initted && Math.round(haxe.Timer.stamp() * 1000) - _time < 10000)
            {
                _video.attachNetStream(null);
            }
            else if (_renderedOnce)
            {
                _applyPendingPause();
            }
        }
        else if (!_bufferFull)
        {
            _bufferFull = true;
            dispatchEvent(new LoaderEvent(VIDEO_BUFFER_FULL, this));
        }
    }
    
    private function set_videoPaused(value : Bool) : Bool
    {
        var changed : Bool = cast(value != _videoPaused, Bool);
        _videoPaused = value;
        if (_videoPaused)
        {
            if (!_renderedOnce)
            {
                _setForceTime(0);
                _pausePending = true;
                _sound.volume = 0;
                _ns.soundTransform = _sound;
            }
            else
            {
                _pausePending = false;
                this.volume = _volume;
                _ns.pause();
            }
            if (changed)
            {
                dispatchEvent(new LoaderEvent(VIDEO_PAUSE, this));
            }
        }
        else
        {
            if (_pausePending || !_bufferFull)
            {
                if (_stageVideo != null)
                {
                    _stageVideo.attachNetStream(_ns);
                }
                else if (_video.stage != null)
                {
                    _video.attachNetStream(_ns);
                }
                if (_initted && _renderedOnce)
                {
                    _seek(this.videoTime);
                }
                _pausePending = false;
            }
            this.volume = _volume;
            _ns.resume();
            if (changed && _playStarted)
            {
                dispatchEvent(new LoaderEvent(VIDEO_PLAY, this));
            }
        }
        return value;
    }
    
    public function gotoVideoCuePoint(name : String, forcePlay : Bool = false, skipCuePoints : Bool = true) : Float
    {
        return gotoVideoTime(getCuePointTime(name), forcePlay, skipCuePoints);
    }
    
    private function get_volume() : Float
    {
        return _volume;
    }
    
    private function get_soundTransform() : SoundTransform
    {
        return _sound;
    }
    
    private function _forceInit() : Void
    {
        if (_ns.bufferTime >= _duration)
        {
            _ns.bufferTime = as3hx.Compat.parseInt(_duration - 1);
        }
        _initted = true;
        if (!_bufferFull && _ns.bufferLength >= _ns.bufferTime)
        {
            _onBufferFull();
        }
        cast((_sprite), Object).rawContent = _video;
        if (!_bufferFull && _pausePending && _renderedOnce && _video.stage != null)
        {
            _video.attachNetStream(null);
        }
        else if (_stageVideo != null)
        {
            _stageVideo.attachNetStream(_ns);
        }
        else if (!_autoDetachNetStream || _video.stage != null)
        {
            _video.attachNetStream(_ns);
        }
    }
    
    private function get_stageVideo() : Dynamic
    {
        return _stageVideo;
    }
    
    public function pauseVideo(event : Event = null) : Void
    {
        this.videoPaused = true;
    }
    
    private function get_rawContent() : Video
    {
        return _video;
    }
    
    override private function _calculateProgress() : Void
    {
        _cachedBytesLoaded = _ns.bytesLoaded;
        if (_cachedBytesLoaded > 1)
        {
            if (_bufferMode)
            {
                _cachedBytesTotal = _ns.bytesTotal * (_ns.bufferTime / _duration);
                if (_ns.bufferLength > 0)
                {
                    _cachedBytesLoaded = _ns.bufferLength / _ns.bufferTime * _cachedBytesTotal;
                }
            }
            else
            {
                _cachedBytesTotal = _ns.bytesTotal;
            }
            if (_cachedBytesTotal <= _cachedBytesLoaded)
            {
                _cachedBytesTotal = (this.metaData != null && _renderedOnce && _initted || Math.round(haxe.Timer.stamp() * 1000) - _time >= 10000) ? as3hx.Compat.parseInt(_cachedBytesLoaded) : as3hx.Compat.parseInt(as3hx.Compat.parseInt(1.01 * _cachedBytesLoaded) + 1);
            }
            if (!_auditedSize)
            {
                _auditedSize = true;
                dispatchEvent(new Event("auditedSize"));
            }
        }
        _cacheIsDirty = false;
    }
    
    public function clearVideo() : Void
    {
        _video.smoothing = false;
        _video.clear();
        _video.smoothing = this.vars.smoothing != false;
        _video.clear();
    }
    
    private function set_soundTransform(value : SoundTransform) : SoundTransform
    {
        _ns.soundTransform = _sound = value;
        return value;
    }
    
    private function set_volume(value : Float) : Float
    {
        _sound.volume = _volume = value;
        _ns.soundTransform = _sound;
        return value;
    }
    
    override private function _auditStreamHandler(event : Event) : Void
    {
        if (Std.is(event, ProgressEvent) && _bufferMode)
        {
            (try cast(event, ProgressEvent) catch(e:Dynamic) null).bytesTotal *= _ns.bufferTime / _duration;
        }
        super._auditStreamHandler(event);
    }
    
    private function _refreshNetStream() : Void
    {
        if (_ns != null)
        {
            _ns.pause();
            try
            {
                _ns.close();
            }
            catch (error : Error)
            {
            }
            _sprite.removeEventListener(Event.ENTER_FRAME, _playProgressHandler);
            _video.attachNetStream(null);
            _video.clear();
            _ns.client = { };
            _ns.removeEventListener(NetStatusEvent.NET_STATUS, _statusHandler);
            _ns.removeEventListener("ioError", _failHandler);
            _ns.removeEventListener("asyncError", _failHandler);
            _ns.removeEventListener(Event.RENDER, _renderHandler);
        }
        _prevTime = _prevCueTime = 0;
        _ns = (Std.is(this.vars.netStream, NetStream)) ? this.vars.netStream : new NetStream(_nc);
        _ns.checkPolicyFile = cast(this.vars.checkPolicyFile == true, Bool);
        _ns.client = {
                    onMetaData : _metaDataHandler
                };
        _ns.addEventListener(NetStatusEvent.NET_STATUS, _statusHandler, false, 0, true);
        _ns.addEventListener("ioError", _failHandler, false, 0, true);
        _ns.addEventListener("asyncError", _failHandler, false, 0, true);
        _ns.bufferTime = !!(Math.isNaN(this.vars.bufferTime)) ? 5 : as3hx.Compat.parseFloat(as3hx.Compat.parseFloat(this.vars.bufferTime));
        if (_stageVideo != null)
        {
            _stageVideo.attachNetStream(_ns);
        }
        else if (!_autoDetachNetStream || _video.stage != null)
        {
            _video.attachNetStream(_ns);
        }
        _sound = _ns.soundTransform;
    }
    
    public function repeatCount(value : Int = 0) : Dynamic
    {
        if (!arguments.length)
        {
            return _repeatCount;
        }
        if (value < as3hx.Compat.parseInt(this.vars.repeat))
        {
            _videoComplete = false;
        }
        _repeatCount = value;
        return this;
    }
    
    private function set_stageVideo(value : Dynamic) : Dynamic
    {
        if (_stageVideo != value)
        {
            _stageVideo = value;
            if (_stageVideo != null)
            {
                _stageVideo.attachNetStream(_ns);
                _video.clear();
            }
            else
            {
                _video.attachNetStream(_ns);
            }
        }
        return value;
    }
    
    override public function addEventListener(type : String, listener : Function, useCapture : Bool = false, priority : Int = 0, useWeakReference : Bool = false) : Void
    {
        if (type == PLAY_PROGRESS)
        {
            _dispatchPlayProgress = true;
        }
        super.addEventListener(type, listener, useCapture, priority, useWeakReference);
    }
    
    private function _seek(time : Float) : Void
    {
        _ns.seek(time);
        _setForceTime(time);
        if (_bufferFull)
        {
            _bufferFull = false;
            dispatchEvent(new LoaderEvent(VIDEO_BUFFER_EMPTY, this));
        }
    }
    
    override private function get_content() : Dynamic
    {
        return _sprite;
    }
    
    private function get_autoDetachNetStream() : Bool
    {
        return _autoDetachNetStream;
    }
    
    override public function auditSize() : Void
    {
        var request : URLRequest = null;
        if (_url.substr(0, 4) == "http" && _url.indexOf("://") != -1)
        {
            super.auditSize();
        }
        else if (_auditNS == null)
        {
            _auditNS = new NetStream(_nc);
            _auditNS.bufferTime = !!(Math.isNaN(this.vars.bufferTime)) ? 5 : as3hx.Compat.parseFloat(as3hx.Compat.parseFloat(this.vars.bufferTime));
            _auditNS.client = {
                        onMetaData : _auditHandler,
                        onCuePoint : _auditHandler
                    };
            _auditNS.addEventListener(NetStatusEvent.NET_STATUS, _auditHandler, false, 0, true);
            _auditNS.addEventListener("ioError", _auditHandler, false, 0, true);
            _auditNS.addEventListener("asyncError", _auditHandler, false, 0, true);
            _auditNS.soundTransform = new SoundTransform(0);
            request = new URLRequest();
            request.data = _request.data;
            _setRequestURL(request, _url, !(_isLocal || _url.substr(0, 4) == "http") ? "gsCacheBusterID=" + _cacheID++ + "&purpose=audit" : "");
            _auditNS.play(request.url);
        }
    }
    
    private function get_netStream() : NetStream
    {
        return _ns;
    }
    
    private function get_playProgress() : Float
    {
        return !!(_videoComplete) ? 1 : as3hx.Compat.parseFloat(this.videoTime / _duration);
    }
    
    private function get_videoPaused() : Bool
    {
        return _videoPaused;
    }
    
    private function get_bufferProgress() : Float
    {
        if (as3hx.Compat.parseInt(_ns.bytesTotal) < 5)
        {
            return 0;
        }
        return (_ns.bufferLength > _ns.bufferTime) ? 1 : as3hx.Compat.parseFloat(_ns.bufferLength / _ns.bufferTime);
    }
    
    private function _videoRemovedFromStage(event : Event) : Void
    {
        if (_autoDetachNetStream)
        {
            _video.attachNetStream(null);
            _video.clear();
        }
    }
    
    private function get_duration() : Float
    {
        return _duration;
    }
    
    public function playVideo(event : Event = null) : Void
    {
        this.videoPaused = false;
    }
    
    private function _applyPendingPause() : Void
    {
        _pausePending = false;
        this.volume = _volume;
        _seek(_forceTime || 0);
        if (_stageVideo != null)
        {
            _stageVideo.attachNetStream(_ns);
            _ns.pause();
        }
        else if (!_autoDetachNetStream || _video.stage != null)
        {
            _video.cacheAsBitmap = false;
            _video.attachNetStream(_ns);
            _ns.pause();
        }
    }
    
    private function _videoAddedToStage(event : Event) : Void
    {
        if (_autoDetachNetStream)
        {
            if (!_pausePending)
            {
                _seek(this.videoTime);
            }
            if (_stageVideo != null)
            {
                _stageVideo.attachNetStream(_ns);
            }
            else
            {
                _video.attachNetStream(_ns);
            }
        }
    }
    
    override private function _load() : Void
    {
        var concatChar : String = null;
        _prepRequest();
        _repeatCount = 0;
        _prevTime = _prevCueTime = 0;
        _bufferFull = _playStarted = _renderedOnce = false;
        this.metaData = null;
        _pausePending = _videoPaused;
        if (_videoPaused)
        {
            _setForceTime(0);
            _sound.volume = 0;
            _ns.soundTransform = _sound;
        }
        else
        {
            this.volume = _volume;
        }
        _sprite.addEventListener(Event.ENTER_FRAME, _playProgressHandler);
        _sprite.addEventListener(Event.ENTER_FRAME, _loadingProgressCheck);
        _waitForRender();
        _videoComplete = _initted = false;
        if (this.vars.noCache && (!_isLocal || _url.substr(0, 4) == "http") && _request.data != null)
        {
            concatChar = _request.url.indexOf("?") != -(1) ? "&" : "?";
            _ns.play(_request.url + concatChar + Std.string(_request.data));
        }
        else
        {
            _ns.play(_request.url);
        }
    }
    
    private function _waitForRender() : Void
    {
        _ns.addEventListener(Event.RENDER, _renderHandler, false, 0, true);
        _renderTimer.reset();
        _renderTimer.start();
    }
    
    public function gotoVideoTime(time : Float, forcePlay : Bool = false, skipCuePoints : Bool = true) : Float
    {
        if (Math.isNaN(time) || _ns == null)
        {
            return Math.NaN;
        }
        if (time > _duration)
        {
            time = _duration;
        }
        var changed : Bool = time != this.videoTime;
        if (_initted && _renderedOnce && changed && !_finalFrame)
        {
            _seek(time);
        }
        else
        {
            _setForceTime(time);
        }
        _videoComplete = false;
        if (changed)
        {
            if (skipCuePoints)
            {
                _prevCueTime = time;
            }
            else
            {
                _playProgressHandler(null);
            }
        }
        if (forcePlay)
        {
            playVideo();
        }
        return time;
    }
    
    private function _auditHandler(event : Event = null) : Void
    {
        var request : URLRequest = null;
        var type : String = (event == null) ? "" : event.type;
        var code : String = event == null || !((Std.is(event, NetStatusEvent))) ? "" : cast((event), NetStatusEvent).info.code;
        if (event != null && Lambda.has(event, "duration"))
        {
            _duration = cast((event), Object).duration;
        }
        if (_auditNS != null)
        {
            _cachedBytesTotal = _auditNS.bytesTotal;
            if (_bufferMode && _duration != 0)
            {
                _cachedBytesTotal *= _auditNS.bufferTime / _duration;
            }
        }
        if (type == "ioError" || type == "asyncError" || code == "NetStream.Play.StreamNotFound" || code == "NetConnection.Connect.Failed" || code == "NetStream.Play.Failed" || code == "NetStream.Play.FileStructureInvalid" || code == "The MP4 doesn\'t contain any supported tracks")
        {
            if (this.vars.alternateURL != null && this.vars.alternateURL != "" && this.vars.alternateURL != _url)
            {
                _errorHandler(new LoaderEvent(LoaderEvent.ERROR, this, code));
                if (_status != LoaderStatus.DISPOSED)
                {
                    _url = this.vars.alternateURL;
                    _setRequestURL(_request, _url);
                    request = new URLRequest();
                    request.data = _request.data;
                    _setRequestURL(request, _url, !(_isLocal || _url.substr(0, 4) == "http") ? "gsCacheBusterID=" + _cacheID++ + "&purpose=audit" : "");
                    _auditNS.play(request.url);
                }
                return;
            }
            super._failHandler(new LoaderEvent(LoaderEvent.ERROR, this, code));
        }
        _auditedSize = true;
        _closeStream();
        dispatchEvent(new Event("auditedSize"));
    }
    
    public function addASCuePoint(time : Float, name : String = "", parameters : Dynamic = null) : Dynamic
    {
        var prev : CuePoint = _firstCuePoint;
        if (prev != null && prev.time > time)
        {
            prev = null;
        }
        else
        {
            while (prev && prev.time <= time && prev.next && prev.next.time <= time)
            {
                prev = prev.next;
            }
        }
        var cp : CuePoint = new CuePoint(time, name, parameters, prev);
        if (prev == null)
        {
            if (_firstCuePoint != null)
            {
                _firstCuePoint.prev = cp;
                cp.next = _firstCuePoint;
            }
            _firstCuePoint = cp;
        }
        return cp;
    }
    
    private function _playProgressHandler(event : Event) : Void
    {
        var prevTime : Float = Math.NaN;
        var prevCueTime : Float = Math.NaN;
        var next : CuePoint = null;
        var cp : CuePoint = null;
        if (!_bufferFull && !_videoComplete && (_ns.bufferLength >= _ns.bufferTime || this.duration - this.videoTime - _ns.bufferLength < 0.1))
        {
            _onBufferFull();
        }
        if (_bufferFull && (_firstCuePoint != null || _dispatchPlayProgress))
        {
            prevTime = _prevTime;
            prevCueTime = _prevCueTime;
            _prevTime = _prevCueTime = (((_forceTime != 0 && !Math.isNaN(_forceTime)) || _forceTime == 0) && _ns.time <= _duration) ? as3hx.Compat.parseFloat(_ns.time) : as3hx.Compat.parseFloat(this.videoTime);
            cp = _firstCuePoint;
            while (cp)
            {
                next = cp.next;
                if (cp.time > prevCueTime && cp.time <= _prevCueTime && !cp.gc)
                {
                    dispatchEvent(new LoaderEvent(VIDEO_CUE_POINT, this, "", cp));
                }
                cp = next;
            }
            if (_dispatchPlayProgress && prevTime != _prevTime)
            {
                dispatchEvent(new LoaderEvent(PLAY_PROGRESS, this));
            }
        }
    }
    
    override private function _dump(scrubLevel : Int = 0, newStatus : Int = 0, suppressEvents : Bool = false) : Void
    {
        if (_sprite == null)
        {
            return;
        }
        _sprite.removeEventListener(Event.ENTER_FRAME, _loadingProgressCheck);
        _sprite.removeEventListener(Event.ENTER_FRAME, _playProgressHandler);
        _sprite.removeEventListener(Event.ENTER_FRAME, _detachNS);
        _sprite.removeEventListener(Event.ENTER_FRAME, _finalFrameFinished);
        _ns.removeEventListener(Event.RENDER, _renderHandler);
        _renderTimer.stop();
        _forceTime = Math.NaN;
        _prevTime = _prevCueTime = 0;
        _initted = false;
        _renderedOnce = false;
        _videoComplete = false;
        this.metaData = null;
        if (scrubLevel != 2)
        {
            _refreshNetStream();
            (try cast(_sprite, Dynamic) catch(e:Dynamic) null).rawContent = null;
            if (_video.parent != null)
            {
                _video.parent.removeChild(_video);
            }
        }
        if (scrubLevel >= 2)
        {
            if (scrubLevel == 3)
            {
                (try cast(_sprite, Dynamic) catch(e:Dynamic) null).dispose(false, false);
            }
            _renderTimer.removeEventListener(TimerEvent.TIMER, _renderHandler);
            _nc.removeEventListener("asyncError", _failHandler);
            _nc.removeEventListener("securityError", _failHandler);
            _ns.removeEventListener(NetStatusEvent.NET_STATUS, _statusHandler);
            _ns.removeEventListener("ioError", _failHandler);
            _ns.removeEventListener("asyncError", _failHandler);
            _video.removeEventListener(Event.ADDED_TO_STAGE, _videoAddedToStage);
            _video.removeEventListener(Event.REMOVED_FROM_STAGE, _videoRemovedFromStage);
            _firstCuePoint = null;
            (try cast(_sprite, Dynamic) catch(e:Dynamic) null).gcProtect = (scrubLevel == 3) ? null : _ns;
            _ns.client = { };
            _video = null;
            _ns = null;
            _nc.close();
            _nc = null;
            _sound = null;
            (try cast(_sprite, Dynamic) catch(e:Dynamic) null).loader = null;
            _sprite = null;
            _renderTimer = null;
        }
        else
        {
            _duration = !!(Math.isNaN(this.vars.estimatedDuration)) ? 200 : as3hx.Compat.parseFloat(as3hx.Compat.parseFloat(this.vars.estimatedDuration));
            _videoPaused = _pausePending = cast(this.vars.autoPlay == false, Bool);
        }
        super._dump(scrubLevel, newStatus, suppressEvents);
    }
    
    private function _metaDataHandler(info : Dynamic) : Void
    {
        var a : Array<Dynamic> = null;
        var i : Int = 0;
        if (this.metaData == null || this.metaData.cuePoints == null)
        {
            this.metaData = info;
        }
        if (this.metaData.cuePoints)
        {
            a = this.metaData.cuePoints;
            i = a.length;
            while (--i > -1)
            {
                this.removeASCuePoint(a[i].name);
                this.addASCuePoint(a[i].time, a[i].name);
            }
        }
        _duration = info.duration;
        if (Lambda.has(info, "width"))
        {
            _video.width = as3hx.Compat.parseFloat(info.width);
            _video.height = as3hx.Compat.parseFloat(info.height);
        }
        if (Lambda.has(info, "framerate"))
        {
            _renderTimer.delay = as3hx.Compat.parseInt(1000 / as3hx.Compat.parseFloat(info.framerate) + 1);
        }
        if (!_initted)
        {
            _forceInit();
        }
        else
        {
            (try cast(_sprite, Dynamic) catch(e:Dynamic) null).rawContent = _video;
        }
        dispatchEvent(new LoaderEvent(LoaderEvent.INIT, this, "", info));
    }
    
    private function _finalFrameFinished(event : Event) : Void
    {
        _sprite.removeEventListener(Event.ENTER_FRAME, _finalFrameFinished);
        _finalFrame = false;
        if (!Math.isNaN(_forceTime))
        {
            _seek(_forceTime);
        }
    }
    
    private function _loadingProgressCheck(event : Event) : Void
    {
        var bl : Int = _cachedBytesLoaded;
        var bt : Int = _cachedBytesTotal;
        if (!_bufferFull && _ns.bufferLength >= _ns.bufferTime)
        {
            _onBufferFull();
        }
        _calculateProgress();
        if (_cachedBytesLoaded == _cachedBytesTotal)
        {
            _sprite.removeEventListener(Event.ENTER_FRAME, _loadingProgressCheck);
            if (!_bufferFull)
            {
                _onBufferFull();
            }
            if (_initted)
            {
                _completeHandler(event);
            }
            else
            {
                as3hx.Compat.setTimeout(function() : Dynamic
                        {
                            if (!_initted)
                            {
                                _forceInit();
                                _errorHandler(new LoaderEvent(LoaderEvent.ERROR, this, "No metaData was received."));
                            }
                            _completeHandler(event);
                        }, 100);
            }
        }
        else if (_dispatchProgress && _cachedBytesLoaded / _cachedBytesTotal != bl / bt)
        {
            dispatchEvent(new LoaderEvent(LoaderEvent.PROGRESS, this));
        }
    }
    
    private function set_videoTime(value : Float) : Float
    {
        gotoVideoTime(value, !_videoPaused, true);
        return value;
    }
    
    override private function _closeStream() : Void
    {
        if (_auditNS != null)
        {
            _auditNS.client = { };
            _auditNS.removeEventListener(NetStatusEvent.NET_STATUS, _auditHandler);
            _auditNS.removeEventListener("ioError", _auditHandler);
            _auditNS.removeEventListener("asyncError", _auditHandler);
            _auditNS.pause();
            try
            {
                _auditNS.close();
            }
            catch (error : Error)
            {
            }
            _auditNS = null;
        }
        else
        {
            super._closeStream();
        }
    }
    
    private function get_videoTime() : Float
    {
        if ((_forceTime != 0 && !Math.isNaN(_forceTime)) || _forceTime == 0)
        {
            return _forceTime;
        }
        if (_videoComplete)
        {
            return _duration;
        }
        if (_ns.time > _duration)
        {
            return _duration * 0.995;
        }
        return _ns.time;
    }
    
    private function _renderHandler(event : Event) : Void
    {
        _renderedOnce = true;
        if (!_videoPaused || _initted)
        {
            if (!_finalFrame)
            {
                _forceTime = Math.NaN;
                _renderTimer.stop();
                _ns.removeEventListener(Event.RENDER, _renderHandler);
            }
        }
        if (_pausePending)
        {
            if (_bufferFull)
            {
                _applyPendingPause();
            }
            else if (_video.stage != null)
            {
                _sprite.addEventListener(Event.ENTER_FRAME, _detachNS, false, 100, true);
            }
        }
        else if (_videoPaused && _initted)
        {
            _ns.pause();
        }
    }
    
    public function removeASCuePoint(timeNameOrCuePoint : Dynamic) : Dynamic
    {
        var cp : CuePoint = _firstCuePoint;
        while (cp)
        {
            if (cp == timeNameOrCuePoint || cp.time == timeNameOrCuePoint || cp.name == timeNameOrCuePoint)
            {
                if (cp.next)
                {
                    cp.next.prev = cp.prev;
                }
                if (cp.prev)
                {
                    cp.prev.next = cp.next;
                }
                else if (cp == _firstCuePoint)
                {
                    _firstCuePoint = cp.next;
                }
                cp.next = cp.prev = null;
                cp.gc = true;
                return cp;
            }
            cp = cp.next;
        }
        return null;
    }
    
    private function _setForceTime(time : Float) : Void
    {
        if (!(_forceTime || _forceTime == 0))
        {
            _waitForRender();
        }
        _forceTime = time;
    }
    
    private function set_autoDetachNetStream(value : Bool) : Bool
    {
        _autoDetachNetStream = value;
        if (_autoDetachNetStream && _video.stage == null)
        {
            _video.attachNetStream(null);
            _video.clear();
        }
        else if (_stageVideo != null)
        {
            _stageVideo.attachNetStream(_ns);
        }
        else
        {
            _video.attachNetStream(_ns);
        }
        return value;
    }
    
    private function _detachNS(event : Event) : Void
    {
        _sprite.removeEventListener(Event.ENTER_FRAME, _detachNS);
        if (!_bufferFull && _pausePending)
        {
            _video.attachNetStream(null);
        }
    }
    
    private function _statusHandler(event : NetStatusEvent) : Void
    {
        var videoRemaining : Float = Math.NaN;
        var prevBufferMode : Bool = false;
        var prog : Float = Math.NaN;
        var loadRemaining : Float = Math.NaN;
        var revisedBufferTime : Float = Math.NaN;
        var code : String = event.info.code;
        if (code == "NetStream.Play.Start" && !_playStarted)
        {
            _playStarted = true;
            if (!_pausePending)
            {
                dispatchEvent(new LoaderEvent(VIDEO_PLAY, this));
            }
        }
        dispatchEvent(new LoaderEvent(NetStatusEvent.NET_STATUS, this, code, event.info));
        if (code == "NetStream.Play.Stop")
        {
            if (_videoPaused)
            {
                return;
            }
            _finalFrame = true;
            _sprite.addEventListener(Event.ENTER_FRAME, _finalFrameFinished, false, 100, true);
            if (this.vars.repeat == -1 || as3hx.Compat.parseInt(this.vars.repeat) > _repeatCount)
            {
                ++_repeatCount;
                dispatchEvent(new LoaderEvent(VIDEO_COMPLETE, this));
                gotoVideoTime(0, !_videoPaused, true);
            }
            else
            {
                _videoComplete = true;
                this.videoPaused = true;
                _playProgressHandler(null);
                dispatchEvent(new LoaderEvent(VIDEO_COMPLETE, this));
            }
        }
        else if (code == "NetStream.Buffer.Full")
        {
            _onBufferFull();
        }
        else if (code == "NetStream.Seek.Notify")
        {
            if (!_autoDetachNetStream && !Math.isNaN(_forceTime))
            {
                _renderHandler(null);
            }
        }
        else if (code == "NetStream.Seek.InvalidTime" && Lambda.has(event.info, "details"))
        {
            _seek(event.info.details);
        }
        else if (code == "NetStream.Buffer.Empty" && !_videoComplete)
        {
            videoRemaining = this.duration - this.videoTime;
            prevBufferMode = _bufferMode;
            _bufferMode = false;
            _cacheIsDirty = true;
            prog = this.progress;
            _bufferMode = prevBufferMode;
            _cacheIsDirty = true;
            if (prog == 1)
            {
                return;
            }
            loadRemaining = 1 / prog * this.loadTime;
            revisedBufferTime = videoRemaining * (1 - videoRemaining / loadRemaining) * 0.9;
            if (this.autoAdjustBuffer && loadRemaining > videoRemaining)
            {
                _ns.bufferTime = revisedBufferTime;
            }
            _bufferFull = false;
            dispatchEvent(new LoaderEvent(VIDEO_BUFFER_EMPTY, this));
        }
        else if (code == "NetStream.Play.StreamNotFound" || code == "NetConnection.Connect.Failed" || code == "NetStream.Play.Failed" || code == "NetStream.Play.FileStructureInvalid" || code == "The MP4 doesn\'t contain any supported tracks")
        {
            _failHandler(new LoaderEvent(LoaderEvent.ERROR, this, code));
        }
    }
}


class CuePoint
{
    
    
    public var time : Float;
    
    public var parameters : Dynamic;
    
    public var name : String;
    
    public var next : CuePoint;
    
    public var prev : CuePoint;
    
    public var gc : Bool;
    
    private function new(time : Float, name : String, params : Dynamic, prev : CuePoint)
    {
        super();
        this.time = time;
        this.name = name;
        this.parameters = params;
        if (prev != null)
        {
            this.prev = prev;
            if (prev.next)
            {
                prev.next.prev = this;
                this.next = prev.next;
            }
            prev.next = this;
        }
    }
}
