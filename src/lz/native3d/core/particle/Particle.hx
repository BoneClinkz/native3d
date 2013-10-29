package lz.native3d.core.particle;
import flash.geom.Vector3D;

/**
 * ...
 * @author lizhi http://matrix3d.github.io/
 */
class Particle extends Vector3D
{
	public var indexs:Array<UInt>;
	public var color:Vector3D;
	public var a:Vector3D;
	public var v:Vector3D;
	public var colorA:Vector3D;
	public var scaleA:Vector3D;
	public var power:Float;
	public function new(x:Float=0,y:Float=0,z:Float=0,w:Float=1) 
	{
		super(x, y, z, w);
		indexs = new Array<UInt>();
		color = new Vector3D(1, 1, 1, 1);
	}
	
	public function update():Void {
		
	}
	
}