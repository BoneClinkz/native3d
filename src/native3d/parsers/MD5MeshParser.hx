package native3d.parsers;
import flash.geom.Vector3D;
import flash.utils.ByteArray;
import flash.Vector;
import native3d.core.Drawable3D;
import native3d.core.IndexBufferSet;
import native3d.core.Node3D;
import native3d.core.TextureSet;
import native3d.core.VertexBufferSet;
import native3d.materials.PhongMaterial;
import native3d.meshs.MeshUtils;

/**
 * ...
 * @author lizhi
 */
class MD5MeshParser extends AbsParser
{
	public var joints:Array<MD5Joint>;
	public var meshs:Array<MD5Mesh>;
	public function new() 
	{
		super(null);
		joints = [];
		meshs = [];
	}
	
	override public function parser():Void {
		var txt = cast(data, ByteArray).toString();
		txt= ~/\/\/.*/g.replace(txt, "");
		var lines = ~/[\r\n]+/g.split(txt);
		var result;
		var numJoints=0;
		while(lines.length>0) {
			var line = lines.shift();
			if ((result= ~/MD5Version (\d+)/).match(line)) {
			}else if ((result=~/numJoints (\d+)/).match(line)) {
				numJoints = Std.parseInt(result.matched(1));
			}else if ((result =~/numMeshes (\d+)/).match(line)) {
			}else if ((result=~/joints {/).match(line)) {
				for (i in 0...numJoints) {
					line = lines.shift();
					(result = ~/"(.+)"\s+(-?\d+).*\(\s*(\S+)\s+(\S+)\s+(\S+)\s*\).*\(\s*(\S+)\s+(\S+)\s+(\S+)\s*\)/).match(line);
					var joint:MD5Joint = new MD5Joint();
					joint.name = result.matched(1);
					joint.parent = Std.parseInt(result.matched(2));
					joint.pos = new Vector3D(Std.parseFloat(result.matched(3)), Std.parseFloat(result.matched(4)), Std.parseFloat(result.matched(5)));
					joint.quat = new Vector3D(Std.parseFloat(result.matched(6)), Std.parseFloat(result.matched(7)), Std.parseFloat(result.matched(8)));
					Quat.computeW(joint.quat);
					joints.push(joint);
				}
			}else if ((result =~/mesh {/).match(line)) {
				var mesh:MD5Mesh = new MD5Mesh();
				meshs.push(mesh);
				while (lines.length>0) {
					line = lines.shift();
					if (line.charAt(0) == "}") break;
					if ((result =~/shader\s+"(.+)"/).match(line)) {
						mesh.shader = result.matched(1);
					}else if ((result =~/numverts (\d+)/).match(line)) {
					}else if ((result =~/numtris (\d+)/).match(line)) {
					}else if ((result =~/numweights (\d+)/).match(line)) {
					}else if ((result =~/vert\s+(\d+)\s*\(\s*(\S+)\s+(\S+)\s*\)\s+(\d+)\s+(\d+)/).match(line)) {
						var  vert:MD5Vertex = new MD5Vertex();
						vert.uv = new Vector3D(Std.parseFloat(result.matched(2)), 1-Std.parseFloat(result.matched(3)));
						vert.start = Std.parseInt(result.matched(4));
						vert.count = Std.parseInt(result.matched(5));
						mesh.vs2[Std.parseInt(result.matched(1))] = vert;
					}else if ((result =~/vert\s+(\d+)\s*\(\s*(\S+)\s+(\S+)\s*\)\s+(\S+)\s+(\S+)\s+(\S+)/).match(line)) {
						mesh.vs[Std.parseInt(result.matched(1))] = [Std.parseFloat(result.matched(2)), 1 - Std.parseFloat(result.matched(3)), Std.parseFloat(result.matched(4)), Std.parseFloat(result.matched(5)), Std.parseFloat(result.matched(6))];
					}else if ((result =~/tri\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)/).match(line)) {
						mesh.ins[Std.parseInt(result.matched(1))] = [Std.parseInt(result.matched(2)), Std.parseInt(result.matched(3)), Std.parseInt(result.matched(4)) ];
					}else if ((result =~/weight\s+(\d+)\s+(\d+)\s+(\S+)\s*\(\s*(\S+)\s+(\S+)\s+(\S+)\s*\)/).match(line)) {
						var weight:MD5Weight = new MD5Weight();
						weight.joint = Std.parseInt(result.matched(2));
						weight.bias = Std.parseFloat(result.matched(3));
						weight.pos = new Vector3D(Std.parseFloat(result.matched(4)),Std.parseFloat(result.matched(5)),Std.parseFloat(result.matched(6)));
						mesh.weights[Std.parseInt(result.matched(1))] = weight;
					}
				}
			}
		}
		
		prepareMesh();
		createNode3D();
	}
	
	private function prepareMesh():Void {
		for (mesh in meshs) {
			for ( i in 0...mesh.vs2.length) {
				var vert:MD5Vertex = mesh.vs2[i];
				if(vert!=null){
					var fvert:Vector3D = new Vector3D();
					for (j in 0...vert.count) {
						var weight:MD5Weight = mesh.weights[vert.start + j];
						var joint:MD5Joint = joints[weight.joint];
						var pvert:Vector3D = Quat.rotatePoint(joint.quat, weight.pos);
						pvert = pvert.add(joint.pos);
						pvert.scaleBy(weight.bias);
						fvert = fvert.add(pvert);
					}
					mesh.vs[i] = [vert.uv.x, vert.uv.y, fvert.x, fvert.y, fvert.z];
				}
			}
		}
	}
	
	private function createNode3D():Void {
		var vsCounter:Int = 0;
		var xyz:Array<Float> = [];
		var uv:Array<Float> = [];
		var ins:Array<UInt> = [];
		for (mesh in meshs) {
			for (v in mesh.vs) {
				xyz.push(v[2]);
				xyz.push(v[3]);
				xyz.push(v[4]);
				uv.push(v[0]);
				uv.push(v[1]);
			}
			for (i in mesh.ins) {
				ins.push(i[0]+vsCounter);
				ins.push(i[1]+vsCounter);
				ins.push(i[2]+vsCounter);
			}
			vsCounter += mesh.vs.length;
		}
		
		var node = new Node3D();
		var drawable:Drawable3D = new Drawable3D();
		drawable.indexBufferSet = new IndexBufferSet(ins.length, Vector.ofArray(ins), 0);
		drawable.xyz = new VertexBufferSet(Std.int(xyz.length/3), 3, Vector.ofArray(xyz), 0);
		drawable.uv = new VertexBufferSet(Std.int(uv.length/2), 2, Vector.ofArray(uv), 0);
		MeshUtils.computeNorm(drawable);
		MeshUtils.computeRadius(drawable);
		node.drawable = drawable;
		node.setRotation(-90,180, 0);
		node.material = 
		new PhongMaterial(
			[.2, .2, .2],//AmbientColor
			[.5,.5,.5],//DiffuseColor
			[.8,.8,.8],//SpecularColor
			200,
			TextureSet.getTempTexture()
			);
		this.node.add(node);
	}
}

class MD5Joint {
	public var name:String;
	public var parent:Int;
	public var pos:Vector3D;
	public var quat:Vector3D;
	public function new() {}
}
class MD5Weight {
	public var joint:Int;
	public var bias:Float;
	public var pos:Vector3D;
	public function new() {}
}

class MD5Vertex {
	public var uv:Vector3D;
	public var start:Int;
	public var count:Int;
	public function new() {}
}

class Quat {
	public static function computeW (q:Vector3D):Void{
		var t:Float = 1 - q.x * q.x - q.y * q.y - q.z * q.z;
		q.w = t < 0?0: -Math.sqrt(t);
	}
	
	public static function rotatePoint(quat:Vector3D,vector:Vector3D):Vector3D {
		var t:Vector3D = cross(quat, vector);
		t.scaleBy(2);
		var t2:Vector3D = t.clone();
		t2.scaleBy(quat.w);
		return vector.add(t2).add(cross(quat,t));
	}
	
	private static function cross(v1:Vector3D, v2:Vector3D):Vector3D {
		return new Vector3D(
		v1.y * v2.z - v1.z * v2.y,
		v1.z * v2.x - v1.x * v2.z,
		v1.x * v2.y - v1.y * v2.x
		);
	}
}

class MD5Mesh {
	public var vs:Array<Array<Float>>;
	public var vs2:Array<MD5Vertex>;
	public var ins:Array<Array<UInt>>;
	public var weights:Array<MD5Weight>;
	public var shader:String;
	public function new() {
		vs = [];
		vs2 = [];
		ins = [];
		weights = [];
	}
}