package native3d.core.animation;
import flash.geom.Matrix3D;
import flash.geom.Vector3D;
import flash.utils.ByteArray;
import flash.Vector;
import native3d.core.ByteArraySet;
import native3d.core.Node3D;
import native3d.core.TextureSet;
import native3d.core.VertexBufferSet;

/**
 * ...
 * @author lizhi http://matrix3d.github.io/
 */
class Skin
{
	public var node:Node3D;
	public var jointRoot:Node3D;
	public var anims:Map<String,AnimationItem>;
	public var currentAnim:AnimationItem;
	
	public var bindShapeMatrix:Matrix3D;
	public var invBindMatrixs:Vector<Matrix3D>;
	
	public var joints:Array<Node3D>;
	
	public var vertexs:Array<Vertex>;
	public var indexss:Array<Array<Int>>;
	
	public var texture:TextureSet;
	
	public var draws:Array<SkinDrawable>;
	public var maxWeightLen:Int = 0;
	public var  useQuas:Bool = false;
	public var useBytes:Bool = false;
	public function new() 
	{
		anims = new Map();
	}
	
	public function play(name:String):Void {
		var item = anims.get(name);
		if (item != null) {
			currentAnim = item;
			for (i in 0...draws.length) {
				var draw = draws[i];
				draw.cacheBytes = item.cacheBytess[i];
				draw.cacheQuasBytes = item.cacheQuasBytess[i];
				draw.cacheQuasTransBytes = item.cacheQuasTransBytess[i];
			}
		}
	}
	
}