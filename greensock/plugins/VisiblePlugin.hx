/**
 * VERSION: 12.1
 * DATE: 2012-06-19
 * AS3
 * UPDATES AND DOCS AT: http://www.greensock.com
 **/
package com.greensock.plugins;

import com.greensock.TweenLite;

/**
 * [AS3/AS2 only] Toggles the visibility at the end of a tween. For example, if you want to set <code>visible</code> to false
 * at the end of the tween, do:<p><code>
 * 
 * TweenLite.to(mc, 1, {x:100, visible:false});</code></p>
 * 
 * <p>The <code>visible</code> property is forced to true during the course of the tween. </p>
 * 
 * <p><b>USAGE:</b></p>
 * <listing version="3.0">
import com.greensock.TweenLite; <br />
import com.greensock.plugins.TweenPlugin; <br />
import com.greensock.plugins.VisiblePlugin; <br />
TweenPlugin.activate([VisiblePlugin]); //activation is permanent in the SWF, so this line only needs to be run once.<br /><br />

TweenLite.to(mc, 1, {x:100, visible:false}); <br /><br />
</listing>
 * 
 * <p><strong>Copyright 2008-2014, GreenSock. All rights reserved.</strong> This work is subject to the terms in <a href="http://www.greensock.com/terms_of_use.html">http://www.greensock.com/terms_of_use.html</a> or for <a href="http://www.greensock.com/club/">Club GreenSock</a> members, the software agreement that was issued with the membership.</p>
 * 
 * @author Jack Doyle, jack@greensock.com
 */
class VisiblePlugin extends TweenPlugin
{
    /** @private **/
    public static inline var API : Float = 2;  //If the API/Framework for plugins changes in the future, this number helps determine compatibility  
    
    /** @private **/
    private var _target : Dynamic;
    /** @private **/
    private var _tween : TweenLite;
    /** @private **/
    private var _visible : Bool;
    /** @private **/
    private var _initVal : Bool;
    /** @private **/
    private var _progress : Int;
    
    /** @private **/
    public function new()
    {
        super("visible");
    }
    
    /** @private **/
    override public function _onInitTween(target : Dynamic, value : Dynamic, tween : TweenLite) : Bool
    {
        _target = target;
        _tween = tween;
        _progress = ((_tween.vars.runBackwards)) ? 0 : 1;
        _initVal = _target.visible;
        _visible = cast(value, Bool);
        return true;
    }
    
    /** @private **/
    override public function setRatio(v : Float) : Void
    {
        _target.visible = ((v == 1 && (_tween._time / _tween._duration == _progress || _tween._duration == 0))) ? _visible : _initVal;
    }
}
