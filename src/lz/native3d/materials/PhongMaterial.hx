#if flash
package lz.native3d.materials;
import flash.display3D.Context3D;
import flash.display3D.Context3DBlendFactor;
import flash.display3D.Context3DCompareMode;
import flash.display3D.Context3DProgramType;
import flash.display3D.Program3D;
import flash.display3D.textures.TextureBase;
import flash.errors.Error;
import flash.geom.Vector3D;
import flash.Vector;
import hxsl.Shader.ShaderInstance;
import lz.native3d.core.animation.Skin;
import lz.native3d.core.BasicLight3D;
import lz.native3d.core.BasicPass3D;
import lz.native3d.core.ByteArraySet;
import lz.native3d.core.DrawAble3D;
import lz.native3d.core.Instance3D;
import lz.native3d.core.Node3D;
import lz.native3d.core.VertexBufferSet;

/**
 * ...
 * @author lizhi
 */
class PhongMaterial extends MaterialBase
{
	private var shader:PhongShader;
	private var lightNode:BasicLight3D;
	public var diffuseTex:TextureBase;
	private var shaderInstance:ShaderInstance;
	public var skin:Skin;
	public function new(i3d:Instance3D,lightNode:BasicLight3D,AmbientColor:Vector3D,DiffuseColor:Vector3D,SpecularColor:Vector3D,SpecularExponent:Float=200,diffuseTex:TextureBase=null,skin:Skin=null) 
	{
		super();
		if (DiffuseColor.w>0) {//有透明度
			sourceFactor = Context3DBlendFactor.SOURCE_ALPHA;
			destinationFactor = Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA;
			passCompareMode = Context3DCompareMode.ALWAYS;
		}
		shader = new PhongShader();
		shader.AmbientColor = AmbientColor;
		shader.DiffuseColor = DiffuseColor;
		shader.SpecularColor = SpecularColor;
		shader.SpecularExponent = SpecularExponent;
		shader.LightPosition = lightNode.position;
		
		this.diffuseTex = diffuseTex;
		if(diffuseTex!=null)shader.DiffuseTex = diffuseTex;
		shader.hasDiffuseTex = diffuseTex != null;
		
		this.skin = skin;
		if(skin!=null)shader.anmMats = [new Vector3D(100,101,102,103)];
		shader.hasAnm = skin != null;
		
		shaderInstance = shader.getInstance();
		if (shaderInstance.program==null) {
			shaderInstance.program = i3d.c3d.createProgram();
			shaderInstance.program.upload(shaderInstance.vertexBytes.getData(), shaderInstance.fragmentBytes.getData());
		}
		vertex = shaderInstance.vertexVars.toData().concat();
		fragment = shaderInstance.fragmentVars.toData().concat();
		progrom = shaderInstance.program;
		this.lightNode = lightNode;
	}
	
