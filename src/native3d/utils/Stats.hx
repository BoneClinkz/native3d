package native3d.utils;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Rectangle;
import flash.Lib;
import flash.system.System;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;
import native3d.core.Instance3D;

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
		tf.mouseEnabled=tf.selectable = false;
		buttonMode = true;
		tf.defaultTextFormat = new TextFormat("Verdana");
		addChild(tf);
		tf.autoSize = TextFieldAutoSize.LEFT;
		tf.textColor = 0xffffff;
		addEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
	}
	
	private function mouseDown(e:MouseEvent):Void 
	{
		if (stage != null) {
			startDrag(false,new Rectangle(0,0,stage.stageWidth-width,stage.stageHeight-height));
			stage.addEventListener(MouseEvent.MOUSE_UP, stage_mouseUp);
		}
	}
	
	private function stage_mouseUp(e:MouseEvent):Void 
	{
		if(stage!=null)stage.removeEventListener(MouseEvent.MOUSE_UP, stage_mouseUp);
		stopDrag();
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
				text +="num : "+ i3d.drawCounter+" / "+i3d.doTransform.passNodes.length ;
				text += "\ntri : " + i3d.drawTriangleCounter;
				var info =i3d.context==null?"null": i3d.context.driverInfo;
				var indexS = info.indexOf(" ");
				if (indexS!=-1) {
					info = info.substr(0, indexS);
				}
				text += "\ndriver : " + info;
			}
		}
		text += "\nfps : " + fps + " / " ;
		if (stage!=null) {
			text +=  stage.frameRate;
		}
		var mem = Std.int(System.totalMemoryNumber / 1024 / 1024);
		if (mem > maxMem) maxMem = mem;
		text += "\nmem : " + mem+" / "+maxMem;
		tf.text = text;
		
		graphics.clear();
		graphics.beginFill(0, .7);
		graphics.drawRect(0, 0, tf.width, tf.height);
	}
	
}