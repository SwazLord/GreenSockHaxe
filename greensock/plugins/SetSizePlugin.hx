/**
 * VERSION: 12.0
 * DATE: 2012-01-14
 * AS3 
 * UPDATES AND DOCS AT: http://www.greensock.com
 **/
package com.greensock.plugins;

import com.greensock.*;

/**
 * [AS3/AS2 only] Some components require resizing with setSize() instead of standard tweens of width/height in
 * order to scale properly. The SetSizePlugin accommodates this easily. You can define the width, 
 * height, or both. <br /><br />
 * 
 * <p><b>USAGE:</b></p>
 * <listing version="3.0">
import com.greensock.TweenLite; 
import com.greensock.plugins.TweenPlugin; 
import com.greensock.plugins.SetSizePlugin;
TweenPlugin.activate([SetSizePlugin]); //activation is permanent in the SWF, so this line only needs to be run once.

TweenLite.to(myComponent, 1, {setSize:{width:200, height:30}}); 
</listing>
 * 
 * <p><strong>Copyright 2008-2014, GreenSock. All rights reserved.</strong> This work is subject to the terms in <a href="http://www.greensock.com/terms_of_use.html">http://www.greensock.com/terms_of_use.html</a> or for <a href="http://www.greensock.com/club/">Club GreenSock</a> members, the software agreement that was issued with the membership.</p>
 * 
 * @author Jack Doyle, jack@greensock.com
 */
class SetSizePlugin extends TweenPlugin
{
    /** @private **/
    public static inline var API : Float = 2;  //If the API/Framework for plugins changes in the future, this number helps determine compatibility  
    
    /** @private **/
    public var width : Float;
    /** @private **/
    public var height : Float;
    
    /** @private **/
    private var _target : Dynamic;
    /** @private **/
    private var _setWidth : Bool;
    /** @private **/
    private var _setHeight : Bool;
    /** @private **/
    private var _hasSetSize : Bool;
    
    /** @private **/
    public function new()
    {
        super("setSize,setActualSize,width,height,scaleX,scaleY");
    }
    
    /** @private **/
    override public function _onInitTween(target : Dynamic, value : Dynamic, tween : TweenLite) : Bool
    {
        _target = target;
        _hasSetSize = cast(Lambda.has(_target, "setSize"), Bool);
        if (Lambda.has(value, "width") && _target.width != value.width)
        {
            _addTween(((_hasSetSize)) ? this : _target, "width", _target.width, value.width, "width", true);
            _setWidth = _hasSetSize;
        }
        if (Lambda.has(value, "height") && _target.height != value.height)
        {
            _addTween(((_hasSetSize)) ? this : _target, "height", _target.height, value.height, "height", true);
            _setHeight = _hasSetSize;
        }
        if (_firstPT == null)
        {
            _hasSetSize = false;
        }
        return true;
    }
    
    
    /** @private **/
    override public function _kill(lookup : Dynamic) : Bool
    {
        if (Lambda.has(lookup, "setSize") || Lambda.has(lookup, "width") || Lambda.has(lookup, "scaleX"))
        {
            _setWidth = false;
        }
        if (Lambda.has(lookup, "setSize") || Lambda.has(lookup, "height") || Lambda.has(lookup, "scaleY"))
        {
            _setHeight = false;
        }
        return super._kill(lookup);
    }
    
    /** @private **/
    override public function setRatio(v : Float) : Void
    {
        super.setRatio(v);
        if (_hasSetSize)
        {
            _target.setSize(((_setWidth)) ? this.width : _target.width, ((_setHeight)) ? this.height : _target.height);
        }
    }
}
