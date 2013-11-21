package ;
import flash.events.Event;
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
		ctrl.position.setTo( 8, 22, 42);
		ctrl.rotation.setTo(24, 190, 0);
		ctrl.speed = 1;
	}
	
	override public function enterFrame(e:Event):Void 
	{
		bv.instance3Ds[0].render();
	}
	public static function main() {
		Lib.current.addChild(new SkeletonAnimationExample());
	}
	
}