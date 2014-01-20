package native3d.core ;
//{
	import flash.display3D.Context3DCompareMode;
	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.textures.TextureBase;
	import flash.Vector;
	/**
	 * ...
	 * @author lizhi http://matrix3d.github.io/
	 */
	 class PassTarget 
	{
		public var texture:TextureBase;
		public var enableDepthAndStencil:Bool = true;
		public var antiAlias:Int = 0;
		public var surfaceSelector:Int = 0; 
		public var colorOutputIndex:Int = 0;
		private var _clear:Bool = true;
		public var size:Int;
		public var i3dIndex:Int = 0;
		public function new(size:Int) 
		{
			this.size = size;
			texture = Instance3D.getInstance(i3dIndex).createTexture(size, size, Context3DTextureFormat.BGRA, true);
		}
		
	}

//}