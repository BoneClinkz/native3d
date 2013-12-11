package lz.native2d;
import flash.events.MouseEvent;
import flash.geom.Vector3D;
import flash.Lib;
import flash.Vector.Vector;
import lz.native3d.core.Node3D;

/**
 * ...
 * @author lizhi
 */
class Mouse2D
{
	public var nodes:Vector<Node3D>;
	public var mousePos:Vector3D;
	public var lastMouseNodes:Vector<Node3D>;
	public var mouseNodes:Vector<Node3D>;
	public var changed:Bool = false;
	public function new() 
	{
		mousePos = new Vector3D();
		nodes = new Vector<Node3D>();
		lastMouseNodes = new Vector<Node3D>();
		mouseNodes = new Vector<Node3D>();
		Lib.current.stage.addEventListener(MouseEvent.MOUSE_MOVE, stage_mouseevent);
		Lib.current.stage.addEventListener(MouseEvent.CLICK, stage_mouseevent);
		Lib.current.stage.addEventListener(MouseEvent.MOUSE_DOWN, stage_mouseevent);
		Lib.current.stage.addEventListener(MouseEvent.MOUSE_UP, stage_mouseevent);
	}
	
	private function stage_mouseevent(e:MouseEvent):Void 
	{
		for (node in mouseNodes) {
			node.dispatchEvent(e);
		}
	}
	
	public function clear():Void {
		nodes.length = 0;
		changed = true;
	}
	
	public function doMouse(mouseX:Float,mouseY:Float):Void {
		//mouse event
		var i = nodes.length - 1;
		mousePos.x = mouseX;
		mousePos.y = mouseY;
		lastMouseNodes = mouseNodes;
		mouseNodes = new Vector<Node3D>(); 
		while (i >= 0) {
			var node = nodes[i];
			if (node.getMouseEnable()&&node.hittest(mousePos)) {
				var cnode = node;
				while (cnode!=null) {
					mouseNodes.push(cnode);
					cnode = cnode.parent;
				}
				break;
			}
			i--;
		}
		var event = new MouseEvent(MouseEvent.MOUSE_OUT);
		for (node in lastMouseNodes) {
			if (mouseNodes.indexOf(node)==-1) {
				node.dispatchEvent(event);
			}
		}
		event = new MouseEvent(MouseEvent.MOUSE_OVER);
		for (node in mouseNodes) {
			if (lastMouseNodes.indexOf(node)==-1) {
				node.dispatchEvent(event);
			}
		}
		changed = false;
	}
}