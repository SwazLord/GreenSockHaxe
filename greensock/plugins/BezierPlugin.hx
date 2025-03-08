package com.greensock.plugins;

import openfl.utils.Function;
import as3hx.Compat;
import openfl.errors.Error;
import com.greensock.TweenLite;
import openfl.geom.Point;

class BezierPlugin extends TweenPlugin {
	public static inline var API:Float = 2;
	private static var _RAD2DEG:Float = 180 / Math.PI;
	private static var _r1:Array<Dynamic> = [];
	private static var _r2:Array<Dynamic> = [];
	private static var _r3:Array<Dynamic> = [];
	private static var _corProps:Dynamic = {};

	private var _target:Dynamic;
	private var _autoRotate:Array<Dynamic>;
	private var _round:Dynamic;
	private var _lengths:Array<Dynamic>;
	private var _segments:Array<Dynamic>;
	private var _length:Float;
	private var _func:Dynamic;
	private var _props:Array<Dynamic>;
	private var _l1:Float;
	private var _l2:Float;
	private var _li:Float;
	private var _curSeg:Array<Dynamic>;
	private var _s1:Float;
	private var _s2:Float;
	private var _si:Float;
	private var _beziers:Dynamic;
	private var _segCount:Int;
	private var _prec:Float;
	private var _timeRes:Int;
	private var _initialRotations:Array<Dynamic>;
	private var _startRatio:Int;

	/** @private **/
	public function new() {
		super("bezier");
		this._overwriteProps.pop();
		this._func = {};
		this._round = {};
	}

	override public function _onInitTween(target:Dynamic, value:Dynamic, tween:TweenLite):Bool {
		this._target = target;
		var vars:Dynamic = ((Std.isOfType(value, Array))) ? {
			values: value
		} : value;
		this._props = [];
		this._timeRes = ((vars.timeResolution == null)) ? 6 : Std.int(vars.timeResolution);
		var values:Array<Dynamic> = vars.values ?? [];
		var first:Dynamic = {};
		var second:Dynamic = values[0];
		var autoRotate:Dynamic = vars.autoRotate ?? tween.vars.orientToBezier;
		var p:String = null;
		var isFunc:Bool = false;
		var i:Int;
		var j:Int;
		var ar:Array<Dynamic>;
		var prepend:Dynamic = {};

		// this._autoRotate = (autoRotate != null) ? ((Std.isOfType(autoRotate, Array))) ? try cast(autoRotate, Array</*AS3HX WARNING no type*/>) catch(e:Dynamic) null : [["x", "y", "rotation", (((autoRotate == true)) ? 0 : as3hx.Compat.parseFloat(autoRotate))]] : null;
		this._autoRotate = autoRotate ? (Std.isOfType(autoRotate,
			Array)) ? autoRotate : [["x", "y", "rotation", ((autoRotate == true) ? 0 : Std.parseFloat(autoRotate))]] : null;

		if (Std.isOfType(second, Point)) {
			this._props = ["x", "y"];
		} else {
			for (p in Reflect.fields(second)) {
				this._props.push(p);
			}
		}

		i = this._props.length;
		while (--i > -1) {
			p = this._props[i];
			this._overwriteProps.push(p);
			// isFunc = (Std.isOfType(Reflect.field(target, p), Function));
			isFunc = Reflect.isFunction(Reflect.field(target, p));

			Reflect.setField(this._func, p, Reflect.isFunction(Reflect.field(target, p)));
			// Reflect.setField(first, p, ((!isFunc)) ? Reflect.field(target, p) : Reflect.field(target, Std.string((((p.indexOf("set") || !(Lambda.has(target, "get" + p.substr(3))))) ? p : "get" + p.substr(3))))());
			Reflect.setField(first, p, (!isFunc) ? Reflect.field(_target, p) : Reflect.callMethod(_target, Reflect.field(_target, "get" + p.substr(3)), []));
			if (prepend == null) {
				if (Reflect.field(first, p) != Reflect.field(values[0], p)) {
					prepend = first;
				}
			}
		}
		// this._beziers = ((vars.type != "cubic" && vars.type != "quadratic" && vars.type != "soft")) ? bezierThrough(values, (Math.isNaN(vars.curviness)) ? 1 : vars.curviness, false, vars.type == "thruBasic", vars.correlate || "x,y,z", prepend) : _parseBezierData(values, vars.type, first);
		// this._segCount = this._beziers[p].length;

		this._beziers = (vars.type != "cubic" && vars.type != "quadratic" && vars.type != "soft") ? bezierThrough(values,
			Math.isNaN(vars.curviness) ? 1 : vars.curviness, false, (vars.type == "thruBasic"), vars.correlate ?? "x,y,z",
			prepend) : _parseBezierData(values, vars.type, first);
		this._segCount = Reflect.fields(Reflect.field(_beziers, p)).length;

		if (this._timeRes != null) {
			var ld:Dynamic = _parseLengthData(this._beziers, this._timeRes);
			this._length = ld.length;
			this._lengths = ld.lengths;
			this._segments = ld.segments;
			this._l1 = this._li = this._s1 = this._si = 0;
			this._l2 = this._lengths[0];
			this._curSeg = this._segments[0];
			this._s2 = this._curSeg[0];
			this._prec = 1 / this._curSeg.length;
		}

		if ((ar = this._autoRotate) != null) {
			this._initialRotations = [];
			if (!(Std.isOfType(ar[0], Array))) {
				this._autoRotate = ar = [ar];
			}
			i = ar.length;
			while (--i > -1) {
				for (j in 0...3) {
					p = ar[i][j];
					// this._func[p] = ((Std.isOfType(Reflect.field(target, p), Function))) ? Reflect.field(target, Std.string((((p.indexOf("set") || !(Lambda.has(target, "get" + p.substr(3))))) ? p : "get" + p.substr(3)))) : false;
					if (Reflect.isFunction(Reflect.field(target, p))) {
						if (p.indexOf("set") == 0) {
							Reflect.setField(this._func, p, Reflect.field(target, p));
						} else {
							var getterName:String = "get" + p.substr(3);
							if (Reflect.hasField(target, getterName)) {
								Reflect.setField(this._func, p, Reflect.field(target, getterName));
							} else {
								Reflect.setField(this._func, p, Reflect.field(target, p));
							}
						}
					} else {
						Reflect.setField(this._func, p, false);
					}
				}
				p = ar[i][2];
				// this._initialRotations[i] = (this._func[p] != null) ? this._func[p]() : this._target[p];
				if (Reflect.field(this._func, p) != null) {
					this._initialRotations[i] = Reflect.callMethod(this._target, Reflect.field(this._func, p), []);
				} else {
					this._initialRotations[i] = Reflect.field(this._target, p);
				}
			}
		}
		_startRatio = (tween.vars.runBackwards) ? 1 : 0;
		return true;
	}

