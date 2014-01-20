#if flash
package native3d.materials;
import flash.display3D.Context3D;
import flash.display3D.Context3DBlendFactor;
import flash.display3D.Context3DCompareMode;
import flash.display3D.Context3DProgramType;
import flash.display3D.Program3D;
import flash.display3D.textures.TextureBase;
import flash.errors.Error;
import flash.geom.Matrix3D;
import flash.geom.Vector3D;
import flash.Lib;
import flash.Vector;
import hxsl.Shader.ShaderInstance;
import native3d.core.animation.Skin;
import native3d.core.BasicLight3D;
import native3d.core.BasicPass3D;
import native3d.core.ByteArraySet;
import native3d.core.Drawable3D;
import native3d.core.Instance3D;
import native3d.core.Node3D;
import native3d.core.VertexBufferSet;

/**
 * ...
 * @author lizhi
 */
class PhongMaterial extends MaterialBase
{
	private static var HELP_V3D:Vector3D = new Vector3D();
	private static var ZAX:Vector3D = new Vector3D(0, 0, 1);
	var isShadowDepth:Bool;
	
	public static var defAmbient:Array<Float>=[.2,.2,.2];
	public static var defDiffuse:Array<Float>=[.8,.8,.8];
	public static var defSpecular:Array<Float>=[.8,.8,.8,200];
	
	public var diffuseTex:TextureBase;
	public var skin:Skin;
	public var skinConstIndex:Int = 8;
	public function new(ambient:Array<Float>=null,diffuse:Array<Float>=null,specular:Array<Float>=null,specularExponent:Float=200,diffuseTex:TextureBase=null,skin:Skin=null,isShadowDepth:Bool=false) 
	{
		super();
		var shader = new PhongShader();
		this.shader = shader;
		
		//test
		//isShadowDepth = true;
		this.isShadowDepth = isShadowDepth;
		shader.isShadowDepth = isShadowDepth;
		//i3d.context.enableErrorChecking = true;
		
		if(!isShadowDepth){
			if (specular != null) specular[3] = specularExponent;
			shader.ambient = arr2ve3(ambient==null?defAmbient:ambient);
			shader.diffuse = arr2ve3(diffuse==null?defDiffuse:diffuse);
			shader.specular = arr2ve3(specular == null?defSpecular:specular);
			if (i3d.shadowLight!=null) {
				shader.shadowProjectonMatrix = i3d.shadowLightPass.camera.perspectiveProjectionMatirx;
				skinConstIndex = 12;
			}
			var lights = { ambientLights:[],distantLights:[],pointLights:[],spotLights:[]};
			for (light in i3d.lights) {
				if(light.lightType==BasicLight3D.TYPE_AMBIENT){
					lights.ambientLights.push( { color:HELP_V3D } );
				}else if(light.lightType==BasicLight3D.TYPE_DISTANT){
					lights.distantLights.push( { color:HELP_V3D, position:HELP_V3D } );
				}else if(light.lightType==BasicLight3D.TYPE_POINT){
					lights.pointLights.push( { colorLen:HELP_V3D, position:HELP_V3D } );
				}else if(light.lightType==BasicLight3D.TYPE_SPOT){
					lights.spotLights.push( { colorLen:HELP_V3D, position:HELP_V3D,direction:HELP_V3D,innerOuter:HELP_V3D } );
				}
			}
			shader.lights =  lights;
			this.diffuseTex = diffuseTex;
			if(diffuseTex!=null)shader.diffuseMap = diffuseTex;
			shader.hasDiffuseMap = diffuseTex != null;
		}
		
		this.skin = skin;
		if (skin != null) shader.anmMats = [];
		shader.hasAnm = skin != null;
		build();
		//trace(shader.getDebugShaderCode(true));
		
		if(!isShadowDepth){
			var i = 12;
			for (light in i3d.lights) {
				if(light.lightType==BasicLight3D.TYPE_AMBIENT){
					fragment[i] = light.color[0];
					fragment[i+1] =light.color[1];
					fragment[i + 2] = light.color[2];
					i+=4;
				}else if(light.lightType==BasicLight3D.TYPE_DISTANT){
					fragment[i] = light.color[0];
					fragment[i+1] =light.color[1];
					fragment[i + 2] = light.color[2];
					i+=4;
					
					fragment[i] = light.position.x;
					fragment[i+1] =light.position.y;
					fragment[i + 2] = light.position.z;
					i += 4;
				}else if(light.lightType==BasicLight3D.TYPE_POINT){
					fragment[i] = light.color[0];
					fragment[i+1] =light.color[1];
					fragment[i + 2] = light.color[2];
					fragment[i + 3] = light.distance;
					i+=4;
					
					fragment[i] = light.position.x;
					fragment[i+1] =light.position.y;
					fragment[i + 2] = light.position.z;
					i += 4;
				}else if(light.lightType==BasicLight3D.TYPE_SPOT){
					fragment[i] = light.color[0];
					fragment[i+1] =light.color[1];
					fragment[i + 2] = light.color[2];
					fragment[i + 3] = light.distance;
					i+=4;
					
					fragment[i] = light.position.x;
					fragment[i+1] =light.position.y;
					fragment[i + 2] = light.position.z;
					i += 4;
					
					//dir
					i += 4;
					
					fragment[i] = light.innerConeAngle;
					fragment[i+1] =light.outerConeAngle;
					i += 4;
				}
			}
		}
	}
	
