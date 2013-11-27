package lz.native2d;

/**
 * ...
 * @author lizhi
 */
class SwfMovieClip2D extends Node2D
{
	public var tags:Array<Node2D>;
	public var frames:Array<Array<Array<Int>>>;
	public function new() 
	{
		super();
		tags = new Array<Node2D>();
		frames = new Array<Array<Array<Int>>>();
	}
	
}