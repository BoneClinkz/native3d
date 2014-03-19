package native3d.materials;
import flash.display3D.textures.Texture;
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
			weight:Float4,
			matrixIndex:Float4,
			weight2:Float4,
			matrixIndex2:Float4,
			uv:Float2
		}
		
		//interpolated
		var eyespacePos:Float3;
		var surfaceNormal:Float3;
		var viewVec:Float3;
		var uv:Float2;
		var shadowDepthZW:Float2;
		var shadowLightPos:Float4;
		
		//vertex parameter
		var modelViewMatrix:M44;
		var projectionMatrix:M44;
		
		//bcs the haxe array not support texture,so make a shadow light out the lights
		var shadowProjectonMatrix:M44;
		var shadowMap:Texture;
		
		var anmMats:M34<38>;
		var anmQuas:Float4<57>;
		var anmTrans:Float3<57>;
		var hasWeight1:Bool;
		var hasWeight2:Bool;
		var hasWeight3:Bool;
		var hasWeight4:Bool;
		var hasWeight5:Bool;
		var hasWeight6:Bool;
		var hasWeight7:Bool;
		var hasAnm:Bool;
		var useQuas:Bool;//使用四元树
		
		//texture
		var diffuseMap:Texture;
		var hasDiffuseMap:Bool;
		var isShadowDepth:Bool;
		
		//fragment parameter
		var	ambient:Float3;
		var	diffuse:Float3;
		var	specular:Float4;
		
		
		var lights:Param < {
			var ambientLights:Array<{color:Float3}>;
			var distantLights:Array<{color:Float3,position:Float3}>;
			var pointLights:Array<{colorLen:Float4,position:Float3}>;
			var spotLights:Array<{colorLen:Float4,position:Float3,direction:Float3,innerOuter:Float2}>;
		}>;
		
		function vertex() {
			var wpos:Float4 = input.xyz.xyzw;
			//wpos.xyz += input.normal * .7;
			if (hasAnm != null) {
				if (useQuas) {
					var result = wpos.xyz;
					var target = wpos.xyz;
					
					var q = anmQuas[input.matrixIndex.x];
					var t = anmTrans[input.matrixIndex.x];
					
					var w1 = -q.x*wpos.x - q.y*wpos.y - q.z*wpos.z;
					var x1 = q.w*wpos.x + q.y*wpos.z - q.z*wpos.y;
					var y1 = q.w*wpos.y - q.x*wpos.z + q.z*wpos.x;
					var z1 = q.w*wpos.z + q.x*wpos.y - q.y*wpos.x;
					
					target.x = -w1*q.x + x1*q.w - y1*q.z + z1*q.y+t.x;
					target.y = -w1*q.y + x1*q.z + y1*q.w - z1*q.x+t.y;
					target.z = -w1 * q.z - x1 * q.y + y1 * q.x + z1 * q.w + t.z;
					target *= input.weight.x;
					result = target;
					
					q = anmQuas[input.matrixIndex.y];
					t = anmTrans[input.matrixIndex.y];
					
					w1 = -q.x*wpos.x - q.y*wpos.y - q.z*wpos.z;
					x1 = q.w*wpos.x + q.y*wpos.z - q.z*wpos.y;
					y1 = q.w*wpos.y - q.x*wpos.z + q.z*wpos.x;
					z1 = q.w*wpos.z + q.x*wpos.y - q.y*wpos.x;
					
					target.x = -w1*q.x + x1*q.w - y1*q.z + z1*q.y+t.x;
					target.y = -w1*q.y + x1*q.z + y1*q.w - z1*q.x+t.y;
					target.z = -w1*q.z - x1*q.y + y1*q.x + z1*q.w+t.z;
					target *= input.weight.y;
					result += target;
					
					q = anmQuas[input.matrixIndex.z];
					t = anmTrans[input.matrixIndex.z];
					
					w1 = -q.x*wpos.x - q.y*wpos.y - q.z*wpos.z;
					x1 = q.w*wpos.x + q.y*wpos.z - q.z*wpos.y;
					y1 = q.w*wpos.y - q.x*wpos.z + q.z*wpos.x;
					z1 = q.w*wpos.z + q.x*wpos.y - q.y*wpos.x;
					
					target.x = -w1*q.x + x1*q.w - y1*q.z + z1*q.y+t.x;
					target.y = -w1*q.y + x1*q.z + y1*q.w - z1*q.x+t.y;
					target.z = -w1*q.z - x1*q.y + y1*q.x + z1*q.w+t.z;
					target *= input.weight.z;
					result += target;
					
					wpos.xyz = result.xyz;
				}else {
					var result = wpos.xyz;
					result = wpos * input.weight.x * anmMats[input.matrixIndex.x];
					if (hasWeight1) result.xyz += wpos * input.weight.y * anmMats[input.matrixIndex.y] ;
					if (hasWeight2) result.xyz += wpos * input.weight.z * anmMats[input.matrixIndex.z] ;
					if (hasWeight3) result.xyz += wpos * input.weight.w * anmMats[input.matrixIndex.w] ;
					if (hasWeight4) result.xyz += wpos * input.weight2.x * anmMats[input.matrixIndex2.x] ;
					if (hasWeight5) result.xyz += wpos * input.weight2.y * anmMats[input.matrixIndex2.y] ;
					if (hasWeight6) result.xyz += wpos * input.weight2.z * anmMats[input.matrixIndex2.z] ;
					if (hasWeight7) result.xyz += wpos * input.weight2.w * anmMats[input.matrixIndex2.w] ;
					wpos.xyz = result;
				}
				
			}
			if (isShadowDepth) {
				wpos = wpos * modelViewMatrix * projectionMatrix;
				out = wpos;
				shadowDepthZW = wpos.zw;
			}else {
				out = wpos * modelViewMatrix * projectionMatrix;
			}
			if (shadowProjectonMatrix != null) {
				shadowLightPos = wpos * modelViewMatrix * shadowProjectonMatrix;
			}
			
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
			if(!isShadowDepth){
				var color:Float4 = [0,0,0,1.];
				for (light in lights.ambientLights) {
					color.xyz += ambient*diffuse.xyz*light.color;
				}
				for (light in lights.distantLights) {
					color.xyz += getPhongColor(light.position)
					*light.color;
				}
				for (light in lights.pointLights) {
					color.xyz += getPhongColor(light.position)
					*getDistanceColor(light.position,light.colorLen.w)
					*light.colorLen.xyz;
				}
				for (light in lights.spotLights) {
					color.xyz += getPhongColor(light.position)
					*getDistanceColor(light.position, light.colorLen.w)
					*getSmoothColor(light.position,light.direction,light.innerOuter.x,light.innerOuter.y)
					*light.colorLen.xyz;
				}
				if (shadowProjectonMatrix != null) {
					var shadowColor:Float = 1;
					var shadowLightXY:Float2 = shadowLightPos.xy / shadowLightPos.w * [.5, -.5] + .5;
					var lightPackedDepth:Float4 = shadowMap.get(shadowLightXY,clamp);
					var lightDepth:Float = dot(lightPackedDepth, [1 / 0x1000000, 1 / 0x10000, 1 / 0x100, 1]);
					var curDepth:Float = sat(shadowLightPos.z/shadowLightPos.w);
					shadowColor -=  gt(curDepth, lightDepth+.002+1000*(lte(shadowLightXY.x,0)+lte(shadowLightXY.y,0)+gte(shadowLightXY.x,1)+gte(shadowLightXY.y,1))) * .6;
					
					color *= shadowColor;
				}
				if (hasDiffuseMap) {
					color = diffuseMap.get(uv, nearest)*color;
				}
				out =  color;
			}else {
				//pack
				var bitSh:Float4 = [0x1000000, 0x10000, 0x100, 1];
				var bitMsk:Float4 = [0, 1 / 0x100, 1 / 0x100, 1 / 0x100];
				var comp:Float4 = frc(shadowDepthZW.x/shadowDepthZW.y* bitSh);
				out = comp- comp.xxyz* bitMsk;
			}
		}
		
		function getPhongColor(position:Float3):Float3 {
			var lightVec:Float3 = normalize(position - eyespacePos);
			var color:Float3 = ambient;
			if (diffuse!=null) {
				color += diffuse.xyz * max(0, dot(lightVec, surfaceNormal));
			}
			if(specular!=null){
				var reflectedLightVec:Float3  = normalize(2* dot(lightVec, surfaceNormal)* surfaceNormal-lightVec);
				color += specular.xyz * pow(max(0, dot(reflectedLightVec, viewVec)), specular.w);
			}
			return color;
		}
		
		function getDistanceColor(position:Float3, lightDistance:Float):Float {
			var lightToPoint:Float3 = eyespacePos - position;
			return sat(1-dp3(lightToPoint,lightToPoint)/lightDistance/lightDistance);
		}
		function getSmoothColor(position:Float3, direction:Float3, inner:Float, outer:Float):Float {
			var factor1:Float = 1/ (cos(inner/2)- cos(outer/2));
			var factor2:Float = 1- cos(inner/2)* factor1;
			var lightToPoint:Float3 = eyespacePos - position;
			var lightAngleCosine:Float = dp3(direction, normalize(lightToPoint));
			return sat(factor1* lightAngleCosine+ factor2);
		}
	};
	public function new() 
	{
		super();
	}	
}