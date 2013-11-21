package lz.native2d;
import flash.display3D.textures.TextureBase;
import lz.native3d.core.DrawAble3D;
import lz.native3d.core.Instance3D;
import lz.native3d.materials.TwoDBatchMaterial;

/**
 * ...
 * @author lizhi
 */
class Layer2D extends Node2D
{
	public var isBatch:Bool;
	public function new(isBatch:Bool,texture:TextureBase,i3d:Instance3D) 
	{
		super();
		this.isBatch = isBatch;
		if (isBatch) {
			drawAble = new DrawAble3D();
			material = new TwoDBatchMaterial(texture, i3d);
		}
	}
	
}