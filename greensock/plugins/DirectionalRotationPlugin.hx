package com.greensock.plugins;

import com.greensock.TweenLite;
import com.greensock.core.PropTween;

class DirectionalRotationPlugin extends TweenPlugin {
	public static inline var API:Float = 2;

	private var finals:Dynamic;

	public function new() {
		super("directionalRotation");
		_overwriteProps.pop();
	}

	override public function setRatio(v:Float):Void {
		var pt:PropTween = null;
		if (v != 1) {
			super.setRatio(v);
		} else {
			pt = _firstPT;
			while (pt != null) {
				if (pt.f) {
					// pt.t.setField(pt.p, finals[pt.p]);
					Reflect.callMethod(pt.t, Reflect.field(finals, Std.string(pt.p)), []);
				} else {
					// Reflect.setField(pt.t, pt.p, finals[pt.p]);
					Reflect.setField(pt.t, pt.p, Reflect.field(finals, Std.string(pt.p)));
				}
				pt = pt._next;
			}
		}
	}

	override public function _onInitTween(target:Dynamic, value:Dynamic, tween:TweenLite):Bool {
		var p:Dynamic = null;
		var v:Dynamic = null;
		var start:Float = Math.NaN;
		var end:Float = Math.NaN;
		var dif:Float = Math.NaN;
		var type:String = null;

		if (!Std.isOfType(value, Dynamic)) {
			value = {"rotation": value};
		}

		finals = {};
		var cap:Float = value.useRadians == true ? Math.PI * 2 : 360;

		for (p in Reflect.fields(value)) {
			switch (p) {
				case "function":
					continue;
				case "useRadians":
					continue;
				default:
					var property = p;
					var getterName = "get" + p.substr(3);
					var getter = Reflect.getProperty(target, getterName) != null ? getterName : property;
					start = Reflect.callMethod(target, Reflect.getProperty(target, getter), []);

					if (Std.isOfType(v, String) && v.charAt(1) == "=") {
						var increment = Std.parseInt(v.charAt(0) + "1");
						var multiplier = Std.parseFloat(v.substr(2));
						end = start + (increment * multiplier);
						// finals[p] = start + (increment * multiplier);
						// Reflect.setField(finals, Std.string(p), end);
					} else {
						end = Math.isNaN(v) ? 0 : v;
						// finals[p] = Math.isNaN(v) ? 0 : v;
					}

					Reflect.setField(finals, Std.string(p), end);

					dif = end - start;
					if (type == "short") {
						dif %= cap;
						if (dif != dif % (cap / 2)) {
							dif = dif < 0 ? dif + cap : dif - cap;
						}
					} else if (type == "cw" && dif < 0) {
						dif = (dif + cap * 9999999999) % cap - (Std.int(dif / cap)) * cap;
					} else if (type == "ccw" && dif > 0) {
						dif = (dif - cap * 9999999999) % cap - (Std.int(dif / cap)) * cap;
					}
					_addTween(target, p, start, start + dif, p);
					_overwriteProps.push(p);
			}
		}
		return true;
	}
}
