package lz.native3d.core ;
//{
	import flash.display3D.Context3DCompareMode;
	import flash.display3D.Context3DTriangleFace;
	import flash.display3D.textures.TextureBase;
	import flash.geom.Point;
	import flash.geom.Vector3D;
	import flash.utils.Function;
	import flash.Vector;
	import lz.native2d.Image2D;
	import lz.native2d.Layer2D;
	import lz.native3d.materials.MaterialBase;
	import lz.native3d.materials.TwoDBatchMaterial;
	/**
	 * ...
	 * @author lizhi http://matrix3d.github.io/
	 */
	 class BasicPass3D 
	{
		var pass2d:BasicPass3D;
		var root2d:Node3D;
		var layer:Layer2D;
		var image2d:Image2D;
		var doTransform:BasicDoTransform3D;
		public var nodes:Vector<Node3D>;
		public var cnodes:Vector<Node3D>;
		public var camera:Camera3D;
		public var material:MaterialBase;
		public var i3d:Instance3D;
		public var rootIndex:Int = 0;
		public var clear:Bool = true;
		public var present:Bool = true;
		public var customDraw:Function;
		public function new(i3d:Instance3D) 
		{
			this.i3d = i3d;
			camera = i3d.camera;
		}
		
		public function pass(nodes:Vector<Node3D>):Void {
			this.nodes = nodes;
			if (clear) i3d.c3d.clear(0, 0, 0, 0);
			if (customDraw==null) {
				drawScene();
			}else {
				customDraw();
			}
			if(present)i3d.c3d.present();
		}
		
		public function drawScene():Void {
			for(i in 0...nodes.length) {
				var node:Node3D = nodes[i];
				doPass(node);
			}
		}
		
		public function drawQuadTexture(texture:TextureBase, x:Float, y:Float, width:Float, height:Float,colorMul:Array<Float>=null):Void {
			if(pass2d==null){
				pass2d = new BasicPass3D(i3d);
				pass2d.camera = new Camera3D(i3d.width, i3d.height, i3d, true);
				root2d = new Node3D();
				layer = new Layer2D(true, texture, i3d);
				root2d.add(layer);
				image2d = new Image2D(texture, new Point(width, height));
				layer.add(image2d);
				doTransform = new BasicDoTransform3D();
			}
			image2d.setScale(width, -height);
			image2d.texture = texture;
			layer.material= new TwoDBatchMaterial(texture, i3d,colorMul);
			image2d.x = x + width / 2;
			image2d.y = y + height / 2;
			pass2d.camera.resize(i3d.width, i3d.height);
			doTransform.doTransformCamera(pass2d.camera);
			doTransform.doTransform(root2d.children);
			pass2d.nodes = doTransform.passNodes;
			pass2d.drawScene();
		}
		
		inline public function doPass(node:Node3D):Void {
			var m = material;
			if (m == null) m = node.material;
			if (camera.frustumPlanes == null || node.frustumCulling == null || node.frustumCulling.culling(camera)) {
				i3d.drawCounter++;
				if(node.drawable.indexBufferSet!=null)
				i3d.drawTriangleCounter += node.drawable.indexBufferSet.num;
				m.draw(node,this);
			}
		}
	}

//}