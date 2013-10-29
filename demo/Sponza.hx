package ;
import flash.Lib;
import lz.native3d.core.BasicTest;

/**
 * ...
 * @author lizhi http://matrix3d.github.io/
 */
class Sponza extends BasicTest
{
	public function new() 
	{
		super();
	}
	
	override public function initScene() : Void
	{
		addObj();
		addSky();
		light.x = 0;
		light.y = 1050;
		light.z = 0;
		ctrl.position.y = 30;
	}
	public static function main() {
		Lib.current.addChild(new Sponza());
	}
	
}