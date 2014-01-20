package collision;

/**
 * ...
 * @author lizhi
 */
class Raycast
{
	var gridWidth:Int;
	var gridHeight:Int;
	var dx:Float;
	var dy:Float;
	var flag:Bool;
	var ix0:Int;
	var iy0:Int;
	var ix1:Int;
	var iy1:Int;
	var ny:Float;
	var ndy:Float;
	var iny:Int;
	var id:Int;
	var x0:Float;
	var y0:Float;
	var x1:Float;
	var y1:Float;
	var idmap:Map<Int,Bool>;
	var filter:Box;
	public var world:World;
	public var castboxs:Array<Box>;
	public function new() 
	{
		
	}
	
	public function raycast(x0:Float, y0:Float, x1:Float, y1:Float,filter:Box=null):Void {
		this.filter = filter;
		castboxs = [];
		idmap = new Map<Int,Bool>();
		this.y1 = y1;
		this.x1 = x1;
		this.y0 = y0;
		this.x0 = x0;
		gridWidth = world.gridWidth;
		gridHeight = world.gridHeight;
		dx = x1 - x0;
		dy = y1 - y0;
		var temp;
		flag = true;
		if (Math.abs(dx) < Math.abs(dy)) {
			temp = dx;
			dx = dy;
			dy = temp;
			temp = x0;
			x0 = y0;
			y0 = temp;
			temp = x1;
			x1 = y1;
			y1 = temp;
			flag = false;
		}
		ix0 = Std.int(x0 / gridWidth);
		iy0 = Std.int(y0 / gridHeight);
		ix1 = Std.int(x1 / gridWidth);
		iy1 = Std.int(y1 / gridHeight);
		
		var temp2;
		if (ix1 < ix0) {
			temp2 = ix0;
			ix0 = ix1;
			ix1 = temp2;
		}
		var c = (ix0 * gridWidth - x0) / dx;
		ny = y0 / gridHeight + dy * c / gridHeight;
		ndy = dy / dx ;
		for (i in ix0...ix1+1 ) {
			iny = Std.int(ny);
			if (flag) {
				id = iny * 10000 + i;
			}else {
				id = i * 10000 + iny;
			}
			raycastCell();
			ny += ndy;
			var iny2 = Std.int(ny);
			if (iny2 != iny) {
				iny = iny2;
				if (flag) {
					id = iny * 10000 + i;
				}else {
					id = i * 10000 + iny;
				}
				raycastCell();
			}
		}
		castboxs.sort(sortByDistance);
	}
	
	private function sortByDistance(a:Box, b:Box):Int {
		return (Math.abs(a.x - x0) + Math.abs(a.y - y0)) > (Math.abs(b.x - x0) + Math.abs(b.y - y0))?1: -1;
	}
	
	inline private function raycastCell():Void {
		var dbs = world.dynamicGrid.get(id);
		var sbs = world.staticGrid.get(id);
		var bs=null;
		if (dbs!=null) {
			bs = dbs;
			if (sbs!=null) {
				bs = bs.concat(sbs);
			}
		}else if (sbs != null) {
			bs = sbs;
		}
		if (bs!=null) {
			for (box in bs) {
				if (!idmap.exists(box.id)) {
					idmap.set(box.id, true);
					if(filter==null||filter.maskAble(box)){
						if(!((x0<box.aabb.left&&x1<box.aabb.left)||(x0>box.aabb.right&&x1>box.aabb.right))&&!((y0<box.aabb.top&&y1<box.aabb.top)||(y0>box.aabb.bottom&&y1>box.aabb.bottom))){
							if (flag) {//dx>dy ndy=dy/dx
								var cdx0 = box.aabb.left-x0;
								var cdx1 = box.aabb.right - x0;
								var cy0 = y0 + cdx0 * ndy;
								var cy1 = y0 + cdx1 * ndy;
								if (!((cy0<box.aabb.top&&cy1<box.aabb.top)||(cy0>box.aabb.bottom&&cy1>box.aabb.bottom))) {
									castboxs.push(box);
								}
							}else {
								var cdy0 = box.aabb.top-y0;
								var cdy1 = box.aabb.bottom - y0;
								var cx0 = x0 + cdy0 * ndy;
								var cx1 = x0 + cdy1 * ndy;
								if (!((cx0<box.aabb.left&&cx1<box.aabb.left)||(cx0>box.aabb.right&&cx1>box.aabb.right))) {
									castboxs.push(box);
								}
							}
						}
					}
				}
			}
		}
	}
	
}