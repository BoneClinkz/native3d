package ;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.display3D.Context3DTextureFormat;
import flash.display3D.Context3DTriangleFace;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.geom.Vector3D;
import flash.Lib;
import flash.ui.Keyboard;
import flash.utils.JSON;
import lz.collision.Box;
import lz.collision.World;
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
	var tankbox:Box;
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
	var mapboundloader:LoaderCell;
	var boundobj:Dynamic;
	var bound:SwfMovieClip2D;
	var boundWrapper:Sprite;
	var bullets:Array<Node2D>;
	var effectmcs:Array<SwfMovieClip2D>;
	var world:World;
	public function new() 
	{
		super();
		bullets = [];
		effectmcs = [];
		loader = new SwfLoader("../assets/swfsheet/tank.zip");
		loader.addEventListener(Event.COMPLETE, loader_complete);
		loader.start();
		boundWrapper = new Sprite();
		addChild(boundWrapper);
		
		world=new World();
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
		turret = untyped tankmc.getSwfChildByName("turret");
		turret.gotoAndStop(0);
		tracks =untyped tankmc.getSwfChildByName("tracks");
		tracks.gotoAndStop(0);
		layer.add(tank);
		tank.setPosition(500, 500);
		
		mapboundloader = LoaderCell.createUrlLoader("../assets/map/objs.json", null);
		mapboundloader.addEventListener(Event.COMPLETE, mapboundloader_complete);
		mapboundloader.start();
	}
	
	private function mapboundloader_complete(e:Event):Void 
	{
		boundobj = JSON.parse(mapboundloader.getText());
		maploader = LoaderCell.createImageLoader("../assets/map/6201.jpg", null);
		maploader.addEventListener(Event.COMPLETE, maploader_complete);
		maploader.start();
		
		var boundloader:SwfLoader = new SwfLoader(null);
		boundloader.objs = boundobj;
		bound = untyped boundloader.getNode("bounds_mc");
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
		
		tankbox = new Box(0, 0, 20, 20, 0, 0, Box.DYNAMIC_TYPE);
		world.add(tankbox);
		if (bound != null) {
			var flag:Bool = true;
			for (swf in bound.tags) {
				if(swf!=null){
					var n2d = untyped swf.tags[0].tags[0].bounds;
					var name =untyped swf.tags[0].name;
					var rect = new Rectangle(swf.x + n2d.x * swf.scaleX, swf.y + n2d.y * swf.scaleY, n2d.width * swf.scaleX, n2d.height * swf.scaleY);
					var box = new Box(rect.x + rect.width / 2, rect.y + rect.height / 2, rect.width / 2, rect.height / 2);
					if (name=="t1") {//只和坦克碰撞
						box.categoryBits = 1;
					}else {
						box.categoryBits = 3;//和坦克和子弹碰撞
					}
					world.add(box);
				}
			}
		}
		world.resetStaticGrid();
		
		stage.addEventListener(KeyboardEvent.KEY_DOWN, stage_keyDown);
		stage.addEventListener(KeyboardEvent.KEY_UP, stage_keyUp);
		stage.addEventListener(MouseEvent.MOUSE_DOWN, stage_click);
		addEventListener(Event.ENTER_FRAME, enterFrame);
	}
	
	private function stage_click(e:MouseEvent):Void 
	{
		var bullet = loader.getNode("bullet_mc");
		
		var s1:Node2D = turret.getSwfChildByName("s1");
		var sp1:Vector3D = new Vector3D();
		sp1= s1.worldMatrix.transformVector(sp1);
		var p1:Node2D=turret.getSwfChildByName("p1");
		var pp1:Vector3D = new Vector3D();
		pp1= p1.worldMatrix.transformVector(pp1);
		
		bullet.x = sp1.x-layer.x;
		bullet.y = sp1.y - layer.y;
		bullet.rotationZ = Math.atan2(pp1.y - sp1.y, pp1.x - sp1.x) * 180 / Math.PI;
		layer.add(bullet);
		bullets.push(bullet);
		
		var box = new Box(bullet.x, bullet.y, 5, 5, 0, 0, Box.DYNAMIC_TYPE, bullet);
		box.maskBits = 2;
		bullet.userData = box;
		world.add(box);
		
		turret.gotoAndPlay(0);
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
		
		var dx = mouseX - tank.x - layer.x;
		var dy = mouseY - tank.y - layer.y;
		turret.rotationZ = Math.atan2(dy,dx) * 180 / Math.PI + 90;
		
		var gs =  .3;
		var gdx = dx * gs;
		var gdy = dy * gs;
		var ease =  .05;
		lastgdx = lastgdx + (gdx - lastgdx) * ease;
		lastgdy = lastgdy + (gdy - lastgdy) * ease;
		boundWrapper.x= layer.x=maplayer.x  = Math.max(-mapb.width+stage.stageWidth,Math.min(0,stage.stageWidth / 2 - tank.x-lastgdx));
		boundWrapper.y= layer.y=maplayer.y  = Math.max(-mapb.height+stage.stageHeight,Math.min(0,stage.stageHeight / 2-tank.y-lastgdy));
			
		
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
		
		tankbox.x = tank.x;
		tankbox.y = tank.y;
		tankbox.vx = vx;
		tankbox.vy = vy;
		
		
		var i = bullets.length - 1;
		var con = mapb.rect;
		while (true) {
			if (i<0) {
				break;
			}
			var bullet = bullets[i];
			var speed = 15;
			var bvx = Math.cos(bullet.rotationZ * Math.PI / 180) * speed;
			var bvy = Math.sin(bullet.rotationZ * Math.PI / 180) * speed;
			bullet.x += bvx;
			bullet.y += bvy;
			var bbox = cast( bullet.userData,Box);
			bbox.x = bullet.x;
			bbox.y = bullet.y;
			if (!con.containsPoint(new Point(bullet.x,bullet.y))||bbox.collidablePairs.length>0) {
				layer.remove(bullet);
				bullets.splice(i, 1);
				world.remove(bbox);
				
				if (bbox.collidablePairs.length > 0) {
					var emc = cast(loader.getNode("mm_fla.Timeline_33"), SwfMovieClip2D);
					emc.x = bullet.x;
					emc.y = bullet.y;
					layer.add(emc);
					effectmcs.push(emc);
				}
			}
			i--;
		}
		
		world.hittest();
		var flag = false;
		for (pair in tankbox.collidablePairs) {
			var cbox = pair.getCollisionBox(tankbox);
			if (cbox.type == Box.STATIC_TYPE) {
				flag = true;
				break;
			}
		}
		if (!flag) {
			tank.x += vx;
			tank.y += vy;
		}
		
		if (turret.frame>=turret.frames.length) {
			turret.gotoAndStop(0);
		}
		
		for (emc in effectmcs) {
			if (emc.frame>=emc.frames.length) {
				layer.remove(emc);
			}
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