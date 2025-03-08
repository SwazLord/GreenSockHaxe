package com.greensock;

import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.utils.Dictionary;
import flash.utils.Proxy;


class TweenProxy extends Proxy
{
    public var registrationY(get, set) : Float;
    public var y(get, set) : Float;
    public var skewY2(get, set) : Float;
    public var rotation(get, set) : Float;
    public var localRegistration(get, set) : Point;
    public var skewX(get, set) : Float;
    public var target(get, never) : DisplayObject;
    public var localRegistrationX(get, set) : Float;
    public var localRegistrationY(get, set) : Float;
    public var skewY(get, set) : Float;
    public var scale(get, set) : Float;
    public var scaleX(get, set) : Float;
    public var width(get, set) : Float;
    public var scaleY(get, set) : Float;
    public var height(get, set) : Float;
    public var registration(get, set) : Point;
    public var alpha(get, set) : Float;
    public var registrationX(get, set) : Float;
    public var skewX2(get, set) : Float;
    public var skewY2Radians(get, set) : Float;
    public var x(get, set) : Float;
    public var skewX2Radians(get, set) : Float;

    
    private static var _RAD2DEG : Float = 180 / Math.PI;
    
    private static var _dict : Dictionary = new Dictionary(false);
    
    public static inline var VERSION : Float = 0.94;
    
    private static var _DEG2RAD : Float = Math.PI / 180;
    
    private static var _addedProps : String = " tint tintPercent scale skewX skewY skewX2 skewY2 target registration registrationX registrationY localRegistration localRegistrationX localRegistrationY ";
    
    
    public var isTweenProxy : Bool = true;
    
    private var _registration : Point;
    
    public var ignoreSiblingUpdates : Bool = false;
    
    private var _target : DisplayObject;
    
    private var _localRegistration : Point;
    
    private var _regAt0 : Bool;
    
    private var _proxies : Array<Dynamic>;
    
    private var _angle : Float;
    
    private var _scaleX : Float;
    
    private var _scaleY : Float;
    
    public function new(target : DisplayObject, ignoreSiblingUpdates : Bool = false)
    {
        super();
        _target = target;
        if (Reflect.field(_dict, Std.string(_target)) == null)
        {
            Reflect.setField(_dict, Std.string(_target), []);
        }
        _proxies = Reflect.field(_dict, Std.string(_target));
        _proxies.push(this);
        _localRegistration = new Point(0, 0);
        this.ignoreSiblingUpdates = ignoreSiblingUpdates;
        calibrate();
    }
    
    public static function create(target : DisplayObject, allowRecycle : Bool = true) : TweenProxy
    {
        if (Reflect.field(_dict, Std.string(target)) != null && allowRecycle)
        {
            return Reflect.field(_dict, Std.string(target))[0];
        }
        return new TweenProxy(target);
    }
    
    private function set_registrationY(n : Float) : Float
    {
        _registration.y = n;
        calibrateLocal();
        return n;
    }
    
    private function set_y(n : Float) : Float
    {
        var ty : Float = n - _registration.y;
        _target.y += ty;
        var i : Int = as3hx.Compat.parseInt(_proxies.length - 1);
        while (i > -1)
        {
            if (_proxies[i] == this || !_proxies[i].ignoreSiblingUpdates)
            {
                _proxies[i].moveRegY(ty);
            }
            i--;
        }
        return n;
    }
    
    private function get_skewY2() : Float
    {
        return this.skewY2Radians * _RAD2DEG;
    }
    
    private function get_rotation() : Float
    {
        return _angle * _RAD2DEG;
    }
    
    private function set_skewY2(n : Float) : Float
    {
        this.skewY2Radians = n * _DEG2RAD;
        return n;
    }
    
    private function set_localRegistration(p : Point) : Point
    {
        _localRegistration = p;
        calibrateRegistration();
        return p;
    }
    
    public function onSiblingUpdate(scaleX : Float, scaleY : Float, angle : Float) : Void
    {
        _scaleX = scaleX;
        _scaleY = scaleY;
        _angle = angle;
        if (this.ignoreSiblingUpdates)
        {
            calibrateLocal();
        }
        else
        {
            calibrateRegistration();
        }
    }
    
    private function get_skewX() : Float
    {
        var m : Matrix = _target.transform.matrix;
        return (Math.atan2(-m.c, m.d) - _angle) * _RAD2DEG;
    }
    
    override private function hasProperty(name : Dynamic) : Bool
    {
        if (_target.exists(name))
        {
            return true;
        }
        if (_addedProps.indexOf(" " + name + " ") != -1)
        {
            return true;
        }
        return false;
    }
    
    private function get_target() : DisplayObject
    {
        return _target;
    }
    
