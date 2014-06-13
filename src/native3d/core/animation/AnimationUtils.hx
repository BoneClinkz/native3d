package native3d.core.animation;
import flash.display3D.Context3DVertexBufferFormat;
import flash.geom.Matrix3D;
import flash.geom.Orientation3D;
import flash.geom.Vector3D;
import flash.utils.ByteArray;
import flash.utils.Endian;
import flash.Vector;
import native3d.core.BasicLight3D;
import native3d.core.ByteArraySet;
import native3d.core.Drawable3D;
import native3d.core.IndexBufferSet;
import native3d.core.Instance3D;
import native3d.core.Node3D;
import native3d.core.VertexBufferSet;
import native3d.materials.PhongMaterial;
import native3d.meshs.MeshUtils;

/**
 * ...
 * @author lizhi http://matrix3d.github.io/
 */
class AnimationUtils
{
	public static var maxMatrixJoint:Int = 37;
	public static var maxQuatJoint:Int = 55;
	public function new() 
	{
	}
	
	public static function startCache(skin:Skin):Void {
		var useQuas:Bool = skin.useQuas;
		var maxWeightLen0:Int = 0;
		var maxWeightLen1:Int = 0;
		if (skin.maxWeightLen<=4) {
			maxWeightLen0 = skin.maxWeightLen;
		}else {
			maxWeightLen0 = 4;
			maxWeightLen1 = skin.maxWeightLen - 4;
		}
		skin.draws = [];//分解动画
		var indexss =new Array<Array<Int>>();//顶点索引
		var i = 0;
		var maxn = useQuas?maxQuatJoint:maxMatrixJoint;
		while (i < skin.indexss.length) {
			var indexs = skin.indexss[i];
			var mimap = new Map<Int,Bool>();
			var count = 0;
			for (j in i + 1...skin.indexss.length) {//判断下一个skin数据可不可以合并
				var indexs2 = skin.indexss[j];
				for (index in indexs2) {
					for (k in 0...skin.vertexs[index].weights.length) {
						var mi = skin.vertexs[index].weights[k].joint;
						if (mimap.get(mi)==null) {
							mimap.set(mi, true);
							count++;
							if (count>maxn) {
								break;
							}
						}else {
						}
					}
					if (count>maxn) {
						break;
					}
				}
				if (count>maxn) {//骨骼数量 超出范围 跳出
					break;
				}else {//可以合并 合并数据
					indexs = indexs.concat(indexs2);
					i++;
				}
			}
			indexss.push(indexs);
			i++;
		}
		
		
		skin.node.drawable = new Drawable3D();
		skin.node.drawable.indexBufferSet = new IndexBufferSet(0, null,0);
		skin.node.skin = skin;
		skin.node.material = new PhongMaterial([.5,.5,.5],[.5,.5,.5],[.8,.8,.8],
								200,
								skin.texture,
								skin,
								false,
								useQuas
								);
		for (a in 0...indexss.length) {
			var indexs = indexss[a];
			var skinDrawable = new SkinDrawable();
			var newIndexs = new Vector<UInt>(indexs.length);
			var i2newi = new Map<Int,Int>();
			var i2Have= new Map<Int,Bool>();
			var vers = skin.vertexs;
			var newVs  = new Vector<Float>(vers.length);
			var newUVs  = new Vector<Float>(vers.length);
			var newWeights  = new Vector<Float>();
			var newMatrixIndexs  = new Vector<Float>();
			var newWeights2=null;
			var newMatrixIndexs2=null;
			if (skin.maxWeightLen > 4) {
				newWeights2  = new Vector<Float>();
				newMatrixIndexs2  = new Vector<Float>();
			}
			var newi = 0;
			var maxNowi = 0;
			
			var newiM = 0;
			var i2newiM = new Map<Int,Int>();
			skinDrawable.joints = [];
			
			for (i in 0...indexs.length) {
				var oldi = indexs[i];
				var ianduvi = oldi;
				var needAdd = false;
				var nowi = 0;
				if (!i2Have.exists(ianduvi)) {//以前没有存放 这个顶点 设置这个顶点 存放这个点的uv是否为当前uv
					i2Have.set(ianduvi, true);
					i2newi.set(ianduvi, newi);
					maxNowi = Std.int(Math.max(newi, maxNowi));
					newi++;
					needAdd = true;
				}
				
				nowi = i2newi.get(ianduvi);
				newIndexs[i] = nowi;
				if (needAdd) {
					var ver = vers[oldi];
					newVs[nowi * 3] = ver.pos.x;
					newVs[nowi * 3+1] = ver.pos.y;
					newVs[nowi * 3+2] = ver.pos.z;
					newUVs[nowi * 2] = ver.uv.x;
					newUVs[nowi * 2+1] = ver.uv.y;
					for (j in 0...ver.weights.length) {
						var weight = ver.weights[j];
						var mi = weight.joint;
						if (!i2newiM.exists(mi)) {
							i2newiM.set(mi, newiM);
							skinDrawable.joints.push(mi);
							newiM++;
						}
						var nowiM = i2newiM.get(mi);
						if (j<4) {
							var wi = Std.int(nowi * maxWeightLen0 + j);
							if (wi>=newWeights.length) {
								newWeights.length = wi;
								newMatrixIndexs.length = wi;
							}
							newWeights[wi] = weight.bias;
							newMatrixIndexs[wi] = nowiM * (useQuas?1:3) ;
						}else {
							var wi = Std.int(nowi * maxWeightLen1 + j-4);
							if (wi>=newWeights2.length) {
								newWeights2.length = wi;
								newMatrixIndexs2.length = wi;
							}
							newWeights2[wi] = weight.bias;
							newMatrixIndexs2[wi] = nowiM * (useQuas?1:3) ;
						}
					}
				}
			}
			while (skinDrawable.joints.length > maxn) {
				skinDrawable.joints.pop();
				//continue;
			}
			skin.draws.push(skinDrawable);
			
			newVs.length = (maxNowi + 1) * 3;
			newUVs.length = (maxNowi + 1) * 2;
			newWeights.length = newMatrixIndexs.length = (maxNowi + 1) * maxWeightLen0;
			skinDrawable.weightBuff = new VertexBufferSet(Std.int(newWeights.length / maxWeightLen0), Std.int(maxWeightLen0), newWeights, 0);
			skinDrawable.matrixBuff = new VertexBufferSet(Std.int(newWeights.length / maxWeightLen0), Std.int(maxWeightLen0), newMatrixIndexs, 0);
			if(skin.maxWeightLen>4){
				newWeights2.length = newMatrixIndexs2.length = (maxNowi + 1) * maxWeightLen1;
				skinDrawable.weightBuff2 = new VertexBufferSet(Std.int(newWeights2.length / maxWeightLen1), Std.int(maxWeightLen1), newWeights2, 0);
				skinDrawable.matrixBuff2 = new VertexBufferSet(Std.int(newWeights2.length / maxWeightLen1), Std.int(maxWeightLen1), newMatrixIndexs2, 0);
				skinDrawable.weightBuff2.init();
				skinDrawable.matrixBuff2.init();
			}
			skinDrawable.xyz = new VertexBufferSet(Std.int(newVs.length/3), 3, newVs, 0);
			skinDrawable.uv = new VertexBufferSet(Std.int(newUVs.length / 2), 2, newUVs, 0);
			
			skinDrawable.indexBufferSet = new IndexBufferSet(newIndexs.length, newIndexs, 0);
			
			MeshUtils.computeNorm(skinDrawable);
			skinDrawable.xyz.init();
			skinDrawable.uv.init();
			skinDrawable.norm.init();
			skinDrawable.indexBufferSet.init();
			skinDrawable.weightBuff.init();
			skinDrawable.matrixBuff.init();
			MeshUtils.computeRadius(skinDrawable);
			
			if(skin.node.drawable.radius < skinDrawable.radius)
			skin.node.drawable.radius = skinDrawable.radius;
			skin.node.drawable.indexBufferSet.num+=skinDrawable.indexBufferSet.num;
		}
		startCacheStaticAnim(skin);
	}
	
