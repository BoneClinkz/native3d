package native3d.core ;

/**
 * ...
 * @author lizhi http://matrix3d.github.io/
 */
class BasicLight3D extends Node3D
{
	public static var TYPE_AMBIENT:Int = 0;
	public static var TYPE_DISTANT:Int = 1;
	public static var TYPE_POINT:Int = 2;
	public static var TYPE_SPOT:Int = 3;
	
	public var lightType:Int;
	public var color:Array<Float>;
	public var shadowMapEnabled:Bool = false;
	public var shadowMapSize:Int = 1024;
	public var distance:Float = 1000;
	public var innerConeAngle:Float = 3.14 / 6;
	public var outerConeAngle:Float = 3.14 / 3;
	
	public function new(lightType:Int=1) 
	{
		super();
		this.lightType = lightType;
		color = [1,1,1,1];
	}
	
}

