package com.greensock.loading;

import com.greensock.loading.core.LoaderItem;
import flash.display.DisplayObject;
import flash.display.LoaderInfo;
import flash.events.Event;
import flash.events.ProgressEvent;

class SelfLoader extends LoaderItem
{
    
    
    private var _loaderInfo : LoaderInfo;
    
    public function new(self : DisplayObject, vars : Dynamic = null)
    {
        super(self.loaderInfo.url, vars);
        _type = "SelfLoader";
        _loaderInfo = self.loaderInfo;
        _loaderInfo.addEventListener(ProgressEvent.PROGRESS, _progressHandler, false, 0, true);
        _loaderInfo.addEventListener(Event.COMPLETE, _completeHandler, false, 0, true);
        _cachedBytesTotal = _loaderInfo.bytesTotal;
        _cachedBytesLoaded = _loaderInfo.bytesLoaded;
        _status = (_cachedBytesLoaded == _cachedBytesTotal) ? as3hx.Compat.parseInt(LoaderStatus.COMPLETED) : as3hx.Compat.parseInt(LoaderStatus.LOADING);
        _auditedSize = true;
        _content = self;
    }
    
    override private function _dump(scrubLevel : Int = 0, newStatus : Int = 0, suppressEvents : Bool = false) : Void
    {
        if (scrubLevel >= 2)
        {
            _loaderInfo.removeEventListener(ProgressEvent.PROGRESS, _progressHandler);
            _loaderInfo.removeEventListener(Event.COMPLETE, _completeHandler);
        }
        super._dump(scrubLevel, newStatus, suppressEvents);
    }
}

