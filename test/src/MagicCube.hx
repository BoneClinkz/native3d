package ;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.geom.Matrix3D;
import flash.geom.Vector3D;
import flash.Lib;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.Vector;
import native3d.utils.BasicTest;
import native3d.core.Node3D;

/**
 * ...
 * @author lizhi http://matrix3d.github.io/
 */
class MagicCube extends BasicTest
{
	private var cell:Vector<Vector<Vector<Node3D>>>;
	private var axiss:Vector<Axis>;
	private var axisVs:Vector<Vector3D>;
	private var axisCode:Int=0;
	private var line:Int = 0;
	private var help:TextField;
	private var neg:Int = 1;
	public function new() 
	{
		super();
		
		help = new TextField();
		help.autoSize = TextFieldAutoSize.LEFT;
		help.textColor = 0xffff00;
		help.text = "press key num_1--num_7";
		help.x = 100;
		addChild(help);
	}
	
	override public function initScene() : Void
	{
		axisVs = new Vector<Vector3D>();
		axisVs.push(Vector3D.X_AXIS);
		axisVs.push(Vector3D.Y_AXIS);
		axisVs.push(Vector3D.Z_AXIS);
		Lib.current.stage.addEventListener(KeyboardEvent.KEY_DOWN, stage_keyDown);
		
		cell = new Vector<Vector<Vector<Node3D>>>(3);
		for (x in 0...3) {
			cell[x] = new Vector<Vector<Node3D>>(3);
			for (y in 0...3) {
				cell[x][y] = new Vector<Node3D>(3);
				for (z in 0...3) {
					var node:Node3D = addCube(null, (x - 1) * 2, (y - 1) * 2, (z - 1) * 2);
					cell[x][y][z] = node;
				}
			}
		}
		addSky();
		ctrl.position.z = -30;
	}
	
	private function stage_keyDown(e:KeyboardEvent):Void 
	{
		if (e.keyCode>=49&&e.keyCode<=51) {
			line = e.keyCode-49;
		}
		if (e.keyCode>=52&&e.keyCode<=54) {
			axisCode = e.keyCode-52;
		}
		if (e.keyCode==55) {
			neg *= -1;
		}
		
		if (axiss == null) {
			axiss = new Vector<Axis>();
			for (x in 0...3) {
				for (y in 0...3) {
					for (z in 0...3) {
						if (axisCode==0) {//x
							if (x!=line) {
								continue;
							}
						}else if (axisCode==1) {//y
							if (y!=line) {
								continue;
							}
						}else if(axisCode==2){
							if (z!=line) {
								continue;
							}
						}
						var node:Node3D = cell[x][y][z];
						axiss.push(Axis.create(axisVs[axisCode], node,neg*90));
					}
				}
			}
		}
	}
	
	override public function enterFrame(e:Event):Void 
	{
		super.enterFrame(e);
		if (axiss != null) {
			var flag:Bool = false;
			for (axis in axiss) {
				if (axis.percent < 1) {
					var tp:Float = axis.percent + .1;
					if (tp > 1) tp = 1;
					axis.setPercent(tp);
				}else {
					flag = true;
					break;
				}
			}
			if (flag) {
				for (axis in axiss) {
					var node:Node3D = axis.target;
					var x:Int = Math.round(node.x/2)+1;
					var y:Int = Math.round(node.y/2)+1;
					var z:Int = Math.round(node.z/2)+1;
					cell[x][y][z] = node;
				}
				axiss = null;
			}
		}
	}
	public static function main():Void {
		Lib.current.addChild(new MagicCube());
	}
	
}
class Axis {
	public var target:Node3D;
	public var from:Matrix3D;
	public var percent:Float = 0;
	public var degrees:Float;
	public var axisv:Vector3D;
	public function new():Void {
		
	}
	
	public function setPercent(percent:Float):Void {
		this.percent = percent;
		var to:Matrix3D = from.clone();
		to.appendRotation(degrees * percent, axisv);
		target.matrix.copyFrom(to);
		target.matrixVersion++;
	}
	
	public static function create(axisv:Vector3D, target:Node3D,degrees:Float):Axis {
		var axis:Axis = new Axis();
		axis.axisv = axisv;
		axis.from = target.matrix.clone();
		axis.degrees = degrees;
		axis.target = target;
		return axis;
	}
}