	public static function startCacheStaticAnim(skin:Skin):Void {
		var item:AnimationItem = new AnimationItem();
		item.name = "static";
		item.frames = [[]];
		for (inv in skin.invBindMatrixs) {
			item.frames[0].push(inv);
		}
		startCacheAnim(skin, item,true);
	}
	
	public static function startCacheAnim(skin:Skin, item:AnimationItem,isStatic:Bool=false):Void {
		var useQuas = skin.useQuas;
		for (frame in item.frames) {
			for (i in 0...skin.joints.length) {
				var joint = skin.joints[i];
				joint.matrix.copyFrom(frame[i]); 
				joint.matrixVersion++;
			}
			Instance3D.getInstance().doTransform.doTransformNodes(skin.jointRoot.children, false);//转换矩阵
			var matrixs:Array<Matrix3D> = [];
			item.cacheMatrixs.push(matrixs);
			item.numFrame = item.cacheMatrixs.length;
			for (i in 0...skin.joints.length) {
				var joint = skin.joints[i];
				var matrix:Matrix3D = new Matrix3D();
				if(!isStatic){
					matrix.append(skin.invBindMatrixs[i]);
					matrix.append(joint.worldMatrix);
				}
				matrixs.push(matrix);
			}
			skin.anims.set(item.name, item);
			skin.currentAnim = item;
			
			for (skinDrawable in skin.draws) {
				if(useQuas){
					skinDrawable.cacheQuasBytes = [];
					skinDrawable.cacheQuasTransBytes = [];
					item.cacheQuasBytess.push(skinDrawable.cacheQuasBytes);
					item.cacheQuasTransBytess.push(skinDrawable.cacheQuasTransBytes);
					for (cmatrixs in item.cacheMatrixs) {
						var catchQuasByte = new ByteArray();
						catchQuasByte.endian = Endian.LITTLE_ENDIAN;
						var catchQuasTransByte = new ByteArray();
						catchQuasTransByte.endian = Endian.LITTLE_ENDIAN;
						for (i in 0...skinDrawable.joints.length) {
							var matr:Matrix3D = cmatrixs[skinDrawable.joints[i]];
							var comp= matr.decompose(Orientation3D.QUATERNION);
							var quas = comp[1];
							var tran = comp[0];
							catchQuasByte.writeFloat(quas.x);
							catchQuasByte.writeFloat(quas.y);
							catchQuasByte.writeFloat(quas.z);
							catchQuasByte.writeFloat(quas.w);
							catchQuasTransByte.writeFloat(tran.x);
							catchQuasTransByte.writeFloat(tran.y);
							catchQuasTransByte.writeFloat(tran.z);
							catchQuasTransByte.writeFloat(tran.w);
						}
						catchQuasByte.position = 0;
						catchQuasTransByte.position = 0;
						
						var byteSet = new ByteArraySet();
						skinDrawable.cacheQuasBytes.push(byteSet);
						byteSet.byteArrayOffset = 0;
						byteSet.data = catchQuasByte;
						byteSet.numRegisters = Std.int(byteSet.data.bytesAvailable / 16);
						
						
						var byteSet = new ByteArraySet();
						skinDrawable.cacheQuasTransBytes.push(byteSet);
						byteSet.byteArrayOffset = 0;
						byteSet.data = catchQuasTransByte;
						byteSet.numRegisters = Std.int(byteSet.data.bytesAvailable/16);
					}
				}else {
					skinDrawable.cacheBytes = [];
					item.cacheBytess.push(skinDrawable.cacheBytes);
					var catchVector = new Vector<Float>(16);
					for (cmatrixs in item.cacheMatrixs) {
						var catchByte = new ByteArray();
						catchByte.endian = Endian.LITTLE_ENDIAN;
						for (i in 0...skinDrawable.joints.length) {
							cmatrixs[skinDrawable.joints[i]].copyRawDataTo(catchVector,0, true);
							for (j in 0...12) {
								catchByte.writeFloat(catchVector[j]);
							}
						}
						catchByte.position = 0;
						
						var byteSet = new ByteArraySet();
						skinDrawable.cacheBytes.push(byteSet);
						byteSet.byteArrayOffset = 0;
						byteSet.data = catchByte;
						byteSet.numRegisters = Std.int(catchByte.bytesAvailable/16);
					}
				}
			}
		}
	}
}