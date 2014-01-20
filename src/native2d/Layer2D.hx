package native2d;
import flash.display3D.textures.TextureBase;
import native3d.core.Drawable3D;
import native3d.core.Instance3D;
import native3d.materials.TwoDBatchMaterial;

/**
 * ...
 * @author lizhi
 */
class Layer2D extends Node2D
{
	public var isBatch:Bool;
	public function new(isBatch:Bool,texture:TextureBase) 
	{
		super();
		this.isBatch = isBatch;
		if (isBatch) {
			drawable = new Drawable3D();
			material = new TwoDBatchMaterial(texture);
		}
	}
	
}