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
import lz.native3d.core.BasicLight3D;
import lz.native3d.core.BasicPass3D;
import lz.native3d.core.BasicView;
import lz.native3d.core.Camera3D;
import lz.native3d.core.Node3D;
import lz.native3d.core.TextureSet;
import lz.native3d.materials.PhongMaterial;
import lz.native3d.materials.TwoDBatchMaterial;
import lz.native3d.meshs.MeshUtils;
import lz.net.LoaderCell;
import net.hires.debug.Stats;

/**
 * ...
 * @author lizhi http://matrix3d.github.io/
 */
class TwoDFromSwfExample extends Sprite
{
	var bv:BasicView;
	var loader:SwfLoader;
	var maploader:LoaderCell;
	var layer:Layer2D;
	
	private var isUp:Bool = false;
	private var isDown:Bool = false;
	private var isLeft:Bool = false;
	private var isRight:Bool = false;
	var maplayer:Layer2D;
	var mapb:BitmapData;
	var mapboundloader:LoaderCell;
	var boundobj:Dynamic;
	var bound:SwfMovieClip2D;
	var boundWrapper:Sprite;
	var bullets:Array<Bullet>;
	var tanks:Array<Tank>;
	var tankais:Array<TankAI>;
	var effectmcs:Array<SwfMovieClip2D>;
	var world:World;
	
	var rayFilterBox:Box;
	var cube3d:Node3D;
	public function new() 
	{
		super();
		bullets = [];
		effectmcs = [];
		tankais = [];
		tanks = [];
		loader = new SwfLoader("../assets/swfsheet/tank.zip");
		loader.addEventListener(Event.COMPLETE, loader_complete);
		loader.start();
		boundWrapper = new Sprite();
		addChild(boundWrapper);
		
		world = new World();
		rayFilterBox = new Box(0, 0, 0, 0);
		rayFilterBox.categoryBits = GameObject.bulletbit;
		rayFilterBox.maskBits = GameObject.t2bit+GameObject.tankbit;
	}
	
