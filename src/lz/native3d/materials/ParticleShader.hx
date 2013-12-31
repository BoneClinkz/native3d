package lz.native3d.materials;
import hxsl.Shader;

/**
 * ...
 * @author lizhi
 */
 class ParticleShader extends Shader {
	static var SRC = {
		var input : {
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
			wpos.xy += (input.uv-.5) * scale;
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