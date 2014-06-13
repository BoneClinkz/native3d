package native3d.core.animation;
import flash.Vector;
import native3d.core.ByteArraySet;
import native3d.core.Drawable3D;
import native3d.core.VertexBufferSet;
import native3d.materials.MaterialBase;

/**
 * ...
 * @author lizhi http://matrix3d.github.io/
 */
class SkinDrawable extends Drawable3D
{
	//matrix3d
	public var cacheBytes:Array<ByteArraySet>;
	
	//quaternion
	public var cacheQuasBytes:Array<ByteArraySet>;
	public var cacheQuasTransBytes:Array<ByteArraySet>;
	
	public var weightBuff:VertexBufferSet;
	public var matrixBuff:VertexBufferSet;
	public var weightBuff2:VertexBufferSet;
	public var matrixBuff2:VertexBufferSet;
	public var material:MaterialBase;
	public var joints:Array<Int>;
	public function new() 
	{
		super();
	}
	
}