	inline override public function draw(node:Node3D, pass:BasicPass3D):Void {
		//super
		super.draw(node, pass);
		//const
		if (shader.DiffuseColor != null || shader.SpecularColor != null) {
			vertex[32] = lightNode.worldRawData[12];
			vertex[33] = lightNode.worldRawData[13];
			vertex[34] = lightNode.worldRawData[14];
		}
		node.worldMatrix.copyRawDataTo(vertex, 0, true);
		pass.camera.perspectiveProjectionMatirx.copyRawDataTo(vertex, 16, true);
		c3d.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 0, vertex);
		c3d.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, fragment);
		
		//buff
		var xyz=null;
		var norm=null;
		var weightBuff = null;
		var matrixBuff = null;
		var uv = null;
		if(skin==null){
			var drawAble = node.drawAble;
			xyz = drawAble.xyz;
			norm=drawAble.norm;
			uv = drawAble.uv;
			
			c3d.setVertexBufferAt(0, xyz.vertexBuff, 0, xyz.format);
			if (shader.DiffuseColor != null || shader.SpecularColor != null) {
				c3d.setVertexBufferAt(1, norm.vertexBuff, 0, norm.format);
			}
			if(diffuseTex!=null){
				c3d.setVertexBufferAt(2, uv.vertexBuff, 0, uv.format);
				c3d.setTextureAt(0, diffuseTex);
			}
			//draw
			c3d.drawTriangles(drawAble.indexBufferSet.indexBuff);
			
			//clear
			c3d.setVertexBufferAt(0,null, 0, xyz.format);
			if(norm!=null)c3d.setVertexBufferAt(1, null, 0, norm.format);
			if(uv!=null)c3d.setVertexBufferAt(2, null, 0, uv.format);
			c3d.setTextureAt(0, null);
		}else {
			node.frame = node.frame % skin.numFrame;
			if(diffuseTex!=null){
				c3d.setTextureAt(0, diffuseTex);
			}
			for(drawAble in skin.draws){
				xyz = drawAble.xyz;
				norm = drawAble.norm;
				weightBuff = drawAble.weightBuff;
				matrixBuff = drawAble.matrixBuff;
				uv = drawAble.uv;
				c3d.setVertexBufferAt(0, xyz.vertexBuff, 0, xyz.format);
				c3d.setVertexBufferAt(1, norm.vertexBuff, 0, norm.format);
				c3d.setVertexBufferAt(2, weightBuff.vertexBuff, 0, weightBuff.format);
				c3d.setVertexBufferAt(3, matrixBuff.vertexBuff, 0, matrixBuff.format);
				c3d.setVertexBufferAt(4, uv.vertexBuff, 0, uv.format);
				
				var byteSet = drawAble.cacheBytes[node.frame];
				c3d.setProgramConstantsFromByteArray(Context3DProgramType.VERTEX, 9,byteSet.numRegisters,byteSet.data,0);
				c3d.drawTriangles(drawAble.indexBufferSet.indexBuff);
			}
			//clear
			c3d.setVertexBufferAt(0,null, 0, xyz.format);
			if(norm!=null)c3d.setVertexBufferAt(1, null, 0, norm.format);
			c3d.setVertexBufferAt(2, null, 0, weightBuff.format);
			c3d.setVertexBufferAt(3, null, 0, matrixBuff.format);
			if(uv!=null)c3d.setVertexBufferAt(4, null, 0, uv.format);
			c3d.setTextureAt(0, null);
			node.frame++;
		}
		
	}
	override public function init(node:Node3D):Void {
		if(skin==null){//有骨骼动画 初始化交给其它类处理
			node.drawAble.xyz.init();
			if(shader.DiffuseColor!=null||shader.SpecularColor!=null)
			node.drawAble.norm.init();
			if(diffuseTex!=null)
			if(node.drawAble.uv!=null)node.drawAble.uv.init();
			node.drawAble.indexBufferSet.init();
		}
	}
}
#else
package lz.native3d.materials;
import flash.display3D.Context3D;
import flash.display3D.Context3DProgramType;
import flash.display3D.Program3D;
import flash.display3D.textures.TextureBase;
import flash.geom.Vector3D;
import flash.Vector;
import lz.native3d.core.BasicLight3D;
import lz.native3d.core.BasicPass3D;
import lz.native3d.core.Instance3D;
import lz.native3d.core.Node3D;
import lz.native3d.core.VertexBufferSet;
import flash.display3D.shaders.glsl.GLSLProgram;
import flash.display3D.shaders.glsl.GLSLFragmentShader;
import flash.display3D.shaders.glsl.GLSLVertexShader;
import openfl.gl.GL;
class PhongMaterial extends MaterialBase
{
	static var glslProgram :GLSLProgram;
	private var lightNode:BasicLight3D;
	private var LightPositionV:Vector<Float>;
	private var AmbientColorV:Vector<Float>;
	private var DiffuseColorV:Vector<Float>;
	private var SpecularColorV:Vector<Float>;
	private var SpecularExponentV:Vector<Float>;
	private var i3d:Instance3D;
	public function new(i3d:Instance3D,lightNode:BasicLight3D,AmbientColor:Vector3D,DiffuseColor:Vector3D,SpecularColor:Vector3D,SpecularExponent:Float,diffuseTex:TextureBase) 
	{
		super();
		this.i3d = i3d;
		createProgram();
		this.lightNode = lightNode;
		LightPositionV = Vector.ofArray([0.0,0,0,0]);
		AmbientColorV = Vector.ofArray([AmbientColor.x,AmbientColor.y,AmbientColor.z,AmbientColor.w]);
		DiffuseColorV = Vector.ofArray([DiffuseColor.x,DiffuseColor.y,DiffuseColor.z,DiffuseColor.w]);
		SpecularColorV = Vector.ofArray([SpecularColor.x,SpecularColor.y,SpecularColor.z,SpecularColor.w]);
		SpecularExponentV = Vector.ofArray([SpecularExponent, 0, 0, 0]);
	}
	
