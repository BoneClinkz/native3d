package native3d.core;
import flash.geom.Vector3D;

/**
 * ...
 * @author lizhi http://matrix3d.github.io/
 */
class FrustumCulling
{
	public var cameraMap:Map<Camera3D,CullingData>;
	public var node:Node3D;
	public var nodeVersion:Int = -100;
	private var help:Bool;
	private static var VONE:Vector3D = new Vector3D(1, 1, 1, 1);
	public function new() 
	{
		cameraMap = new Map<Camera3D, CullingData>();
	}
	
	public function culling(camera:Camera3D):Bool { //return true;
		help = false;
		var cd:CullingData = cameraMap.get(camera);
		if (cd == null) {
			cd = new CullingData();
			cameraMap.set(camera, cd);
		}
		if (cd.version!=camera.invertVersion) {
			cd.version = camera.invertVersion;
			help = true;
		}
		if (nodeVersion!=node.worldVersion) {
			nodeVersion = node.worldVersion;
			help = true;
		}
		if (help) {
			var temp = node.worldMatrix.transformVector(VONE);
			temp.x -= node.worldRawData[12];
			temp.y -= node.worldRawData[13];
			temp.z -= node.worldRawData[14];
			if (temp.x < 0) temp.x *= -1;
			if (temp.y < 0) temp.y *= -1;
			if (temp.z < 0) temp.z *= -1;
			var max = temp.x;
			if (max < temp.y) max = temp.y;
			if (max < temp.z) max = temp.z;
			cd.culling = camera.isPointInFrustum(node.worldRawData,max*node.drawable.radius);
		}
		return cd.culling;
	}
	
}
class CullingData {
	public var culling:Bool = true;
	public var version:Int = -100;
	public function new() {
		
	}
}