package lz.collision;
import flash.geom.Rectangle;

/**
 * ...
 * @author lizhi
 */
class Box
{
	public static var ID:Int = 0;
	public static var DYNAMIC_TYPE:Int = 0;
	public static var STATIC_TYPE:Int = 1;
	
	public var id:Int;
	public var userData:Dynamic;
	public var categoryBits:UInt=0xffffffff;
	public var maskBits:UInt = 0xffffffff;
	public var x:Float = 0;
	public var y:Float = 0;
	public var vx:Float = 0;
	public var vy:Float = 0;
	public var hw:Float;
	public var hh:Float;
	public var aabb:Rectangle;
	public var type:Int = 0;
	
	public var collidablePairs:Array<CollidablePair>;
	public function new(x:Float,y:Float,hw:Float,hh:Float,vx:Float=0,vy:Float=0,type:Int=1,userData:Dynamic=null) 
	{
		this.x = x;
		this.y = y;
		this.hw = hw;
		this.hh = hh;
		this.vx = vx;
		this.vy = vy;
		this.type = type;
		this.userData = userData;
		aabb = new Rectangle();
		collidablePairs = [];
		id = ID++;
	}
	
}