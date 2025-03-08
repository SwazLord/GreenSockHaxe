package com.greensock.loading;

import com.greensock.events.LoaderEvent;
import com.greensock.loading.core.DisplayObjectLoader;
import com.greensock.loading.core.LoaderItem;
import flash.display.Bitmap;
import flash.display.DisplayObject;
import flash.events.Event;
import flash.events.ProgressEvent;

class ImageLoader extends DisplayObjectLoader
{
    
    private static var _classActivated : Bool = _activateClass("ImageLoader", ImageLoader, "jpg,jpeg,png,gif,bmp");
    
    
    public function new(urlOrRequest : Dynamic, vars : Dynamic = null)
    {
        super(urlOrRequest, vars);
        _type = "ImageLoader";
    }
    
    override private function _initHandler(event : Event) : Void
    {
        _determineScriptAccess();
        if (!_scriptAccessDenied)
        {
            _content = cast((_loader.content), Bitmap);
            _content.smoothing = cast(this.vars.smoothing != false, Bool);
        }
        else
        {
            _content = _loader;
        }
        super._initHandler(event);
    }
    
    override private function _load() : Void
    {
        var loaders : Array<Dynamic> = null;
        var loader : LoaderItem = null;
        var i : Int = 0;
        if (this.vars.noCache != true)
        {
            loaders = _globalRootLoader.getChildren(true, true);
            i = loaders.length;
            while (--i > -1)
            {
                loader = loaders[i];
                if (loader.url == _url && loader != this && loader.status == LoaderStatus.COMPLETED && Std.is(loader, ImageLoader) && Std.is(cast((loader), ImageLoader).rawContent, Bitmap))
                {
                    _closeStream();
                    _content = new Bitmap(cast((loader), ImageLoader).rawContent.bitmapData, "auto", cast(this.vars.smoothing != false, Bool));
                    cast((_sprite), Object).rawContent = try cast(_content, DisplayObject) catch(e:Dynamic) null;
                    _initted = true;
                    _progressHandler(new ProgressEvent(ProgressEvent.PROGRESS, false, false, loader.bytesLoaded, loader.bytesTotal));
                    dispatchEvent(new LoaderEvent(LoaderEvent.INIT, this));
                    _completeHandler(null);
                    return;
                }
            }
        }
        super._load();
    }
}