	public static function bezierThrough(values:Array<Dynamic>, curviness:Float = 1, quadratic:Bool = false, basic:Bool = false, correlate:String = "x,y,z",
			prepend:Dynamic = null):Dynamic {
		var obj:Dynamic = {};
		var first:Dynamic = prepend || values[0];
		var props:Array<Dynamic>;
		var i:Int;
		var p:String = null;
		var j:Int;
		var a:Array<Dynamic>;
		var l:Int;
		var r:Float;
		var seamless:Bool = false;
		var last:Dynamic;
		correlate = "," + correlate + ",";
		if (Std.isOfType(first, Point)) {
			props = ["x", "y"];
		} else {
			props = [];
			for (p in Reflect.fields(first)) {
				props.push(p);
			}
		}

		if (values.length > 1) {
			last = values[values.length - 1];
			seamless = true;
			i = props.length;
			while (--i > -1) {
				p = props[i];
				if (Math.abs(Reflect.field(first, p) - Reflect.field(last, p)) > 0.05) {
					seamless = false;
					break;
				}
			}
			if (seamless) {
				values = values.copy();
				if (prepend != null) {
					values.unshift(prepend);
				}
				values.push(values[1]);
				prepend = values[values.length - 3];
			}
		}
		_r1 = [];
		_r2 = [];
		_r3 = [];
		i = props.length;
		while (--i > -1) {
			p = props[i];
			Reflect.setField(_corProps, p, (correlate.indexOf("," + p + ",") != -1));
			Reflect.setField(obj, p, _parseAnchors(values, p, Reflect.field(_corProps, p), prepend));
		}
		i = _r1.length;
		while (--i > -1) {
			_r1[i] = Math.sqrt(_r1[i]);
			_r2[i] = Math.sqrt(_r2[i]);
		}
		if (!basic) {
			i = props.length;
			while (--i > -1) {
				if (Reflect.field(_corProps, p) != null) {
					a = Reflect.field(obj, Std.string(props[i]));
					l = Std.int(a.length - 1);
					for (j in 0...l) {
						r = a[j + 1].da / _r2[j] + a[j].da / _r1[j];
						_r3[j] = (_r3[j] ?? 0) + r * r;
					}
				}
			}
			i = _r3.length;
			while (--i > -1) {
				_r3[i] = Math.sqrt(_r3[i]);
			}
		}
		i = props.length;
		j = (quadratic) ? 4 : 1;
		while (--i > -1) {
			p = props[i];
			a = Reflect.field(obj, p);
			_calculateControlPoints(a, curviness, quadratic, basic, Reflect.field(_corProps, p));
			if (seamless) {
				a.splice(0, j);
				a.splice(a.length - j, j);
			}
		}
		return obj;
	}

