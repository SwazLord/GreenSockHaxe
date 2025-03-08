package com.greensock.loading;

import com.greensock.events.LoaderEvent;
import com.greensock.loading.core.DisplayObjectLoader;
import com.greensock.loading.core.LoaderCore;
import openfl.display.AVM1Movie;
import openfl.display.DisplayObject;
import openfl.display.DisplayObjectContainer;
import openfl.display.MovieClip;
import openfl.events.Event;
import openfl.media.SoundTransform;
import openfl.Lib;

@:expose("com.greensock.loading.SWFLoader")
class SWFLoader extends DisplayObjectLoader {
	private static var _classActivated:Bool = LoaderCore._activateClass("SWFLoader", SWFLoader, "swf");

	private var _queue:LoaderMax;
	private var _loaderFailed:Bool = false;
	private var _rslAddedCount:UInt;
	private var _loadOnExitStealth:Bool = false;
	private var _hasRSL:Bool = false;
	private var _loaderCompleted:Bool = false;
	private var _lastPTUncaughtError:Event;

	public function new(urlOrRequest:Dynamic, vars:Dynamic = null) {
		super(urlOrRequest, vars);
		_preferEstimatedBytesInAudit = true;
		_type = "SWFLoader";
	}

	override private function set_url(value:String):String {
		if (_url != value) {
			if (_status == LoaderStatus.LOADING && !_initted && !_loaderFailed) {
				_loadOnExitStealth = true;
			}
			super.url = value;
		}

		return value;
	}

	override private function _errorHandler(event:Event):Void {
		if (!_suppressUncaughtError(event)) {
			super._errorHandler(event);
		}
	}

	override private function _determineScriptAccess():Void {
		var mc:DisplayObject = null;
		try {
			mc = _loader.content;
		} catch (error:Dynamic) {
			_scriptAccessDenied = true;
			dispatchEvent(new LoaderEvent(LoaderEvent.SCRIPT_ACCESS_DENIED, this, Std.string(error)));
			return;
		}
		if (Std.isOfType(_loader.content, AVM1Movie)) {
			_scriptAccessDenied = true;
			dispatchEvent(new LoaderEvent(LoaderEvent.SCRIPT_ACCESS_DENIED, this, "AVM1Movie denies script access"));
		}
	}

	override private function _load():Void {
		if (_stealthMode) {
			_stealthMode = _loadOnExitStealth;
		} else if (!_initted) {
			_loader.visible = false;
			_sprite.addChild(_loader);
			super._load();
		} else if (_queue != null) {
			_changeQueueListeners(true);
			_queue.load(false);
		}
	}

	public function getClass(className:String):Class<Dynamic> {
		var result:Dynamic = null;
		var loaders:Array<Dynamic> = null;
		var i:Int = 0;
		if (_content == null || _scriptAccessDenied) {
			return null;
		}
		if (Type.resolveClass(className) != null) {
			return Type.resolveClass(className);
		}
		if (_queue != null) {
			loaders = _queue.getChildren(true, true);
			i = loaders.length;
			while (--i > -1) {
				if (Std.isOfType(loaders[i], SWFLoader)) {
					result = cast(loaders[i], SWFLoader).getClass(className);
					if (result != null) {
						return Type.getClass(result);
					}
				}
			}
		}
		return null;
	}

	public function getContent(nameOrURL:String):Dynamic {
		if (nameOrURL == this.name || nameOrURL == _url) {
			return this.content;
		}
		var loader:LoaderCore = this.getLoader(nameOrURL);
		return loader != null ? loader.content : null;
	}

	override private function _failHandler(event:Event, dispatchError:Bool = true):Void {
		if ((event.type == "ioError" || event.type == "securityError") && event.target == _loader.contentLoaderInfo) {
			_loaderFailed = true;
			if (_loadOnExitStealth) {
				_dump(1, _status, true);
				_load();
				return;
			}
		}
		if (event.target == _queue) {
			_status = LoaderStatus.FAILED;
			_time = Math.round(haxe.Timer.stamp() * 1000) - _time;
			dispatchEvent(new LoaderEvent(LoaderEvent.CANCEL, this));
			dispatchEvent(new LoaderEvent(LoaderEvent.FAIL, this, this.toString() + " > " + Std.string(event)));
			return;
		}
		super._failHandler(event, dispatchError);
	}

	override private function _refreshLoader(unloadContent:Bool = true):Void {
		super._refreshLoader(unloadContent);
		_loaderCompleted = false;
	}

	public function getLoader(nameOrURL:String):Dynamic {
		return _queue != null ? _queue.getLoader(nameOrURL) : null;
	}