	inline override public function draw(node:Node3D, pass:BasicPass3D):Void {
		//super
		super.draw(node, pass);
		//const
		var shader:PhongShader = untyped this.shader;
		if(!isShadowDepth){
			if (shader.diffuse != null || shader.specular != null) {
				var i = 12;
				for (light in i3d.lights) {
					if(light.lightType==BasicLight3D.TYPE_AMBIENT){
						/*fragment[i] = light.color[0];
						fragment[i+1] =light.color[1];
						fragment[i + 2] = light.color[2];*/
						i+=4;
					}else if(light.lightType==BasicLight3D.TYPE_DISTANT){
						/*fragment[i] = light.color[0];
						fragment[i+1] =light.color[1];
						fragment[i + 2] = light.color[2];*/
						i+=4;
						
						fragment[i] = light.position.x;
						fragment[i+1] =light.position.y;
						fragment[i + 2] = light.position.z;
						//fragment[i+3] = light.intensity;
						i += 4;
					}else if(light.lightType==BasicLight3D.TYPE_POINT){
						/*fragment[i] = light.color[0];
						fragment[i+1] =light.color[1];
						fragment[i + 2] = light.color[2];
						fragment[i + 3] = light.distance;*/
						i+=4;
						
						fragment[i] = light.position.x;
						fragment[i+1] =light.position.y;
						fragment[i + 2] = light.position.z;
						//fragment[i+3] = light.intensity;
						i += 4;
					}else if(light.lightType==BasicLight3D.TYPE_SPOT){
						/*fragment[i] = light.color[0];
						fragment[i+1] =light.color[1];
						fragment[i + 2] = light.color[2];
						fragment[i + 3] = light.distance;*/
						i+=4;
						
						fragment[i] = light.position.x;
						fragment[i+1] =light.position.y;
						fragment[i + 2] = light.position.z;
						//fragment[i+3] = light.intensity;
						i += 4;
						
						//dir
						var dir = light.worldMatrix.transformVector(ZAX);
						fragment[i] = dir.x;
						fragment[i+1] =dir.y;
						fragment[i + 2] = dir.z;
						//i += 4;
						
						//fragment[i] = light.innerConeAngle;
						//fragment[i+1] =light.outerConeAngle;
						i += 8;
					}
				}
			}
		}
		node.worldMatrix.copyRawDataTo(vertex, 0, true);
		pass.camera.perspectiveProjectionMatirx.copyRawDataTo(vertex, 16, true);
		if (i3d.shadowLight != null) {
			i3d.shadowLightPass.camera.perspectiveProjectionMatirx.copyRawDataTo(vertex, 32, true);
		}
		i3d.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 0, vertex);
		i3d.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, fragment);
		
		//buff
		var xyz=null;
		var norm=null;
		var weightBuff = null;
		var matrixBuff = null;
		var uv = null;
		if(skin==null){
			var drawable = node.drawable;
			xyz = drawable.xyz;
			norm=drawable.norm;
			uv = drawable.uv;
			
			i3d.setVertexBufferAt(0, xyz.vertexBuff, 0, xyz.format);
			if (shader.diffuse != null || shader.specular != null) {
				i3d.setVertexBufferAt(1, norm.vertexBuff, 0, norm.format);
			}
			if (!isShadowDepth) {
				var ti = 0;
				if (i3d.shadowLight!=null) {
					i3d.setTextureAt(ti++, i3d.shadowLightPass.target.texture);
				}
				if(diffuseTex!=null){
					i3d.setVertexBufferAt(2, uv.vertexBuff, 0, uv.format);
					i3d.setTextureAt(ti, diffuseTex);
				}
			}
			//draw
			i3d.drawTriangles(drawable.indexBufferSet.indexBuff);
		}else {
			if (node.playing) {
				node.frame = (node.startFrame+i3d.frame) % skin.numFrame;
			}
			for(drawable in skin.draws){
				xyz = drawable.xyz;
				weightBuff = drawable.weightBuff;
				matrixBuff = drawable.matrixBuff;
				i3d.setVertexBufferAt(0, xyz.vertexBuff, 0, xyz.format);
				if (!isShadowDepth) {
					var ti = 0;
					if (i3d.shadowLight!=null) {
						i3d.setTextureAt(ti++, i3d.shadowLightPass.target.texture);
					}
					if(diffuseTex!=null){
						i3d.setTextureAt(ti, diffuseTex);
					}
					
					norm = drawable.norm;
					uv = drawable.uv;
					i3d.setVertexBufferAt(1, norm.vertexBuff, 0, norm.format);
					i3d.setVertexBufferAt(2, weightBuff.vertexBuff, 0, weightBuff.format);
					i3d.setVertexBufferAt(3, matrixBuff.vertexBuff, 0, matrixBuff.format);
					i3d.setVertexBufferAt(4, uv.vertexBuff, 0, uv.format);
				}else {
					i3d.setVertexBufferAt(1, weightBuff.vertexBuff, 0, weightBuff.format);
					i3d.setVertexBufferAt(2, matrixBuff.vertexBuff, 0, matrixBuff.format);
				}
				
				var byteSet = drawable.cacheBytes[node.frame];
				i3d.setProgramConstantsFromByteArray(Context3DProgramType.VERTEX, skinConstIndex,byteSet.numRegisters,byteSet.data,0);
				i3d.drawTriangles(drawable.indexBufferSet.indexBuff); 
			}
		}
		
	}
	override public function init(node:Node3D):Void {
		if(skin==null){//有骨骼动画 初始化交给其它类处理
			node.drawable.xyz.init();
			var shader:PhongShader = untyped this.shader;
			if(shader.diffuse!=null||shader.specular!=null)
			node.drawable.norm.init();
			if(diffuseTex!=null)
			if(node.drawable.uv!=null)node.drawable.uv.init();
			node.drawable.indexBufferSet.init();
		}
	}
}
#else
package native3d.materials;
import flash.display3D.Context3D;
import flash.display3D.Context3DProgramType;
import flash.display3D.Program3D;
import flash.display3D.textures.TextureBase;
import flash.geom.Vector3D;
import flash.Vector;
import native3d.core.BasicLight3D;
import native3d.core.BasicPass3D;
import native3d.core.Instance3D;
import native3d.core.Node3D;
import native3d.core.VertexBufferSet;
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
		var c3d = pass.i3d;
		glslProgram.attach();
		glslProgram.setVertexUniformFromMatrix("mpos", node.worldMatrix, true);
		glslProgram.setVertexUniformFromMatrix("mproj", pass.camera.perspectiveProjectionMatirx, true);
		glslProgram.setVertexBufferAt("pos", node.drawable.xyz.vertexBuff, 0, flash.display3D.Context3DVertexBufferFormat.FLOAT_3);
		glslProgram.setVertexBufferAt("norm", node.drawable.norm.vertexBuff, 0, flash.display3D.Context3DVertexBufferFormat.FLOAT_3);
		LightPositionV[0] = lightNode.worldRawData[12];
		LightPositionV[1] =lightNode.worldRawData[13];
		LightPositionV[2] = lightNode.worldRawData[14];
		c3d.setGLSLProgramConstantsFromVector3("lightPosition", LightPositionV);
		c3d.setGLSLProgramConstantsFromVector3("ambientColor", AmbientColorV);
		c3d.setGLSLProgramConstantsFromVector3("diffuseColor", DiffuseColorV);
		c3d.setGLSLProgramConstantsFromVector3("specularColor", SpecularColorV);
		c3d.setGLSLProgramConstantsFromVector1("specularExponent", SpecularExponentV);
		
		c3d.drawTriangles(node.drawable.indexBufferSet.indexBuff);
		glslProgram.detach();
	}
	private function createProgram ():Void {
		 if (glslProgram!=null) {
			 return;
		 }
        glslProgram = new GLSLProgram(i3d);
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
		node.drawable.xyz.init();
		node.drawable.norm.init();
		node.drawable.indexBufferSet.init();
	}
}
#end