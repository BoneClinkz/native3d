package lz.native3d.core ;
//{
	import flash.display3D.Context3DCompareMode;
	import flash.display3D.Context3DTriangleFace;
	import flash.display3D.textures.TextureBase;
	import flash.geom.Vector3D;
	import flash.Vector;
	import lz.native3d.materials.MaterialBase;
	/**
	 * ...
	 * @author lizhi http://matrix3d.github.io/
	 */
	 class BasicPass3D 
	{
		public var target:PassTarget;
		public var cnodes:Vector<Node3D>;
		public var camera:Camera3D;
		public var material:MaterialBase;
		public var i3d:Instance3D;
		public var rootIndex:Int = 0;
		public var clear:Bool = true;
		public var present:Bool = true;
		public function new(i3d:Instance3D) 
		{
			this.i3d = i3d;
			camera = i3d.camera;
		}
		
		public function pass(nodes:Vector<Node3D>):Void {
			if(clear)i3d.c3d.clear(0, 0, 0, 0);
			if (target!=null) {
				target.pass(this, nodes);
			}else{
				for(i in 0...nodes.length) {
					var node:Node3D = nodes[i];
					doPass(node);
				}
			}
			if(present)i3d.c3d.present();
		}
		
		inline public function doPass(node:Node3D):Void {
			var m = material;
			if (m == null) m = node.material;
			if (camera.frustumPlanes==null||node.frustumCulling == null || node.frustumCulling.culling(camera)) {
				m.draw(node,this);
			}
		}
	}

//}