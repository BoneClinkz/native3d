package native3d.core;
//{
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	import flash.Vector;
	/**
	 * ...
	 * @author lizhi http://matrix3d.github.io/
	 */
	 class Camera3D extends Node3D
	{
		private var _fieldOfViewY:Float;
		private var _aspectRatio:Float;
		private var _zNear:Float;
		private var _zFar:Float=4000;
		public var invert:Matrix3D;// = new Matrix3D();
		public var perspectiveProjection:Matrix3D;// = new Matrix3D();
		
		public var viewMatrix:Matrix3D;// = new Matrix3D();
		public var perspectiveProjectionMatirx:Matrix3D;// = new Matrix3D();
		public var invertVersion:Int = -212;
		public var frustumPlanes:Vector<Vector3D>;
		
		public var is2d:Bool = false;
		public var cscale:Vector3D;
		public var cpos:Vector3D;
		public function new(width:Int,height:Int,is2d:Bool=false,index2d:Float=0) 
		{
			super();
			this.is2d = is2d;
			invert = new Matrix3D();
			perspectiveProjection = new Matrix3D();
			viewMatrix = new Matrix3D();
			perspectiveProjectionMatirx = new Matrix3D();
			add(new Node3D());
			
			cscale = new Vector3D(1,-1,1);
			cpos = new Vector3D(-1,1,index2d);
			if (is2d) {
				_zNear = 0;
				orthoLH(width, height, _zNear, _zFar,cscale,cpos);
			}else {
				_zNear = 1;
				perspectiveFieldOfViewLH(Math.PI / 4, width/height, _zNear, _zFar);
			}
			
			parent = new Node3D();
			if(!is2d)
			frustumPlanes = Vector.ofArray([new Vector3D(), new Vector3D(), new Vector3D(), new Vector3D(), new Vector3D(), new Vector3D()]);
		}
		public function perspectiveFieldOfViewLH(fieldOfViewY:Float, 
												 aspectRatio:Float, 
												 zNear:Float, 
												 zFar:Float):Void {
			_zFar = zFar;
			_zNear = zNear;
			_aspectRatio = aspectRatio;
			_fieldOfViewY = fieldOfViewY;
			var yScale:Float = 1.0/Math.tan(fieldOfViewY/2.0);
			var xScale:Float = yScale / aspectRatio; 
			var vs:Vector<Float> = Vector.ofArray([
				xScale, 0, 0, 0,
				0, yScale, 0, 0,
				0, 0, zFar/(zFar-zNear), 1,
				0,0,zNear*zFar/(zNear-zFar),0
			]);
			
			#if flash
			perspectiveProjection.copyRawDataFrom(vs);
			#else
			perspectiveProjection.rawData = vs;
			#end
			
			invertVersion = -3;
		}
		
		public function orthoLH(width:Float, height:Float, zNear:Float, zFar:Float, scale:Vector3D = null,pos:Vector3D=null):Void {
			_zFar = zFar;
			_zNear = zNear;
			cscale = scale;
			cpos = pos;
			var rawData =Vector.ofArray([
				2.0/width, 0.0, 0.0, 0.0,
				0.0, 2.0/height, 0.0, 0.0,
				0.0, 0.0, 1.0/(zFar-zNear), 0.0,
				0.0, 0.0, zNear/(zNear-zFar), 1.0
			]);
			#if flash
			perspectiveProjection.copyRawDataFrom(rawData);
			#else
			perspectiveProjection.rawData = rawData;
			#end
			if(scale!=null)
			perspectiveProjection.appendScale(scale.x, scale.y, scale.z);
			if(cpos!=null)
			perspectiveProjection.appendTranslation(cpos.x, cpos.y, cpos.z);
			invertVersion = -3;
		}
		public function orthoOffCenterLH(left:Float, 
										 right:Float,
										 bottom:Float,
									     top:Float,
										 zNear:Float, 
										 zFar:Float):Void {
			perspectiveProjection.copyRawDataFrom(Vector.ofArray([
				2.0/(right-left), 0.0, 0.0, 0.0,
				0.0, 2.0/(top-bottom), 0.0, 0.0,
				0, 0, 1.0/(zNear-zFar), 0.0,
				(right+left)/(left-right),(top+bottom)/(bottom-top), zNear/(zNear-zFar), 1.0
			]));
			invertVersion = -3;
		}
		public function lookat( position:Vector3D, target:Vector3D, up:Vector3D ):Void
		{
			var uli:Float;
			
			var px:Float = position.x;
			var py:Float = position.y;
			var pz:Float = position.z;
			
			var ux:Float = up.x;
			var uy:Float = up.y;
			var uz:Float = up.z;
			
			var fx:Float = target.x - px;
			var fy:Float = target.y - py;
			var fz:Float = target.z - pz;
			
			// normalize front
			var fls:Float = fx*fx + fy*fy + fz*fz;
			if ( fls == 0 )
				fx = fy = fz = 0;
			else
			{
				var fli:Float = 1 / Math.sqrt( fls ) ;
				fx *= fli;
				fy *= fli;
				fz *= fli;
			}
			
			// normalize up
			var uls:Float = ux*ux + uy*uy + uz*uz;
			if ( uls == 0 )
				ux = uy = uz = 0;
			else
			{
				uli = 1 / Math.sqrt( uls ) ;
				ux *= uli;
				uy *= uli;
				uz *= uli;
			}
			
			// side = front cross up
			var sx:Float = fy * uz - fz * uy;
			var sy:Float = fz * ux - fx * uz;
			var sz:Float = fx * uy - fy * ux;
			
			// normalize side
			var sls:Float = sx*sx + sy*sy + sz*sz;
			if ( sls == 0 )
				sx = sy = sz = 0;
			else
			{
				var sli:Float = 1 / Math.sqrt( sls ) ;
				sx *= sli;
				sy *= sli;
				sz *= sli;
			}
			
			// up = side cross front
			ux = sy * fz - sz * fy;
			uy = sz * fx - sx * fz;
			uz = sx * fy - sy * fx;
			
			// normalize up
			uls = ux*ux + uy*uy + uz*uz;
			if ( uls == 0 )
				ux = uy = uz = 0;
			else
			{
				uli = 1 / Math.sqrt( uls ) ;
				ux *= uli;
				uy *= uli;
				uz *= uli;
			}
			
			var _rawData_ = new Vector<Float>(16);
			_rawData_[ 0 ] = sx;
			_rawData_[ 1 ] = sy;
			_rawData_[ 2 ] = sz;
			_rawData_[ 3 ] = 0;
			
			_rawData_[ 4 ] = ux;
			_rawData_[ 5 ] = uy;
			_rawData_[ 6 ] = uz;
			_rawData_[ 7 ] = 0;
			
			_rawData_[ 8 ] = -fx;
			_rawData_[ 9 ] = -fy;
			_rawData_[ 10 ] = -fz;
			_rawData_[ 11 ] = 0;
			
			_rawData_[ 12 ] = px;
			_rawData_[ 13 ] = py;
			_rawData_[ 14 ] = pz;
			_rawData_[ 15 ] = 1;
			matrix.rawData = _rawData_;
		}
		
		public function resize(width:Int, height:Int):Void {
			var i3d = Instance3D.current;
			if (is2d) {
				orthoLH(i3d.width, i3d.height, _zNear, _zFar,cscale,cpos);
			}else {
				perspectiveFieldOfViewLH(Math.PI / 4, i3d.width/i3d.height, _zNear, _zFar);
			}
		}
		
		/**
		*   Get the distance between a point and a plane
		* http://jacksondunstan.com/articles/1811
		*   @param point Point to get the distance between
		*   @param plane Plane to get the distance between
		*   @return The distance between the given point and plane
		*/
		private inline static function pointPlaneDistance(point:Vector<Float>, plane:Vector3D): Float
		{
			// plane distance + (point [dot] plane)
			return (plane.w + (point[12]*plane.x + point[13]*plane.y + point[14]*plane.z));
		}
 
		/**
		*   Check if a point is in the viewing frustum
		* http://jacksondunstan.com/articles/1811
		*   @param point Point to check
		*   @return If the given point is in the viewing frustum
		*/
		public function isPointInFrustum(point:Vector<Float>,radius:Float):Bool
		{
			for (plane in frustumPlanes)
			{
				if (pointPlaneDistance(point, plane) < -radius)
				{
					return false;
				}
			}
			return true;
		}
	}

//}