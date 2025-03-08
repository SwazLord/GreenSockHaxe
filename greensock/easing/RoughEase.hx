package com.greensock.easing;

import haxe.ds.ArraySort;
import com.greensock.easing.core.EasePoint;

class RoughEase extends Ease {
    /** The default ease instance which can be reused many times in various tweens in order to conserve memory and improve performance slightly compared to creating a new instance each time. **/
    public static var ease:RoughEase = new RoughEase();

    /** @private **/
    private static var _lookup:Map<String, RoughEase> = new Map(); // Keeps track of all named instances so we can find them in byName().

    /** @private **/
    private static var _count:Int = 0;

    /** @private **/
    private var _name:String;

    /** @private **/
    private var _first:EasePoint;

    /** @private **/
    private var _prev:EasePoint;

    public function new(vars:Dynamic = null, ?points:Int, ?clamp:Bool, ?template:Ease, ?taper:String, ?randomize:Bool, ?name:String) {
        super();
        if (Std.isOfType(vars, String)) {
            vars = {
                strength: vars,
                points: points,
                clamp: clamp,
                template: template,
                taper: taper,
                randomize: randomize,
                name: name
            };
        }

        if (vars.name != null) {
            _name = vars.name;
            _lookup.set(vars.name, this);
        } else {
            _name = 'roughEase${_count++}';
        }

        var taper:String = vars.taper != null ? vars.taper : "none";
        var a:Array<Dynamic> = [];
        var cnt:Int = 0;
        var points:Int = Std.parseInt(Std.string(vars.points != null ? vars.points : 20));
        var i:Int = points;
        var randomize:Bool = vars.randomize != false;
        var clamp:Bool = vars.clamp == true;
        var template:Ease = Std.isOfType(vars.template, Ease) ? cast(vars.template, Ease) : null;
        var strength:Float = Std.isOfType(vars.strength, Float) ? vars.strength * 0.4 : 0.4;
        var x:Float, y:Float, bump:Float, invX:Float, obj:{x:Float, y:Float};

        while (--i > -1) {
            x = randomize ? Math.random() : (1 / points) * i;
            y = (template != null) ? template.getRatio(x) : x;

            if (taper == "none") {
                bump = strength;
            } else if (taper == "out") {
                invX = 1 - x;
                bump = invX * invX * strength;
            } else if (taper == "in") {
                bump = x * x * strength;
            } else if (x < 0.5) { // "both" (start)
                invX = x * 2;
                bump = invX * invX * 0.5 * strength;
            } else { // "both" (end)
                invX = (1 - x) * 2;
                bump = invX * invX * 0.5 * strength;
            }

            if (randomize) {
                y += (Math.random() * bump) - (bump * 0.5);
            } else if (i % 2 == 1) {
                y += bump * 0.5;
            } else {
                y -= bump * 0.5;
            }

            if (clamp) {
                if (y > 1) {
                    y = 1;
                } else if (y < 0) {
                    y = 0;
                }
            }

            a[cnt++] = {x: x, y: y};
        }

        ArraySort.sort(a, function(a, b) return a.x - b.x);

        _first = new EasePoint(1, 1, null);
        i = points;

        while (--i > -1) {
            obj = a[i];
            _first = new EasePoint(obj.x, obj.y, _first);
        }

        _first = _prev = new EasePoint(0, 0, (_first.time != 0) ? _first : _first.next);
    }

    public static function create(strength:Float = 1, points:Int = 20, clamp:Bool = false, templateEase:Ease = null, taper:String = "none",
            randomize:Bool = true, name:String = ""):Ease {
        return new RoughEase(strength, points, clamp, templateEase, taper, randomize, name);
    }

    public static function byName(name:String):Ease {
        return _lookup.get(name);
    }

    override public function getRatio(p:Float):Float {
        var pnt:EasePoint = _prev;
        if (p > _prev.time) {
            while (pnt.next != null && p >= pnt.time) {
                pnt = pnt.next;
            }
            pnt = pnt.prev;
        } else {
            while (pnt.prev != null && p <= pnt.time) {
                pnt = pnt.prev;
            }
        }
        _prev = pnt;
        return (pnt.value + ((p - pnt.time) / pnt.gap) * pnt.change);
    }

    /** @private [DEPRECATED] Disposes the RoughEase so that it is no longer stored for easy lookups by name with `byName()`, releasing it for garbage collection. **/
    public function dispose():Void {
        _lookup.remove(_name);
    }

    /** @private [DEPRECATED] name of the RoughEase instance **/
    public var name(get, set):String;

    private function get_name():String {
        return _name;
    }

    private function set_name(value:String):String {
        _lookup.remove(_name);
        _name = value;
        _lookup.set(_name, this);
        return value;
    }

    public function config(vars:Dynamic = null):RoughEase {
        return new RoughEase(vars);
    }
}