	public static function _parseBezierData(values:Array<Dynamic>, type:String, prepend:Dynamic = null):Dynamic {
		type = type ?? "soft";
		var obj:Dynamic = {};
		var inc:Int = ((type == "cubic")) ? 3 : 2;
		var soft:Bool = (type == "soft");
		var a:Float;
		var b:Float;
		var c:Float;
		var d:Float;
		var cur:Array<Dynamic>;
		var props:Array<Dynamic>;
		var i:Int;
		var j:Int;
		var l:Int;
		var p:String;
		var cnt:Int;
		var tmp:Dynamic;
		if (soft && prepend != null) {
			values = [prepend].concat(values);
		}
		if (values == null || values.length < inc + 1) {
			throw new Error("invalid Bezier data");
		}
		if (Std.isOfType(values[1], Point)) {
			props = ["x", "y"];
		} else {
			props = [];
			for (p in Reflect.fields(values[0])) {
				props.push(p);
			}
		}

		i = props.length;
		while (--i > -1) {
			p = props[i];
			Reflect.setField(obj, p, cur = []);
			cnt = 0;
			l = values.length;
			for (j in 0...l) {
				a = ((prepend == null)) ? Reflect.field(values[j],
					p) : ((Compat.typeof(tmp = Reflect.field(values[j], p)) == "string"
						&& tmp.charAt(1) == "=")) ? Reflect.field(prepend, p)
						+ Compat.parseFloat(tmp.charAt(0) + tmp.substr(2)) : Compat.parseFloat(tmp);
				if (soft) {
					if (j > 1) {
						if (j < l - 1) {
							cur[cnt++] = (a + cur[cnt - 2]) / 2;
						}
					}
				}
				cur[cnt++] = a;
			}
			l = Std.int(cnt - inc + 1);
			cnt = 0;
			j = 0;
			while (j < l) {
				a = cur[j];
				b = cur[j + 1];
				c = cur[j + 2];
				d = ((inc == 2)) ? 0 : cur[j + 3];
				cur[cnt++] = ((inc == 3)) ? new Segment(a, b, c, d) : new Segment(a, (2 * b + a) / 3, (2 * b + c) / 3, c);
				j += inc;
			}
			Compat.setArrayLength(cur, cnt);
		}
		return obj;
	}

	private static function _parseAnchors(values:Array<Dynamic>, p:String, correlate:Bool, prepend:Dynamic):Array<Dynamic> {
		var a:Array<Dynamic> = [];
		var l:Int = 0;
		var i:Int = 0;
		var p1:Float = 0.0;
		var p2:Float = 0.0;
		var p3:Float = 0.0;
		var tmp:Dynamic = {};
		if (prepend != null) {
			values = [prepend].concat(values);
			i = values.length;
			while (--i > -1) {
				if (Compat.typeof(tmp = Reflect.field(values[i], p)) == "string") {
					if (tmp.charAt(1) == "=") {
						Reflect.setField(values[i], p, Reflect.field(prepend, p) + Compat.parseFloat(tmp.charAt(0) + tmp.substr(2)));
					}
				}
			}
		}

		l = Std.int(values.length - 2);
		if (l < 0) {
			a[0] = new Segment(Reflect.field(values[0], p), 0, 0, Reflect.field(values[((l < -1)) ? 0 : 1], p));
			return a;
		}

		for (i in 0...l) {
			p1 = Reflect.field(values[i], p);
			p2 = Reflect.field(values[i + 1], p);
			a[i] = new Segment(p1, 0, 0, p2);
			if (correlate) {
				p3 = Reflect.field(values[i + 2], p);
				_r1[i] = (_r1[i] ?? 0) + (p2 - p1) * (p2 - p1);
				_r2[i] = (_r2[i] ?? 0) + (p3 - p2) * (p3 - p2);
			}
		}
		a[i] = new Segment(Reflect.field(values[i], p), 0, 0, Reflect.field(values[i + 1], p));
		return a;
	}

