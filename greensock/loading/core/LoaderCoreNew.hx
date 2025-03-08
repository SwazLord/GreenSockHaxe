package com.greensock.loading.core;

import com.greensock.events.LoaderEvent;
import com.greensock.loading.LoaderMax;
import com.greensock.loading.LoaderStatus;
import openfl.display.DisplayObject;
import openfl.events.Event;
import openfl.events.EventDispatcher;
import openfl.events.ProgressEvent;
// import openfl.net.LocalConnection;
import openfl.system.Capabilities;
import haxe.ds.StringMap;
import haxe.Timer;

@:expose("com.greensock.loading.core.LoaderCore")
class LoaderCore extends EventDispatcher {
	private static var _types:Dynamic = {};
	private static var _listenerTypes:Dynamic = {
		"onOpen": "open",
		"onInit": "init",
		"onComplete": "complete",
		"onProgress": "progress",
		"onCancel": "cancel",
		"onFail": "fail",
		"onError": "error",
		"onSecurityError": "securityError",
		"onHTTPStatus": "httpStatus",
		"onHTTPResponseStatus": "httpResponseStatus",
		"onIOError": "ioError",
		"onScriptAccessDenied": "scriptAccessDenied",
		"onChildOpen": "childOpen",
		"onChildCancel": "childCancel",
		"onChildComplete": "childComplete",
		"onChildProgress": "childProgress",
		"onChildFail": "childFail",
		"onRawLoad": "rawLoad",
		"onUncaughtError": "uncaughtError"
	};
	private static var _isLocal:Bool = false;
	private static var _extensions:Dynamic = {};
	private static var _globalRootLoader:LoaderMax;
	public static inline var version:Float = 1.935;
	private static var _rootLookup:StringMap<LoaderMax> = new StringMap<LoaderMax>();
	private static var _loaderCount:UInt = 0;

	private var _prePauseStatus:Int;

	public var name:String;

	private var _dispatchChildProgress:Bool = false;
	private var _status:Int;
	private var _type:String;
	private var _auditedSize:Bool = false;
	private var _dispatchProgress:Bool = false;

	public var vars:Dynamic;

	private var _cachedBytesTotal:UInt;
	private var _time:UInt;
	private var _content:Dynamic;
	private var _rootLoader:LoaderMax;
	private var _cacheIsDirty:Bool = false;
	private var _cachedBytesLoaded:UInt;

	public var autoDispose:Bool = false;

	public function new(vars:Dynamic = null) {
		super();
		this.vars = vars != null ? vars : {};
		if (this.vars.isGSVars) {
			this.vars = this.vars.vars;
		}
		this.name = this.vars.name != null && cast(this.vars.name, String) != "" ? this.vars.name : "loader" + _loaderCount++;
		_cachedBytesLoaded = 0;
		_cachedBytesTotal = cast(this.vars.estimatedBytes, UInt) != 0 ? cast(cast(this.vars.estimatedBytes, UInt), UInt) : LoaderMax.defaultEstimatedBytes;
		this.autoDispose = this.vars.autoDispose == true;
		_status = this.vars.paused == true ? LoaderStatus.PAUSED : LoaderStatus.READY;
		_auditedSize = cast(this.vars.estimatedBytes, UInt) != 0 && this.vars.auditSize != true;
		if (_globalRootLoader == null) {
			if (this.vars.__isRoot == true) {
				return;
			}
			_globalRootLoader = new LoaderMax({
				"name": "root",
				"__isRoot": true
			});
			_isLocal = Capabilities.playerType == "Desktop" || new LocalConnection().domain == "localhost";
		}
		_rootLoader = Std.isOfType(this.vars.requireWithRoot,
			DisplayObject) ? _rootLookup.get(cast(this.vars.requireWithRoot, DisplayObject)) : _globalRootLoader;
		if (_rootLoader == null) {
			_rootLookup.set(cast(this.vars.requireWithRoot, DisplayObject), _rootLoader = new LoaderMax());
			_rootLoader.name = "subloaded_swf_"
				+ (this.vars.requireWithRoot.loaderInfo != null ? this.vars.requireWithRoot.loaderInfo.url : Std.string(_loaderCount));
			_rootLoader.skipFailed = false;
		}
		for (p in _listenerTypes.keys()) {
			if (Reflect.hasField(this.vars, p) && Reflect.isFunction(Reflect.field(this.vars, p))) {
				this.addEventListener(_listenerTypes.get(p), Reflect.field(this.vars, p), false, 0, true);
			}
		}
		_rootLoader.append(this);
	}

	private static function _activateClass(type:String, loaderClass:Class<Dynamic>, extensions:String):Bool {
		if (type != "") {
			_types.set(type.toLowerCase(), loaderClass);
		}
		var a = extensions.split(",");
		var i = a.length;
		while (--i > -1) {
			_extensions.set(a[i], loaderClass);
		}
		return true;
	}

