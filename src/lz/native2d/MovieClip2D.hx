package lz.native2d;
import flash.display3D.textures.TextureBase;
import flash.geom.Point;
import lz.native3d.core.twoDAnimation.TDSpriteData;
import lz.native3d.core.TwoDData;
import lz.native3d.ctrls.TwoDBatAnmCtrl;

/**
 * ...
 * @author lizhi
 */
class MovieClip2D extends Node2D
{
	public var anmdata:TDSpriteData;
	public var twoD:TwoDData;
	public function new(texture:TextureBase,anmdata:TDSpriteData) 
	{
		super();
		this.anmdata = anmdata;
		
		var image:Image2D = new Image2D(texture, new Point());
		add(image);
		twoD = image.twoDData;
		twoD.anmCtrl = new TwoDBatAnmCtrl();
		twoD.anmCtrl.speed = .4;
		twoD.anmCtrl.data = anmdata;
		twoD.anmCtrl.node3d = image;
	}
}