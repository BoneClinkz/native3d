package native3d.core.animation;
import flash.geom.Matrix3D;
import flash.Vector;

/**
 * ...
 * @author lizhi
 */
class AnimationItem
{
	public var cacheMatrixs:Array<Array<Matrix3D>>;
	public var frames:Array<Array<Matrix3D>>;
	public var numFrame:Int = 0;
	public var cacheQuasBytess:Array<Array<ByteArraySet>>;
	public var cacheQuasTransBytess:Array<Array<ByteArraySet>>;
	public var cacheBytess:Array<Array<ByteArraySet>>;
	public var name:String;
	public function new() 
	{
		cacheMatrixs = [];
		cacheQuasBytess = [];
		cacheQuasTransBytess = [];
		cacheBytess = [];
		frames = [];
	}
	
}