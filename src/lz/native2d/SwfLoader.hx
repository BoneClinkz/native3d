package lz.native2d;
import flash.display.BitmapData;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.geom.Matrix3D;
import flash.utils.ByteArray;
import flash.utils.JSON;
import flash.Vector;
import format.zip.Reader;
import haxe.io.Bytes;
import haxe.io.BytesInput;
import lz.net.LoaderCell;

/**
 * ...
 * @author lizhi
 */
class SwfLoader extends EventDispatcher
{
	var loader:LoaderCell;
	public var bmd:BitmapData;
	var objs:Dynamic;
	var sheet:Dynamic;
	public function new(url:String) 
	{
		super();
		loader = LoaderCell.createBytesLoader(url, null);
		loader.addEventListener(Event.COMPLETE, loader_complete);
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
		dispatchEvent(e);
	}
	
	public function start():Void {
		loader.start();
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
			var timeline = new SwfMovieClip2D();
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
}