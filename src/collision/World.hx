package collision;
import flash.events.EventDispatcher;
import flash.geom.Point;

/**
 * ...
 * @author lizhi
 */
class World extends EventDispatcher
{
	public var gridWidth:Int = 200;
	public var gridHeight:Int = 200;
	public var collidablePairs:Array<CollidablePair>;
	public var boxs:Array<Box>;
	public var dynamicGrid:Map < Int, Array<Box> > ;
	public var staticGrid:Map < Int, Array<Box> > ;
	public var ray:Raycast;
	public function new() 
	{
		super();
		boxs = [];
		ray = new Raycast();
		ray.world = this;
	}
	
	public function add(box:Box):Void {
		boxs.push(box);
	}
	
	public function remove(box:Box):Void {
		boxs.remove(box);
	}
	
	public function resetDynamicGrid():Void {
		dynamicGrid = resetGrid(boxs, Box.DYNAMIC_TYPE);
	}
	
	public function resetStaticGrid():Void {
		staticGrid = resetGrid(boxs, Box.STATIC_TYPE);
	}
	public function resetGrid(boxs:Array<Box>, type:Int):Dynamic {
		var grid = new Map < Int, Array<Box> > () ;
		
		for (box in boxs) {
			if (box.type == type) {
				var aabb = box.aabb;
				aabb.x = box.x + box.vx-box.hw;
				aabb.y = box.y + box.vy-box.hh;
				aabb.width = box.hw * 2;
				aabb.height = box.hh * 2;
				var x1 = Std.int(aabb.left/gridWidth);
				var x2 = Std.int(aabb.right/gridWidth);
				var y1 = Std.int(aabb.top/gridHeight);
				var y2 = Std.int(aabb.bottom / gridHeight);
				for (x in x1...x2+1) {
					for (y in y1...y2 + 1) {
						var i = (y << 24) | x;
						var bs = grid.get(i);
						if (bs==null) {
							bs = [];
							grid.set(i, bs);
						}
						bs.push(box);
					}
				}
			}
		}
		return grid;
	}
	
	public function hittest():Void {
		resetDynamicGrid();
		for (box in boxs) {
			box.collidablePairs = [];
		}
		collidablePairs = [];
		var pairMap = new Map<Int,Bool>();
		for (i in dynamicGrid.keys()) {
			var dbs = dynamicGrid.get(i);
			var sbs = staticGrid.get(i);
			if (sbs==null) {
				sbs = [];
			}
			var bs = dbs.concat(sbs);
			for (a in 0...bs.length-1) {
				var ba = bs[a];
				for (b in a+1...bs.length) {
					var bb = bs[b];
					if((ba!=bb)&&ba.maskAble(bb)){
						var pid=0;
						if (ba.id<bb.id) {
							pid = (ba.id << 24) | bb.id;
						}else {
							pid = (bb.id << 24) | ba.id;
						}
						if ((!pairMap.exists(pid))&&ba.aabb.intersects(bb.aabb)) {
							var pair = new CollidablePair(ba, bb);
							collidablePairs.push(pair);
							pairMap.set(pid, true);
							ba.collidablePairs.push(pair);
							bb.collidablePairs.push(pair);
						}
					}
				}
			}
		}
		for (box in boxs) {
			if (box.collidablePairs!=null) {
				box.collidablePairs.sort(sortCollidablePairsFunc);
			}
		}
	}
	
	private function sortCollidablePairsFunc(x:CollidablePair, y:CollidablePair):Int {
		return x.timeToCollision < y.timeToCollision?1: -1; 
	} 
}