/**
 * VERSION: 12.0
 * DATE: 2012-01-15
 * AS3
 * UPDATES AND DOCS AT: http://www.greensock.com
 **/
package com.greensock.plugins;

import openfl.media.SoundTransform;
import com.greensock.*;
import com.greensock.plugins.*;

/**
 * [AS3/AS2 only] Tweens the volume of an object with a soundTransform property (MovieClip/SoundChannel/NetStream, etc.). 
 * 
 * <p><b>USAGE:</b></p>
 * <listing version="3.0">
import com.greensock.TweenLite; 
import com.greensock.plugins.TweenPlugin; 
import com.greensock.plugins.VolumePlugin; 
TweenPlugin.activate([VolumePlugin]); //activation is permanent in the SWF, so this line only needs to be run once.

TweenLite.to(mc, 1, {volume:0}); 
</listing>
 * 
 * <p><strong>Copyright 2008-2014, GreenSock. All rights reserved.</strong> This work is subject to the terms in <a href="http://www.greensock.com/terms_of_use.html">http://www.greensock.com/terms_of_use.html</a> or for <a href="http://www.greensock.com/club/">Club GreenSock</a> members, the software agreement that was issued with the membership.</p>
 * 
 * @author Jack Doyle, jack@greensock.com
 */
class VolumePlugin extends TweenPlugin
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
        super("volume");
    }
    
    /** @private **/
    override public function _onInitTween(target : Dynamic, value : Dynamic, tween : TweenLite) : Bool
    {
        if (Math.isNaN(value) || target.exists("volume") || !target.exists("soundTransform"))
        {
            return false;
        }
        _target = target;
        _st = _target.soundTransform;
        _addTween(_st, "volume", _st.volume, value, "volume");
        return true;
    }
    
    /** @private **/
    override public function setRatio(v : Float) : Void
    {
        super.setRatio(v);
        _target.soundTransform = _st;
    }
}
