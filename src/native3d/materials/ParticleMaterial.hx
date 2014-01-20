package native3d.materials;
import flash.display3D.Context3D;
import flash.display3D.Context3DBlendFactor;
import flash.display3D.Context3DProgramType;
import flash.display3D.textures.TextureBase;
import flash.geom.Vector3D;
import flash.Lib;
import flash.Vector;
import haxe.Timer;
import hxsl.Shader;
import native3d.core.BasicLight3D;
import native3d.core.BasicPass3D;
import native3d.core.Instance3D;
import native3d.core.Node3D;
import native3d.core.particle.ParticleDrawable3D;
import native3d.core.VertexBufferSet;
import flash.display3D.Context3DCompareMode;

/**
 * ...
 * @author lizhi http://matrix3d.github.io/
 */
class ParticleMaterial extends MaterialBase
{
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
		var shader = new ParticleShader();
		this.shader = shader;
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
		
		build();
	}
	inline override public function draw(node:Node3D, pass:BasicPass3D):Void {
		super.draw(node, pass);
		var shader:ParticleShader = untyped this.shader;
		var drawable:ParticleDrawable3D = untyped node.drawable;
		
		var uv = drawable.uv;
		var timeLifeVariance=drawable.timeLifeVariance;
		var startPosVariance=drawable.startPosVariance;
		var endPosVariance=drawable.endPosVariance;
		var startEndScaleVariance=drawable.startEndScaleVariance;
		var startColorVariance=drawable.startColorVariance;
		var endColorVariance=drawable.endColorVariance;
		var i = 0;
		
		i3d.setVertexBufferAt(i++, uv.vertexBuff, 0, uv.format);
		if (shader.hasTimeLifeVariance) {
			i3d.setVertexBufferAt(i++, timeLifeVariance.vertexBuff, 0, timeLifeVariance.format);
		}
		if (shader.hasStartPosVariance) {
			i3d.setVertexBufferAt(i++, startPosVariance.vertexBuff, 0, startPosVariance.format);
		}
		if (shader.hasEndPosVariance) {
			i3d.setVertexBufferAt(i++, endPosVariance.vertexBuff, 0, endPosVariance.format);
		}
		if (shader.hasStartEndScaleVariance) {
			i3d.setVertexBufferAt(i++, startEndScaleVariance.vertexBuff, 0, startEndScaleVariance.format);
		}
		if (shader.hasStartColorVariance) {
			i3d.setVertexBufferAt(i++, startColorVariance.vertexBuff, 0, startColorVariance.format);
		}
		if (shader.hasEndColorVariance) {
			i3d.setVertexBufferAt(i++, endColorVariance.vertexBuff, 0, endColorVariance.format);
		}
		
		node.worldMatrix.copyRawDataTo(vertex, 0, true);
		pass.camera.invert.copyRawDataTo(vertex, 16, true);
		pass.camera.perspectiveProjection.copyRawDataTo(vertex, 32, true);
		vertex[48] = Lib.getTimer();
		i3d.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 0, vertex);
		i3d.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, fragment);
		
		i3d.setTextureAt(0, texture);
		i3d.drawTriangles(node.drawable.indexBufferSet.indexBuff);
	}
	override public function init(node:Node3D):Void {
	}
}