	private function _errorHandler(event:Event):Void {
		var target:Dynamic = event.target;
		target = Std.isOfType(event, LoaderEvent) && Reflect.hasField(this, "getChildren") ? event.target : this;
		var text:String = "";
		if (Reflect.hasField(event, "error") && Std.isOfType(Reflect.field(event, "error"), Error)) {
			text = cast(Reflect.field(event, "error"), Error).message;
		} else if (Reflect.hasField(event, "text")) {
			text = Reflect.field(event, "text");
		}
		if (event.type != LoaderEvent.ERROR && event.type != LoaderEvent.FAIL && this.hasEventListener(event.type)) {
			dispatchEvent(new LoaderEvent(event.type, target, text, event));
		}
		if (event.type != "uncaughtError") {
			trace("----\nError on " + this.toString() + ": " + text + "\n----");
			if (this.hasEventListener(LoaderEvent.ERROR)) {
				dispatchEvent(new LoaderEvent(LoaderEvent.ERROR, target, this.toString() + " > " + text, event));
			}
		}
	}

	private function _failHandler(event:Event, dispatchError:Bool = true):Void {
		var target:Dynamic = null;
		_dump(0, LoaderStatus.FAILED, true);
		if (dispatchError) {
			_errorHandler(event);
		} else {
			target = event.target;
		}
		dispatchEvent(new LoaderEvent(LoaderEvent.FAIL, Std.isOfType(event, LoaderEvent)
			&& Reflect.hasField(this, "getChildren") ? event.target : this,
			this.toString() + " > " + Reflect.field(event, "text"), event));
		dispatchEvent(new LoaderEvent(LoaderEvent.CANCEL, this));
	}

	private function _completeHandler(event:Event = null):Void {
		_cachedBytesLoaded = _cachedBytesTotal;
		if (_status != LoaderStatus.COMPLETED) {
			dispatchEvent(new LoaderEvent(LoaderEvent.PROGRESS, this));
			_status = LoaderStatus.COMPLETED;
			_time = Timer.stamp() - _time;
		}
		dispatchEvent(new LoaderEvent(LoaderEvent.COMPLETE, this));
		if (this.autoDispose) {
			dispose();
		}
	}

	public var rootLoader(get, never):LoaderMax;

	private function get_rootLoader():LoaderMax {
		return _rootLoader;
	}

	private function _progressHandler(event:Event):Void {
		if (Std.isOfType(event, ProgressEvent)) {
			_cachedBytesLoaded = cast(event, ProgressEvent).bytesLoaded;
			_cachedBytesTotal = cast(event, ProgressEvent).bytesTotal;
			if (!_auditedSize) {
				_auditedSize = true;
				dispatchEvent(new Event("auditedSize"));
			}
		}
		if (_dispatchProgress && _status == LoaderStatus.LOADING && _cachedBytesLoaded != _cachedBytesTotal) {
			dispatchEvent(new LoaderEvent(LoaderEvent.PROGRESS, this));
		}
	}

	public function dispose(flushContent:Bool = false):Void {
		_dump(flushContent ? 3 : 2, LoaderStatus.DISPOSED);
	}

	public var bytesTotal(get, never):UInt;

	private function get_bytesTotal():UInt {
		if (_cacheIsDirty) {
			_calculateProgress();
		}
		return _cachedBytesTotal;
	}

	public function resume():Void {
		this.paused = false;
		load(false);
	}

	public var paused(get, set):Bool = false;

	private function get_paused():Bool {
		return _status == LoaderStatus.PAUSED;
	}

	private function _calculateProgress():Void {}

	public var progress(get, never):Float;

	private function get_progress():Float {
		return this.bytesTotal != 0 ? _cachedBytesLoaded / _cachedBytesTotal : (_status == LoaderStatus.COMPLETED ? 1 : 0);
	}

	public function prioritize(loadNow:Bool = true):Void {
		dispatchEvent(new Event("prioritize"));
		if (loadNow && _status != LoaderStatus.COMPLETED && _status != LoaderStatus.LOADING) {
			load(false);
		}
	}

	override public function addEventListener(type:String, listener:Dynamic->Void, useCapture:Bool = false, priority:Int = 0,
			useWeakReference:Bool = false):Void {
		if (type == LoaderEvent.PROGRESS) {
			_dispatchProgress = true;
		} else if (type == LoaderEvent.CHILD_PROGRESS && Std.isOfType(this, LoaderMax)) {
			_dispatchChildProgress = true;
		}
		super.addEventListener(type, listener, useCapture, priority, useWeakReference);
	}

	public var bytesLoaded(get, never):UInt;

	private function get_bytesLoaded():UInt {
		if (_cacheIsDirty) {
			_calculateProgress();
		}
		return _cachedBytesLoaded;
	}

