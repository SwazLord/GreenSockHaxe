package com.greensock.loading;

import flash.errors.Error;
import haxe.Constraints.Function;
import com.greensock.events.LoaderEvent;
import com.greensock.loading.core.LoaderItem;
import flash.display.Shape;
import flash.events.Event;
import flash.events.ProgressEvent;
import flash.media.Sound;
import flash.media.SoundChannel;
import flash.media.SoundLoaderContext;
import flash.media.SoundTransform;

class MP3Loader extends LoaderItem
{
    public var soundTransform(get, set) : SoundTransform;
    public var soundTime(get, set) : Float;
    public var soundPaused(get, set) : Bool;
    public var playProgress(get, set) : Float;
    public var duration(get, never) : Float;
    public var volume(get, set) : Float;

    
    private static var _shape : Shape = new Shape();
    
    public static inline var SOUND_PAUSE : String = "soundPause";
    
    public static inline var SOUND_COMPLETE : String = "soundComplete";
    
    public static inline var SOUND_PLAY : String = "soundPlay";
    
    private static var _classActivated : Bool = _activateClass("MP3Loader", MP3Loader, "mp3");
    
    public static inline var PLAY_PROGRESS : String = "playProgress";
    
    
    private var _dispatchPlayProgress : Bool;
    
    public var channel : SoundChannel;
    
    private var _position : Float;
    
    private var _soundTransform : SoundTransform;
    
    private var _initPhase : Int;
    
    private var _sound : Sound;
    
    private var _soundPaused : Bool;
    
    private var _soundComplete : Bool;
    
    private var _context : SoundLoaderContext;
    
    private var _repeatCount : Int;
    
    private var _duration : Float;
    
    public var initThreshold : Int;
    
    public function new(urlOrRequest : Dynamic, vars : Dynamic = null)
    {
        super(urlOrRequest, vars);
        _type = "MP3Loader";
        _position = 0;
        _duration = 0;
        _soundPaused = true;
        _soundTransform = new SoundTransform((Lambda.has(this.vars, "volume")) ? as3hx.Compat.parseFloat(this.vars.volume) : 1);
        this.initThreshold = (Lambda.has(this.vars, "initThreshold")) ? as3hx.Compat.parseInt(as3hx.Compat.parseInt(this.vars.initThreshold)) : 102400;
        _initSound();
    }
    
    private function set_soundTransform(value : SoundTransform) : SoundTransform
    {
        _soundTransform = value;
        if (this.channel != null)
        {
            this.channel.soundTransform = value;
        }
        return value;
    }
    
    public function playSound(event : Event = null) : SoundChannel
    {
        this.soundPaused = false;
        return this.channel;
    }
    
    override private function _load() : Void
    {
        _context = (Std.is(this.vars.context, SoundLoaderContext)) ? this.vars.context : new SoundLoaderContext(3000);
        _prepRequest();
        _soundComplete = false;
        _initPhase = -1;
        _position = 0;
        _duration = 0;
        try
        {
            _sound.load(_request, _context);
            if (this.vars.autoPlay != false)
            {
                playSound();
            }
        }
        catch (error : Error)
        {
            _errorHandler(new LoaderEvent(LoaderEvent.ERROR, this, error.message));
        }
    }
    
    private function set_soundTime(value : Float) : Float
    {
        gotoSoundTime(value, !_soundPaused);
        return value;
    }
    