    private function updateSiblingProxies() : Void
    {
        var i : Int = as3hx.Compat.parseInt(_proxies.length - 1);
        while (i > -1)
        {
            if (_proxies[i] != this)
            {
                _proxies[i].onSiblingUpdate(_scaleX, _scaleY, _angle);
            }
            i--;
        }
    }
    
    private function get_localRegistrationX() : Float
    {
        return _localRegistration.x;
    }
    
    private function get_localRegistrationY() : Float
    {
        return _localRegistration.y;
    }
    
    private function get_skewY() : Float
    {
        var m : Matrix = _target.transform.matrix;
        return (Math.atan2(m.b, m.a) - _angle) * _RAD2DEG;
    }
    
    private function set_scale(n : Float) : Float
    {
        if (n == 0)
        {
            n = 0.0001;
        }
        var m : Matrix = _target.transform.matrix;
        m.rotate(-_angle);
        m.scale(n / _scaleX, n / _scaleY);
        m.rotate(_angle);
        _target.transform.matrix = m;
        _scaleX = _scaleY = n;
        reposition();
        if (_proxies.length > 1)
        {
            updateSiblingProxies();
        }
        return n;
    }
    
    private function set_skewX(n : Float) : Float
    {
        var radians : Float = n * _DEG2RAD;
        var m : Matrix = _target.transform.matrix;
        var sy : Float = (_scaleY < 0) ? -_scaleY : _scaleY;
        m.c = -sy * Math.sin(radians + _angle);
        m.d = sy * Math.cos(radians + _angle);
        _target.transform.matrix = m;
        if (!_regAt0)
        {
            reposition();
        }
        if (_proxies.length > 1)
        {
            updateSiblingProxies();
        }
        return n;
    }
    
    private function set_skewY(n : Float) : Float
    {
        var radians : Float = n * _DEG2RAD;
        var m : Matrix = _target.transform.matrix;
        var sx : Float = (_scaleX < 0) ? -_scaleX : _scaleX;
        m.a = sx * Math.cos(radians + _angle);
        m.b = sx * Math.sin(radians + _angle);
        _target.transform.matrix = m;
        if (!_regAt0)
        {
            reposition();
        }
        if (_proxies.length > 1)
        {
            updateSiblingProxies();
        }
        return n;
    }
    
    private function calibrateRegistration() : Void
    {
        _registration = _target.parent.globalToLocal(_target.localToGlobal(_localRegistration));
        _regAt0 = _localRegistration.x == 0 && _localRegistration.y == 0;
    }
    
    private function set_scaleX(n : Float) : Float
    {
        if (n == 0)
        {
            n = 0.0001;
        }
        var m : Matrix = _target.transform.matrix;
        m.rotate(-_angle);
        m.scale(n / _scaleX, 1);
        m.rotate(_angle);
        _target.transform.matrix = m;
        _scaleX = n;
        reposition();
        if (_proxies.length > 1)
        {
            updateSiblingProxies();
        }
        return n;
    }
    
    private function set_width(n : Float) : Float
    {
        _target.width = n;
        if (!_regAt0)
        {
            reposition();
        }
        if (_proxies.length > 1)
        {
            updateSiblingProxies();
        }
        return n;
    }
    
    private function set_scaleY(n : Float) : Float
    {
        if (n == 0)
        {
            n = 0.0001;
        }
        var m : Matrix = _target.transform.matrix;
        m.rotate(-_angle);
        m.scale(1, n / _scaleY);
        m.rotate(_angle);
        _target.transform.matrix = m;
        _scaleY = n;
        reposition();
        if (_proxies.length > 1)
        {
            updateSiblingProxies();
        }
        return n;
    }
    
    private function get_height() : Float
    {
        return _target.height;
    }
    
    private function set_localRegistrationY(n : Float) : Float
    {
        _localRegistration.y = n;
        calibrateRegistration();
        return n;
    }
    
    private function set_localRegistrationX(n : Float) : Float
    {
        _localRegistration.x = n;
        calibrateRegistration();
        return n;
    }
    
    public function moveRegX(n : Float) : Void
    {
        _registration.x += n;
    }
    
    public function moveRegY(n : Float) : Void
    {
        _registration.y += n;
    }
    
    private function get_registration() : Point
    {
        return _registration;
    }
    
    private function set_alpha(n : Float) : Float
    {
        _target.alpha = n;
        return n;
    }
    
    private function get_registrationX() : Float
    {
        return _registration.x;
    }
    
    private function get_registrationY() : Float
    {
        return _registration.y;
    }
    
    private function get_localRegistration() : Point
    {
        return _localRegistration;
    }
    
    private function get_width() : Float
    {
        return _target.width;
    }
    
    public function calibrate() : Void
    {
        _scaleX = _target.scaleX;
        _scaleY = _target.scaleY;
        _angle = _target.rotation * _DEG2RAD;
        calibrateRegistration();
    }
    
    private function get_scale() : Float
    {
        return (_scaleX + _scaleY) / 2;
    }
    
