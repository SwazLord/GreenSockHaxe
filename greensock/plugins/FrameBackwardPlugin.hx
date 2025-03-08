package com.greensock.plugins;


class FrameBackwardPlugin extends FrameForwardPlugin
{
    
    public static inline var API : Float = 2;
    
    
    public function new()
    {
        super();
        _propName = "frameBackward";
        _backward = true;
    }
}

