package lz.ui;
import flash.events.EventDispatcher;
import flash.geom.Vector3D;

/**
 * ...
 * @author lizhi
 */
class UIComponent extends EventDispatcher
{
	public var display:Dynamic;
	public var position:Vector3D;
	public var rotation:Vector3D;
	public var scale:Vector3D;
	public function new() 
	{
		super();
	}
	
}