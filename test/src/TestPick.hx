package ;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Vector3D;
import flash.Lib;
import native3d.materials.GraphicsMaterial;
import native3d.utils.BasicTest;

/**
 * ...
 * @author lizhi
 */
class TestPick extends BasicTest
{
	var rayOrigin:Vector3D;
	var rayDirection:Vector3D;
	var gm:GraphicsMaterial;
	var cube:native3d.core.Node3D;
	public function new() 
	{
		super();
		rayOrigin = new Vector3D();
		rayDirection = new Vector3D();
	}
	
	override public function enterFrame(e:Event):Void 
	{
		graphics.clear();
		bv.instance3Ds[0].render();
	}
	
	override public function initScene():Void {
		cube = addCube();
		 gm = new GraphicsMaterial(graphics);
		 cube.material = gm;
		stage.addEventListener(MouseEvent.CLICK, stage_click);
	}
	
	private function stage_click(e:MouseEvent):Void 
	{
		var pix = new Vector3D();
		bv.instance3Ds[0].camera.computePickRayDirectionMouse(mouseX, mouseY, rayOrigin, rayDirection,pix);
		for (node in bv.instance3Ds[0].passs[bv.instance3Ds[0].passs.length-1].drawableNodes) {
			trace("sphere",node.raySphereTest(rayOrigin,rayDirection));
			trace("mesh", node.rayMeshTest(rayOrigin, rayDirection));
			if (node.rayMeshTest(rayOrigin, rayDirection)) {
				gm.fillColor=Std.random(0xffffff);
			}
		}
		cube.setPosition(pix.x, pix.y, pix.z);
		cube.setScale(.1, .1, .1);
	}
	
	public static function main():Void {
		Lib.current.addChild(new TestPick());
	}
	
}