	inline override public function draw(node:Node3D, pass:BasicPass3D):Void {
		var c3d = pass.i3d.c3d;
		glslProgram.attach();
		glslProgram.setVertexUniformFromMatrix("mpos", node.worldMatrix, true);
		glslProgram.setVertexUniformFromMatrix("mproj", pass.camera.perspectiveProjectionMatirx, true);
		glslProgram.setVertexBufferAt("pos", node.drawAble.xyz.vertexBuff, 0, flash.display3D.Context3DVertexBufferFormat.FLOAT_3);
		glslProgram.setVertexBufferAt("norm", node.drawAble.norm.vertexBuff, 0, flash.display3D.Context3DVertexBufferFormat.FLOAT_3);
		LightPositionV[0] = lightNode.worldRawData[12];
		LightPositionV[1] =lightNode.worldRawData[13];
		LightPositionV[2] = lightNode.worldRawData[14];
		c3d.setGLSLProgramConstantsFromVector3("lightPosition", LightPositionV);
		c3d.setGLSLProgramConstantsFromVector3("ambientColor", AmbientColorV);
		c3d.setGLSLProgramConstantsFromVector3("diffuseColor", DiffuseColorV);
		c3d.setGLSLProgramConstantsFromVector3("specularColor", SpecularColorV);
		c3d.setGLSLProgramConstantsFromVector1("specularExponent", SpecularExponentV);
		
		c3d.drawTriangles(node.drawAble.indexBufferSet.indexBuff);
		glslProgram.detach();
	}
	private function createProgram ():Void {
		 if (glslProgram!=null) {
			 return;
		 }
        glslProgram = new GLSLProgram(i3d.c3d);
        var vertexShaderSource =
       "
	   attribute vec3 pos;
	   attribute vec3 norm;
	   uniform vec3 lightPosition;

		varying vec3 LightVec;
		varying vec3 SurfaceNormal;
		varying vec3 ReflectedLightVec;
		varying vec3 ViewVec;

		uniform mat4 mproj;
        uniform mat4 mpos;
		void main()
		{
			vec3 eyespacePos   = mat3(mpos) * pos;
			SurfaceNormal      = normalize(mat3(mpos) * norm);
			LightVec           = normalize(lightPosition - eyespacePos);
			ViewVec            = normalize(-eyespacePos);
			ReflectedLightVec  = normalize(-reflect(SurfaceNormal, LightVec));

			vec4 wpos = mpos * vec4(pos, 1);
            gl_Position = mproj * wpos;
		}";
        var vertexShader = new GLSLVertexShader(vertexShaderSource);
		
        var fragmentShaderSource =
        "
		uniform vec3 ambientColor;
		uniform vec3 diffuseColor;
		uniform vec3 specularColor;
		uniform float specularExponent;

		varying vec3 LightVec;
		varying vec3 SurfaceNormal;
		varying vec3 ReflectedLightVec;
		varying vec3 ViewVec;

		void main()
		{
			vec3 color = ambientColor;
			color += diffuseColor * max(0, dot(LightVec, SurfaceNormal));
			color += specularColor * pow(max(0, dot(ReflectedLightVec, ViewVec)), specularExponent);
			gl_FragColor = vec4(color,1);
		}";
        var fragmentShader = new GLSLFragmentShader(fragmentShaderSource);
        glslProgram.upload(vertexShader, fragmentShader);
    }
	override public function init(node:Node3D):Void {
		node.drawAble.xyz.init();
		node.drawAble.norm.init();
		node.drawAble.indexBufferSet.init();
	}
}
#end