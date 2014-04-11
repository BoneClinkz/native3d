package native3d.core;
import flash.geom.Vector3D;
import flash.Vector.Vector;

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
	private static var VONE:Vector<Float> = Vector.ofArray([1., 1, 1]);
	private static var TEMP:Vector<Float> = Vector.ofArray([0.0,0,0]);
	public function new() 
	{
		cameraMap = new Map<Camera3D, CullingData>();
	}
	
	public function culling(camera:Camera3D):Bool {
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
			cd.culling = camera.isPointInFrustum(node.worldRawData,node.radius);
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