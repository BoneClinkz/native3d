#if flash
package lz.native3d.materials;
import flash.display3D.Context3D;
import flash.display3D.Context3DProgramType;
import flash.display3D.textures.CubeTexture;
import flash.display3D.textures.TextureBase;
import flash.Vector;
import hxsl.Shader;
import lz.native3d.core.BasicPass3D;
import lz.native3d.core.Instance3D;
import lz.native3d.core.Node3D;
import lz.native3d.core.VertexBufferSet;

private class SkyShader extends Shader {
	static var SRC = {
		var input : {
			pos : Float3,
		};
		var dir:Float3;
		function vertex( mpos : M44, mproj : M44, cameraPos:Float4) {
			var wpos = input.pos.xyzw * mpos;
			out = wpos * mproj;
			dir = wpos.xyz - cameraPos.xyz;
		}
		function fragment( tex:CubeTexture) {
			out = tex.get(dir,clamp);
		}
	};
}
/**
 * ...
 * @author lizhi http://matrix3d.github.io/
 */
class SkyboxMaterial extends MaterialBase
{
	public var texture:TextureBase;
	public function new(i3d:Instance3D,texture:TextureBase) 
	{
		super();
		shader = new SkyShader();
		this.texture = texture;
		this.i3d = i3d;
		build();
	}
	inline override public function draw(node:Node3D, pass:BasicPass3D):Void {
		super.draw(node, pass);
		var xyz:VertexBufferSet = node.drawable.xyz;
		i3d.setVertexBufferAt(0, xyz.vertexBuff, 0, xyz.format);
		i3d.setTextureAt(0, texture);
		i3d.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, node.worldMatrix, true);
		i3d.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 4, pass.camera.perspectiveProjectionMatirx, true);
		vertex[0] = pass.camera.worldRawData[12];
		vertex[1] = pass.camera.worldRawData[13];
		vertex[2] = pass.camera.worldRawData[14];
		i3d.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 8, vertex);
		i3d.drawTriangles(node.drawable.indexBufferSet.indexBuff);
	}
	override public function init(node:Node3D):Void {
		node.drawable.xyz.init();
		node.drawable.indexBufferSet.init();
	}
}
#else
package lz.native3d.materials;

import lz.native3d.core.Instance3D;
import lz.native3d.core.Node3D;
import lz.native3d.core.BasicPass3D;
import flash.display3D.Context3D;
import flash.display3D.Context3DProgramType;
import flash.display3D.Program3D;
import flash.display3D.textures.TextureBase;
import flash.display3D.textures.Texture;
import flash.geom.Vector3D;
import flash.Vector;
import lz.native3d.core.VertexBufferSet;
import flash.display3D.shaders.glsl.GLSLProgram;
import flash.display3D.shaders.glsl.GLSLFragmentShader;
import flash.display3D.shaders.glsl.GLSLVertexShader;
import openfl.gl.GL;
class SkyboxMaterial extends MaterialBase
{
	public var texture:TextureBase;
	static var glslProgram :GLSLProgram;
	private var i3d:Instance3D;
	public function new(i3d:Instance3D,texture:TextureBase) 
	{
		super();
		this.i3d = i3d;
		this.texture = texture;
		vertex = new Vector<Float>(4, true);
		createProgram();
	}
	inline override public function draw(node:Node3D, pass:BasicPass3D):Void {
		//super.draw(node, pass);
		var c3d = pass.i3d;
		glslProgram.attach();
		glslProgram.setVertexUniformFromMatrix("mpos", node.worldMatrix, true);
		glslProgram.setVertexUniformFromMatrix("mproj", pass.camera.perspectiveProjectionMatirx, true);
		glslProgram.setVertexBufferAt("pos", node.drawable.xyz.vertexBuff, 0, flash.display3D.Context3DVertexBufferFormat.FLOAT_3);
		vertex[0] = pass.camera.worldRawData[12];
		vertex[1] = pass.camera.worldRawData[13];
		vertex[2] = pass.camera.worldRawData[14];
		c3d.setGLSLProgramConstantsFromVector3("cameraPos", vertex);
		//glslProgram.setTextureAt("samplerCube",texture);
		c3d.setGLSLCubeTextureAt("samplerCube", texture, 0);
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
		varying vec3 dir;

        uniform mat4 mpos;
		uniform mat4 mproj;
		uniform vec3 cameraPos;
		void main()
		{
			vec4 wpos = mpos * vec4(pos, 1);
            gl_Position = mproj * wpos;
			dir = wpos.xyz - cameraPos;
		}";
         var vertexShader = new GLSLVertexShader(vertexShaderSource);
		
        var fragmentShaderSource =
        "
		varying vec3 dir;
		uniform samplerCube cubemap;
		void main()
		{
			vec4 color;
			color=vec4(textureCube(cubemap,dir));
			gl_FragColor=clamp(color,0.0,1.0);
		}";
        var fragmentShader = new GLSLFragmentShader(fragmentShaderSource);
        glslProgram.upload(vertexShader, fragmentShader);
    }
	
	override public function init(node:Node3D):Void {
		node.drawable.xyz.init();
		node.drawable.indexBufferSet.init();
	}
}
#end