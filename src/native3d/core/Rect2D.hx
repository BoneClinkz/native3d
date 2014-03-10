package native3d.core;
import flash.display3D.textures.TextureBase;
import native3d.materials.Rect2DMatchMaterial;

/**
 * 
 * @author lizhi
 */
class Rect2D extends Node3D
{
	public var width:Float;
	public var height:Float;
	public function new(width:Float,height:Float,texture:TextureBase) 
	{
		super();
		this.width = width;
		this.height = height;
		drawable = new Drawable3D();
		frustumCulling = null;
		material = new Rect2DMatchMaterial(texture);
	}
	
}