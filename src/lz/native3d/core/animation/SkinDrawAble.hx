package lz.native3d.core.animation;
import flash.Vector;
import lz.native3d.core.ByteArraySet;
import lz.native3d.core.Drawable3D;
import lz.native3d.core.VertexBufferSet;
import lz.native3d.materials.MaterialBase;

/**
 * ...
 * @author lizhi http://matrix3d.github.io/
 */
class SkinDrawable extends Drawable3D
{
	
	public var cacheBytes:Vector<ByteArraySet>;
	
	public var weightBuff:VertexBufferSet;
	public var matrixBuff:VertexBufferSet;
	public var material:MaterialBase;
	public function new() 
	{
		super();
	}
	
}