    private function set_soundPaused(value : Bool) : Bool
    {
        var changed : Bool = cast(value != _soundPaused, Bool);
        _soundPaused = value;
        if (!changed)
        {
            return value;
        }
        if (_soundPaused)
        {
            if (this.channel != null)
            {
                _position = this.channel.position;
                this.channel.removeEventListener(Event.SOUND_COMPLETE, _soundCompleteHandler);
                _shape.removeEventListener(Event.ENTER_FRAME, _enterFrameHandler);
                this.channel.stop();
            }
        }
        else
        {
            _playSound(_position);
            if (this.channel == null)
            {
                return value;
            }
        }
        dispatchEvent(new LoaderEvent(!!(_soundPaused) ? SOUND_PAUSE : SOUND_PLAY, this));
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
    
    private function _id3Handler(event : Event) : Void
    {
        if (_sound.bytesLoaded > this.initThreshold)
        {
            _initPhase = 1;
            dispatchEvent(new LoaderEvent(LoaderEvent.INIT, this));
        }
        else
        {
            _initPhase = 0;
        }
    }
    
    override private function _dump(scrubLevel : Int = 0, newStatus : Int = 0, suppressEvents : Bool = false) : Void
    {
        this.pauseSound();
        _initSound();
        _position = 0;
        _duration = 0;
        _repeatCount = 0;
        _soundComplete = false;
        super._dump(scrubLevel, newStatus);
        _content = _sound;
    }
    
    private function _playSound(position : Float) : Void
    {
        if (this.channel != null)
        {
            this.channel.removeEventListener(Event.SOUND_COMPLETE, _soundCompleteHandler);
            this.channel.stop();
        }
        _position = position;
        this.channel = _sound.play(_position, 1, this.soundTransform);
        if (this.channel != null)
        {
            this.channel.addEventListener(Event.SOUND_COMPLETE, _soundCompleteHandler);
            _shape.addEventListener(Event.ENTER_FRAME, _enterFrameHandler, false, 0, true);
        }
    }
    
    private function _enterFrameHandler(event : Event) : Void
    {
        if (_dispatchPlayProgress)
        {
            dispatchEvent(new LoaderEvent(PLAY_PROGRESS, this));
        }
    }
    
    public function gotoSoundTime(time : Float, forcePlay : Bool = false, resetRepeatCount : Bool = true) : Void
    {
        if (time > _duration)
        {
            time = _duration;
        }
        _position = time * 1000;
        _soundComplete = false;
        if (resetRepeatCount)
        {
            _repeatCount = 0;
        }
        if (!_soundPaused || forcePlay)
        {
            _playSound(_position);
            if (_soundPaused)
            {
                _soundPaused = false;
                dispatchEvent(new LoaderEvent(SOUND_PLAY, this));
            }
        }
    }
    
    private function set_playProgress(value : Float) : Float
    {
        if (this.duration != 0)
        {
            gotoSoundTime(value * _duration, !_soundPaused);
        }
        return value;
    }
    
    private function get_duration() : Float
    {
        if (_sound.bytesLoaded < _sound.bytesTotal)
        {
            _duration = _sound.length / 1000 / (_sound.bytesLoaded / _sound.bytesTotal);
        }
        return _duration;
    }
    
    private function get_soundPaused() : Bool
    {
        return _soundPaused;
    }
    
    private function get_soundTime() : Float
    {
        return !(_soundPaused && this.channel != null) ? as3hx.Compat.parseFloat(this.channel.position / 1000) : as3hx.Compat.parseFloat(_position / 1000);
    }
    
    private function _soundCompleteHandler(event : Event) : Void
    {
        if (as3hx.Compat.parseInt(this.vars.repeat) > _repeatCount || as3hx.Compat.parseInt(this.vars.repeat) == -1)
        {
            ++_repeatCount;
            _playSound(0);
        }
        else
        {
            _repeatCount = 0;
            _soundComplete = true;
            this.soundPaused = true;
            _position = _duration * 1000;
            _enterFrameHandler(null);
            dispatchEvent(new LoaderEvent(SOUND_COMPLETE, this));
        }
    }
    
    private function get_playProgress() : Float
    {
        return !!(_soundComplete) ? 1 : as3hx.Compat.parseFloat(this.soundTime / this.duration);
    }
    
    private function get_soundTransform() : SoundTransform
    {
        return (this.channel != null) ? this.channel.soundTransform : _soundTransform;
    }
    
    override private function _progressHandler(event : Event) : Void
    {
        if (_initPhase == 0 && _sound.bytesLoaded > this.initThreshold)
        {
            _initPhase = 1;
            dispatchEvent(new LoaderEvent(LoaderEvent.INIT, this));
        }
        super._progressHandler(event);
    }
    
    private function set_volume(value : Float) : Float
    {
        _soundTransform = this.soundTransform;
        _soundTransform.volume = value;
        if (this.channel != null)
        {
            this.channel.soundTransform = _soundTransform;
        }
        return value;
    }
    
    private function _initSound() : Void
    {
        if (_sound != null)
        {
            try
            {
                _sound.close();
            }
            catch (error : Error)
            {
            }
            _sound.removeEventListener(ProgressEvent.PROGRESS, _progressHandler);
            _sound.removeEventListener(Event.COMPLETE, _completeHandler);
            _sound.removeEventListener("ioError", _failHandler);
            _sound.removeEventListener(Event.ID3, _id3Handler);
        }
        _initPhase = -1;
        _sound = _content = new Sound();
        _sound.addEventListener(ProgressEvent.PROGRESS, _progressHandler, false, 0, true);
        _sound.addEventListener(Event.COMPLETE, _completeHandler, false, 0, true);
        _sound.addEventListener("ioError", _failHandler, false, 0, true);
        _sound.addEventListener(Event.ID3, _id3Handler, false, 0, true);
    }
    
    private function get_volume() : Float
    {
        return this.soundTransform.volume;
    }
    
    public function pauseSound(event : Event = null) : Void
    {
        this.soundPaused = true;
    }
    
    override private function _completeHandler(event : Event = null) : Void
    {
        _duration = _sound.length / 1000;
        if (_initPhase != 1)
        {
            _initPhase = 1;
            dispatchEvent(new LoaderEvent(LoaderEvent.INIT, this));
        }
        super._completeHandler(event);
    }
}