	override private function _dump(scrubLevel:Int = 0, newStatus:Int = 0, suppressEvents:Bool = false):Void {
		var content:Dynamic = null;
		_loaderCompleted = false;
		if (_status == LoaderStatus.LOADING && !_initted && !_loaderFailed) {
			_stealthMode = true;
			super._dump(scrubLevel, newStatus, suppressEvents);
			return;
		}
		if (_initted && !_scriptAccessDenied && scrubLevel != 2) {
			_stopMovieClips(_loader.content);
			if (Reflect.hasField(_rootLookup, _loader.content)) {
				_queue = cast(_rootLookup[_loader.content], LoaderMax);
				_changeQueueListeners(false);
				if (scrubLevel == 0) {
					_queue.cancel();
				} else {
					Reflect.deleteField(_rootLookup, _loader.content);
					_queue.dispose(scrubLevel != 2);
				}
			}
		}
		if (_stealthMode) {
			try {
				_loader.close();
			} catch (error:Dynamic) {}
		}
		_loadOnExitStealth = false;
		_stealthMode = _hasRSL = _loaderFailed = false;
		_cacheIsDirty = true;
		if (scrubLevel >= 1) {
			_queue = null;
			_initted = false;
			super._dump(scrubLevel, newStatus, suppressEvents);
		} else {
			content = _content;
			super._dump(scrubLevel, newStatus, suppressEvents);
			_content = content;
		}
	}

	private function _stopMovieClips(obj:DisplayObject):Void {
		var mc:MovieClip = Std.isOfType(obj, MovieClip) ? cast(obj, MovieClip) : null;
		if (mc == null) {
			return;
		}
		mc.stop();
		var i:Int = mc.numChildren;
		while (--i > -1) {
			_stopMovieClips(mc.getChildAt(i));
		}
	}

	private function _checkRequiredLoaders():Void {
		if (_queue == null && this.vars.integrateProgress != false && !_scriptAccessDenied && _content != null) {
			_queue = cast(_rootLookup[_content], LoaderMax);
			if (_queue != null) {
				_changeQueueListeners(true);
				_queue.load(false);
				_cacheIsDirty = true;
			}
		}
	}

	override private function _completeHandler(event:Event = null):Void {
		var st:SoundTransform = null;
		_loaderCompleted = true;
		_checkRequiredLoaders();
		_calculateProgress();
		if (this.progress == 1) {
			if (!_scriptAccessDenied && this.vars.autoPlay == false && Std.isOfType(_content, MovieClip)) {
				st = cast(_content, MovieClip).soundTransform;
				st.volume = 1;
				cast(_content, MovieClip).soundTransform = st;
			}
			_changeQueueListeners(false);
			super._determineScriptAccess();
			super._completeHandler(event);
		}
	}

	private function _changeQueueListeners(add:Bool):Void {
		var p:String = null;
		if (_queue != null) {
			if (add && this.vars.integrateProgress != false) {
				for (p in _listenerTypes.keys()) {
					if (p != "onProgress" && p != "onInit") {
						_queue.addEventListener(_listenerTypes[p], _passThroughEvent, false, -100, true);
					}
				}
				_queue.addEventListener(LoaderEvent.COMPLETE, _completeHandler, false, -100, true);
				_queue.addEventListener(LoaderEvent.PROGRESS, _progressHandler, false, -100, true);
				_queue.addEventListener(LoaderEvent.FAIL, _failHandler, false, -100, true);
			} else {
				_queue.removeEventListener(LoaderEvent.COMPLETE, _completeHandler);
				_queue.removeEventListener(LoaderEvent.PROGRESS, _progressHandler);
				_queue.removeEventListener(LoaderEvent.FAIL, _failHandler);
				for (p in _listenerTypes.keys()) {
					if (p != "onProgress" && p != "onInit") {
						_queue.removeEventListener(_listenerTypes[p], _passThroughEvent);
					}
				}
			}
		}
	}

	override private function _initHandler(event:Event):Void {
		var awaitingLoad:Bool = false;
		var tempContent:DisplayObject = null;
		var className:String = null;
		var rslPreloader:Dynamic = null;
		if (_stealthMode) {
			_initted = true;
			awaitingLoad = _loadOnExitStealth;
			_dump(_status == LoaderStatus.DISPOSED ? 3 : 1, _status, true);
			if (awaitingLoad) {
				_load();
			}
			return;
		}
		_hasRSL = false;
		try {
			tempContent = _loader.content;
			className = Type.getClassName(Type.getClass(tempContent));
			if (className.substr(-13) == "__Preloader__") {
				rslPreloader = Reflect.field(tempContent, "__rslPreloader");
				if (rslPreloader != null) {
					className = Type.getClassName(Type.getClass(rslPreloader));
					if (className == "fl.rsl::RSLPreloader") {
						_hasRSL = true;
						_rslAddedCount = 0;
						tempContent.addEventListener(Event.ADDED, _rslAddedHandler);
					}
				}
			}
		} catch (error:Dynamic) {}
		if (!_hasRSL) {
			_init();
		}
	}

