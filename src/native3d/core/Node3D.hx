package native3d.core ;

	import flash.events.EventDispatcher;
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	import flash.Lib;
	import flash.Vector;
	import native3d.core.animation.Skin;
	import native3d.core.Drawable3D;
	import native3d.materials.MaterialBase;
	import native3d.utils.Color;
	//import native3d.ns.native3d;
	//use namespace native3d;
	/**
	 * ...
	 * @author lizhi http://matrix3d.github.io/
	 */
	 class Node3D extends EventDispatcher
	{
		public var userData:Dynamic;
		private var _mouseEnable:Bool = false;
		public static inline var NODE_TYPE:String = "NODE";
		public static inline var JOINT_TYPE:String = "JOINT";
		public var name:String;
		public var type:String;
		public var castShadow:Bool = false;
		public var radius:Float = 0;
		
		private static var ID:Int = 0;
		public static var NODES:Map<Int,Node3D> = new Map<Int,Node3D>();
		private static var toAngle:Float =  180 / Math.PI;
		private static var toRadian:Float =  Math.PI / 180;
		
		public var id:Int;
		public var idVector:Vector<Float>;
		public var parent:Node3D;
		public var children:Vector<Node3D>;// = new Vector<Node3D>();
		public var skin:Skin;//皮肤
		
		public var playing:Bool = true;
		public var startFrame:Int;
		public var frame:Int;
		//native3d var compChanged:Bool = false;
		//public var matrixChanged:Bool = false;
		public var matrix:Matrix3D ;//= new Matrix3D();
		
		/**@private**/
		public var matrixVersion:Int = -1;
		/**@private**/
		public var comps:Vector<Vector3D>;
		/**@private**/
		public var compsVersion:Int = -1;
		/**@private**/
		public var position:Vector3D;// = comps[0];
		/**@private**/
		public var rotation:Vector3D;// = comps[1];
		/**@private**/
		public var scale:Vector3D;// = comps[2];
		
		public var worldMatrix:Matrix3D;// = new Matrix3D();
		public var worldRawData:Vector<Float>;
		/**@private**/
		public var worldVersion:Int = -123;
		public var drawable:Drawable3D;
		
		private var _material:MaterialBase;
		#if swc @:extern #end 
		public var material(get_material, set_material):MaterialBase;
		
		/**@getter,setter**/
		#if swc @:extern #end 
		public var x(get_x,set_x):Float;
		#if swc @:extern #end 
		public var y(get_y,set_y):Float;
		#if swc @:extern #end 
		public var z(get_z,set_z):Float;
		 #if swc @:extern #end 
		 public var rotationX(get_rotationX,set_rotationX):Float;
		#if swc @:extern #end 
		public var rotationY(get_rotationY,set_rotationY):Float;
		#if swc @:extern #end 
		public var rotationZ(get_rotationZ,set_rotationZ):Float;
		#if swc @:extern #end 
		public var scaleX(get_scaleX,set_scaleX):Float;
		#if swc @:extern #end 
		public var scaleY(get_scaleY,set_scaleY):Float;
		#if swc @:extern #end 
		public var scaleZ(get_scaleZ,set_scaleZ):Float;
		
		public function getMouseEnable():Bool 
		{
			return _mouseEnable;
		}
		
		public function setMouseEnable(value:Bool,depth:Bool):Void 
		{
			_mouseEnable = value;
			if (depth) {
				for (node in children) {
					node.setMouseEnable(value, depth);
				}
			}
		}
		
		 public var frustumCulling:FrustumCulling;
		 
		 public var twoDData:TwoDData;
		public function new() 
	{
		super();
		frame =  0;// Std.random(100000);
		//super();
		id =++ID;
		NODES.set(id, this);
		var rgba = Color.toRGBA(id);
		idVector = new Vector<Float>(4);
		idVector[0] = rgba.x;
		idVector[1] = rgba.y;
		idVector[2] = rgba.z;
		idVector[3] = rgba.w;
		children = new Vector<Node3D>();
		matrix = new Matrix3D();
		comps = matrix.decompose();
		position = comps[0];
		rotation = comps[1];
		scale = comps[2];
		worldMatrix = new Matrix3D();
		worldRawData = worldMatrix.rawData;
		frustumCulling = new FrustumCulling();
		frustumCulling.node = this;
	}
		public function add(node:Node3D):Void
		{
			if (node.parent!=null) {
				node.parent.remove(node);
			}
			children.push(node);
			node.parent = this;
		}
		
		public function remove(node:Node3D):Void {
			node.parent = null;
			for (i in 0...children.length) {
				if (children[i]==node) {
					children.splice(i, 1);
					break;
				}
			}
			/*var i = children.indexOf(node);
			if (i!=-1) {
				children.splice(i, 1);
			}*/
		}
		
		#if swc @:getter(x) #end inline private function get_x():Float 
		{
			decompose();
			return position.x;
		}
		#if swc @:setter(x) #end inline private function set_x(value:Float):Float 
		{
			compsVersion++;
			//compChanged = true;
			return position.x = value;
		}
		
		#if swc @:getter(y) #end inline private function get_y():Float 
		{
			decompose();
			return position.y;
		}
		
		#if swc @:setter(y) #end inline private function set_y(value:Float):Float 
		{
			compsVersion++;
			return position.y = value;
		}
		
		#if swc @:getter(z) #end inline private function get_z():Float 
		{
			decompose();
			return position.z;
		}
		
		#if swc @:setter(z) #end inline private function set_z(value:Float):Float 
		{
			
			compsVersion++;
			return position.z = value;
		}
		
		#if swc @:getter(rotationX) #end inline private function get_rotationX():Float 
		{
			decompose();
			return rotation.x*toAngle;
		}
		
		#if swc @:setter(rotationX) #end inline private function set_rotationX(value:Float):Float 
		{
			
			compsVersion++;
			return rotation.x = value * toRadian;
		}
		
		#if swc @:getter(rotationY) #end inline private function get_rotationY():Float 
		{
			decompose();
			return rotation.y*toAngle;
		}
		
		#if swc @:setter(rotationY) #end inline private function set_rotationY(value:Float):Float 
		{
			
			compsVersion++;
			return rotation.y = value * toRadian;
		}
		
		#if swc @:getter(rotationZ) #end inline private function get_rotationZ():Float 
		{
			decompose();
			return rotation.z*toAngle;
		}
		
		#if swc @:setter(rotationZ) #end inline private function set_rotationZ(value:Float):Float 
		{
			
			compsVersion++;
			return rotation.z = value * toRadian;
		}
		
		#if swc @:getter(scaleX) #end inline private function get_scaleX():Float 
		{
			decompose();
			return scale.x;
		}
		
		#if swc @:setter(scaleX) #end inline private function set_scaleX(value:Float):Float 
		{
			compsVersion++;
			return scale.x = value;
		}
		
		#if swc @:getter(scaleY) #end inline private function get_scaleY():Float 
		{
			decompose();
			return scale.y;
		}
		
		#if swc @:setter(scaleY) #end inline private function set_scaleY(value:Float):Float 
		{
			
			compsVersion++;
			return scale.y = value;
		}
		
		#if swc @:getter(scaleZ) #end inline private function get_scaleZ():Float 
		{
			decompose();
			return scale.z;
		}
		
		#if swc @:setter(scaleZ) #end inline private function set_scaleZ(value:Float):Float 
		{
			compsVersion++;
			return scale.z = value;
		}
		
		#if swc @:getter(material) #end inline private function get_material():MaterialBase 
		{
			return _material;
		}
		
		#if swc @:setter(material) #end inline private function set_material(value:MaterialBase):MaterialBase 
		{
			_material = value;
			if(value!=null)
			value.init(this);
			return _material;
		}
		
		inline public function setPosition(x:Float=0, y:Float=0, z:Float=0):Void {
			this.x = x;
			this.y = y;
			this.z = z;
		}
		inline public function setRotation(x:Float=0, y:Float=0, z:Float=0):Void {
			rotationX = x;
			rotationY = y;
			rotationZ = z;
		}
		inline public function setScale(x:Float=1, y:Float=1, z:Float=1):Void {
			scaleX = x;
			scaleY = y;
			scaleZ = z;
		}
		
		inline public function decompose():Void {
			if(compsVersion<matrixVersion){
				var comps = matrix.decompose();
				position.copyFrom(comps[0]);
				rotation.copyFrom(comps[1]);
				scale.copyFrom(comps[2]);
				compsVersion = matrixVersion;
			}
		}
		
		public function clone():Node3D {
			var node:Node3D = new Node3D();
			node.matrix = matrix.clone();
			node.matrixVersion = matrixVersion;
			node.compsVersion = compsVersion;
			node.position.copyFrom(position);
			node.rotation.copyFrom(rotation);
			node.scale.copyFrom(scale);
			
			#if flash
			node.worldMatrix.copyFrom(worldMatrix);
			#else
			node.worldMatrix.rawData = worldMatrix.rawData.copy();
			#end
			
			node.worldVersion = worldVersion;
			node.drawable = drawable;
			node.skin = skin;
			node.material = material;
			
			for (child in children) {
				if (child.type != JOINT_TYPE) {
					node.add(child.clone());
				}
			}
			return node;
		}
		
		public function getChildByName(name:String):Node3D {
			for (c in children) {
				if (c.name==name) {
					return c;
				}
			}
			return null;
		}
		
		public function hittest(mousePos:Vector3D):Bool {
			return false;
		}
		
		public function update():Void {
			
		}
		
		public function setAttribValueDepth(name:String, value:Dynamic):Void {
			Reflect.setProperty(this, name, value);
			for (c in children) {
				c.setAttribValueDepth(name, value);
			}
		}
		
		//http://www.cnblogs.com/graphics/archive/2010/08/09/1795348.html
		public function rayMeshTest( rayOrigin:Vector3D, rayDirection:Vector3D ):Bool
		{
			if (drawable!=null&&drawable.indexBufferSet!=null&&drawable.indexBufferSet.data!=null) {
				var inv:Matrix3D = worldMatrix.clone();
				inv.invert();
				var localRayOrigin:Vector3D = inv.transformVector(rayOrigin);
				var localRayDirection:Vector3D = inv.deltaTransformVector(rayDirection);//inv.transformVector(rayOrigin.add(rayDirection)).subtract(localRayOrigin);
				//localRayDirection.normalize();
				var ins = drawable.indexBufferSet.data;
				var i = 0;
				var len = ins.length;
				var xyz = drawable.xyz.data;
				while (i < len) {
					var i0:Int = ins[i++]*3;
					var i1:Int = ins[i++]*3;
					var i2:Int = ins[i++]*3;
					var x0 = xyz[i0];
					var y0 = xyz[i0+1];
					var z0 = xyz[i0+2];
					var x1 = xyz[i1];
					var y1 = xyz[i1+1];
					var z1 = xyz[i1+2];
					var x2 = xyz[i2];
					var y2 = xyz[i2 + 1];
					var z2 = xyz[i2 + 2];
					
					var e1 = new Vector3D(x1-x0,y1-y0,z1-z0);
					var e2 = new Vector3D(x2-x0,y2-y0,z2-z0);
					var p = localRayDirection.crossProduct(e2);
					// determinant
					var det = e1.dotProduct(p);

					// keep det > 0, modify T accordingly
					var t;
					if( det >0 )
					{
						t = localRayOrigin.subtract(new Vector3D(x0, y0, z0));
					}
					else
					{
						t = new Vector3D(x0,y0,z0).subtract(localRayOrigin);
						det = -det;
					}

					// If determinant is near zero, ray lies in plane of triangle
					if ( det < 0.0001 ) {
						continue;
						//return false;
					}

					// Calculate u and make sure u <= 1
					var u = t.dotProduct(p);
					if ( u < 0.0 || u > det ) {
						continue;
						//return false;
					}

					// Q
					var q = t.crossProduct(e1);

					// Calculate v and make sure u + v <= 1
					var v = localRayDirection.dotProduct(q);
					if ( v < 0.0 || u + v > det ) {
						continue;
						//return false;
					}

					// Calculate t, scale parameters, ray intersects triangle
					var t2 = e2.dotProduct(q);

					var fInvDet = 1.0 / det;
					t2 *= fInvDet;
					u *= fInvDet;
					v *= fInvDet;
					return true;
				}
			}
			return false;
		}
		
		public function raySphereTest( rayOrigin:Vector3D, rayDirection:Vector3D ):Bool
		{
			var qx = worldMatrix.position.x - rayOrigin.x;
			var qy = worldMatrix.position.y - rayOrigin.y;
			var qz = worldMatrix.position.z - rayOrigin.z;
			
			var qr = qx*rayDirection.x + qy*rayDirection.y + qz*rayDirection.z;
			
			var d2 = qx*qx + qy*qy + qz*qz - ( qr > 0 ? qr*qr : 0 );
			
			return d2 < radius*radius;
		}
	}

