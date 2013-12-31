package ;
import flash.display.Sprite;
import flash.geom.Vector3D;
import hxsl.Shader;

class TestShader extends Shader {
	static var SRC = {
		var lights:Param <{
			var lights:Array<{position:Float3,type:Float}>;
		}>;
		function vertex() {
			out = [1, 1, 1, 1];
		}
		function fragment() {
			var color:Float4 = [0,0,0,0];
			for (light in lights.lights) {
				color.xyz += light.position;
			}
			out = color;
		}
	}
}
class TestHxsl extends Sprite
{
	public static function main():Void {
		var shader = new TestShader();
		shader.lights = { 
			lights:[
				{position:new Vector3D(.1, .2, .3),type:.4 }
			]
		};
		var shaderInstance = shader.getInstance();
		trace(shader.getDebugShaderCode(true));
		trace(shaderInstance.fragmentVars);
	}
	
}
