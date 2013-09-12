package lz.native3d.materials;
import hxsl.Shader;

/**
 * ...
 * @author lizhi http://matrix3d.github.io/
 */
class PhongShader extends Shader
{
	static var SRC = { 
		var input: {
			gl_Vertex:Float3,
			gl_Normal:Float3,
			gl_UV:Float2,
		}
		
		var LightVec:Float3;
		var SurfaceNormal:Float3;
		var ReflectedLightVec:Float3;
		var ViewVec:Float3;
		var UV:Float2;
		
		var gl_ModelViewMatrix:M44;
		//gl_NormalMatrix:M44,
		var gl_ProjectionMatrix:M44;
		var LightPosition:Float3;
		function vertex(
		){
			if(DiffuseColor!=null||SpecularColor!=null){
				var eyespacePos   = (input.gl_Vertex*gl_ModelViewMatrix).xyz;
				var surfaceNormal      = normalize(input.gl_Normal * gl_ModelViewMatrix/*gl_NormalMatrix*/);
				SurfaceNormal = surfaceNormal;
				var lightVec           = normalize(LightPosition - eyespacePos);
				LightVec = lightVec;
				ViewVec            = normalize( -eyespacePos);
				ReflectedLightVec  = normalize(2* dot(lightVec, surfaceNormal)* surfaceNormal-lightVec);
			}
			out = input.gl_Vertex.xyzw * gl_ModelViewMatrix * gl_ProjectionMatrix;
			if (hasDiffuseTex) {
				UV = input.gl_UV;
			}
		}
		
		var	AmbientColor:Float4;
		var	DiffuseColor:Float4;
		var	SpecularColor:Float4;
		var	SpecularExponent:Float;
		
		var DiffuseTex:Texture;
		var hasDiffuseTex:Bool;
		function fragment(){
			var color:Float4 = AmbientColor;
			if (DiffuseColor!=null) {
				color += DiffuseColor * max(0, dot(LightVec, SurfaceNormal));
			}
			if(SpecularColor!=null){
				color += SpecularColor * pow(max(0, dot(ReflectedLightVec, ViewVec)), SpecularExponent);
			}
			if (hasDiffuseTex) {
				color *= DiffuseTex.get(UV, wrap);
			}
			out =  color.xyzw;
		}
	};
	public function new() 
	{
		super();
	}	
}