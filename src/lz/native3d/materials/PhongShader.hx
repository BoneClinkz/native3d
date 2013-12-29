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
		var anmMats:M34<39>;
		var test:Param < {
			var dirs:Array<Float4>;
		}>;
		var hasAnm:Bool;
		function vertex() {
			for (p in test.dirs) {
				
			}
			var wpos:Float4 = input.gl_Vertex.xyzw;
			if (hasAnm != null) {
				wpos.xyz = 
					wpos * input.weight.x * anmMats[input.matrixIndex.x ] 
					+ wpos * input.weight.y * anmMats[input.matrixIndex.y] 
					+ wpos * input.weight.z * anmMats[input.matrixIndex.z];
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