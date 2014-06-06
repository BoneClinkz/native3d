package ;
import native3d.parsers.MD5AnimParser;
import flash.display.Sprite;
import flash.events.Event;
import flash.geom.Matrix3D;
import flash.geom.Vector3D;
import flash.Lib;
import flash.Vector;
import native3d.core.math.Quaternion;
import native3d.parsers.MD5MeshParser;
import flash.utils.ByteArray;
import native3d.utils.BasicTest;
import native3d.utils.Stats;
import flash.display.BitmapData;

/**
 * ...
 * @author lizhi
 */
class TestMD5 extends BasicTest
{
	var md5Parser:MD5MeshParser;
	var md5AnmParser:native3d.parsers.MD5AnimParser;

	public function new() 
	{
		super();
	}
	
	override public function initScene() : Void
	{
		//return;
		//addSky();
		md5Parser = new MD5MeshParser(new BMD(512,512));
		md5Parser.data = new MD5Mesh();
		md5Parser.parser();
		
		md5AnmParser = new MD5AnimParser();
		md5AnmParser.data = new MD5ANM();
		md5AnmParser.parser();
		
		root3d.add(md5Parser.node);
		//md5Parser.node.setScale(100, 100, 100);
		ctrl.position.setTo( -150, 180, -133);
		ctrl.rotation.setTo(30, 50, 0);
	}
	
	var cframe:Float = 0;
	override public function enterFrame(e:Event):Void 
	{
		cframe+=60/60;
		if (cframe>=md5AnmParser.md5anim.frames.length) {
			cframe = 0;
		}
		md5Parser.joints = md5AnmParser.md5anim.frames[Std.int(cframe)].joints;
		//md5Parser.node.children.length = 0;
		md5Parser.prepareMesh();
		md5Parser.createNode3D();
		
		bv.instance3Ds[0].antiAlias = 2;
		bv.instance3Ds[0].render();
		//trace(ctrl.position, ctrl.rotation);
		if (md5Parser!=null) {
			md5Parser.node.rotationY++;
		}
		
		
	}
	
	public static function main():Void {
		Lib.current.addChild( new TestMD5());
	}
	
}

//@:file("src/wuji01/a_yidong.MD5ANIM") 
//@:file("src/wuji01/wudao01.MD5ANIM") 
@:file("src/headpain.md5anim") 
class MD5ANM extends ByteArray { } 
@:file("src/hellknight.md5mesh") 
//@:file("src/wuji01/wuji01.MD5MESH") 
class MD5Mesh extends ByteArray { } 
@:bitmap("src/hellknight_diffuse.jpg")
//@:bitmap("src/wuji01/wuji01.png")
class BMD extends BitmapData{}