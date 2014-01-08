package ;
import flash.display.BitmapData;
import flash.display.Shape;
import flash.display3D.Context3DTextureFormat;
import flash.display3D.textures.TextureBase;
import flash.events.Event;
import flash.Lib;
import lz.native3d.core.Instance3D;
import lz.native3d.utils.BasicTest;
import lz.native3d.core.TextureSet;

/**
 * http://www.wazim.com/Downloads.htm
 * @author lizhi http://matrix3d.github.io/
 */
class SkeletonAnimationExample extends BasicTest
{
	var textureA:TextureBase;
	var textureB:TextureBase;
	public function new() 
	{
		super();
	}
	
	override public function initScene() : Void
	{
		addDae();
		#if flash
		//addSky();
		#end	
		ctrl.position.setTo( 8, 22, 42);
		ctrl.rotation.setTo(24, 190, 0);
		ctrl.speed = 1;
		
		var tset = new TextureSet();
		tset.setBmd(new BitmapData(1024, 1024,true,0), Context3DTextureFormat.BGRA, true);
		textureA = tset.texture;
		tset = new TextureSet();
		tset.setBmd(new BitmapData(1024, 1024,true,0), Context3DTextureFormat.BGRA, true);
		textureB = tset.texture;
		
		//bv.instance3Ds[0].passs[0].customDraw = customDraw;
	}
	
	function customDraw() 
	{
		var mainpass = bv.instance3Ds[0].passs[bv.instance3Ds[0].passs.length - 1];
		if(mainpass!=null){
			bv.instance3Ds[0].setRenderToTexture(textureA, true);
			bv.instance3Ds[0].clear(0,0,0,0);
			mainpass.drawScene();
			mainpass.drawQuadTexture(textureB, 0, 0, stage.stageWidth, stage.stageHeight,[.8,.7,.6,0]);
			
			bv.instance3Ds[0].setRenderToBackBuffer();
			mainpass.drawQuadTexture(textureA, 0, 0, stage.stageWidth, stage.stageHeight);
			
			var temp = textureA;
			textureA = textureB;
			textureB = temp;
		}
	}
	
	override public function enterFrame(e:Event):Void 
	{
		var mainpass = bv.instance3Ds[0].passs[bv.instance3Ds[0].passs.length - 1];
		mainpass.present = false;
		bv.instance3Ds[0].render();
		
		var x = 150;
		var size = 150;
		for (i in 0...bv.instance3Ds[0].passs.length-1) {
			var pass = bv.instance3Ds[0].passs[i];
			if (pass.target != null) {
				mainpass.drawQuadTexture(pass.target.texture, x, 0, size, size);
				x += size;
			}
		}
		bv.instance3Ds[0].context.present();
		
	}
	public static function main() {
		Lib.current.addChild(new SkeletonAnimationExample());
	}
	
}