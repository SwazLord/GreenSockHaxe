package com.greensock.plugins;

import com.greensock.TweenLite;

class HexColorsPlugin extends TweenPlugin {
	public static var API:Float = 2;

	private var _colors:Array<ColorProp>;

	public function new() {
		super("hexColors");
		_overwriteProps = [];
		_colors = [];
	}

	override public function _onInitTween(target:Dynamic, value:Dynamic, tween:TweenLite):Bool {
		for (p in Reflect.fields(value)) {
			_initColor(target, p, Std.int(Reflect.field(value, p)));
		}
		return true;
	}

	public function _initColor(target:Dynamic, p:String, end:UInt):Void {
		var isFunc:Bool = Reflect.isFunction(Reflect.field(target, p));
		var start:UInt;

		if (isFunc) {
			if (p.indexOf("set") == 0 || !Reflect.hasField(target, "get" + p.substr(3))) {
				start = Reflect.callMethod(target, Reflect.field(target, p), []);
			} else {
				start = Reflect.callMethod(target, Reflect.field(target, "get" + p.substr(3)), []);
			}
		} else {
			start = Reflect.field(target, p);
		}

		if (start != end) {
			var r:UInt = start >> 16;
			var g:UInt = (start >> 8) & 0xff;
			var b:UInt = start & 0xff;
			_colors.push(new ColorProp(target, p, isFunc, r, (end >> 16) - r, g, ((end >> 8) & 0xff) - g, b, (end & 0xff) - b));
			_overwriteProps.push(p);
		}
	}

	override public function _kill(lookup:Dynamic):Bool {
		var i:Int = _colors.length;
		while (i-- > 0) {
			if (Reflect.field(lookup, _colors[i].p) != null) {
				_colors.splice(i, 1);
			}
		}
		return super._kill(lookup);
	}

	override public function setRatio(v:Float):Void {
		var i:Int = _colors.length;
		var clr:ColorProp;
		var val:Float;
		while (--i > -1) {
			clr = _colors[i];
			val = Std.int(clr.rs + (v * clr.rc)) << 16 | Std.int(clr.gs + (v * clr.gc)) << 8 | Std.int(clr.bs + (v * clr.bc));
			if (clr.f) {
				Reflect.callMethod(clr.t, Reflect.field(clr.t, clr.p), [val]);
			} else {
				Reflect.setField(clr.t, clr.p, val);
			}
		}
	}
}

@:allow(com.greensock.plugins.HexColorsPlugin)
class ColorProp {
	public var t:Dynamic;
	public var p:String;
	public var f:Bool = false;
	public var rs:Int;
	public var rc:Int;
	public var gs:Int;
	public var gc:Int;
	public var bs:Int;
	public var bc:Int;

	public function new(t:Dynamic, p:String, f:Bool, rs:Int, rc:Int, gs:Int, gc:Int, bs:Int, bc:Int) {
		this.t = t;
		this.p = p;
		this.f = f;
		this.rs = rs;
		this.rc = rc;
		this.gs = gs;
		this.gc = gc;
		this.bs = bs;
		this.bc = bc;
	}
}
