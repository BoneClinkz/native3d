package lz.native3d.core ;

/**
 * ...
 * @author lizhi http://matrix3d.github.io/
 */
class BasicLight3D extends Node3D
{
	public static var TYPE_DISTANT:Int = 0;
	public static var TYPE_POINT:Int = 1;
	public static var TYPE_SPOT:Int = 2;
	
	public var lightType:Int;
	public var color:Array<Float>;
	public var intensity:Float = 1;
	public var shadowMapEnabled:Bool = false;
	public var innerConeAngle:Float = 3.14 / 6;
	public var outerConeAngle:Float = 3.14 / 3;
	
	public function new(lightType:Int=0) 
	{
		super();
		this.lightType = lightType;
		
	}
	
}

