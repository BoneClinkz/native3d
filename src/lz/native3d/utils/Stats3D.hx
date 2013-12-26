package lz.native3d.utils;
import flash.display.Sprite;
import flash.events.Event;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import lz.native3d.core.Instance3D;

/**
 * ...
 * @author lizhi
 */
class Stats3D extends Sprite
{
	var tf:TextField;
	public function new() 
	{
		super();
		addEventListener(Event.ENTER_FRAME, enterFrame);
		tf = new TextField();
		tf.text = "stats3d";
		addChild(tf);
		tf.autoSize = TextFieldAutoSize.LEFT;
		tf.textColor = 0xffffff;
	}
	
	private function enterFrame(e:Event):Void 
	{
		var text = "";
		if (Instance3D._instances!=null) {
			for (i3d in Instance3D._instances) {
				text +="num:\t"+ i3d.doTransform.passNodes.length;
				text += "\ndraw:\t" + i3d.drawCounter;
				text += "\ntri:\t" + i3d.drawTriangleCounter;
			}
		}
		tf.text = text;
		
		graphics.clear();
		graphics.beginFill(0, .5);
		graphics.drawRect(0, 0, tf.width, tf.height);
	}
	
}