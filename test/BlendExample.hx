package ;
import flash.events.Event;
import flash.geom.Matrix3D;
import flash.geom.Vector3D;
import flash.Lib;
import flash.utils.CompressionAlgorithm;
import flash.utils.Endian;
import flash.Vector;
import lz.native3d.utils.BasicTest;
import lz.native3d.core.Drawable3D;
import lz.native3d.core.IndexBufferSet;
import lz.native3d.core.Node3D;
import lz.native3d.core.VertexBufferSet;
import lz.native3d.materials.PhongMaterial;
import lz.native3d.meshs.MeshUtils;
import lz.net.LoaderCell;

/**
 * ...
 * @author lizhi
 */
class BlendExample extends BasicTest
{
	var loader:LoaderCell;

	public function new() 
	{
		super();
	}
	
	override public function initScene():Void {
		loader = LoaderCell.createBytesLoader("../assets/model/threecubes.blend.bin", null);
		loader.addEventListener(Event.COMPLETE, loader_complete);
		loader.start();
	}
	
	private function loader_complete(e:Event):Void 
	{
		var byte= loader.getBytes();
		byte.endian = Endian.LITTLE_ENDIAN;
		byte.uncompress(CompressionAlgorithm.LZMA);
		var blenderObj = byte.readObject();
		
		var blenderScene = new Node3D();
		root3d.add(blenderScene);
		for (obj in cast(blenderObj,Array<Dynamic>)) {
			var matrix:Matrix3D = new Matrix3D(Vector.ofArray(obj.obmat));// (obj.obmat);
			var node:Node3D= buildMesh(obj, matrix);
			if (obj.index) {
				/*if (image2objs[obj.image]==null) {
					image2objs[obj.image] = [];
					var image:String = obj.image;
					var jpg:String = image.replace(".png", ".jpg");
					var url:String = "../assets/model/btamap01_texture/" + jpg;
					var loader:LoaderCell = LoaderCell.createImageLoader(url, null, image);
					loader.userData = image;
					loader.addEventListener(Event.COMPLETE, loader_complete);
					loader.start();
				}*/
				if (obj.name=="OBcol_douro") {
					//initBullet(node);
				}else{
					blenderScene.add(node);
				}
				//image2objs[obj.image].push(node);
			}
		}
		//blenderScene.setScale(1000, 1000, 1000);
		ctrl.position.z = -20;
		ctrl.speed = 5;
	}
	
	private function buildMesh(obj:Dynamic, matrix:Matrix3D):Node3D {
		var n = new Node3D();
		if(obj.index){
			var material = 
			new PhongMaterial(
				[.2, .2, .2],//AmbientColor
				[Math.random()/2+.5,Math.random()/2+.5,Math.random()/2+.5],//DiffuseColor
				[.8,.8,.8],//SpecularColor
				200
				);
				
			var xyz = obj.xyz;
			var uvs = obj.uv;
			var index = obj.index;
			if (xyz==null) {
				return null;
			}
			var drawable = new Drawable3D();
			drawable.xyz = new VertexBufferSet(Std.int(xyz.length / 3), 3,untyped xyz, 0);
			drawable.uv = new VertexBufferSet(Std.int(uvs.length / 2), 2,untyped uvs, 0);
			drawable.indexBufferSet = new IndexBufferSet(index.length,untyped index, 0);
			MeshUtils.computeNorm(drawable);
			MeshUtils.computeRadius(drawable);
			n.drawable = drawable;
			n.material=material;
			
			n.matrix = matrix;
			n.matrixVersion++;
		}
		return n;
	}
	
	public static function main() {
		Lib.current.addChild(new BlendExample());
	}
	
}