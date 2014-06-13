package ;
import native3d.core.animation.AnimationUtils;
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
		
		md5AnmParser = new MD5AnimParser("a1");
		md5AnmParser.data = new MD5ANM();
		md5AnmParser.parser();
		
		AnimationUtils.startCacheAnim(md5Parser.skin, md5AnmParser.item);
		
		root3d.add(md5Parser.node);
		md5Parser.node.setScale(50, 50, 50);
		ctrl.position.setTo( -150, 180, -133);
		ctrl.rotation.setTo(30, 50, 0);
		bv.instance3Ds[0].antiAlias = 2;
		bv.instance3Ds[0].resize(
		bv.instance3Ds[0].width,
		bv.instance3Ds[0].height);
		
		var c = 4;
		for (x in 0...c ) {
			for(y in 0...c){
				var clone = md5Parser.node.clone();
				var d:Int = 360;
				clone.setPosition(d * (x / c - .5), 0 , d * (y / c - .5));
				root3d.add(clone);
			}
		}
	}
	
	override public function enterFrame(e:Event):Void 
	{
		bv.instance3Ds[0].render();
	}
	
	public static function main():Void {
		Lib.current.addChild( new TestMD5());
	}
	
}

//@:file("src/wuji01/a_yidong.MD5ANIM") 
@:file("src/wuji01/hurt.MD5ANIM") 
//@:file("src/wuji01/wudao01.MD5ANIM") 
//@:file("src/headpain.md5anim") 
class MD5ANM extends ByteArray { } 
//@:file("src/hellknight.md5mesh") 
@:file("src/wuji01/wuji01.MD5MESH") 
//@:file("src/888.md5mesh") 
class MD5Mesh extends ByteArray { } 
//@:bitmap("src/hellknight_diffuse.jpg")
@:bitmap("src/wuji01/wuji01.png")
class BMD extends BitmapData{}