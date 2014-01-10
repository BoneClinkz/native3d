package ;
import flash.display.Sprite;
import flash.events.Event;
import flash.geom.Vector3D;
import flash.Lib;
import flash.utils.ByteArray;
import haxe.io.Bytes;
import haxe.io.BytesInput;
import haxe.Json;
import haxe.zip.Entry;
import haxe.zip.Reader;
import lz.native3d.core.BasicLight3D;
import lz.native3d.core.BasicView;
import lz.native3d.core.Node3D;
import lz.native3d.materials.PhongMaterial;
import lz.native3d.parsers.AbsParser;
import lz.native3d.parsers.BSP30Parser;
import lz.native3d.parsers.ColladaParser;
import lz.native3d.utils.Stats;
import lz.net.LoaderBat;
import lz.xml.XPath;

/**
 * ...
 * @author lizhi http://matrix3d.github.io/
 */
class Test extends Sprite
{
	private var bv:BasicView;
	private var parser:BSP30Parser;
	private var node:Node3D;
	public function new() 
	{
		super();
		
		var obj:Dynamic = [];
		untyped obj.push(3);
		untyped obj.push(.3);
		untyped obj.a = 1;
		untyped obj.b = "a";
		for (c in Reflect.fields(obj)) {
			trace(untyped obj[c]);
		}
		
		
		var xml = Xml.parse("<x><n id='2'>a<a>av</a></n></x>");
		trace(XPath.xpath(xml,"x.n@id=2.a"));//[<a>av</a>]
		return;
		bv = new BasicView(400, 400, false);
		addChild(bv);
		bv.instance3Ds[0].addEventListener(Event.CONTEXT3D_CREATE, bv_context3dCreate);
		addChild(new Stats());
		
	}
	
	private function bv_context3dCreate(e:Event):Void 
	{
		parser = new BSP30Parser(null);
		parser.addEventListener(Event.COMPLETE, parser_complete);
		parser.fromUrlZip("../assets/model/es_iceworld.zip", "es_iceworld.bsp");
		//rootNode.add(parser.node);
		addEventListener(Event.ENTER_FRAME, enterFrame);
		bv.instance3Ds[0].camera.z = -1500;
		
	}
	
	private function parser_complete(e:Event):Void 
	{
		node = new Node3D();
		node.drawable = parser.drawable;
		node.material = new PhongMaterial([1,1,1],[1,1,1],[1,1,1]);// new ColorMaterial(Std.random(0xffffff), Std.random(0xffffff), new BasicLight3D());
		bv.instance3Ds[0].root.add(node);
	}
	
	private function enterFrame(e:Event):Void 
	{
		if (node!=null) {
			node.rotationX++;
			node.rotationY++;
		}
		bv.instance3Ds[0].render();
	}
	public static function main() {
		Lib.current.addChild(new Test());
	}
	
}