package ;
import aglsl.AGALTokenizer;
import aglsl.AGLSLParser;
import flash.display.Sprite;
import flash.events.Event;
import flash.Lib;
import flash.utils.ByteArray;
import native3d.materials.PhongMaterial;
import native3d.materials.PhongShader;
import net.LoaderCell;

/**
 * ...
 * @author lizhi
 */
class Test extends Sprite
{
	var loader:LoaderCell;

	public function new() 
	{
		super();
		var shader:PhongShader = new PhongShader();
		var agal:AGALTokenizer = new AGALTokenizer();
		var bytes:ByteArray = shader.getInstance().vertexBytes.getData();
		bytes.position = 0;
		var parser : AGLSLParser = new AGLSLParser();
		trace( parser.parse(agal.decribeAGALByteArray(bytes)));
	}
	
	static function main():Void {
		Lib.current.addChild(new Test());
	}
}



