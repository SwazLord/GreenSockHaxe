/**
 * VERSION: 12.0
 * DATE: 2012-01-14
 * AS3
 * UPDATES AND DOCS AT: http://www.greensock.com
 **/
package com.greensock.plugins;

import com.greensock.TweenLite;
import openfl.media.SoundTransform;

/**
 * [AS3 only] Tweens properties of an object's soundTransform property (like the volume, pan, leftToRight, etc. of a MovieClip/SoundChannel/NetStream). <br /><br />
 * 
 * <p><b>USAGE:</b></p>
 * <listing version="3.0">
import com.greensock.TweenLite; 
import com.greensock.plugins.TweenPlugin; 
import com.greensock.plugins.SoundTransformPlugin; 
TweenPlugin.activate([SoundTransformPlugin]); //activation is permanent in the SWF, so this line only needs to be run once.

TweenLite.to(mc, 1, {soundTransform:{volume:0.2, pan:0.5}}); 
</listing>
 * 
 * <p><strong>Copyright 2008-2014, GreenSock. All rights reserved.</strong> This work is subject to the terms in <a href="http://www.greensock.com/terms_of_use.html">http://www.greensock.com/terms_of_use.html</a> or for <a href="http://www.greensock.com/club/">Club GreenSock</a> members, the software agreement that was issued with the membership.</p>
 * 
 * @author Jack Doyle, jack@greensock.com
 */
class SoundTransformPlugin extends TweenPlugin
{
    /** @private **/
    public static inline var API : Float = 2;  //If the API/Framework for plugins changes in the future, this number helps determine compatibility  
    
    /** @private **/
    private var _target : Dynamic;
    /** @private **/
    private var _st : SoundTransform;
    
    /** @private **/
    public function new()
    {
        super("soundTransform,volume");
    }
    
    /** @private **/
    override public function _onInitTween(target : Dynamic, value : Dynamic, tween : TweenLite) : Bool
    {
        if (!target.exists("soundTransform"))
        {
            return false;
        }
        _target = target;
        _st = _target.soundTransform;
        for (p in Reflect.fields(value))
        {
            _addTween(_st, p, Reflect.field(_st, p), Reflect.field(value, p), p);
        }
        return true;
    }
    
    /** @private **/
    override public function setRatio(v : Float) : Void
    {
        super.setRatio(v);
        _target.soundTransform = _st;
    }
}
