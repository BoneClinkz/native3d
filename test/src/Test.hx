package ;
import flash.display.BlendMode;
import flash.display.Sprite;
import flash.events.Event;
import flash.geom.Matrix3D;
import flash.Lib;
import flash.utils.ByteArray;
import flash.Vector;
import native3d.core.animation.Animation;
import native3d.core.animation.Skin;
import native3d.core.BasicLight3D;
import native3d.core.Node3D;
import native3d.core.TextureSet;
import native3d.materials.GraphicsMaterial;
import native3d.materials.PhongMaterial;
import native3d.materials.PhongShader;
import native3d.utils.BasicTest;
import net.LoaderCell;

/**
 * ...
 * @author lizhi
 */
class Test extends BasicTest
{
	public function new() 
	{
		super();
	}
	
	override public function initScene():Void {
		var c:Int = 20;
		var atft:TextureSet = new TextureSet();
		atft.setAtf(new ATF());
		while (c-->0){
			var cube= addCube(null,
			(Math.random() - .5) * 20,
			(Math.random() - .5) * 20,
			(Math.random() - .5) * 20,
			360*Math.random(),
			360*Math.random(),
			360*Math.random()
			);
			if (Math.random() < .5) {
				//cube.material = new GraphicsMaterial(graphics);
				cube.material = new PhongMaterial(null, null, null, 200, atft);
				cube.material.setBlendModel(BlendMode.LAYER);
			}
			
		}
	}
	
	override public function enterFrame(e:Event):Void 
	{
		graphics.clear();
		for (node in root3d.children) {
			node.rotationX++;
			node.rotationY+=2;
		}
		super.enterFrame(null);
	}
	
	static function main():Void {
		Lib.current.addChild(new Test());
	}
}

@:file("src/blue.atf") 
class ATF extends ByteArray{} 



