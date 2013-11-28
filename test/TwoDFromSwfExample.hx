package ;
import flash.display.Sprite;
import flash.display3D.Context3DTextureFormat;
import flash.display3D.Context3DTriangleFace;
import flash.events.Event;
import flash.Lib;
import lz.native2d.Layer2D;
import lz.native2d.Node2D;
import lz.native2d.SwfLoader;
import lz.native2d.SwfMovieClip2D;
import lz.native3d.core.BasicView;
import lz.native3d.core.Camera3D;
import lz.native3d.core.TextureSet;
import lz.native3d.materials.TwoDBatchMaterial;
import net.hires.debug.Stats;

/**
 * ...
 * @author lizhi http://matrix3d.github.io/
 */
class TwoDFromSwfExample extends Sprite
{
	var bv:BasicView;
	var tankmc:SwfMovieClip2D;
	var turret:Node2D;
	var tank:Node2D;
	var loader:SwfLoader;
	public function new() 
	{
		super();
		loader = new SwfLoader("../assets/swfsheet/tank.zip");
		loader.addEventListener(Event.COMPLETE, loader_complete);
		loader.start();
	}
	
	private function loader_complete(e:Event):Void 
	{
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
		textureset.setBmd(loader.bmd,Context3DTextureFormat.BGRA);
		var layer:Layer2D = new Layer2D(true, textureset.texture, bv.instance3Ds[0]);
		cast(layer.material , TwoDBatchMaterial).gchanged = true;
		bv.instance3Ds[0].root.add(layer);
		tank = loader.getNode("tank_1201");
		tankmc =untyped tank.getSwfChildByName("mc");
		tankmc.gotoAndStop(0);
		turret = tankmc.getSwfChildByName("turret");
		layer.add(tank);
		tank.setPosition(300, 300);
		addEventListener(Event.ENTER_FRAME, enterFrame);
	}
	
	private function enterFrame(e:Event):Void 
	{
		turret.rotationZ= Math.atan2(mouseY - tank.y, mouseX - tank.x) * 180 / Math.PI+90;
		for (i3d in bv.instance3Ds) {
			i3d.render();
		}
	}
	
	public static function main():Void {
		Lib.current.addChild(new TwoDFromSwfExample());
	}
	
}