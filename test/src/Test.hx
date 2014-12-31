package ;
import flash.display.Sprite;
import flash.display3D.Context3DTriangleFace;
import flash.events.Event;
import flash.geom.Matrix3D;
import flash.geom.Vector3D;
import flash.Lib;
import native3d.core.Drawable3D;
import native3d.core.math.Quaternion;
import native3d.core.Node3D;
import native3d.materials.PhongMaterial;
import native3d.meshs.MeshUtils;
import native3d.utils.BasicTest;

/**
 * ...
 * @author lizhi
 */
class Test extends BasicTest
{
	private var planeDrawable:Drawable3D;
	public function new() 
	{
		super();
		
	}
	
	override public function initScene():Void {
		var c = 4000;
		while (c-->0) {
			var cube:Node3D = addCube(null,300 * (Math.random() - .5), 300 * (Math.random() - .5), 300 * (Math.random() - .5));
			cube.material = new PhongMaterial();
			cube.setScale(30, 30, 30);
		}
		root3d.children.sort(function(n1, n2):Int { return Std.int(n1.z - n2.z); } );
		ctrl.stop();
	}
	
	override public function initLight():Void {
	}
	
	override public function enterFrame(e:Event):Void 
	{
		//root3d.rotationY += .2;
		//root3d.rotationZ += .22;
		for (cube in root3d.children) {
			cube.rotationY++;
		}
		bv.instance3Ds[0].render();
	}
	
	static function main():Void {
		Lib.current.addChild(new Test());
	}
}