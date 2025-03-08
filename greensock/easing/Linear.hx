package com.greensock.easing;


@:final class Linear extends Ease
{
    
    public static var easeNone : Linear = new Linear();
    
    public static var easeIn : Linear = easeNone;
    
    public static var easeOut : Linear = easeNone;
    
    public static var easeInOut : Linear = easeNone;
    
    public static var ease : Linear = easeNone;
    
    
    public function new()
    {
        super(null, null, 1, 0);
    }
}

