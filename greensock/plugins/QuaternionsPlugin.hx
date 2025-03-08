package com.greensock.plugins;

import com.greensock.TweenLite;

class QuaternionsPlugin extends TweenPlugin
{
    
    public static inline var API : Float = 2;
    
    private static var _RAD2DEG : Float = 180 / Math.PI;
    
    
    private var _target : Dynamic;
    
    private var _quaternions : Array<Dynamic>;
    
    public function new()
    {
        _quaternions = [];
        super("quaternions");
        _overwriteProps.pop();
    }
    
    public function _initQuaternion(end : Dynamic, p : String) : Void
    {
        var angle : Float = Math.NaN;
        var q1 : Dynamic = null;
        var q2 : Dynamic = null;
        var x1 : Float = Math.NaN;
        var x2 : Float = Math.NaN;
        var y1 : Float = Math.NaN;
        var y2 : Float = Math.NaN;
        var z1 : Float = Math.NaN;
        var z2 : Float = Math.NaN;
        var w1 : Float = Math.NaN;
        var w2 : Float = Math.NaN;
        var theta : Float = Math.NaN;
        var isFunc : Bool = Std.is(Reflect.field(_target, p), Function);
        q1 = !(isFunc) ? Reflect.field(_target, p) : Reflect.field(_target, Std.string(p.indexOf("set") || !((Lambda.has(_target, "get" + p.substr(3)))) ? p : "get" + p.substr(3)))();
        q2 = end;
        x1 = q1.x;
        x2 = q2.x;
        y1 = q1.y;
        y2 = q2.y;
        z1 = q1.z;
        z2 = q2.z;
        w1 = q1.w;
        w2 = q2.w;
        angle = x1 * x2 + y1 * y2 + z1 * z2 + w1 * w2;
        if (angle < 0)
        {
            x1 *= -1;
            y1 *= -1;
            z1 *= -1;
            w1 *= -1;
            angle *= -1;
        }
        if (angle + 1 < 0.000001)
        {
            y2 = -y1;
            x2 = x1;
            w2 = -w1;
            z2 = z1;
        }
        theta = Math.acos(angle);
        _quaternions[_quaternions.length] = [q1, p, x1, x2, y1, y2, z1, z2, w1, w2, angle, theta, 1 / Math.sin(theta), isFunc];
        _overwriteProps[_overwriteProps.length] = p;
    }
    
    override public function _kill(lookup : Dynamic) : Bool
    {
        var i : Int = _quaternions.length;
        while (--i > -1)
        {
            if (Reflect.field(lookup, Std.string(_quaternions[i][1])) != null)
            {
                _quaternions.splice(i, 1);
            }
        }
        return super._kill(lookup);
    }
    
    override public function setRatio(v : Float) : Void
    {
        var q : Array<Dynamic> = null;
        var scale : Float = Math.NaN;
        var invScale : Float = Math.NaN;
        var i : Int = _quaternions.length;
        while (--i > -1)
        {
            q = _quaternions[i];
            if (q[10] + 1 > 0.000001)
            {
                if (1 - q[10] >= 0.000001)
                {
                    scale = Math.sin(q[11] * (1 - v)) * q[12];
                    invScale = Math.sin(q[11] * v) * q[12];
                }
                else
                {
                    scale = 1 - v;
                    invScale = v;
                }
            }
            else
            {
                scale = Math.sin(Math.PI * (0.5 - v));
                invScale = Math.sin(Math.PI * v);
            }
            q[0].x = scale * q[2] + invScale * q[3];
            q[0].y = scale * q[4] + invScale * q[5];
            q[0].z = scale * q[6] + invScale * q[7];
            q[0].w = scale * q[8] + invScale * q[9];
            if (q[13] != null)
            {
                Reflect.field(_target, Std.string(q[1]))(q[0]);
            }
            else
            {
                Reflect.setField(_target, Std.string(q[1]), q[0]);
            }
        }
    }
    
    override public function _onInitTween(target : Dynamic, value : Dynamic, tween : TweenLite) : Bool
    {
        var p : Dynamic = null;
        if (value == null)
        {
            return false;
        }
        _target = target;
        for (p in Reflect.fields(value))
        {
            _initQuaternion(Reflect.field(value, Std.string(p)), p);
        }
        return true;
    }
}

