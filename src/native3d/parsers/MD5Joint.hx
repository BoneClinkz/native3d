package native3d.parsers;
import flash.geom.Matrix3D;
import flash.geom.Vector3D;
import native3d.core.math.Quaternion;

/**
 * ...
 * @author lizhi
 */
class MD5Joint
{
	public var name:String;
	public var parent:Int;
	public var pos:Vector3D;
	public var quat:Quaternion;
	public var matr:Matrix3D;
	public var matrInv:Matrix3D;
	public var matr2:Matrix3D;
	public function new() 
	{
		
	}
	
	public function toMatrix():Void {
		matr = quat.toMatrix();
		matr.appendTranslation(pos.x, pos.y, pos.z);
		matrInv = matr.clone();
		matrInv.invert();
	}
	
}