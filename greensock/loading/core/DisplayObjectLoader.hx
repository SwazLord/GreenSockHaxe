/**
 * VERSION: 1.935
 * DATE: 2013-03-18
 * AS3
 * UPDATES AND DOCS AT: http://www.greensock.com/loadermax/
**/

package com.greensock.loading.core;

import openfl.errors.Error;
import com.greensock.events.LoaderEvent;
import com.greensock.loading.LoaderMax;
import com.greensock.loading.LoaderStatus;
import com.greensock.loading.display.ContentDisplay;
import openfl.display.DisplayObject;
import openfl.display.Loader;
import openfl.display.Sprite;
import openfl.events.ErrorEvent;
import openfl.events.Event;
import openfl.events.ProgressEvent;
// import openfl.net.LocalConnection;
import openfl.net.URLRequest;
import openfl.system.ApplicationDomain;
import openfl.system.Capabilities;
import openfl.system.LoaderContext;
import openfl.system.Security;
import openfl.system.SecurityDomain;

/**
 * Serves as the base class for SWFLoader and ImageLoader. There is no reason to use this class on its own. 
 * Please refer to the documentation for the other classes.
 * 
 * <p><strong>Copyright 2014, GreenSock. All rights reserved.</strong> This work is subject to the terms in <a href="http://www.greensock.com/terms_of_use.html">http://www.greensock.com/terms_of_use.html</a> or for <a href="http://www.greensock.com/club/">Club GreenSock</a> members, the software agreement that was issued with the membership.</p>
 * 
 * @author Jack Doyle, jack@greensock.com
 */
class DisplayObjectLoader extends LoaderItem {
	public var rawContent(get, never):Dynamic;

	/** By default, LoaderMax will automatically attempt to force garbage collection when a SWFLoader or ImageLoader is unloaded or cancelled but if you prefer to skip this measure, set defaultAutoForceGC to <code>false</code>. If garbage collection isn't forced, sometimes Flash doesn't completely unload swfs/images properly, particularly if there is audio embedded in the root timeline. **/
	public static var defaultAutoForceGC:Bool = true;

	/** @private the Sprite to which the EVENT_LISTENER was attached for forcing garbage collection after 1 frame (improves performance especially when multiple loaders are disposed at one time). **/
	private static var _gcDispatcher:Sprite;

	/** @private **/
	private static var _gcCycles:Int = 0;

	/** @private **/
	private var _loader:Loader;

	/** @private **/
	private var _sprite:Sprite;

	/** @private **/
	private var _context:LoaderContext;

	/** @private **/
	private var _initted:Bool = false;

	/** @private used by SWFLoader when the loader is canceled before the SWF ever had a chance to init which causes garbage collection issues. We slip into stealthMode at that point, wait for it to init, and then cancel the _loader's loading.**/
	private var _stealthMode:Bool = false;

	/** @private allows us to apply a LoaderContext to the file size audit (only if necessary - URLStream is better/faster/smaller and works great unless we run into security errors because of a missing crossdomain.xml file) **/
	private var _fallbackAudit:Loader;

	/**
	 * Constructor
	 * 
	 * @param urlOrRequest The url (<code>String</code>) or <code>URLRequest</code> from which the loader should get its content
	 * @param vars An object containing optional parameters like <code>estimatedBytes, name, autoDispose, onComplete, onProgress, onError</code>, etc. For example, <code>{estimatedBytes:2400, name:"myImage1", onComplete:completeHandler}</code>.
	 */
	public function new(urlOrRequest:Dynamic, vars:Dynamic = null) {
		super(urlOrRequest, vars);
		_refreshLoader(false);
		if (Std.isOfType(LoaderMax.contentDisplayClass, Class)) {
			_sprite = new loaderMax.ContentDisplayClass(this);
			if (!_sprite.exists("rawContent")) {
				throw new Error("LoaderMax.contentDisplayClass must be set to a class with a 'rawContent' property, like com.greensock.loading.display.ContentDisplay");
			}
		} else {
			_sprite = new ContentDisplay(this);
		}
	}

	/** @private Set inside ContentDisplay's or FlexContentDisplay's "loader" setter. **/
	public function setContentDisplay(contentDisplay:Sprite):Void {
		_sprite = contentDisplay;
	}

	/** @private **/
	override private function _load():Void {
		_prepRequest();
		if (Std.isOfType(this.vars.context, LoaderContext)) {
			_context = this.vars.context;
		} else if (_context == null) {
			if (LoaderMax.defaultContext != null) {
				_context = LoaderMax.defaultContext;
				if (_isLocal) {
					_context.securityDomain = null;
				}
			} else if (!_isLocal) {
				_context = new LoaderContext(true, new ApplicationDomain(ApplicationDomain.currentDomain), SecurityDomain.currentDomain);
			}
		}
		if (Capabilities.playerType != "Desktop")
			// AIR apps will choke on Security.allowDomain()
		{
			Security.allowDomain(_url);
		}
		_loader.load(_request, _context);
	}

