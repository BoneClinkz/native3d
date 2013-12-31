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
			xyz:Float3,
			normal:Float3,
			weight:Float3,
			matrixIndex:Float4,
			uv:Float2
		}
		
		//interpolated
		var eyespacePos:Float3;
		var surfaceNormal:Float3;
		var viewVec:Float3;
		var uv:Float2;
		
		//vertex parameter
		var modelViewMatrix:M44;
		var projectionMatrix:M44;
		var anmMats:M34<39>;
		var hasAnm:Bool;
		
		//fragment parameter
		var	ambient:Float3;
		var	diffuse:Float3;
		var	specular:Float3;
		var lights:Param < {
			var lights:Array<{color:Float3,position:Float3,intensity:Float}>;
		}>;
		
		var diffuseMap:Texture;
		var hasDiffuseMap:Bool;
		
		function vertex() {
			var wpos:Float4 = input.xyz.xyzw;
			if (hasAnm != null) {
				wpos.xyz = 
					wpos * input.weight.x * anmMats[input.matrixIndex.x ] 
					+ wpos * input.weight.y * anmMats[input.matrixIndex.y] 
					+ wpos * input.weight.z * anmMats[input.matrixIndex.z];
			}
			out = wpos * modelViewMatrix * projectionMatrix;
			
			if(diffuse!=null||specular!=null){
				var eyespacePosTemp = (wpos.xyz * modelViewMatrix).xyz;
				eyespacePos = eyespacePosTemp;
				viewVec = normalize( -eyespacePosTemp);
				surfaceNormal = normalize(input.normal * modelViewMatrix);
			}
			if (hasDiffuseMap) {
				uv = input.uv;
			}
		}
		
		function fragment() {
			var color:Float4 = [0,0,0,1.];
			for (light in lights.lights) {
				var lightVec:Float3 = normalize(light.position - eyespacePos);
				color.xyz += ambient;
				if (diffuse!=null) {
					color.xyz += diffuse.xyz * max(0, dot(lightVec, surfaceNormal));
				}
				if(specular!=null){
					var reflectedLightVec:Float3  = normalize(2* dot(lightVec, surfaceNormal)* surfaceNormal-lightVec);
					color.xyz += specular * pow(max(0, dot(reflectedLightVec, viewVec)), light.intensity);
				}
				color.xyz *= light.color;
			}
			if (hasDiffuseMap) {
				color *= diffuseMap.get(uv, wrap);
			}
			out =  color;
		}
	};
	public function new() 
	{
		super();
	}	
}