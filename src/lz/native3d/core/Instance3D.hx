package lz.native3d.core ;
//{
	import flash.display3D.Context3D;
	import flash.display3D.Context3DTriangleFace;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.Vector;
	/**
	 * ...
	 * @author lizhi http://matrix3d.github.io/
	 */
	class Instance3D extends EventDispatcher
	{
		var nodess:Vector<Vector<Node3D>>;
		public static var _instances:Vector<Instance3D>=new Vector<Instance3D>();
		public var c3d:Context3D;
		public var drawCounter:Int = 0;
		public var drawTriangleCounter:Int = 0;
		public var root:Node3D;// = new Node3D();
		public var roots:Vector<Node3D>;
		public var camera:Camera3D;// = new Camera3D();
		public var doTransform:BasicDoTransform3D;// = new BasicDoTransform3D();
		public var passs:Vector<BasicPass3D>;// = new Vector<BasicPass3D>();
		public var lights:Vector<BasicLight3D>;
		public var width:Int=400;
		public var height:Int = 400;
		public var  antiAlias:Int = 0;
		public function new() 
		{
			super();	
			root = new Node3D();
			camera = new Camera3D(width,height,this);
			 doTransform = new BasicDoTransform3D();
			 passs = new Vector<BasicPass3D>();
			 lights = new Vector<BasicLight3D>();
			 roots = new Vector<Node3D>();
			 roots.push(root);
		}
		 static public function getInstance(i:Int=0):Instance3D
		{
			return _instances[i];
		}
		
		public function init(c3d:Context3D):Void {
			this.c3d = c3d;
			passs.push(new BasicPass3D(this));
			resize(width, height);
			dispatchEvent(new Event(Event.CONTEXT3D_CREATE));
		}
		
		public function render():Void {
			drawCounter = drawTriangleCounter = 0;
			
			nodess = new Vector<Vector<Node3D>>();
			for (r in roots) {
				nodess.push(doTransform.doTransform(r.children));
			}
			
			for (i in 0...passs.length) {
				var pass:BasicPass3D = passs[i];
				var nodes:Vector<Node3D> = nodess[pass.rootIndex];
				if (pass.camera!=null) doTransform.doTransformCamera(pass.camera);
				pass.pass(pass.cnodes!=null?doTransform.doTransform(pass.cnodes):nodes);
			}
		}
		
		public function resize(width:Int, height:Int):Void {
			this.width = width;
			this.height = height;
			if (c3d!=null) {
				c3d.configureBackBuffer(width, height, antiAlias);
				for (i in 0...passs.length) {
					var pass:BasicPass3D = passs[i];
					if (pass.camera != null) {
						pass.camera.resize(width, height);
					}
				}
				camera.resize(width, height);
			}
		}
		
	}

//}