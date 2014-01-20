package native2d;

/**
 * ...
 * @author lizhi
 */
class UV2D
{
	public var left:Float;
	public var right:Float;
	public var top:Float;
	public var bottom:Float;
	public function new(left:Float,right:Float,top:Float,bottom:Float) 
	{
		this.left = left;
		this.right = right;
		this.top = top;
		this.bottom = bottom;
	}
	
	public static function fromXYWH(x:Int,y:Int,w:Int,h:Int,imageW:Int,imageH:Int):UV2D {
		return new UV2D(x / imageW, (x + w) / imageW, y / imageH, (y + h) / imageH);
	}
	
}