package ;
import flash.display.Sprite;
import flash.Lib;
import lz.collision.*;

class TestSpeed extends Sprite
{
	public var box:Box;
	
	public function new() 
	{
		super();
		
		var world = new World();
		var box = new Box(0, 0, 0, 0);
		
		// case #1 : dynamic function declare in loop
		
		var t = flash.Lib.getTimer();
		for (i in 0...10000) 
		{
			box.collidablePairs.sort(function(x:CollidablePair, y:CollidablePair):Int 
			{
				return x.timeToCollision < y.timeToCollision?1: -1; 
			});
		}
		
		trace(flash.Lib.getTimer()-t);
		
		// test #2 : call private function
		
		t = flash.Lib.getTimer();
		
		for (i in 0...10000) 
		{
			box.collidablePairs.sort(sortFunc);
		}
		
		trace(flash.Lib.getTimer()-t);
	}

	private function sortFunc(x:CollidablePair, y:CollidablePair):Int 
	{
		return x.timeToCollision < y.timeToCollision?1: -1; 
	}

	public static function main() 
	{
		Lib.current.addChild(new TestSpeed());
	}
}