package ;
import flash.events.Event;
import flash.Lib;
import lz.native3d.core.BasicTest;
import lz.native3d.core.Node3D;


 class TeapotsExample extends BasicTest
{
	
	public static function main() {
		Lib.current.addChild( new TeapotsExample());
	}
	public function new()
	{
		super();
	}
	
	override public function initScene() : Void
	{
		var w = 5;
		var h = w;
		var d = w;
		var scale = 30;
		var gap = 100;
		for (x in 0...w) {
			for (y in 0...h) {
				for (z in 0...d) {
					addCube(null, (x - w / 2) * gap, (y - h / 2) * gap, (z - d / 2) * gap, 0, 0, 0, scale, scale, scale);
				}
			}
		}
		#if flash
		addSky();
		#end	
		ctrl.position.z = -1300;
	}
}