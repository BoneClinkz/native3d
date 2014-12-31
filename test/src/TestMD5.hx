package ;
import flash.events.MouseEvent;
import native3d.core.animation.AnimationUtils;
import native3d.core.Node3D;
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
	var test:flash.Vector.Vector<Node3D>;

	public function new() 
	{
		super();
	}
	
	override public function initScene() : Void
	{
		//return;
		//addSky();
		md5Parser = new MD5MeshParser(new BMD(512,512));
		//md5Parser = new MD5MeshParser(new BitmapData(512,512));
		md5Parser.data = new MD5Mesh();
		md5Parser.parser();
		
		md5AnmParser = new MD5AnimParser("a1");
		md5AnmParser.data = new MD5ANM();
		md5AnmParser.parser();
		
		AnimationUtils.startCacheAnim(md5Parser.skin, md5AnmParser.item);
		//return;
		//root3d.add(md5Parser.node);
		md5Parser.node.setScale(50, 50, 50);
		ctrl.position.setTo( -150, 180, -133);
		ctrl.rotation.setTo(30, 50, 0);
		//ctrl.stop();
		bv.instance3Ds[0].antiAlias = 2;
		bv.instance3Ds[0].resize(
		bv.instance3Ds[0].width,
		bv.instance3Ds[0].height);
		
		var c = 10;
		for (x in 0...c ) {
			for(y in 0...c){
				var clone = //addCube(root3d,0,0,0,0,0,0,3,3,3); 
				md5Parser.node.clone();
				var d:Int = 360;
				clone.setPosition(d * (x / c - .5), 0 , d * (y / c - .5));
				root3d.add(clone);
			}
		}
		test = root3d.children.concat();
		root3d.children.length = 0;
		addDae(10);
		
		addEventListener("test", testdds);
		//stage.addEventListener(MouseEvent.CLICK, stage_click);
	}
	
	private function testdds(e:Event):Void 
	{
		var test2 = root3d.children.concat();
		root3d.children.length = 0;
		for (i in 0 ...100) {
			root3d.children.push(test2[i]);
			root3d.children.push(test[i]);
			addCube(null, Math.random() * 100, Math.random() * 100, Math.random() * 100);
		}
	}
	
	/*private var last:Node3D;
	private function stage_click(e:MouseEvent):Void 
	{	
		if (last!=null) {
			last.setScale(3,3,3);
		}
		var now:Node3D  = bv.instance3Ds[0].root.pickMouse(mouseX, mouseY);
		trace(now);
		if (now!=null) {
			last = now;
			last.setScale(6, 6, 6);
		}
	}*/
	
	override public function enterFrame(e:Event):Void 
	{
		bv.instance3Ds[0].render();
		//root3d.rotationY += .2;
		//bv.instance3Ds[0].camera.rotationY+=.2;
	}
	
	public static function main():Void {
		Lib.current.addChild( new TestMD5());
	}
	
}

@:file("src/wuji01/a_daiji.MD5ANIM") 
//@:file("src/kuangzhanshi/a_daiji.md5anim") 
//@:file("src/wuji01/hurt.MD5ANIM") 
//@:file("src/wuji01/wudao01.MD5ANIM") 
//@:file("src/headpain.md5anim") 
//@:file("src/a2jianduenshi/b_daiji.MD5ANIM") 
class MD5ANM extends ByteArray { } 
//@:file("src/hellknight.md5mesh") 
@:file("src/wuji01/wuji01.MD5MESH") 
//@:file("src/kuangzhanshi/wp110.MD5MESH") 
//@:file("src/888.md5mesh") 
//@:file("src/a2jianduenshi/shen02.MD5MESH") 
class MD5Mesh extends ByteArray { } 
//@:bitmap("src/hellknight_diffuse.jpg")
@:bitmap("src/wuji01/wuji01.png")
//@:bitmap("src/kuangzhanshi/test.png")
//@:bitmap("src/a2jianduenshi/shen202_p.png")
class BMD extends BitmapData{}