	private static function _calculateControlPoints(a:Array<Dynamic>, curviness:Float = 1, quad:Bool = false, basic:Bool = false, correlate:Bool = false):Void {
		var l:Int = Std.int(a.length - 1);
		var ii:Int = 0;
		var cp1:Float = a[0].a;
		var i:Int;
		var p1:Float;
		var p2:Float;
		var p3:Float;
		var seg:Segment;
		var m1:Float;
		var m2:Float;
		var mm:Float;
		var cp2:Float;
		var qb:Array<Dynamic>;
		var r1:Float;
		var r2:Float;
		var tl:Float;
		for (i in 0...l) {
			seg = a[ii];
			p1 = seg.a;
			p2 = seg.d;
			p3 = a[ii + 1].d;

			if (correlate) {
				r1 = _r1[i];
				r2 = _r2[i];
				tl = ((r2 + r1) * curviness * 0.25) / ((basic) ? 0.5 : _r3[i] ?? 0.5);
				m1 = p2 - (p2 - p1) * ((basic) ? curviness * 0.5 : ((r1 != 0) ? tl / r1 : 0));
				m2 = p2 + (p3 - p2) * ((basic) ? curviness * 0.5 : ((r2 != 0) ? tl / r2 : 0));
				mm = p2 - (m1 + (((m2 - m1) * ((r1 * 3 / (r1 + r2)) + 0.5) / 4) ?? 0));
			} else {
				m1 = p2 - (p2 - p1) * curviness * 0.5;
				m2 = p2 + (p3 - p2) * curviness * 0.5;
				mm = p2 - (m1 + m2) / 2;
			}
			m1 += mm;
			m2 += mm;

			seg.c = cp2 = m1;
			if (i != 0) {
				seg.b = cp1;
			} else {
				seg.b = cp1 = seg.a + (seg.c - seg.a) * 0.6;
			}

			seg.da = p2 - p1;
			seg.ca = cp2 - p1;
			seg.ba = cp1 - p1;

			if (quad) {
				qb = cubicToQuadratic(p1, cp1, cp2, p2);
				Compat.arraySplice(a, ii, 1, [qb[0], qb[1], qb[2], qb[3]]);
				ii += 4;
			} else {
				ii++;
			}

			cp1 = m2;
		}
		seg = a[ii];
		seg.b = cp1;
		seg.c = cp1 + (seg.d - cp1) * 0.4;
		seg.da = seg.d - seg.a;
		seg.ca = seg.c - seg.a;
		seg.ba = cp1 - seg.a;
		if (quad) {
			qb = cubicToQuadratic(seg.a, cp1, seg.c, seg.d);
			Compat.arraySplice(a, ii, 1, [qb[0], qb[1], qb[2], qb[3]]);
		}
	}

	public static function cubicToQuadratic(a:Float, b:Float, c:Float, d:Float):Array<Dynamic> {
		var q1:Dynamic = {
			a: a
		};
		var q2:Dynamic = {};
		var q3:Dynamic = {};
		var q4:Dynamic = {
			c: d
		};
		var mab:Float = (a + b) / 2;
		var mbc:Float = (b + c) / 2;
		var mcd:Float = (c + d) / 2;
		var mabc:Float = (mab + mbc) / 2;
		var mbcd:Float = (mbc + mcd) / 2;
		var m8:Float = (mbcd - mabc) / 8;
		q1.b = mab + (a - mab) / 4;
		q2.b = mabc + m8;
		q1.c = q2.a = (q1.b + q2.b) / 2;
		q2.c = q3.a = (mabc + mbcd) / 2;
		q3.b = mbcd - m8;
		q4.b = mcd + (d - mcd) / 4;
		q3.c = q4.a = (q3.b + q4.b) / 2;
		return [q1, q2, q3, q4];
	}

