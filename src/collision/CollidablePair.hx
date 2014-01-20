package collision;

/**
 * ...
 * @author lizhi
 */
class CollidablePair
{
	public var a:Box;
	public var b:Box;
	public var timeToCollision:Float;
	public var collidablePairs:Array<CollidablePair>;
	public function new(a:Box,b:Box) 
	{
		this.b = b;
		this.a = a;
		// todo : calculate the timetocollision value
	}
	
	public function getCollisionBox(box:Box):Box {
		if (a==box) {
			return b;
		}
		return a;
	}
}