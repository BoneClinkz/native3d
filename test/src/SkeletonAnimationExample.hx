package ;
import flash.display.BitmapData;
import flash.display.Shape;
import flash.display3D.Context3DTextureFormat;
import flash.display3D.textures.TextureBase;
import flash.events.Event;
import flash.Lib;
import native2d.Layer2D;
import native2d.Node2D;
import native3d.core.Instance3D;
import native3d.core.Rect2D;
import native3d.meshs.MeshUtils;
import native3d.utils.BasicTest;
import native3d.core.TextureSet;

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
		addDae(Std.int(Math.sqrt(300)));
		//root3d.setScale(.1, .1, .1);
		#if flash
		addSky();
		#end	
		ctrl.position.setTo( 8, 22, 42);
		ctrl.rotation.setTo(24, 190, 0);
		ctrl.speed = 1;
		var cube = addCube(null, 0, -1, 0, 0, 0, 0, 100, 1, 100);
		cube.castShadow = false;
	}
	
	override public function enterFrame(e:Event):Void 
	{
		bv.instance3Ds[0].render();
		
	}
	public static function main() {
		Lib.current.addChild(new SkeletonAnimationExample());
	}
	
}