package ;
import flash.Lib;
import lz.native3d.core.BasicTest;

/**
 * http://www.wazim.com/Downloads.htm
 * @author lizhi http://matrix3d.github.io/
 */
class SkeletonAnimationExample extends BasicTest
{
	public function new() 
	{
		super();
	}
	
	override public function initScene() : Void
	{
		bv.instance3Ds[0].camera.frustumPlanes = null;
		addDae();
		#if flash
		addSky();
		#end	
		ctrl.position.z = -30;
	}
	public static function main() {
		Lib.current.addChild(new SkeletonAnimationExample());
	}
	
}