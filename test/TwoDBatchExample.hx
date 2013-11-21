package ;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.display3D.Context3DTextureFormat;
import flash.display3D.Context3DTriangleFace;
import flash.events.Event;
import flash.geom.Point;
import flash.Lib;
import flash.Vector.Vector;
import lz.native2d.Image2D;
import lz.native2d.Layer2D;
import lz.native2d.MovieClip2D;
import lz.native3d.core.BasicView;
import lz.native3d.core.Camera3D;
import lz.native3d.core.TextureSet;
import lz.native3d.core.twoDAnimation.TDSpriteData;
import lz.native3d.ctrls.TwoDBatAnmCtrl;
import lz.net.LoaderBat;
import net.hires.debug.Stats;

/**
 * ...
 * @author lizhi http://matrix3d.github.io/
 */
class TwoDBatchExample extends Sprite
{
	var bv:BasicView;
	var bmd:BitmapData;
	var xml:Xml;
	var center:Point;
	var image:Image2D;
	var mcs:Array<MovieClip2D>;
	public function new() 
	{
		super();
		center = new Point(310,298);
		var loader:LoaderBat = new LoaderBat();
		loader.addEventListener(Event.COMPLETE, loader_complete);
		loader.addImageLoader("../assets/sheet/explode/sheet.png");
		loader.addUrlLoader("../assets/sheet/explode/sheet.xml");
		loader.start();
	}
	
	private function loader_complete(e:Event):Void 
	{
		for (cell in  cast(e.currentTarget,LoaderBat).loaderComps) {
			if (cell.getImage()!=null) {
				bmd = cell.getImage();
			}else {
				xml = Xml.parse(cell.getText());
			}
		}
		
		bv = new BasicView(200, 200,true);
		bv.instance3Ds[0].camera = new Camera3D(200, 200, bv.instance3Ds[0],true);
		bv.instance3Ds[0].camera.frustumPlanes = null;
		bv.instance3Ds[0].culling = Context3DTriangleFace.NONE;
		addChild(bv);
		bv.instance3Ds[0].addEventListener(Event.CONTEXT3D_CREATE, context3dCreate);
		addChild(new Stats());
	}
	
	private function context3dCreate(e:Event):Void 
	{
		var textureset:TextureSet = new TextureSet(bv.instance3Ds[0]);
		
		textureset.setBmd(bmd,Context3DTextureFormat.BGRA);
		var layer:Layer2D = new Layer2D(true, textureset.texture, bv.instance3Ds[0]);
		bv.instance3Ds[0].root.add(layer);
		var td:TDSpriteData = TDSpriteData.create1(bmd, xml, center);
		image = new Image2D(null, new Point(bmd.width, bmd.height));
		layer.add(image);
		image.setPosition(200, 200);
		
		var c:Int = 10;
		mcs = []; 
		while (c-->0) {
			var player:MovieClip2D = new MovieClip2D(textureset.texture, td);
			player.x =  stage.stageWidth * (Math.random());
			player.y =  stage.stageHeight * (Math.random());
			layer.add(player);
			mcs.push(player);
		}
		addEventListener(Event.ENTER_FRAME, enterFrame);
	}
	
	private function enterFrame(e:Event):Void 
	{
		image.x = mouseX;
		image.y = mouseY;
		image.rotationZ++;
		for (mc in mcs) {
			var anm:TwoDBatAnmCtrl = mc.twoD.anmCtrl;
			if (Std.int(anm.frame % anm.data.totalFrame) == (anm.data.totalFrame-1)) {
				anm.frame++;
				mc.x =  stage.stageWidth * (Math.random());
				mc.y =  stage.stageHeight * (Math.random());
			}
		}
		for (i3d in bv.instance3Ds) {
			i3d.render();
		}
	}
	
	public static function main():Void {
		Lib.current.addChild(new TwoDBatchExample());
	}
	
}