	private function loader_complete(e:Event):Void 
	{
		bv = new BasicView(200, 200,true);
		bv.instance3Ds[0].camera = new Camera3D(200, 200, bv.instance3Ds[0],true);
		bv.instance3Ds[0].camera.frustumPlanes = null;
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
		
		mapboundloader = LoaderCell.createUrlLoader("../assets/map/objs.json", null);
		mapboundloader.addEventListener(Event.COMPLETE, mapboundloader_complete);
		mapboundloader.start();
		
		//init3d
		bv.instance3Ds[0].passs[0].present = false;
		var pass:BasicPass3D = new BasicPass3D(bv.instance3Ds[0]);
		pass.rootIndex = 1;
		pass.clear = false;
		pass.camera = new Camera3D(100, 100, bv.instance3Ds[0]);
		pass.camera.z = -1000;
		var root3d:Node3D = new Node3D();
		bv.instance3Ds[0].roots.push(root3d);
		bv.instance3Ds[0].passs.push(pass);
		
		var	cubeDrawAble=MeshUtils.createCube(1,bv.instance3Ds[0]);
		var node:Node3D = new Node3D();
		node.setPosition(0, 200, 0);
		node.setRotation(0, 0, 0);
		node.setScale(30, 30, 30);
		node.drawAble = cubeDrawAble;
		root3d.add(node);
		var light = new BasicLight3D();
		root3d.add(light);
		bv.instance3Ds[0].lights.push(light);
		light.setPosition( -100,100,-1000);
		node.material = new PhongMaterial(bv.instance3Ds[0], light,
		new Vector3D(.2, .2, .2),//AmbientColor
		new Vector3D(Math.random()/2+.5,Math.random()/2+.5,Math.random()/2+.5),//DiffuseColor
		new Vector3D(.8,.8,.8),//SpecularColor
		200,
		null
		);
		cube3d = node;
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
		
		var tank = Tank.create(loader);
		layer.add(tank.mc);
		tank.mc.setPosition(500, 500);
		world.add(tank.box);
		tanks.push(tank);
		
		var c:Int = 10;
		while (c-->0) {
			var tank = Tank.create(loader);
			layer.add(tank.mc);
			tank.mc.setPosition(600+200*Math.random(), 500+200*Math.random());
			world.add(tank.box);
			tanks.push(tank);
			var ai = new TankAI();
			ai.tank = tank;
			tankais.push(ai);
		}
		
		if (bound != null) {
			var flag:Bool = true;
			for (swf in bound.tags) {
				if(swf!=null){
					var n2d = untyped swf.tags[0].tags[0].bounds;
					var name =untyped swf.tags[0].name;
					var rect = new Rectangle(swf.x + n2d.x * swf.scaleX, swf.y + n2d.y * swf.scaleY, n2d.width * swf.scaleX, n2d.height * swf.scaleY);
					var box = new Box(rect.x + rect.width / 2, rect.y + rect.height / 2, rect.width / 2, rect.height / 2);
					if (name=="t1") {//只和坦克碰撞
						box.categoryBits = GameObject.t1bit;
						box.maskBits = GameObject.tankbit;
					}else {
						box.categoryBits = GameObject.t2bit;//和坦克和子弹碰撞
						box.maskBits = GameObject.tankbit + GameObject.bulletbit;
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
		var bullet = tanks[0].shoot(loader, layer, bullets,world);
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
		var tank:Tank = tanks[0];
		tank.vx  = .0;
		tank.vy  = .0;
		if (isUp) {
			tank.vy = -tank.speed;
		}else if (isDown) {
			tank.vy = tank.speed;
		}
		if (isLeft) {
			tank.vx = -tank.speed;
		}else if (isRight) {
			tank.vx = tank.speed;
		}
		
		var dx = mouseX - tank.mc.x - layer.x;
		var dy = mouseY - tank.mc.y - layer.y;
		tank.turret.rotationZ = Math.atan2(dy,dx) * 180 / Math.PI + 90;
		
		for (ai in tankais) {
			ai.doAI(loader, layer, bullets, world);
		}
		
		boundWrapper.x= layer.x=maplayer.x  = Math.max(-mapb.width+stage.stageWidth,Math.min(0,stage.stageWidth / 2 - tank.mc.x));
		boundWrapper.y= layer.y=maplayer.y  = Math.max(-mapb.height+stage.stageHeight,Math.min(0,stage.stageHeight / 2-tank.mc.y));
		
		layer.children.sort(function(n1:Node3D, n2:Node3D):Int { return n1.y > n2.y?1: -1; } );
		if(cube3d!=null){
		cube3d.rotationX++;
		cube3d.rotationY++; }
		TwoDBatchMaterial.mouse2d.clear();
		for (i3d in bv.instance3Ds) {
			i3d.render();
		}
		TwoDBatchMaterial.mouse2d.doMouse(mouseX, mouseY);
		for (tank in tanks) {
			tank.updateTracks();
			tank.updateBox();
		}
		
		var i = bullets.length - 1;
		var con = mapb.rect;
		while (true) {
			if (i<0) {
				break;
			}
			var bullet = bullets[i];
			var speed = 15;
			bullet.advance();
			var bbox = bullet.box;
			bullet.updateBox();
			if (!con.containsPoint(new Point(bullet.mc.x,bullet.mc.y))||bbox.collidablePairs.length>0) {
				layer.remove(bullet.mc);
				bullets.splice(i, 1);
				world.remove(bbox);
				
				if (bbox.collidablePairs.length > 0) {
					var emc = cast(loader.getNode("mm_fla.Timeline_33"), SwfMovieClip2D);
					emc.x = bullet.mc.x;
					emc.y = bullet.mc.y;
					layer.add(emc);
					effectmcs.push(emc);
				}
			}
			i--;
		}
		world.hittest();
		for(tank in tanks){
			tank.updateTurret();
		}
		
		for (emc in effectmcs) {
			if (emc.frame>=emc.frames.length) {
				layer.remove(emc);
			}
		}
		
		boundWrapper.graphics.clear();
		boundWrapper.graphics.lineStyle(0, 0xff0000);
		boundWrapper.graphics.moveTo(tank.mc.x, tank.mc.y);
		var x1 = tank.mc.x + 1000 * Math.cos((tank.turret.rotationZ-90)*Math.PI/180);
		var y1 = tank.mc.y + 1000 * Math.sin((tank.turret.rotationZ-90) * Math.PI / 180);
		boundWrapper.graphics.lineTo(x1, y1);
		world.ray.raycast(tank.mc.x, tank.mc.y, x1, y1,rayFilterBox);
		for (box in world.ray.castboxs) {
			boundWrapper.graphics.drawRect(box.aabb.left, box.aabb.top, box.aabb.width, box.aabb.height);
		}
	}
	
	public static function main():Void {
		Lib.current.addChild(new TwoDFromSwfExample());
	}
}

class GameObject {
	static public var t1bit:Int = 1;
	static public var t2bit:Int = 2;
	static public var tankbit:Int = 4;
	static public var bulletbit:Int = 8;
	
	public var hp:Int;
	public var attack:Int;
	public var speed:Float=0;
	public var vx:Float=0;
	public var vy:Float=0;
	public var team:Int;
	public var box:Box;
	public var mc:SwfMovieClip2D;
	public function new() { }
	
	public function updateBox():Void {
		box.x = mc.x;
		box.y = mc.y;
		box.vx = vx;
		box.vy = vy;
	}
	
	public function advance():Void {
		mc.x += vx;
		mc.y += vy;
	}
}

class Bullet extends GameObject {
	public function new() {
		super();
		speed = 10;
	}
	public static function create(loader:SwfLoader):Bullet {
		var bullet = new Bullet();
		bullet.mc = untyped loader.getNode("bullet_mc");
		var box = new Box(0, 0, 5, 5, 0, 0, Box.DYNAMIC_TYPE, bullet);
		box.categoryBits = GameObject.bulletbit;
		box.maskBits = GameObject.t2bit + GameObject.tankbit;
		bullet.box = box;
		return bullet;
	}
	
	public function updateSpeed():Void {
		vx = Math.cos(mc.rotationZ * Math.PI / 180) * speed;
		vy = Math.sin(mc.rotationZ * Math.PI / 180) * speed;
	}
}
class Tank extends GameObject {
	public var tankmc:SwfMovieClip2D;
	public var turret:SwfMovieClip2D;
	public var tracks:SwfMovieClip2D;
	var s1:Node2D;
	var p1:Node2D;
	public var hitFlag:Bool;
	public function new() {
		super();
		speed = 2;
	}
	public static function create(loader:SwfLoader):Tank {
		var tank = new Tank();
		tank.mc= untyped loader.getNode("tank_1201");
		tank.tankmc =untyped tank.mc.getSwfChildByName("mc");
		tank.tankmc.gotoAndStop(0);
		tank.turret = untyped tank.tankmc.getSwfChildByName("turret");
		tank.turret.gotoAndStop(0);
		tank.tracks =untyped tank.tankmc.getSwfChildByName("tracks");
		tank.tracks.gotoAndStop(0);
		tank.s1 = tank.turret.getSwfChildByName("s1");
		tank.p1=tank.turret.getSwfChildByName("p1");
		tank.box = new Box(0, 0, 30, 30, 0, 0, Box.DYNAMIC_TYPE);
		tank.box.categoryBits = GameObject.tankbit;
		tank.box.maskBits = GameObject.t1bit + GameObject.t2bit + GameObject.bulletbit;//坦克和所有墙子弹进行碰撞检测
		
		//测试 坦克鼠标事件
		tank.mc.setMouseEnable(true, true);
		tank.mc.addEventListener(MouseEvent.CLICK, mouseevent);
		tank.mc.addEventListener(MouseEvent.MOUSE_DOWN, mouseevent);
		tank.mc.addEventListener(MouseEvent.MOUSE_UP, mouseevent);
		return tank;
	}
	
	static private function mouseevent(e:MouseEvent):Void 
	{
		trace(e.type);
	}
	
	public function shoot(loader:SwfLoader, layer:Layer2D, bullets:Array<Bullet>, world:World):Bullet 
	{
		var sp1:Vector3D = new Vector3D();
		sp1= s1.worldMatrix.transformVector(sp1);
		var pp1:Vector3D = new Vector3D();
		pp1 = p1.worldMatrix.transformVector(pp1);
		var bullet = Bullet.create(loader);
		bullet.mc.x = sp1.x - layer.x;
		bullet.mc.y = sp1.y - layer.y;
		bullet.mc.rotationZ = Math.atan2(pp1.y - sp1.y, pp1.x - sp1.x) * 180 / Math.PI;
		bullet.updateBox();
		bullet.updateSpeed();
		turret.gotoAndPlay(0);
		
		layer.add(bullet.mc);
		bullets.push(bullet);
		world.add(bullet.box);
		return bullet;
	}
	
	public function updateTracks() 
	{
		if (Math.abs(vx) >= 0.01 || Math.abs(vy) >= 0.01) {
			tracks.play();
			var len = Math.sqrt(vx * vx+ vy * vy);
			var a = getA(tracks.rotationZ,Math.atan2(vy,vx)*180/Math.PI+90);
			tracks.rotationZ += (a - tracks.rotationZ) * len / 30;
		}else {
			tracks.stop();
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
	
	public function updateTurret() 
	{
		hitFlag = false;
		for (pair in box.collidablePairs) {
			var cbox = pair.getCollisionBox(box);
			if (cbox.type == Box.STATIC_TYPE) {
				hitFlag = true;
				break;
			}
		}
		if (!hitFlag) {
			advance();
		}
		if (turret.frame>=turret.frames.length) {
			turret.gotoAndStop(0);
		}
	}
}
class Wall extends GameObject {
	public function new() {
		super();
	}
}

class TankAI {
	public var tank:Tank;
	public var moveCount:Int = 0;
	public var rotationCount:Int = 0;
	public var rotationSpeed:Float = 0;
	public function new() {
		
	}
	public function doAI(loader:SwfLoader, layer:Layer2D, bullets:Array<Bullet>, world:World):Void {
		if (moveCount<0||tank.hitFlag) {
			moveCount = Std.random(60) + 60;
			var a = Math.random() * 2 * Math.PI;
			tank.vx = tank.speed * Math.sin(a);
			tank.vy = tank.speed * Math.cos(a);
		}
		if (rotationCount<0) {
			rotationCount = Std.random(60) + 60;
			rotationSpeed = (Math.random() - .5) * 5;
		}
		tank.turret.rotationZ += rotationSpeed;
		if (Math.random()<.01) {
			tank.shoot(loader, layer,bullets,world);
		}
		moveCount--;
		rotationCount--;
	}
}