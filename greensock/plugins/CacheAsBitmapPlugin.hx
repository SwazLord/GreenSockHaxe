/**
 * VERSION: 12.0
 * DATE: 2012-01-12
 * AS3
 * UPDATES AND DOCS AT: http://www.greensock.com
 **/
package com.greensock.plugins;

import com.greensock.TweenLite;
import openfl.display.DisplayObject;

/**
 * [AS3/AS2 only] Forces the <code>cacheAsBitmap</code> property of a DisplayObject to be a certain value (<code>true</code> or <code>false</code>)
 * during the tween and then sets it back to whatever it was before the tween was rendered for the first time. This <i>can</i> improve 
 * performance in certain situations, like when the DisplayObject <strong>NOT</strong> tweening its rotation, scaleX, scaleY, or similar
 * things with its <code>transform.matrix</code>. See Adobe's docs for details about when it is appropriate to set <code>cacheAsBitmap</code>
 * to <code>true</code>. Also beware that whenever a DisplayObject's <code>cacheAsBitmap</code> is <code>true</code>, it will ONLY be
 * rendered on whole pixel values which can lead to animation that looks "choppy" at slow speeds.
 * 
 * <p>For example, if you want to set <code>cacheAsBitmap</code> to <code>true</code> while the tween is running, do:</p><p><code>
 * 
 * TweenLite.to(mc, 1, {x:100, cacheAsBitmap:true});</code></p>
 * 
 * <p><b>USAGE:</b></p>
 * <listing version="3.0">
import com.greensock.TweenLite; 
import com.greensock.plugins.TweenPlugin; 
import com.greensock.plugins.CacheAsBitmapPlugin; 
TweenPlugin.activate([CacheAsBitmapPlugin]); //activation is permanent in the SWF, so this line only needs to be run once.

TweenLite.to(mc, 1, {x:100, cacheAsBitmap:true}); 
</listing>
 * 
 * <p><strong>Copyright 2008-2014, GreenSock. All rights reserved.</strong> This work is subject to the terms in <a href="http://www.greensock.com/terms_of_use.html">http://www.greensock.com/terms_of_use.html</a> or for <a href="http://www.greensock.com/club/">Club GreenSock</a> members, the software agreement that was issued with the membership.</p>
 * 
 * @author Jack Doyle, jack@greensock.com
 */
class CacheAsBitmapPlugin extends TweenPlugin
{
    /** @private **/
    public static inline var API : Float = 2;  //If the API/Framework for plugins changes in the future, this number helps determine compatibility  
    
    /** @private **/
    private var _target : DisplayObject;
    /** @private **/
    private var _tween : TweenLite;
    /** @private **/
    private var _cacheAsBitmap : Bool;
    /** @private **/
    private var _initVal : Bool;
    
    /** @private **/
    public function new()
    {
        super("cacheAsBitmap");
    }
    
    /** @private **/
    override public function _onInitTween(target : Dynamic, value : Dynamic, tween : TweenLite) : Bool
    {
        _target = try cast(target, DisplayObject) catch(e:Dynamic) null;
        _tween = tween;
        _initVal = _target.cacheAsBitmap;
        _cacheAsBitmap = cast(value, Bool);
        return true;
    }
    
    /** @private **/
    override public function setRatio(v : Float) : Void
    {
        if ((v == 1 && _tween._duration == _tween._time && _tween.data != "isFromStart") || (v == 0 && _tween._time == 0))
        
        //a changeFactor of 1 doesn't necessarily mean the tween is done - if the ease is Elastic.easeOut or Back.easeOut for example, they could hit 1 mid-tween.
        {
            
            _target.cacheAsBitmap = _initVal;
        }
        else if (_target.cacheAsBitmap != _cacheAsBitmap)
        {
            _target.cacheAsBitmap = _cacheAsBitmap;
        }
    }
}
