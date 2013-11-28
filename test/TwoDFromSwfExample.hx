package ;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.display3D.Context3DTextureFormat;
import flash.display3D.Context3DTriangleFace;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.Lib;
import flash.ui.Keyboard;
import lz.native2d.Image2D;
import lz.native2d.Layer2D;
import lz.native2d.Node2D;
import lz.native2d.SwfLoader;
import lz.native2d.SwfMovieClip2D;
import lz.native3d.core.BasicView;
import lz.native3d.core.Camera3D;
import lz.native3d.core.TextureSet;
import lz.native3d.materials.TwoDBatchMaterial;
import lz.net.LoaderCell;
import net.hires.debug.Stats;

/**
 * ...
 * @author lizhi http://matrix3d.github.io/
 */
class TwoDFromSwfExample extends Sprite
{
	var bv:BasicView;
	var tankmc:SwfMovieClip2D;
	var turret:SwfMovieClip2D;
	var tracks:SwfMovieClip2D;
	var tank:Node2D;
	var loader:SwfLoader;
	var maploader:LoaderCell;
	var layer:Layer2D;
	
	private var isUp:Bool = false;
	private var isDown:Bool = false;
	private var isLeft:Bool = false;
	private var isRight:Bool = false;
	var lastgdx:Float=0;
	var lastgdy:Float=0;
	var maplayer:Layer2D;
	var mapb:BitmapData;
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
		layer = new Layer2D(true, textureset.texture, bv.instance3Ds[0]);
		cast(layer.material , TwoDBatchMaterial).gchanged = true;
		bv.instance3Ds[0].root.add(layer);
		tank = loader.getNode("tank_1201");
		tankmc =untyped tank.getSwfChildByName("mc");
		tankmc.gotoAndStop(0);
		turret =untyped tankmc.getSwfChildByName("turret");
		tracks =untyped tankmc.getSwfChildByName("tracks");
		tracks.gotoAndStop(0);
		layer.add(tank);
		tank.setPosition(500, 500);
		
		maploader = LoaderCell.createImageLoader("../assets/map/6201.jpg", null);
		maploader.addEventListener(Event.COMPLETE, maploader_complete);
		maploader.start();
	}
	
	private function maploader_complete(e:Event):Void 
	{
		mapb = maploader.getImage();
		var textureset:TextureSet = new TextureSet(bv.instance3Ds[0]);
		textureset.setBmd(mapb, Context3DTextureFormat.BGRA);
		maplayer = new Layer2D(true, textureset.texture, bv.instance3Ds[0]);
		bv.instance3Ds[0].root.add(maplayer);
		bv.instance3Ds[0].root.add(layer);
		var map:Image2D = new Image2D(null, new Point(mapb.width, mapb.height));
		map.x = mapb.width / 2;
		map.y = mapb.height / 2;
		maplayer.add(map);
		
		stage.addEventListener(KeyboardEvent.KEY_DOWN, stage_keyDown);
		stage.addEventListener(KeyboardEvent.KEY_UP, stage_keyUp);
		//stage.addEventListener(MouseEvent.MOUSE_DOWN, stage_click);
		addEventListener(Event.ENTER_FRAME, enterFrame);
	}
	
	private function stage_keyDown(e:KeyboardEvent):Void 
	{
		if (e.keyCode == Keyboard.UP||e.keyCode==Keyboard.W) {
			isUp = true;
			isDown = false;
		}else if (e.keyCode == Keyboard.DOWN||e.keyCode==Keyboard.S) {
			isDown = true;
			isUp = false;
		}else if (e.keyCode == Keyboard.LEFT||e.keyCode==Keyboard.A) {
			isLeft = true;
			isRight = false;
		}else if (e.keyCode == Keyboard.RIGHT||e.keyCode==Keyboard.D) {
			isRight = true;
			isLeft = false;
		}
	}
	
	private function stage_keyUp(e:KeyboardEvent):Void 
	{
		if (e.keyCode == Keyboard.UP||e.keyCode==Keyboard.W) {
			isUp = false;
		}else if (e.keyCode == Keyboard.DOWN||e.keyCode==Keyboard.S) {
			isDown = false;
		}else if (e.keyCode == Keyboard.LEFT||e.keyCode==Keyboard.A) {
			isLeft = false;
		}else if (e.keyCode == Keyboard.RIGHT||e.keyCode==Keyboard.D) {
			isRight = false;
		}
	}
	
	private function enterFrame(e:Event):Void 
	{
		var vx  = .0;
		var vy  = .0;
		var speed = 2.;
		if (isUp) {
			vy = -speed;
		}else if (isDown) {
			vy = speed;
		}
		if (isLeft) {
			vx = -speed;
		}else if (isRight) {
			vx = speed;
		}
		
		tank.x += vx;
		tank.y += vy;
		var dx = mouseX - tank.x - layer.x;
		var dy = mouseY - tank.y - layer.y;
		turret.rotationZ = Math.atan2(dy,dx) * 180 / Math.PI + 90;
		
		var gs =  .3;
		var gdx = dx * gs;
		var gdy = dy * gs;
		var ease =  .05;
		lastgdx = lastgdx + (gdx - lastgdx) * ease;
		lastgdy = lastgdy + (gdy - lastgdy) * ease;
		layer.x=maplayer.x  = Math.max(-mapb.width+stage.stageWidth,Math.min(0,stage.stageWidth / 2 - tank.x-lastgdx));
		layer.y=maplayer.y  = Math.max(-mapb.height+stage.stageHeight,Math.min(0,stage.stageHeight / 2-tank.y-lastgdy));
			
		
		if (Math.abs(vx) >= 0.01 || Math.abs(vy) >= 0.01) {
			tracks.play();
			var len = Math.sqrt(vx * vx+ vy * vy);
			var a = getA(tracks.rotationZ,Math.atan2(vy,vx)*180/Math.PI+90);
			tracks.rotationZ += (a - tracks.rotationZ) * len / 30;
		}else {
			tracks.stop();
		}
		for (i3d in bv.instance3Ds) {
			i3d.render();
		}
	}
	
	public function getA(rotation:Float,a:Float):Float {
		while (Math.abs(a-rotation)>180) {
			if (a>rotation) {
				a -= 360;
			}else {
				a += 360;
			}
		}
		return a;
	}
	
	public static function main():Void {
		Lib.current.addChild(new TwoDFromSwfExample());
	}
	
}