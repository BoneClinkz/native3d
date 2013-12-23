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
		
		var hasTimeLifeVariance:Bool;
		var hasStartPosVariance:Bool;
		var hasEndPosVariance:Bool;
		var hasStartEndScaleVariance:Bool;
		var hasStartColorVariance:Bool;
		var hasEndColorVariance:Bool;
		
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
			var mVal = 0;
			if (hasTimeLifeVariance) {
				var alife = life + input.timeLifeVariance.y;
				mVal = ((time + input.timeLifeVariance.x) % alife) / alife;
			}else {
				mVal = (time % life) / life;
			}
			
			var pos = startPos.xyzz;
			if (hasStartPosVariance) {
				pos += input.startPosVariance.xyzw;
			}
			if(endPos!=null){
				var pos2 =  endPos.xyzz;
				if(hasEndPosVariance){
					pos2 += input.endPosVariance.xyzw;
				}
				pos += (pos2 - pos)*mVal;
			}else if (hasEndPosVariance) {
				pos += input.endPosVariance.xyzw * mVal;
			}
			
			var scale = startScale;
			if (hasStartEndScaleVariance) {
				scale+=input.startEndScaleVariance.x;
			}
			//if (endScale!=startScale) {
				var scale2 = endScale;
				if (hasStartEndScaleVariance) {
					scale2+=input.startEndScaleVariance.y;
				}
				scale +=  (scale2 - scale) * mVal;
			//}
			
			var color=startColor;
			if(hasStartColorVariance){
				color += input.startColorVariance;
			}
			if (endColor!=null) {
				var color2 =  endColor;
				if (hasEndColorVariance) {
					color2 += input.endColorVariance;
				}
				diffuse =color + (color2 - color) * mVal;
			}else if (hasEndColorVariance) {
				diffuse = color + input.endColorVariance * mVal;
			}else {
				diffuse = color;
			}
			
			var wpos = pos * mpos * invert;
			wpos.xy += (input.offset.xy) * scale;
			out = wpos * mproj;
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
	public var shader:ParticleShader;
	private var shaderInstance:ShaderInstance;
	private var texture:TextureBase;
	var timeVarRandom:Bool;
	public var endRGBAVar:Array<Float>;
	public var endRGBA:Array<Float>;
	public var startRGBAVar:Array<Float>;
	public var startRGBA:Array<Float>;
	public var endScaleVar:Float;
	public var endScale:Float;
	public var startScaleVar:Float;
	public var startScale:Float;
	public var endPosVar:Array<Float>;
	public var endPos:Array<Float>;
	public var startPosVar:Array<Float>;
	public var startPos:Array<Float>;
	public var lifeVar:Float;
	public var life:Float;
	public function new(
		i3d:Instance3D,
		texture:TextureBase,
		life:Float=1000,
		lifeVar:Float=0,
		startPos:Array<Float>=null,
		startPosVar:Array<Float>=null,
		endPos:Array<Float>=null,
		endPosVar:Array<Float>=null,
		startScale:Float=1,
		startScaleVar:Float=0,
		endScale:Float=1,
		endScaleVar:Float=0,
		startRGBA:Array<Float>=null,
		startRGBAVar:Array<Float>=null,
		endRGBA:Array<Float>=null,
		endRGBAVar:Array<Float> = null,
		timeVarRandom:Bool=true
	) 
	{
		super();
		this.timeVarRandom = timeVarRandom;
		sourceFactor = Context3DBlendFactor.SOURCE_ALPHA;
		destinationFactor = Context3DBlendFactor.ONE;
		passCompareMode = Context3DCompareMode.ALWAYS;
		
		this.endRGBAVar = endRGBAVar;
		this.endRGBA = endRGBA;
		this.startRGBAVar = startRGBAVar;
		this.startRGBA = startRGBA;
		this.endScaleVar = endScaleVar;
		this.endScale = endScale;
		this.startScaleVar = startScaleVar;
		this.startScale = startScale;
		this.endPosVar = endPosVar;
		this.endPos = endPos;
		this.startPosVar = startPosVar;
		this.startPos = startPos;
		this.lifeVar = lifeVar;
		this.life = life;
		
		this.texture = texture;
		shader = new ParticleShader();
		shader.life = life;
		shader.time = 0;
		shader.startPos = arr2ve3(startPos,true);
		shader.endPos = arr2ve3(endPos);
		shader.startScale =startScale;
		shader.endScale = endScale;
		shader.startColor = arr2ve3(startRGBA,true);
		shader.endColor = arr2ve3(endRGBA);
		
		shader.hasTimeLifeVariance = lifeVar != 0 || timeVarRandom;
		shader.hasStartPosVariance = startPosVar != null;
		shader.hasEndPosVariance = endPosVar != null;
		shader.hasStartEndScaleVariance = startScaleVar != 0 || endScaleVar != 0;
		shader.hasStartColorVariance = startRGBAVar != null;
		shader.hasEndColorVariance = endRGBAVar != null;
		
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
		if (shader.hasTimeLifeVariance) {
			c3d.setVertexBufferAt(i++, timeLifeVariance.vertexBuff, 0, timeLifeVariance.format);
		}
		if (shader.hasStartPosVariance) {
			c3d.setVertexBufferAt(i++, startPosVariance.vertexBuff, 0, startPosVariance.format);
		}
		if (shader.hasEndPosVariance) {
			c3d.setVertexBufferAt(i++, endPosVariance.vertexBuff, 0, endPosVariance.format);
		}
		if (shader.hasStartEndScaleVariance) {
			c3d.setVertexBufferAt(i++, startEndScaleVariance.vertexBuff, 0, startEndScaleVariance.format);
		}
		if (shader.hasStartColorVariance) {
			c3d.setVertexBufferAt(i++, startColorVariance.vertexBuff, 0, startColorVariance.format);
		}
		if (shader.hasEndColorVariance) {
			c3d.setVertexBufferAt(i++, endColorVariance.vertexBuff, 0, endColorVariance.format);
		}
		
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
	}
}