    public function getCenter() : Point
    {
        var s : Sprite = null;
        var remove : Bool = false;
        if (_target.parent == null)
        {
            remove = true;
            s = new Sprite();
            s.addChild(_target);
        }
        var b : Rectangle = _target.getBounds(_target.parent);
        var p : Point = new Point(b.x + b.width / 2, b.y + b.height / 2);
        if (remove)
        {
            _target.parent.removeChild(_target);
        }
        return p;
    }
    
    private function get_scaleX() : Float
    {
        return _scaleX;
    }
    
    private function set_skewX2(n : Float) : Float
    {
        this.skewX2Radians = n * _DEG2RAD;
        return n;
    }
    
    override private function getProperty(prop : Dynamic) : Dynamic
    {
        return Reflect.field(_target, Std.string(prop));
    }
    
    override private function callProperty(name : Dynamic, args : Array<Dynamic> = null) : Dynamic
    {
        return Reflect.field(_target, Std.string(name)).apply(null, args);
    }
    
    private function set_height(n : Float) : Float
    {
        _target.height = n;
        if (!_regAt0)
        {
            reposition();
        }
        if (_proxies.length > 1)
        {
            updateSiblingProxies();
        }
        return n;
    }
    
    private function get_scaleY() : Float
    {
        return _scaleY;
    }
    
    override private function setProperty(prop : Dynamic, value : Dynamic) : Void
    {
        Reflect.setField(_target, Std.string(prop), value);
    }
    
    private function set_skewY2Radians(n : Float) : Float
    {
        var m : Matrix = _target.transform.matrix;
        m.b = Math.tan(n);
        _target.transform.matrix = m;
        if (!_regAt0)
        {
            reposition();
        }
        if (_proxies.length > 1)
        {
            updateSiblingProxies();
        }
        return n;
    }
    
    private function reposition() : Void
    {
        var p : Point = _target.parent.globalToLocal(_target.localToGlobal(_localRegistration));
        _target.x += _registration.x - p.x;
        _target.y += _registration.y - p.y;
    }
    
    private function calibrateLocal() : Void
    {
        _localRegistration = _target.globalToLocal(_target.parent.localToGlobal(_registration));
        _regAt0 = _localRegistration.x == 0 && _localRegistration.y == 0;
    }
    
    private function get_alpha() : Float
    {
        return _target.alpha;
    }
    
    private function get_skewX2() : Float
    {
        return this.skewX2Radians * _RAD2DEG;
    }
    
    private function get_skewY2Radians() : Float
    {
        return Math.atan(_target.transform.matrix.b);
    }
    
    private function set_x(n : Float) : Float
    {
        var tx : Float = n - _registration.x;
        _target.x += tx;
        var i : Int = as3hx.Compat.parseInt(_proxies.length - 1);
        while (i > -1)
        {
            if (_proxies[i] == this || !_proxies[i].ignoreSiblingUpdates)
            {
                _proxies[i].moveRegX(tx);
            }
            i--;
        }
        return n;
    }
    
    private function set_registration(p : Point) : Point
    {
        _registration = p;
        calibrateLocal();
        return p;
    }
    
    private function set_skewX2Radians(n : Float) : Float
    {
        var m : Matrix = _target.transform.matrix;
        m.c = Math.tan(-n);
        _target.transform.matrix = m;
        if (!_regAt0)
        {
            reposition();
        }
        if (_proxies.length > 1)
        {
            updateSiblingProxies();
        }
        return n;
    }
    
    private function get_skewX2Radians() : Float
    {
        return -Math.atan(_target.transform.matrix.c);
    }
    
    private function get_x() : Float
    {
        return _registration.x;
    }
    
    private function get_y() : Float
    {
        return _registration.y;
    }
    
    public function destroy() : Void
    {
        var i : Int = 0;
        var a : Array<Dynamic> = Reflect.field(_dict, Std.string(_target));
        i = as3hx.Compat.parseInt(a.length - 1);
        while (i > -1)
        {
            if (a[i] == this)
            {
                a.splice(i, 1);
            }
            i--;
        }
        if (a.length == 0)
        {
            This is an intentional compilation error. See the README for handling the delete keyword
            delete _dict[_target];
        }
        _target = null;
        _localRegistration = null;
        _registration = null;
        _proxies = null;
    }
    
    private function set_rotation(n : Float) : Float
    {
        var radians : Float = n * _DEG2RAD;
        var m : Matrix = _target.transform.matrix;
        m.rotate(radians - _angle);
        _target.transform.matrix = m;
        _angle = radians;
        reposition();
        if (_proxies.length > 1)
        {
            updateSiblingProxies();
        }
        return n;
    }
    
    private function set_registrationX(n : Float) : Float
    {
        _registration.x = n;
        calibrateLocal();
        return n;
    }
}

