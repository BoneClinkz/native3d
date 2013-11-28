package lz.native2d;

/**
 * ...
 * @author lizhi
 */
class SwfMovieClip2D extends Node2D
{
	public var tags:Array<Node2D>;
	public var frames:Array<Array<Array<Int>>>;
	public var frameChanged:Bool = true;
	public var playing:Bool = true;
	public function new() 
	{
		super();
		tags = new Array<Node2D>();
		frames = new Array<Array<Array<Int>>>();
	}
	
	public function stop():Void {
		playing = false;
	}
	
	public function play():Void {
		playing = true;
	}
	
	public function gotoAndStop(frame:Int):Void {
		this.frame = frame;
		frameChanged = true;
		stop();
	}
	
	public function gotoAndPlay(frame:Int):Void {
		this.frame = frame;
		frameChanged = true;
		play();
	}
	
	public function update():Void {
		if(frameChanged){
			children.length = 0;
			var cframe = frame % frames.length;
			for (obj in frames[cframe]) {
				var dis = tags[obj[0]];
				var tdis = tags[obj[1]];
				if (dis!=null) {
					if (obj[1]>0) {
						dis.matrix = tdis.matrix;
						dis.matrixVersion++;
					}
					add(dis);
				}
			}
			frameChanged = false;
		}
		if(playing){
			frame++;
			frameChanged = true;
		}
	}
	
	public function getSwfChildByName(name:String):Node2D {
		for (c in tags) {
			if (c.name==name) {
				return c;
			}
		}
		return null;
	}
	
}