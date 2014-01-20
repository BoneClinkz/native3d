package native3d.core.particle;
import native3d.core.Drawable3D;
import native3d.core.VertexBufferSet;

/**
 * ...
 * @author lizhi
 */
class ParticleDrawable3D extends Drawable3D
{

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