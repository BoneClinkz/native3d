package lz.native3d.materials;
import flash.display3D.Context3D;
import flash.display3D.Context3DProgramType;
import flash.geom.Vector3D;
import flash.Vector;
import hxsl.Shader;
import lz.native3d.core.BasicLight3D;
import lz.native3d.core.BasicPass3D;
import lz.native3d.core.Instance3D;
import lz.native3d.core.Node3D;
import lz.native3d.core.VertexBufferSet;

private class IShader extends Shader {
	static var SRC = {
		var input : {
			pos : Float3,
			norm:Float3,
		};
			var depth:Float2;
		function vertex( mpos : M44, mproj : M44,temp:Float4) {
			var vpos = input.pos.xyzw * mpos*mproj;
			out = vpos;
			vpos.z += temp.w;
			depth = vpos.zw;
		}
		function fragment(bitSh:Float4,bitMsk:Float4) {
			var c = depth.x / depth.y;
			var comp = frac(bitSh*c);
			out = comp-comp.xxyz*bitMsk;
		}
	};
}
/**
 * ...
 * @author lizhi http://matrix3d.github.io/
 */
class DisMaterial extends MaterialBase
{
	private var lightNode:BasicLight3D;
	public function new(lightNode:BasicLight3D) 
	{
		super();
		this.lightNode = lightNode;
		shader = new IShader();
		build();
		fragment = Vector.ofArray([256. * 256. * 256., 256. * 256, 256., 1.,0., 1. / 256., 1. / 256., 1. / 256.]);
		vertex = new Vector<Float>(4, true);
		vertex[3] =  0.005;
	}
	inline override public function draw(node:Node3D, pass:BasicPass3D):Void {
			var c3d:Context3D = Instance3D.getInstance().c3d;
			
			Instance3D.getInstance().c3d.setDepthTest(true, passCompareMode);
			c3d.setBlendFactors(sourceFactor, destinationFactor);
			c3d.setProgram(progrom);
			var xyz:VertexBufferSet = node.drawable.xyz;
			c3d.setVertexBufferAt(0, xyz.vertexBuff, 0, xyz.format);
			c3d.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, node.worldMatrix, true);
			c3d.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 4, pass.camera.perspectiveProjectionMatirx, true);
			/*vertex[0] = lightNode.wpos.x;
			vertex[1] = lightNode.wpos.y;
			vertex[2] = lightNode.wpos.z;*/
			c3d.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 8, vertex);
			c3d.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, fragment);
			
			c3d.drawTriangles(node.drawable.indexBufferSet.indexBuff);
			c3d.setVertexBufferAt(0,null, 0, xyz.format);
		}
		override public function init(node:Node3D):Void {
			node.drawable.xyz.init();
			//node.drawable.norm.init();
			node.drawable.indexBufferSet.init();
		}
}