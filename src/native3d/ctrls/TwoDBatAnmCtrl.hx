package native3d.ctrls;
import flash.geom.Matrix;
import flash.utils.Function;
import native3d.core.Node3D;
import native3d.core.twoDAnimation.TDFrame;
import native3d.core.twoDAnimation.TDSpriteData;

/**
 * ...
 * @author lizhi http://matrix3d.github.io/
 */
class TwoDBatAnmCtrl
{

	public var data:TDSpriteData;
	public var frame:Float ;
	public var speed:Float = 1;
	public var node3d:Node3D;
	
	private var lastFrame:TDFrame;
	public function new() 
	{
		frame = 1000 * Math.random();
		var a = new TDFrame();
		var b = new TDSpriteData();
	}
	public function next():Void {
		frame += speed;
		var eframe:TDFrame = data.frames[Std.int(frame) % data.totalFrame];
		if (eframe != lastFrame) {
			lastFrame = eframe;
			node3d.twoDData.uvChanged = true;
			node3d.matrix = eframe.matrix;
			node3d.matrixVersion++;
			node3d.twoDData.uvData = lastFrame.uv;
		}
	}
	
}