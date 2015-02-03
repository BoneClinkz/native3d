package ;
import flash.events.MouseEvent;
import native3d.core.animation.AnimationUtils;
import native3d.core.Instance3D;
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
	var md5AnmParser:MD5AnimParser;
	var bindNode:Node3D;
	public function new() 
	{
		super();
	}
	
	override public function initScene() : Void
	{
		addSky();
		md5Parser = new MD5MeshParser(new BMD(512,512));
		md5Parser.data = new MD5Mesh();
		md5Parser.parser();
		
		md5AnmParser = new MD5AnimParser("a1");
		md5AnmParser.data = new MD5ANM();
		md5AnmParser.parser();
		AnimationUtils.startCacheAnim(md5Parser.skin, md5AnmParser.item);
		
		md5Parser.node.setScale(50, 50, 50);
		ctrl.position.setTo( -150, 180, -133);
		ctrl.rotation.setTo(30, 50, 0);
		bv.instance3Ds[0].antiAlias = 2;
		bv.instance3Ds[0].resize(
		bv.instance3Ds[0].width,
		bv.instance3Ds[0].height);
		
		var c = 3;
		for (x in 0...c ) {
			for(y in 0...c){
				var clone = md5Parser.node.clone();
				var d:Int = 360;
				clone.setPosition(d * (x / c - .5), 0 , d * (y / c - .5));
				root3d.add(clone);
				clone.children[0].startFrame = Std.random(1000);
			}
		}
		root3d.add(md5Parser.node);
		bindNode = new Node3D();
		root3d.add(bindNode);
		addCube(bindNode,0,0,0,0,0,0,.1,.1,.1);
	}
	
	override public function enterFrame(e:Event):Void 
	{
		bv.instance3Ds[0].render();
		
		var frame = md5Parser.skin.currentAnim.frames[md5Parser.skin.node.frame];
		for (i in 0...md5Parser.skin.joints.length) {
			var joint = md5Parser.skin.joints[i];
			joint.matrix.copyFrom(frame[i]); 
			joint.matrixVersion++;
		}
		Instance3D.getInstance().doTransform.doTransformNodes(md5Parser.skin.jointRoot.children, false);
		bindNode.matrix = md5Parser.skin.joints[33].worldMatrix.clone();
		bindNode.matrix.append(md5Parser.skin.node.worldMatrix.clone());
		
		bindNode.matrixVersion++;
		
	}
	
	public static function main():Void {
		Lib.current.addChild( new TestMD5());
	}
	
}

@:file("src/wuji01/a_daiji.MD5ANIM") 
class MD5ANM extends ByteArray { } 
@:file("src/wuji01/wuji01.MD5MESH") 
class MD5Mesh extends ByteArray { } 
@:bitmap("src/wuji01/wuji01.png")
class BMD extends BitmapData{}