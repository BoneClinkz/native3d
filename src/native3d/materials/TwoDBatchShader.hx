package native3d.materials;
import hxsl.Shader;

/**
 * ...
 * @author lizhi
 */
class TwoDBatchShader extends Shader {
	static var SRC = {
		var input: {
			pos : Float3,
			uv : Float2,
		}
		var uv:Float2;
		function vertex(mproj:M44) {
			out = input.pos.xyzw * mproj;
			uv = input.uv;
		}
		var colorMul:Float4;
		function fragment(tex:Texture) {
			if (colorMul != null) {
				out = tex.get(uv, wrap)*colorMul;
			}else {
				out = tex.get(uv, wrap);
			}
		}
	};
}