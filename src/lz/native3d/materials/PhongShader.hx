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
			weight:Float3,
			matrixIndex:Float4,
			gl_UV:Float2
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
		var anmMats:Float4<117>;
		//var anmMats:Array<Float4>;
		var hasAnm:Bool;
		function vertex() {
			var wpos:Float4 = input.gl_Vertex.xyzw;
			if(hasAnm!=null){
				var t = input.matrixIndex.x;
				wpos.x = dp4(input.gl_Vertex.xyzw, anmMats[t]);
				t+=1;
				wpos.y = dp4(input.gl_Vertex.xyzw, anmMats[t]);
				t +=1;
				wpos.z = dp4(input.gl_Vertex.xyzw, anmMats[t]);
				wpos.w = input.gl_Vertex.w;
				var wpos2 = wpos*input.weight.x;
				
				t = input.matrixIndex.y;
				wpos.x = dp4(input.gl_Vertex.xyzw, anmMats[t]);
				t +=1;
				wpos.y = dp4(input.gl_Vertex.xyzw, anmMats[t]);
				t +=1;
				wpos.z = dp4(input.gl_Vertex.xyzw, anmMats[t]) ;
				wpos.w = input.gl_Vertex.w;
				wpos2 += wpos * input.weight.y;
				
				t = input.matrixIndex.z;
				wpos.x = dp4(input.gl_Vertex.xyzw, anmMats[t]);
				t +=1;
				wpos.y = dp4(input.gl_Vertex.xyzw, anmMats[t]);
				t +=1;
				wpos.z = dp4(input.gl_Vertex.xyzw, anmMats[t]) ;
				wpos.w = input.gl_Vertex.w;
				wpos2 += wpos * input.weight.z;
				
				wpos = wpos2;
			}
			out = wpos * gl_ModelViewMatrix * gl_ProjectionMatrix;
			
			if(DiffuseColor!=null||SpecularColor!=null){
				var eyespacePos   = (wpos.xyz*gl_ModelViewMatrix).xyz;
				var surfaceNormal      = normalize(input.gl_Normal * gl_ModelViewMatrix);
				SurfaceNormal = surfaceNormal;
				var lightVec           = normalize(LightPosition - eyespacePos);
				LightVec = lightVec;
				ViewVec            = normalize( -eyespacePos);
				ReflectedLightVec  = normalize(2* dot(lightVec, surfaceNormal)* surfaceNormal-lightVec);
			}
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