	/** @inheritDoc **/
	override public function auditSize():Void {
		if (Capabilities.playerType != "Desktop")
			// AIR apps will choke on Security.allowDomain()
		{
			Security.allowDomain(_url);
		}
		super.auditSize();
	}

	override private function _closeStream():Void {
		_closeFallbackAudit();
		super._closeStream();
	}

	private function _closeFallbackAudit():Void {
		if (_fallbackAudit != null) {
			_fallbackAudit.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, _auditStreamHandler, false, 0, true);
			_fallbackAudit.contentLoaderInfo.addEventListener(Event.COMPLETE, _auditStreamHandler, false, 0, true);
			_fallbackAudit.contentLoaderInfo.addEventListener("ioError", _auditStreamHandler, false, 0, true);
			_fallbackAudit.contentLoaderInfo.addEventListener("securityError", _auditStreamHandler, false, 0, true);
			try {
				_fallbackAudit.close();
			} catch (error:Error) {}
			_fallbackAudit = null;
		}
	}

	/** @private **/
	override private function _auditStreamHandler(event:Event):Void // If a security error is thrown because of a missing crossdomain.xml file for example and the user didn't define a specific LoaderContext, we'll try again without checking the policy file, accepting the restrictions that come along with it because typically people would rather have the content show up on the screen rather than just error out (and they can always check the scriptAccessDenied property if they need to figure out whether it's safe to do BitmapData stuff on it, etc.)
	{
		if (event.type == "securityError") {
			if (_fallbackAudit == null) {
				_context = new LoaderContext(false);
				_scriptAccessDenied = true;
				dispatchEvent(new LoaderEvent(LoaderEvent.SCRIPT_ACCESS_DENIED, this, cast((event), ErrorEvent).text));
				_errorHandler(event);
				_fallbackAudit = new Loader(); // so that we can apply a LoaderContext. We don't want to use a Loader initially because they are more memory-intensive than URLStream and they can tend to have more problems with garbage collection.
				_fallbackAudit.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, _auditStreamHandler, false, 0, true);
				_fallbackAudit.contentLoaderInfo.addEventListener(Event.COMPLETE, _auditStreamHandler, false, 0, true);
				_fallbackAudit.contentLoaderInfo.addEventListener("ioError", _auditStreamHandler, false, 0, true);
				_fallbackAudit.contentLoaderInfo.addEventListener("securityError", _auditStreamHandler, false, 0, true);
				var request:URLRequest = new URLRequest();
				request.data = _request.data;
				request.method = _request.method;
				_setRequestURL(request, _url, ((!_isLocal || _url.substr(0, 4) == "http")) ? "gsCacheBusterID=" + (_cacheID++) + "&purpose=audit" : "");
				if (Capabilities.playerType != "Desktop")
					// AIR apps will choke on Security.allowDomain()
				{
					Security.allowDomain(_url);
				}
				_fallbackAudit.load(request, _context);
				return;
			} else {
				_closeFallbackAudit();
			}
		}
		super._auditStreamHandler(event);
	}

	/** @private **/
	private function _refreshLoader(unloadContent:Bool = true):Void {
		if (_loader != null)
			// to avoid gc issues and get around a bug in Flash that incorrectly reports progress values on Loaders that were closed before completing, we must force gc and recreate the Loader altogether...
		{
			if (_status == LoaderStatus.LOADING) {
				try {
					_loader.close();
				} catch (error:Error) {}
			}
			_loader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS, _progressHandler);
			_loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, _completeHandler);
			_loader.contentLoaderInfo.removeEventListener("ioError", _failHandler);
			_loader.contentLoaderInfo.removeEventListener("securityError", _securityErrorHandler);
			_loader.contentLoaderInfo.removeEventListener("httpStatus", _httpStatusHandler);
			_loader.contentLoaderInfo.removeEventListener("httpResponseStatus", _httpStatusHandler);
			_loader.contentLoaderInfo.removeEventListener(Event.INIT, _initHandler);
			if (_loader.exists("uncaughtErrorEvents"))
				// not available when published to FP9, so we reference things this way to avoid compiler errors
			{
				cast((_loader), Object).uncaughtErrorEvents.removeEventListener("uncaughtError", _errorHandler);
			}
			if (unloadContent) {
				try {
					if (_loader.parent == null && _sprite != null) {
						_sprite.addChild(_loader);
					}
					if (_loader.exists("unloadAndStop"))
						// Flash Player 10 and later only
					{
						(try cast(_loader, Dynamic) catch (e:Dynamic) null).unloadAndStop();
					} else {
						_loader.unload();
					}
				} catch (error:Error) {}
				if (_loader.parent) {
					_loader.parent.removeChild(_loader);
				}
				if (((Lambda.has(this.vars, "autoForceGC"))) ? this.vars.autoForceGC : defaultAutoForceGC) {
					forceGC(((this.exists("getClass"))) ? 3 : 1);
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
			// not available when published to FP9, so we reference things this way to avoid compiler errors
		{
			cast((_loader), Object).uncaughtErrorEvents.addEventListener("uncaughtError", _errorHandler, false, 0, true);
		}
	}

	/** @private works around bug in Flash Player that prevents SWFs from properly being garbage collected after being unloaded - for certain types of objects like swfs, this needs to be run more than once (spread out over several frames) to force Flash to properly garbage collect everything. **/
	public static function forceGC(cycles:Int = 1):Void {
		if (_gcCycles < cycles) {
			_gcCycles = cycles;
			if (_gcDispatcher == null) {
				_gcDispatcher = new Sprite();
				_gcDispatcher.addEventListener(Event.ENTER_FRAME, _forceGCHandler, false, 0, true);
			}
		}
	}

	/** @private **/
	private static function _forceGCHandler(event:Event):Void {
		if (--_gcCycles <= 0) {
			_gcDispatcher.removeEventListener(Event.ENTER_FRAME, _forceGCHandler);
			_gcDispatcher = null;
		}
		try {
			new LocalConnection().connect("FORCE_GC");
			new LocalConnection().connect("FORCE_GC");
		} catch (error:Error) {}
	}

	/** @private scrubLevel: 0 = cancel, 1 = unload, 2 = dispose, 3 = flush **/
	override private function _dump(scrubLevel:Int = 0, newStatus:Int = LoaderStatus.READY, suppressEvents:Bool = false):Void {
		if (!_stealthMode) {
			_refreshLoader(cast(scrubLevel != 2, Bool));
		}
		if (scrubLevel == 1)
			// unload
		{
			(try cast(_sprite, Dynamic) catch (e:Dynamic) null).rawContent = null;
		} else if (scrubLevel == 2)
			// dispose
		{
			(try cast(_sprite, Dynamic) catch (e:Dynamic) null).loader = null;
		} else if (scrubLevel == 3)
			// unload and dispose
		{
			(try cast(_sprite, Dynamic) catch (e:Dynamic) null).dispose(false, false);
		}
		super._dump(scrubLevel, newStatus, suppressEvents);
	}

	/** @private **/
	private function _determineScriptAccess():Void {
		if (!_scriptAccessDenied) {
			if (!_loader.contentLoaderInfo.childAllowsParent) {
				_scriptAccessDenied = true;
				dispatchEvent(new LoaderEvent(LoaderEvent.SCRIPT_ACCESS_DENIED, this,
					"Error #2123: Security sandbox violation: " + this + ". No policy files granted access."));
			}
		}
	}

	//---- EVENT HANDLERS ------------------------------------------------------------------------------------

	/** @private **/
	private function _securityErrorHandler(event:ErrorEvent):Void // If a security error is thrown because of a missing crossdomain.xml file for example and the user didn't define a specific LoaderContext, we'll try again without checking the policy file, accepting the restrictions that come along with it because typically people would rather have the content show up on the screen rather than just error out (and they can always check the scriptAccessDenied property if they need to figure out whether it's safe to do BitmapData stuff on it, etc.)
	{
		if (_context != null && _context.checkPolicyFile && !(Std.isOfType(this.vars.context, LoaderContext))) {
			_context = new LoaderContext(false);
			_scriptAccessDenied = true;
			dispatchEvent(new LoaderEvent(LoaderEvent.SCRIPT_ACCESS_DENIED, this, event.text));
			_errorHandler(event);
			_load();
		} else {
			_failHandler(event);
		}
	}

	/** @private **/
	private function _initHandler(event:Event):Void {
		if (!_initted) {
			_initted = true;
			if (_content == null)
				// _content is set in ImageLoader or SWFLoader (subclasses), but we put this here just in case someone wants to use DisplayObjectLoader on its own as a lighter weight alternative without the bells & whistles of SWFLoader/ImageLoader.
			{
				_content = ((_scriptAccessDenied)) ? _loader : _loader.content;
			}
			(try cast(_sprite, Dynamic) catch (e:Dynamic) null).rawContent = (try cast(_content, DisplayObject) catch (e:Dynamic) null);
			dispatchEvent(new LoaderEvent(LoaderEvent.INIT, this));
		}
	}

	//---- GETTERS / SETTERS -------------------------------------------------------------------------

	/** A ContentDisplay object (a Sprite) that will contain the remote content as soon as the <code>INIT</code> event has been dispatched. This ContentDisplay can be accessed immediately; you do not need to wait for the content to load. **/
	override private function get_content():Dynamic {
		return _sprite;
	}

	/** 
	 * The raw content that was successfully loaded <strong>into</strong> the <code>content</code> ContentDisplay 
	 * Sprite which varies depending on the type of loader and whether or not script access was denied while 
	 * attempting to load the file: 
	 * 
	 * <ul>
	 * 		<li>ImageLoader with script access granted: <code>flash.display.Bitmap</code></li>
	 * 		<li>ImageLoader with script access denied: <code>flash.display.Loader</code></li>
	 * 		<li>SWFLoader with script access granted: <code>flash.display.DisplayObject</code> (the swf's <code>root</code>)</li>
	 * 		<li>SWFLoader with script access denied: <code>flash.display.Loader</code> (the swf's <code>root</code> cannot be accessed because it would generate a security error)</li>
	 * </ul>
	**/
	private function get_rawContent():Dynamic {
		return _content;
	}
}
