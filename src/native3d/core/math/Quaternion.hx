package native3d.core.math;
import flash.geom.Matrix3D;
import flash.geom.Orientation3D;
import flash.geom.Vector3D;
import flash.Vector;

/**
 * ...
 * @author lizhi
 */
class Quaternion extends Vector3D
{
	private static var HELP_VEC:Vector<Vector3D> = Vector.ofArray([new Vector3D(), new Vector3D(), new Vector3D(1, 1, 1)]);
	private static var HELP_MATRIX:Matrix3D = new Matrix3D();
	public function new(x:Float=0,y:Float=0,z:Float=0,w:Float=0) 
	{
		super(x, y, z, w);
	}
	
	public function computeW ():Void{
		var t:Float = 1 - lengthSquared;
		w = t < 0?0: -Math.sqrt(t);
	}
	
	public function rotatePoint(vector:Vector3D,target:Vector3D=null):Vector3D {
		if (target == null) target = new Vector3D();
		var x2 = vector.x;
		var y2 = vector.y;
		var z2 = vector.z;
		var w1 = -x*x2 - y*y2 - z*z2;
		var x1 = w*x2 + y*z2 - z*y2;
		var y1 = w*y2 - x*z2 + z*x2;
		var z1 = w*z2 + x*y2 - y*x2;
		
		target.x = -w1*x + x1*w - y1*z + z1*y;
		target.y = -w1*y + x1*z + y1*w - z1*x;
		target.z = -w1*z - x1*y + y1*x + z1*w;
		
		return target;
	}
	
	public function fromMatrix(matrix:Matrix3D):Void
	{
		var temp = matrix.decompose(Orientation3D.QUATERNION)[1];
		copyFrom(temp);
		w = temp.w;
	}
	
	public function toMatrix(matr:Matrix3D=null):Matrix3D {
		if (matr == null) matr = new Matrix3D();
		HELP_VEC[1] = this;
		matr.recompose(HELP_VEC,Orientation3D.QUATERNION);
		return matr;
	}
	
	override public function clone():Quaternion {
		return new Quaternion(x, y, z, w);
	}
	
	public static function cross(v1:Vector3D, v2:Vector3D):Vector3D {
		return new Vector3D(
		v1.y * v2.z - v1.z * v2.y,
		v1.z * v2.x - v1.x * v2.z,
		v1.x * v2.y - v1.y * v2.x
		);
	}
	
	override public function toString():String {
		return "Quaternion(" +x+","+y+","+z+","+w+ ")";
	}
}