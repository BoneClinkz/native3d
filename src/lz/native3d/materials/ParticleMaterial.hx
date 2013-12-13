package lz.native3d.materials;
import flash.display3D.Context3D;
import flash.display3D.Context3DBlendFactor;
import flash.display3D.Context3DProgramType;
import flash.display3D.textures.TextureBase;
import flash.geom.Vector3D;
import flash.Lib;
import flash.Vector;
import haxe.Timer;
import hxsl.Shader;
import lz.native3d.core.BasicLight3D;
import lz.native3d.core.BasicPass3D;
import lz.native3d.core.Instance3D;
import lz.native3d.core.Node3D;
import lz.native3d.core.particle.ParticleDrawable3D;
import lz.native3d.core.VertexBufferSet;
import flash.display3D.Context3DCompareMode;
private class ParticleShader extends Shader {
	static var SRC = {
		var input : {
			offset : Float2,
			uv:Float2,
			timeLifeVariance:Float2,
			startPosVariance:Float3,
			endPosVariance:Float3,
			startEndScaleVariance:Float2,
			startColorVariance:Float4,
			endColorVariance:Float4
		};
		var mpos : M44;
		var invert:M44;
		var mproj : M44;
		var time:Float;
		var life:Float;
		var startPos : Float3;
		var endPos : Float3;
		var startScale:Float;
		var endScale:Float;
		var startColor:Float4;
		var endColor:Float4;
		
		var diffuse:Float4;
		var tuv:Float2;
		function vertex() {
			var alife = life + input.timeLifeVariance.y;
			var mVal = ((time + input.timeLifeVariance.x) % alife) / alife;
			
			var pos1 = input.startPosVariance.xyzw + startPos.xyzz;
			var pos2 = input.endPosVariance.xyzw + endPos.xyzz;
			var pos = pos1 + (pos2 - pos1)*mVal;
			var wpos = pos * mpos * invert;
			
			var scale1=(input.startEndScaleVariance.x + startScale);
			var scale2=(input.startEndScaleVariance.y + endScale);
			var scale = scale1 + (scale2 - scale1) * mVal;
			wpos.xy += (input.offset.xy) * scale;
			out = wpos * mproj;
			
			var color1=input.startColorVariance + startColor;
			var color2 = input.endColorVariance + endColor;
			diffuse = color1 + (color2-color1) * mVal;
			
			tuv = input.uv;
		}
		function fragment(tex:Texture) {
			out =  tex.get(tuv) * diffuse;
		}
	};
	public function new() 
	{
		super();
	}
}
/**
 * ...
 * @author lizhi http://matrix3d.github.io/
 */
class ParticleMaterial extends MaterialBase
{
	private var shader:ParticleShader;
	private var shaderInstance:ShaderInstance;
	private var texture:TextureBase;
	public function new(i3d:Instance3D,texture:TextureBase) 
	{
		super();
		sourceFactor = Context3DBlendFactor.SOURCE_ALPHA;
		destinationFactor = Context3DBlendFactor.ONE;
		passCompareMode = Context3DCompareMode.ALWAYS;
		
		this.texture = texture;
		shader = new ParticleShader();
		shader.startPos = new Vector3D();
		shader.startScale = .5;
		shader.life = 1000;
		shader.time = 10;
		shader.endScale = 1;
		shaderInstance = shader.getInstance();
		if (shaderInstance.program==null) {
			shaderInstance.program = i3d.c3d.createProgram();
			shaderInstance.program.upload(shaderInstance.vertexBytes.getData(), shaderInstance.fragmentBytes.getData());
		}
		vertex = shaderInstance.vertexVars.toData().concat();
		fragment = shaderInstance.fragmentVars.toData().concat();
		progrom = shaderInstance.program;
	}
	inline override public function draw(node:Node3D, pass:BasicPass3D):Void {
		super.draw(node, pass);
		var drawable:ParticleDrawable3D = untyped node.drawable;
		
		var offset = drawable.offset;
		var uv = drawable.uv;
		var timeLifeVariance=drawable.timeLifeVariance;
		var startPosVariance=drawable.startPosVariance;
		var endPosVariance=drawable.endPosVariance;
		var startEndScaleVariance=drawable.startEndScaleVariance;
		var startColorVariance=drawable.startColorVariance;
		var endColorVariance=drawable.endColorVariance;
		var i = 0;
		c3d.setVertexBufferAt(i++, offset.vertexBuff, 0, offset.format);
		c3d.setVertexBufferAt(i++, uv.vertexBuff, 0, uv.format);
		c3d.setVertexBufferAt(i++, timeLifeVariance.vertexBuff, 0, timeLifeVariance.format);
		c3d.setVertexBufferAt(i++, startPosVariance.vertexBuff, 0, startPosVariance.format);
		c3d.setVertexBufferAt(i++, endPosVariance.vertexBuff, 0, endPosVariance.format);
		c3d.setVertexBufferAt(i++, startEndScaleVariance.vertexBuff, 0, startEndScaleVariance.format);
		c3d.setVertexBufferAt(i++, startColorVariance.vertexBuff, 0, startColorVariance.format);
		c3d.setVertexBufferAt(i++, endColorVariance.vertexBuff, 0, endColorVariance.format);
		
		node.worldMatrix.copyRawDataTo(vertex, 0, true);
		pass.camera.invert.copyRawDataTo(vertex, 16, true);
		pass.camera.perspectiveProjection.copyRawDataTo(vertex, 32, true);
		vertex[48] = Lib.getTimer();
		c3d.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 0, vertex);
		c3d.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, fragment);
		
		c3d.setTextureAt(0, texture);
		c3d.drawTriangles(node.drawable.indexBufferSet.indexBuff);
		
		c3d.setVertexBufferAt(0,null, 0, null);
		c3d.setVertexBufferAt(1,null, 0, null);
		c3d.setVertexBufferAt(2,null, 0, null);
		c3d.setVertexBufferAt(3,null, 0, null);
		c3d.setVertexBufferAt(4,null, 0, null);
		c3d.setVertexBufferAt(5,null, 0, null);
		c3d.setVertexBufferAt(6,null, 0, null);
		c3d.setVertexBufferAt(7,null, 0, null);
		c3d.setTextureAt(0, null);
	}
	override public function init(node:Node3D):Void {
		var drawable:ParticleDrawable3D = untyped node.drawable;
		drawable.startPosVariance.init();
		drawable.uv.init();
		drawable.offset.init();
		drawable.timeLifeVariance.init();
		drawable.startPosVariance.init();
		drawable.endPosVariance.init();
		drawable.startEndScaleVariance.init();
		drawable.startColorVariance.init();
		drawable.endColorVariance.init();
		drawable.indexBufferSet.init();
	}
}