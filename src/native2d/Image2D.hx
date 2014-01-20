package native2d;
import flash.display3D.textures.TextureBase;
import flash.geom.Matrix3D;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.geom.Vector3D;
import flash.Vector;
import native3d.core.TwoDData;

/**
 * ...
 * @author lizhi
 */
class Image2D extends Node2D
{
	public static var helpHittestMatrix3d:Matrix3D = new Matrix3D();
	
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
	override public function hittest(mousePos:Vector3D):Bool {
		helpHittestMatrix3d.copyFrom(worldMatrix);
		helpHittestMatrix3d.invert();
		var pos = helpHittestMatrix3d.transformVector(mousePos);
		return pos.x>=-.5&&pos.x<=.5&&pos.y>=-.5&&pos.y<=.5;
	}
	
}