	private function _dump(scrubLevel:Int = 0, newStatus:Int = 0, suppressEvents:Bool = false):Void {
		var p:String = null;
		_content = null;
		var isLoading:Bool = _status == LoaderStatus.LOADING;
		if (_status == LoaderStatus.PAUSED && newStatus != LoaderStatus.PAUSED && newStatus != LoaderStatus.FAILED) {
			_prePauseStatus = newStatus;
		} else if (_status != LoaderStatus.DISPOSED) {
			_status = newStatus;
		}
		if (isLoading) {
			_time = Timer.stamp() - _time;
		}
		_cachedBytesLoaded = 0;
		if (_status < LoaderStatus.FAILED) {
			if (Std.isOfType(this, LoaderMax)) {
				_calculateProgress();
			}
			if (_dispatchProgress && !suppressEvents) {
				dispatchEvent(new LoaderEvent(LoaderEvent.PROGRESS, this));
			}
		}
		if (!suppressEvents) {
			if (isLoading) {
				dispatchEvent(new LoaderEvent(LoaderEvent.CANCEL, this));
			}
			if (scrubLevel != 2) {
				dispatchEvent(new LoaderEvent(LoaderEvent.UNLOAD, this));
			}
		}
		if (newStatus == LoaderStatus.DISPOSED) {
			if (!suppressEvents) {
				dispatchEvent(new Event("dispose"));
			}
			for (p in _listenerTypes.keys()) {
				if (Reflect.hasField(this.vars, p) && Reflect.isFunction(Reflect.field(this.vars, p))) {
					this.removeEventListener(_listenerTypes.get(p), Reflect.field(this.vars, p));
				}
			}
		}
	}

	private function _load():Void {}

	public var loadTime(get, never):Float;

	private function get_loadTime():Float {
		if (_status == LoaderStatus.READY) {
			return 0;
		}
		if (_status == LoaderStatus.LOADING) {
			return (Timer.stamp() - _time) / 1000;
		}
		return _time / 1000;
	}

	public var auditedSize(get, never):Bool = false;

	private function get_auditedSize():Bool {
		return _auditedSize;
	}

	private function set_paused(value:Bool):Bool {
		if (value && _status != LoaderStatus.PAUSED) {
			_prePauseStatus = _status;
			if (_status == LoaderStatus.LOADING) {
				_dump(0, LoaderStatus.PAUSED);
			}
			_status = LoaderStatus.PAUSED;
		} else if (!value && _status == LoaderStatus.PAUSED) {
			if (_prePauseStatus == LoaderStatus.LOADING) {
				load(false);
			} else {
				_status = _prePauseStatus != null ? _prePauseStatus : LoaderStatus.READY;
			}
		}
		return value;
	}

	private function _passThroughEvent(event:Event):Void {
		var type:String = event.type;
		var target:Dynamic = this;
		if (Reflect.hasField(this, "getChildren")) {
			if (Std.isOfType(event, LoaderEvent)) {
				target = event.target;
			}
			if (type == "complete") {
				type = "childComplete";
			} else if (type == "open") {
				type = "childOpen";
			} else if (type == "cancel") {
				type = "childCancel";
			} else if (type == "fail") {
				type = "childFail";
			}
		}
		if (this.hasEventListener(type)) {
			dispatchEvent(new LoaderEvent(type, target, Reflect.hasField(event, "text") ? Reflect.field(event, "text") : "", Std.isOfType(event,
				LoaderEvent) && cast(event, LoaderEvent).data != null ? cast(event, LoaderEvent).data : event));
		}
	}

	public function load(flushContent:Bool = false):Void {
		var time:UInt = Timer.stamp();
		if (this.status == LoaderStatus.PAUSED) {
			_status = _prePauseStatus <= LoaderStatus.LOADING ? LoaderStatus.READY : _prePauseStatus;
			if (_status == LoaderStatus.READY && Std.isOfType(this, LoaderMax)) {
				time -= _time;
			}
		}
		if (flushContent || _status == LoaderStatus.FAILED) {
			_dump(1, LoaderStatus.READY);
		}
		if (_status == LoaderStatus.READY) {
			_status = LoaderStatus.LOADING;
			_time = time;
			_load();
			if (this.progress < 1) {
				dispatchEvent(new LoaderEvent(LoaderEvent.OPEN, this));
			}
		} else if (_status == LoaderStatus.COMPLETED) {
			_completeHandler(null);
		}
	}

	override public function toString():String {
		return _type + " '" + this.name + "'" + (Std.isOfType(this, LoaderItem) ? " (" + cast(this, LoaderItem).url + ")" : "");
	}

	public var status(get, never):Int;

	private function get_status():Int {
		return _status;
	}

	public function pause():Void {
		this.paused = true;
	}

	public var content(get, never):Dynamic;

	private function get_content():Dynamic {
		return _content;
	}

	public function cancel():Void {
		if (_status == LoaderStatus.LOADING) {
			_dump(0, LoaderStatus.READY);
		}
	}

	public function auditSize():Void {}

	public function unload():Void {
		_dump(1, LoaderStatus.READY);
	}
}