	public static function quadraticToCubic(a:Float, b:Float, c:Float):Dynamic {
		return new Segment(a, (2 * b + a) / 3, (2 * b + c) / 3, c);
	}

	private static function _parseLengthData(obj:Dynamic, precision:Int = 6):Dynamic {
		var a:Array<Dynamic> = [];
		var lengths:Array<Dynamic> = [];
		var d:Float = 0;
		var total:Float = 0;
		var threshold:Int = Std.int(precision - 1);
		var segments:Array<Dynamic> = [];
		var curLS:Array<Dynamic> = [];
		var p:String;
		var i:Int;
		var l:Int;
		var index:Float;
		for (p in Reflect.fields(obj)) {
			_addCubicLengths(Reflect.field(obj, p), a, precision);
		}
		l = a.length;
		for (i in 0...l) {
			d += Math.sqrt(a[i]);
			index = i % precision;
			Reflect.setField(curLS, Std.string(index), d);
			if (index == threshold) {
				total += d;
				index = Std.int(i / precision);
				Reflect.setField(segments, Std.string(index), curLS);
				Reflect.setField(lengths, Std.string(index), total);
				d = 0;
				curLS = [];
			}
		}
		return {
			length: total,
			lengths: lengths,
			segments: segments
		};
	}

	private static function _addCubicLengths(a:Array<Dynamic>, steps:Array<Dynamic>, precision:Int = 6):Void {
		var inc:Float = 1 / precision;
		var j:Int = a.length;
		var d:Float;
		var d1:Float;
		var s:Float;
		var da:Float;
		var ca:Float;
		var ba:Float;
		var p:Float;
		var i:Int;
		var inv:Float;
		var bez:Segment;
		var index:Int;
		while (--j > -1) {
			bez = a[j];
			s = bez.a;
			da = bez.d - s;
			ca = bez.c - s;
			ba = bez.b - s;
			d = d1 = 0;
			for (i in 1...precision + 1) {
				p = inc * i;
				inv = 1 - p;
				d = d1 - (d1 = (p * p * da + 3 * inv * (p * ca + inv * ba)) * p);
				index = Std.int(j * precision + i - 1);
				steps[index] = (steps[index] ?? 0) + d * d;
			}
		}
	}

	override public function _kill(lookup:Dynamic):Bool {
		var a:Array<Dynamic> = this._props;
		var p:String;
		var i:Int;
		for (p in Reflect.fields(_beziers)) {
			if (Lambda.has(lookup, p)) {
				Reflect.deleteField(_beziers, p);
				Reflect.deleteField(_func, p);
				i = a.length;
				while (--i > -1) {
					if (a[i] == p) {
						a.splice(i, 1);
					}
				}
			}
		}
		return super._kill(lookup);
	}

	override public function _roundProps(lookup:Dynamic, value:Bool = true):Void {
		var op:Array<Dynamic> = this._overwriteProps;
		var i:Int = op.length;
		while (--i > -1) {
			if ((Lambda.has(lookup, op[i])) || (Lambda.has(lookup, "bezier")) || (Lambda.has(lookup, "bezierThrough"))) {
				this._round[op[i]] = value;
			}
		}
	}

