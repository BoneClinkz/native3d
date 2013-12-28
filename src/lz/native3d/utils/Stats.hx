package lz.native3d.utils;
import flash.display.Sprite;
import flash.events.Event;
import flash.Lib;
import flash.system.System;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;
import lz.native3d.core.Instance3D;

/**
 * ...
 * @author lizhi
 */
class Stats extends Sprite
{
	var tf:TextField;
	var fpsCounter:Int = 0;
	var fps:Int = 0;
	var lastTime:Int = -10000;
	var maxMem:Int = 0;
	public function new() 
	{
		super();
		addEventListener(Event.ENTER_FRAME, enterFrame);
		tf = new TextField();
		tf.defaultTextFormat = new TextFormat("Verdana");
		tf.text = "stats3d";
		addChild(tf);
		tf.autoSize = TextFieldAutoSize.LEFT;
		tf.textColor = 0xffffff;
	}
	
	private function enterFrame(e:Event):Void 
	{
		var time = Lib.getTimer();
		if (time-1000>lastTime) {
			fps = fpsCounter;
			if (fps > 0) fps--;
			fpsCounter = 0;
			lastTime = time;
		}
		fpsCounter++;
		
		var text = "";
		if (Instance3D._instances!=null) {
			for (i3d in Instance3D._instances) {
				text +="num:\t"+ i3d.drawCounter+" / "+i3d.doTransform.passNodes.length ;
				text += "\ntri:\t" + i3d.drawTriangleCounter;
				var info = i3d.context.driverInfo;
				var indexS = info.indexOf(" ");
				if (indexS!=-1) {
					info = info.substr(0, indexS);
				}
				text += "\ndriver:\t" + info;
			}
		}
		text += "\nfps:\t" + fps + " / " ;
		if (stage!=null) {
			text +=  stage.frameRate;
		}
		var mem = Std.int(System.totalMemoryNumber / 1024 / 1024);
		if (mem > maxMem) maxMem = mem;
		text += "\nmem:\t" + mem+" / "+maxMem;
		tf.text = text;
		
		graphics.clear();
		graphics.beginFill(0, .7);
		graphics.drawRect(0, 0, tf.width, tf.height);
	}
	
}