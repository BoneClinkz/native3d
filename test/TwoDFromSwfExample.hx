package ;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.display3D.Context3DTextureFormat;
import flash.display3D.Context3DTriangleFace;
import flash.events.Event;
import flash.geom.Matrix3D;
import flash.geom.Point;
import flash.Lib;
import flash.utils.ByteArray;
import flash.utils.JSON;
import flash.Vector.Vector;
import format.zip.Reader;
import format.zip.Tools;
import haxe.io.Bytes;
import haxe.io.BytesInput;
import lz.native2d.Image2D;
import lz.native2d.Layer2D;
import lz.native2d.MovieClip2D;
import lz.native2d.Node2D;
import lz.native2d.SwfMovieClip2D;
import lz.native2d.UV2D;
import lz.native3d.core.BasicView;
import lz.native3d.core.Camera3D;
import lz.native3d.core.TextureSet;
import lz.native3d.core.twoDAnimation.TDSpriteData;
import lz.native3d.ctrls.TwoDBatAnmCtrl;
import lz.native3d.materials.TwoDBatchMaterial;
import lz.net.LoaderBat;
import lz.net.LoaderCell;
import net.hires.debug.Stats;

/**
 * ...
 * @author lizhi http://matrix3d.github.io/
 */
class TwoDFromSwfExample extends Sprite
{
	var bv:BasicView;
	var bmd:BitmapData;
	var objs:Dynamic;
	var sheet:Dynamic;
	var mcs:Array<SwfMovieClip2D>;
	var tankmc:SwfMovieClip2D;
	var turret:Node2D;
	var tank:Node2D;
	public function new() 
	{
		super();
		mcs = new Array<SwfMovieClip2D>();
		var loader:LoaderCell = LoaderCell.createBytesLoader("../assets/swfsheet/tank.zip", null);
		//var loader:LoaderCell = LoaderCell.createBytesLoader("../assets/swfsheet/mouse.zip", null);
		loader.addEventListener(Event.COMPLETE, loader_complete);
		loader.start();
	}
	
	private function loader_complete(e:Event):Void 
	{
		var loader:LoaderCell = cast(e.currentTarget, LoaderCell);
		var bytes:ByteArray= loader.getBytes();
		var hbytes:Bytes = Bytes.ofData(bytes);
		var input:BytesInput = new BytesInput(hbytes);
		var reader:Reader = new Reader(input);
		var entrys = reader.read();
		for (entry in entrys) {
			var b:ByteArray = entry.data.getData();
			b.position = 0;
			if (entry.fileName=="objs.json") {
				 objs=JSON.parse(b + "");
			}else if (entry.fileName=="sheet.json") {
				sheet = JSON.parse(b + "");
			}else {
				var bloader:LoaderCell = LoaderCell.createBytesImageLoader(b, null);
				bloader.addEventListener(Event.COMPLETE, bloader_complete);
				bloader.start();
			}
		}
	}
	
	private function bloader_complete(e:Event):Void 
	{
		var loader:LoaderCell = cast(e.currentTarget, LoaderCell);
		bmd = loader.getImage();
		
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
		cast(layer.material , TwoDBatchMaterial).gchanged = true;
		bv.instance3Ds[0].root.add(layer);
		tank = getNode("tank_1201");
		tankmc =untyped tank.children[0].getSwfChildByName("mc");
		tankmc.gotoAndStop(0);
		untyped tankmc.getSwfChildByName("tracks").gotoAndStop(0);
		turret = tankmc.getSwfChildByName("turret");
		layer.add(tank);
		tank.setPosition(300, 300);
		addEventListener(Event.ENTER_FRAME, enterFrame);
	}
	
	public function getNode(name:String):Node2D {
		return doobj(Reflect.field(objs, name));
	}
	
	private function doobj(obj:Dynamic):Node2D {
		var type:Int = Reflect.field(obj, "t");
		var m = Reflect.field(obj, "m");
		var matrix = new Matrix3D(Vector.ofArray([
													m[0], m[1], 0.0, 0,
													m[2], m[3], 0, 0,
													0, 0, 1, 0,
													m[4], m[5], 0, 1,
													]));
		var name = Reflect.field(obj, "n");
													
		if (type == 1) {
			var uv = Reflect.field(sheet, Reflect.field(obj,"id"));
			var image = new Image2D(null, null, UV2D.fromXYWH(uv[0], uv[1], uv[2], uv[3], bmd.width, bmd.height));
			if (name != null) {
				image.name = name;
			}
			var matrix2:Matrix3D = new Matrix3D();
			matrix2.appendTranslation(.5,-.5,0);
			matrix2.appendScale(uv[2], -uv[3], 1);
			matrix2.append(matrix);
			image.matrix = matrix2;
			image.matrixVersion = 5;
			image.decompose();
			return image;
		}else if (type == 2) {
			//trace("sprite");
			var sprite= new Node2D();
			var childs:Array<Dynamic> = Reflect.field(obj, "c");
			for (child in childs) {
				sprite.add(doobj(child));
			}
			sprite.matrix = matrix;
			sprite.matrixVersion = 5;
			sprite.decompose();
			if (name!=null) {
				sprite.name = name;
			}
			return sprite;
		}else if (type==3) {
			//trace("timeline");
			var timeline = new SwfMovieClip2D();
			mcs.push(timeline);
			var childs:Array<Dynamic> = Reflect.field(obj, "c");
			for (child in childs) {
				if (child != null) {
					timeline.tags.push(doobj(child));
				}else {
					timeline.tags.push(null);
				}
			}
			var f:Array<Array<Array<Int>>> = Reflect.field(obj, "f");
			timeline.frames = f;
			timeline.matrix = matrix;
			timeline.matrixVersion += 5;
			
			timeline.decompose();
			if (name!=null) {
				timeline.name = name;
			}
			return timeline;
		}
		return null;
	}
	
	private function enterFrame(e:Event):Void 
	{
		turret.rotationZ=Math.atan2(mouseX-tank.x,-mouseY+tank.y)*180/Math.PI;
		for (timeline in mcs) {
			timeline.update();
		}
		for (i3d in bv.instance3Ds) {
			i3d.render();
		}
	}
	
	public static function main():Void {
		Lib.current.addChild(new TwoDFromSwfExample());
	}
	
}