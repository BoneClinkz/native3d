package lz.native3d.core.particle;
import lz.native3d.core.Drawable3D;
import lz.native3d.core.VertexBufferSet;

/**
 * ...
 * @author lizhi
 */
class ParticleDrawable3D extends Drawable3D
{

	public var offset : VertexBufferSet;
	public var timeLifeVariance:VertexBufferSet;
	public var startPosVariance:VertexBufferSet;
	public var endPosVariance:VertexBufferSet;
	public var startEndScaleVariance:VertexBufferSet;
	public var startColorVariance:VertexBufferSet;
	public var endColorVariance:VertexBufferSet;
	public function new() 
	{
		super();
	}
	
}