	private function _rslAddedHandler(event:Event):Void {
		if (Std.isOfType(event.target, DisplayObject)
			&& Std.isOfType(event.currentTarget, DisplayObjectContainer)
			&& cast(event.target, DisplayObject).parent == event.currentTarget) {
			++_rslAddedCount;
		}
		if (_rslAddedCount > 1) {
			event.currentTarget.removeEventListener(Event.ADDED, _rslAddedHandler);
			if (_status == LoaderStatus.LOADING) {
				_content = event.target;
				_init();
				_calculateProgress();
				dispatchEvent(new LoaderEvent(LoaderEvent.PROGRESS, this));
				_completeHandler(null);
			}
		}
	}

	override private function _passThroughEvent(event:Event):Void {
		if (!(event.type == "uncaughtError" && _suppressUncaughtError(event)) && event.target != _queue) {
			super._passThroughEvent(event);
		}
	}

	override private function _progressHandler(event:Event):Void {
		var bl:UInt = 0;
		var bt:UInt = 0;
		if (_status == LoaderStatus.LOADING) {
			if (_queue == null && _initted) {
				_checkRequiredLoaders();
			}
			if (_dispatchProgress) {
				bl = _cachedBytesLoaded;
				bt = _cachedBytesTotal;
				_calculateProgress();
				if (_cachedBytesLoaded != _cachedBytesTotal && (bl != _cachedBytesLoaded || bt != _cachedBytesTotal)) {
					dispatchEvent(new LoaderEvent(LoaderEvent.PROGRESS, this));
				}
			} else {
				_cacheIsDirty = true;
			}
		}
	}

	private function _init():Void {
		var st:SoundTransform = null;
		_determineScriptAccess();
		if (!_scriptAccessDenied) {
			if (!_hasRSL) {
				_content = _loader.content;
			}
			if (_content != null) {
				if (this.vars.autoPlay == false && Std.isOfType(_content, MovieClip)) {
					st = cast(_content, MovieClip).soundTransform;
					st.volume = 0;
					cast(_content, MovieClip).soundTransform = st;
					cast(_content, MovieClip).stop();
				}
				_checkRequiredLoaders();
			}
			if (_loader.parent == _sprite) {
				if (_sprite.stage != null && this.vars.suppressInitReparentEvents == true) {
					_sprite.addEventListener(Event.ADDED_TO_STAGE, _captureFirstEvent, true, 1000, true);
					_loader.addEventListener(Event.REMOVED_FROM_STAGE, _captureFirstEvent, true, 1000, true);
				}
				_sprite.removeChild(_loader);
			}
		} else {
			_content = _loader;
			_loader.visible = true;
		}
		super._initHandler(null);
	}

	private function _captureFirstEvent(event:Event):Void {
		event.stopImmediatePropagation();
		event.currentTarget.removeEventListener(event.type, _captureFirstEvent);
	}

	override private function _calculateProgress():Void {
		_cachedBytesLoaded = _stealthMode ? 0 : _loader.contentLoaderInfo.bytesLoaded;
		if (_loader.contentLoaderInfo.bytesTotal != 0) {
			_cachedBytesTotal = _loader.contentLoaderInfo.bytesTotal;
		}
		if (_cachedBytesTotal < _cachedBytesLoaded || _loaderCompleted) {
			_cachedBytesTotal = _cachedBytesLoaded;
		}
		if (this.vars.integrateProgress != false) {
			if (_queue != null && (cast(this.vars.estimatedBytes, UInt) < _cachedBytesLoaded || _queue.auditedSize)) {
				if (_queue.status <= LoaderStatus.COMPLETED) {
					_cachedBytesLoaded += _queue.bytesLoaded;
					_cachedBytesTotal += _queue.bytesTotal;
				}
			} else if (cast(this.vars.estimatedBytes, UInt) > _cachedBytesLoaded
				&& (!_initted || _queue != null && _queue.status <= LoaderStatus.COMPLETED && !_queue.auditedSize)) {
				_cachedBytesTotal = cast(this.vars.estimatedBytes, UInt);
			}
		}
		if (_hasRSL && _content == null || !_initted && _cachedBytesLoaded == _cachedBytesTotal) {
			_cachedBytesLoaded = Std.int(_cachedBytesLoaded * 0.99);
		}
		_cacheIsDirty = false;
	}

	public function getChildren(includeNested:Bool = false, omitLoaderMaxes:Bool = false):Array<Dynamic> {
		return _queue != null ? _queue.getChildren(includeNested, omitLoaderMaxes) : [];
	}

	public function getSWFChild(name:String):DisplayObject {
		return !_scriptAccessDenied
			&& Std.isOfType(_content, DisplayObjectContainer) ? cast(_content, DisplayObjectContainer).getChildByName(name) : null;
	}

	private function _suppressUncaughtError(event:Event):Bool {
		if (Std.isOfType(event, LoaderEvent) && Std.isOfType(cast(event, LoaderEvent).data, Event)) {
			event = cast(cast(event, LoaderEvent).data, Event);
		}
		if (event.type == "uncaughtError") {
			if (_lastPTUncaughtError == (_lastPTUncaughtError = event)) {
				return true;
			}
			if (this.vars.suppressUncaughtErrors == true) {
				event.preventDefault();
				event.stopImmediatePropagation();
				return true;
			}
		}
		return false;
	}
}
