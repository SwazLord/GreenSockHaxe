package com.greensock.loading;

import flash.events.Event;
import flash.text.StyleSheet;

@:meta(Event(name="httpStatus",type="com.greensock.events.LoaderEvent"))

class CSSLoader extends DataLoader
{
    
    private static var _classActivated : Bool = _activateClass("CSSLoader", CSSLoader, "css");
    
    
    public function new(urlOrRequest : Dynamic, vars : Dynamic = null)
    {
        super(urlOrRequest, vars);
        _loader.dataFormat = "text";
        _type = "CSSLoader";
    }
    
    override private function _receiveDataHandler(event : Event) : Void
    {
        var style : StyleSheet = _content = new StyleSheet();
        style.parseCSS(_loader.data);
        super._completeHandler(event);
    }
}

