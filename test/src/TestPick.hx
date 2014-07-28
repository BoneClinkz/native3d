package ;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Vector3D;
import flash.Lib;
import native3d.utils.BasicTest;

/**
 * ...
 * @author lizhi
 */
class TestPick extends BasicTest
{
	var rayOrigin:Vector3D;
	var rayDirection:Vector3D;
	public function new() 
	{
		super();
		rayOrigin = new Vector3D();
		rayDirection = new Vector3D();
	}
	
	override public function enterFrame(e:Event):Void 
	{
		bv.instance3Ds[0].render();
	}
	
	override public function initScene():Void {
		addCube();
		stage.addEventListener(MouseEvent.CLICK, stage_click);
	}
	
	private function stage_click(e:MouseEvent):Void 
	{
		bv.instance3Ds[0].camera.computePickRayDirectionMouse(mouseX, mouseY, rayOrigin, rayDirection);
		for (node in bv.instance3Ds[0].passs[0].drawableNodes) {
			trace("sphere",node.raySphereTest(rayOrigin,rayDirection));
			trace("mesh",node.rayMeshTest(rayOrigin,rayDirection));
		}
	}
	
	public static function main():Void {
		Lib.current.addChild(new TestPick());
	}
	
}