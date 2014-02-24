package native3d.materials;
import flash.display3D.textures.TextureBase;
import native3d.core.BasicPass3D;
import native3d.core.Instance3D;
import native3d.core.Node3D;
import native3d.core.Rect2D;

/**
 * ...
 * @author lizhi
 */
class Rect2DMatchMaterial extends MaterialBase
{
	var texture:TextureBase;

	public function new(texture:TextureBase) 
	{
		super();
		this.texture = texture;
		
	}
	
	inline override public function draw(node:Node3D, pass:BasicPass3D):Void {
		var rect2d:Rect2D = untyped node;
		pass.drawQuadTexture(texture, rect2d.x, rect2d.y, rect2d.width, rect2d.height);
	}
	
}