	/** @private **/
	override public function setRatio(v:Float):Void {
		var segments:Int = this._segCount;
		var func:Dynamic = this._func;
		var target:Dynamic = this._target;
		var notStart:Bool = (v != this._startRatio);
		var curIndex:Int;
		var inv:Float;
		var i:Int;
		var p:String;
		var b:Segment;
		var t:Float;
		var val:Float;
		var l:Int;
		var lengths:Array<Dynamic>;
		var curSeg:Array<Dynamic>;
		if (this._timeRes == 0) {
			curIndex = ((v < 0)) ? 0 : ((v >= 1)) ? segments - 1 : Std.int(segments * v);
			t = (v - (curIndex * (1 / segments))) * segments;
		} else {
			lengths = this._lengths;
			curSeg = this._curSeg;
			v *= this._length;
			i = Std.int(this._li);
			// find the appropriate segment (if the currently cached one isn't correct)
			if (v > this._l2 && i < segments - 1) {
				l = Std.int(segments - 1);
				while (i < l && (this._l2 = lengths[++i]) <= v) {}
				this._l1 = lengths[i - 1];
				this._li = i;
				this._curSeg = curSeg = this._segments[i];
				this._s2 = curSeg[Std.int(this._s1 = this._si = 0)];
			} else if (v < this._l1 && i > 0) {
				while (i > 0 && (this._l1 = lengths[--i]) >= v) {}
				if (i == 0 && v < this._l1) {
					this._l1 = 0;
				} else {
					i++;
				}
				this._l2 = lengths[i];
				this._li = i;
				this._curSeg = curSeg = this._segments[i];
				this._s1 = curSeg[Std.int(this._si = curSeg.length - 1) - 1] ?? 0;
				this._s2 = curSeg[Std.int(this._si)];
			}
			curIndex = i;

			v -= this._l1;
			i = Std.int(this._si);
			if (v > this._s2 && i < curSeg.length - 1) {
				l = Std.int(curSeg.length - 1);
				while (i < l && (this._s2 = curSeg[++i]) <= v) {}
				this._s1 = curSeg[i - 1];
				this._si = i;
			} else if (v < this._s1 && i > 0) {
				while (i > 0 && (this._s1 = curSeg[--i]) >= v) {}
				if (i == 0 && v < this._s1) {
					this._s1 = 0;
				} else {
					i++;
				}
				this._s2 = curSeg[i];
				this._si = i;
			}
			t = (i + (v - this._s1) / (this._s2 - this._s1)) * this._prec;
		}
		inv = 1 - t;

		i = this._props.length;
		while (--i > -1) {
			p = this._props[i];
			// b = this._beziers[p][curIndex];
			b = Reflect.field(this._beziers, p)[curIndex];
			val = (t * t * b.da + 3 * inv * (t * b.ca + inv * b.ba)) * t + b.a;
			if (Reflect.field(this._round, p) != null) {
				val = Std.int(val + (((val > 0)) ? 0.5 : -0.5));
			}
			if (Reflect.field(func, p) != null) {
				Reflect.field(target, p)(val);
			} else {
				Reflect.setField(target, p, val);
			}
		}

		if (this._autoRotate != null) {
			var ar:Array<Dynamic> = this._autoRotate;
			var b2:Segment;
			var x1:Float;
			var y1:Float;
			var x2:Float;
			var y2:Float;
			var add:Float;
			var conv:Float;
			i = ar.length;
			while (--i > -1) {
				p = ar[i][2];
				add = ar[i][3] ?? 0;
				conv = ((ar[i][4] == true)) ? 1 : _RAD2DEG;
				b = this._beziers[ar[i][0]][curIndex];
				b2 = this._beziers[ar[i][1]][curIndex];

				x1 = b.a + (b.b - b.a) * t;
				x2 = b.b + (b.c - b.b) * t;
				x1 += (x2 - x1) * t;
				x2 += ((b.c + (b.d - b.c) * t) - x2) * t;

				y1 = b2.a + (b2.b - b2.a) * t;
				y2 = b2.b + (b2.c - b2.b) * t;
				y1 += (y2 - y1) * t;
				y2 += ((b2.c + (b2.d - b2.c) * t) - y2) * t;

				val = (notStart) ? Math.atan2(y2 - y1, x2 - x1) * conv + add : this._initialRotations[i];

				if (Reflect.field(func, p) != null) {
					Reflect.field(target, p)(val);
				} else {
					Reflect.setField(target, p, val);
				}
			}
		}
	}
}

class Segment {
	public var a:Float;
	public var b:Float;
	public var c:Float;
	public var d:Float;
	public var da:Float;
	public var ca:Float;
	public var ba:Float;

	@:allow(com.greensock.plugins)
	private function new(a:Float, b:Float, c:Float, d:Float) {
		this.a = a;
		this.b = b;
		this.c = c;
		this.d = d;
		this.da = d - a;
		this.ca = c - a;
		this.ba = b - a;
	}
}
