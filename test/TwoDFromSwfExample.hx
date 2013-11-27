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
	public function new() 
	{
		super();
		mcs = new Array<SwfMovieClip2D>();
		//var loader:LoaderCell = LoaderCell.createBytesLoader("../assets/swfsheet/tank.zip", null);
		var loader:LoaderCell = LoaderCell.createBytesLoader("../assets/swfsheet/mouse.zip", null);
		loader.addEventListener(Event.COMPLETE, loader_complete);
		loader.start();
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
		var i:Int = 0;
		var c:Int = 4;
		while(c-->0)
		for (n in Reflect.fields(objs)) {
			var player:Node2D = doobj(Reflect.field(objs, n));
			player.setPosition(100 * (i%10 + 1), (i/10+1)*100);
			i++;
			player.compsVersion = 6;
			layer.add(player);
		}
		addEventListener(Event.ENTER_FRAME, enterFrame);
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
													
		if (type == 1) {
			var uv = Reflect.field(sheet, Reflect.field(obj,"id"));
			var image = new Image2D(null,null,UV2D.fromXYWH(uv[0],uv[1],uv[2],uv[3],bmd.width,bmd.height));
			var matrix2:Matrix3D = new Matrix3D();
			matrix2.appendTranslation(.5,-.5,0);
			matrix2.appendScale(uv[2], -uv[3], 1);
			matrix2.append(matrix);
			image.matrix = matrix2;
			image.matrixVersion = 5;
			return image;
		}else if (type == 2) {
			//trace("sprite");
			var sprite= new Node2D();
			var childs:Array<Dynamic> = Reflect.field(obj, "c");
			for (child in childs) {
				sprite.add(doobj(child));
			}
			sprite.matrix = matrix;
			sprite.matrixVersion=5;
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
			var f:Array<Array<Dynamic>> = Reflect.field(obj, "f");
			//timeline.frames = f;
			for (frame in f) {
				var sframe:Array<Array<Int>> = new Array<Array<Int>>();
				timeline.frames.push(sframe);
				for (im in frame) {
					sframe.push([Reflect.field(im,"i"),Reflect.field(im,"mi")]);
				}
			}
			timeline.matrix = matrix;
			timeline.matrixVersion+=5;
			return timeline;
		}
		return null;
	}
	
	private function enterFrame(e:Event):Void 
	{
		for (timeline in mcs) {
			timeline.children.length = 0;
			var cframe = timeline.frame % timeline.frames.length;
			for (obj in timeline.frames[cframe]) {
				var dis = timeline.tags[obj[0]];
				var tdis = timeline.tags[obj[1]];
				if (dis!=null) {
					if (obj[1]>0) {
						//dis.matrix.copyFrom(tdis.matrix);
						dis.matrix=tdis.matrix;
						dis.matrixVersion++;
					}
					timeline.add(dis);
				}
			}
			timeline.frame++;
		}
		for (i3d in bv.instance3Ds) {
			i3d.render();
		}
	}
	
	public static function main():Void {
		Lib.current.addChild(new TwoDFromSwfExample());
	}
	
}