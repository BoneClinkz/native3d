package lz.native2d;
import flash.display3D.textures.TextureBase;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.Vector;
import lz.native3d.core.TwoDData;

/**
 * ...
 * @author lizhi
 */
class Image2D extends Node2D
{
	public var texture:TextureBase;
	public var uv:UV2D;
	public function new(texture:TextureBase,size:Point=null,uv:UV2D=null) 
	{
		super();
		this.texture = texture;
		this.uv = uv;
		
		twoDData = new TwoDData();
		if (size != null) {
			setScale(size.x, -size.y);
		}else {
			setScale(100, 100);
		}
		
		if (uv != null) {
			twoDData.uvData = Vector.ofArray([
			uv.left, uv.bottom, uv.right, uv.bottom, uv.left, uv.top, uv.right, uv.top
			]);
		}
	}
	
}