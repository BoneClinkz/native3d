package native3d.meshs ;
//{
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	import flash.Vector;
	import native3d.core.animation.Skin;
	import native3d.core.Drawable3D;
	import native3d.core.Instance3D;
	import native3d.core.Vertex;
	//import native3d.ns.native3d;
	import native3d.core.IndexBufferSet;
	import native3d.core.Node3D;
	import native3d.core.VertexBufferSet;
	//use namespace native3d;
	/**
	 * ...
	 * @author lizhi http://matrix3d.github.io/
	 */
	class MeshUtils 
	{
		
		public function new() 
		{
			
		}
		public static function createCube(r:Float,back:Bool=false):Drawable3D
		{
			var drawable:Drawable3D = new Drawable3D();
			var vin:Vector<Float> = Vector.ofArray( [
			// top
				r, r, r,  -r, r, -r,  r, r, -r, 
				r, r, r,  -r, r, r,  -r, r, -r, 
				// bottom
				-r, -r, -r,  r, -r, r,  r, -r, -r, 
				-r, -r, r,  r, -r, r,  -r, -r, -r, 
				// back
				r, -r, r,  -r, r, r,  r, r, r, 
				-r, r, r,  r, -r, r,  -r, -r, r, 
				// front
				-r, r, -r,  -r, -r, -r,  r, r, -r, 
				-r, -r, -r,  r, -r, -r,  r, r, -r, 
				// left
				-r, -r, -r,  -r, r, r,  -r, -r, r, 
				-r, r, r,  -r, -r, -r,  -r, r, -r, 
				// right
				r, -r, r,  r, r, r,  r, r, -r, 
				r, r, -r,  r, -r, -r,  r, -r, r
			
			] );
			var uv:Vector<Float> = Vector.ofArray( [
			// top
				 1., 0.,  0., 1.,    1., 1.,
				 1., 0., - 0., 0.,    0., 1.,
				// bottom
				 0., 0.,    1., 1.,    1., 0.,
				   0., 1.,    1., 1.,  0., 0.,
				// back
				   0., 1., - 1., 0.,  0., 0.,
				- 1., 0.,    0., 1.,    1., 1.,
				// front
				   0., 0.,  0., 1.,    1., 0.,
				 0., 1.,    1., 1.,    1., 0.,
				// left
				 1., 1., - 0., 0.,    0., 1.,
				- 0., 0.,  1., 1.,    1., 0.,
				// right
				   1., 1.,  1., 0.,    0., 0.,
				   0., 0.,    0., 1.,    1., 1.
			
			] );
			
			var ilen = Std.int(vin.length / 3);
			var indexs = new Vector<UInt>();
			if (back) {
				ilen = Std.int(ilen/3 );
				for (i in 0...ilen) {
					indexs[i*3] = i*3;
					indexs[i*3+1] = i*3+2;
					indexs[i*3+2] = i*3+1;
				}
			}else{
				for (i in 0...ilen) {
					indexs[i] = i;
				}
			}
			drawable.xyz = new VertexBufferSet(untyped(vin.length / 3), 3, vin, 0);
			drawable.uv = new VertexBufferSet(untyped(uv.length / 2), 2, uv, 0);
			drawable.indexBufferSet = new IndexBufferSet(indexs.length, indexs, 0);
			computeNorm(drawable);
			drawable.radius = Math.sqrt(r*r+r*r+r*r);
			return drawable;
		}
		
		public static function createPlane(r:Float):Drawable3D
		{
			var drawable:Drawable3D = new Drawable3D();
			var vin:Vector<Float> = #if flash Vector.ofArray( #end [-r, -r, 0, r, -r, 0, -r, r, 0, r, r, 0] #if flash ) #end ;
			var uv:Vector<Float> = #if flash Vector.ofArray( #end [0.0, 1, 1, 1, 0, 0, 1, 0] #if flash ) #end ;
			var arr:Array<#if flash UInt #else Int #end>=[
			0, 1, 2, 1, 3, 2];
			var indexs = #if flash Vector.ofArray( #end arr #if flash ) #end ;
			drawable.xyz = new VertexBufferSet(untyped(vin.length / 3), 3, vin, 0);
			drawable.uv = new VertexBufferSet(untyped(uv.length / 2), 2, uv, 0);
			drawable.indexBufferSet = new IndexBufferSet(indexs.length, indexs, 0);
			computeNorm(drawable);
			drawable.radius = Math.sqrt(r*r+r*r);
			return drawable;
		}
		
		public static function computeRadius(drawable:Drawable3D):Void {
			var len = drawable.indexBufferSet.data.length;
			var xyz = drawable.xyz.data;
			var mr = .0;
			var i = 0;
			while(i<len)
			{
				var i3=drawable.indexBufferSet.data[i] * 3;
				var x = xyz[i3];
				var y = xyz[i3+1];
				var z = xyz[i3+2];
				var r = x * x + y * y + z * z;
				if (r>mr) {
					mr = r;
				}
				i ++;
			}
			drawable.radius=Math.sqrt(mr);
		}
		public static function computeNorm(drawable:Drawable3D):Void
		{
			var normVs:Vector<Vector<Vector3D>> = new Vector<Vector<Vector3D>>();
			for (i in 0...untyped(drawable.xyz.data.length/3)) {
				normVs.push(new Vector<Vector3D>());
			}
			var norm:Vector<Float> = new Vector<Float>(drawable.xyz.data.length);
			var vin:Vector<Float> = drawable.xyz.data;
			var i:Int = 0;
			var len:Int =Std.int(drawable.indexBufferSet.data.length/3)*3;
			while(i<len)
			{
				var i0:Int = drawable.indexBufferSet.data[i] * 3;
				var i1:Int = drawable.indexBufferSet.data[i + 1] * 3;
				var i2:Int = drawable.indexBufferSet.data[i + 2] * 3;
				var v1:Vector3D = new Vector3D(vin[i0] - vin[i1], vin[i0 + 1] - vin[i1 + 1], vin[i0 + 2] - vin[i1 + 2]);
				var v2:Vector3D = new Vector3D(vin[i2] - vin[i1], vin[i2 + 1] - vin[i1 + 1], vin[i2 + 2] - vin[i1 + 2]);
				var normv:Vector3D = v1.crossProduct(v2);
				normVs[drawable.indexBufferSet.data[i]].push(normv);
				normVs[drawable.indexBufferSet.data[i+1]].push(normv);
				normVs[drawable.indexBufferSet.data[i+2]].push(normv);
				i += 3;
			}
			for (i in 0...normVs.length) {
				var normv:Vector3D = new Vector3D();
				var vs:Vector<Vector3D> = normVs[i];
				for (v in vs) {
					normv.x += v.x;
					normv.y += v.y;
					normv.z += v.z;
				}
				normv.normalize();
				norm[i * 3] = normv.x;
				norm[i * 3+1] = normv.y;
				norm[i * 3+2] = normv.z;
			}
			drawable.norm = new VertexBufferSet(Std.int(norm.length / 3), 3, norm, 0);
		}
		
		public static function mergePosUV(skin:Skin, uvIndexss:Vector<Vector<Int>>, uvs:Vector<Float>):Void {
			var newIndexss = [];
			var newVers = [];
			var map = new Map<String,Int>();
			for (i in 0...skin.indexss.length) {
				var indexs = skin.indexss[i];
				var uvIndexs = uvIndexss[i];
				var newIndexs = [];
				newIndexss.push(newIndexs);
				for (j in 0...indexs.length) {
					var index = indexs[j];
					var uvIndex = uvIndexs[j];
					var id = index + "," + uvIndex;
					var nowI;
					if (!map.exists(id)) {
						nowI = newVers.length;
						map.set(id, newVers.length);
						var ver = new Vertex();
						newVers.push(ver);
						var oldVer = skin.vertexs[index];
						ver.pos = oldVer.pos;
						ver.weights = oldVer.weights;
						ver.norm = oldVer.norm;
						ver.uv = new Vector3D(uvs[uvIndex*2],uvs[uvIndex*2+1]);
					}else {
						nowI = map.get(id);
					}
					newIndexs.push(nowI);
				}
			}
			skin.indexss = newIndexss;
			skin.vertexs = newVers;
		}
		
	}

//}