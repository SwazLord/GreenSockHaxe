package com.greensock.motionPaths;


class PathFollower
{
    public var progress(get, set) : Float;
    public var rawProgress(get, set) : Float;

    
    
    public var path : MotionPath;
    
    public var cachedProgress : Float;
    
    public var target : Dynamic;
    
    public var cachedRawProgress : Float;
    
    public var cachedNext : PathFollower;
    
    public var autoRotate : Bool;
    
    public var rotationOffset : Float;
    
    public var cachedPrev : PathFollower;
    
    public function new(target : Dynamic, autoRotate : Bool = false, rotationOffset : Float = 0)
    {
        super();
        this.target = target;
        this.autoRotate = autoRotate;
        this.rotationOffset = rotationOffset;
        this.cachedProgress = this.cachedRawProgress = 0;
    }
    
    private function set_progress(value : Float) : Float
    {
        if (value > 1)
        {
            this.cachedRawProgress = value;
            this.cachedProgress = value - as3hx.Compat.parseInt(value);
            if (this.cachedProgress == 0)
            {
                this.cachedProgress = 1;
            }
        }
        else if (value < 0)
        {
            this.cachedRawProgress = value;
            this.cachedProgress = value - (as3hx.Compat.parseInt(value) - 1);
        }
        else
        {
            this.cachedRawProgress = as3hx.Compat.parseInt(this.cachedRawProgress) + value;
            this.cachedProgress = value;
        }
        if (this.path)
        {
            this.path.renderObjectAt(this.target, this.cachedProgress, this.autoRotate, this.rotationOffset);
        }
        return value;
    }
    
    private function set_rawProgress(value : Float) : Float
    {
        this.progress = value;
        return value;
    }
    
    private function get_rawProgress() : Float
    {
        return this.cachedRawProgress;
    }
    
    private function get_progress() : Float
    {
        return this.cachedProgress;
    }
}

