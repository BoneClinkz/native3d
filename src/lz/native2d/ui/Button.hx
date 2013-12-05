package lz.native2d.ui;
import flash.events.MouseEvent;
import flash.Lib;
import lz.native2d.SwfMovieClip2D;

/**
 * ...
 * @author lizhi
 */
class Button extends Component
{
	public var mc:SwfMovieClip2D;
	public var isPressed:Bool = false;
	public var isOver:Bool = false;
	public var state:Int;
	public function new(mc:SwfMovieClip2D) 
	{
		super();
		this.mc = mc;
		init();
	}
	
	private function init():Void {
		mc.gotoAndStop(0);
		addMouseEffect();
		setState(0);
	}
	
	public function addMouseEffect():Void {
		mc.addEventListener(MouseEvent.MOUSE_OUT, btnOut);
		mc.addEventListener(MouseEvent.MOUSE_OVER, btnOver);
	}
	public function removeMouseEffect():Void {
		mc.removeEventListener(MouseEvent.MOUSE_OUT, btnOut);
		mc.removeEventListener(MouseEvent.MOUSE_OVER, btnOver);
		
		mc.removeEventListener(MouseEvent.MOUSE_DOWN, btnDown);
		Lib.current.stage.removeEventListener(MouseEvent.MOUSE_UP, btnUp);
	}
	private function btnOver(e:MouseEvent):Void {
		isOver = true;
		updateButtonEffect();
		mc.addEventListener(MouseEvent.MOUSE_DOWN, btnDown);
		Lib.current.stage.addEventListener(MouseEvent.MOUSE_UP, btnUp);
	}
	private function btnOut(e:MouseEvent):Void {
		isOver = false;
		updateButtonEffect();
		mc.removeEventListener(MouseEvent.MOUSE_DOWN, btnDown);
	}
	private function btnDown(e:MouseEvent):Void {
		isPressed = true;
		updateButtonEffect();
	}
	private function btnUp(e:MouseEvent):Void {
		isPressed = false;
		updateButtonEffect();
	}
	public function updateButtonEffect():Void {
		/*if (!mc.mouseEnabled) {
			setState(4);
		}else */if (isOver&&isPressed) {
			setState(2);
		}else if (isOver&&!isPressed) {
			setState(1);
		}else {
			setState(0);
		}
	}
	public function setState(state:Int):Void {
		this.state = state;
		mc.gotoAndStop(state);
	}
	
}