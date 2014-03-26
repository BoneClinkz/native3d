package native3d.core ;
//{
	import flash.display.BitmapData;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.textures.CubeTexture;
	import flash.display3D.textures.Texture;
	import flash.display3D.textures.TextureBase;
	import flash.errors.Error;
	import flash.geom.Matrix;
	import flash.utils.ByteArray;
	/**
	 * ...
	 * @author lizhi http://matrix3d.github.io/
	 */
	class TextureSet 
	{
		public var texture:TextureBase;
		public var version:Int = -1;
		public var changed:Bool = false;
		private var _bmd:BitmapData;
		private var ttexture:Texture;
		
		private static var tempTexture:TextureSet;
		public var width:Int;
		public var height:Int;
		public var isDXT1:Bool;
		public var isDXT5:Bool;
		public function new() 
		{
		}
		
		public function setAtf(data:ByteArray, optimizeForRenderToTexture:Bool = false,streamingLevels:Int=0):Void {
			var sign:String = data.readUTFBytes(3);
			if (sign != "ATF")
				throw "ATF parsing error, unknown format " + sign;
			
			if (data[6] == 255)
				data.position = 12; // new file version
			else
				data.position = 6; // old file version
			
			var tdata:UInt = data.readUnsignedByte();
			var _type:Int = tdata >> 7; // UB[1]
			var _format:Int = tdata & 0x7f; // UB[7]
			var format=null;
			switch (_format) {
				case 0:
				case 1:
					format = Context3DTextureFormat.BGRA;
				case 2:
				case 3:
					format = Context3DTextureFormat.COMPRESSED;
					isDXT1 = true;
				case 4:
				case 5:
					format = Context3DTextureFormat.COMPRESSED_ALPHA;
					isDXT5 = true;
					// explicit string to stay compatible 
				// with older versions
				default:
					throw "Invalid ATF format";
			}
			
			var type;
			switch (_type) {
				case 0:
					type = "ATFData.TYPE_NORMAL";
				case 1:
					type = "ATFData.TYPE_CUBE";
			}
			
			width = Std.int(Math.pow(2, data.readUnsignedByte()));
			height = Std.int(Math.pow(2, data.readUnsignedByte()));
			var numTextures = data.readUnsignedByte();
			texture = Instance3D.current.createTexture(width, height, format, optimizeForRenderToTexture,streamingLevels);
			ttexture = cast( texture, Texture);
			ttexture.uploadCompressedTextureFromByteArray(data, 0);
		}
		
		public function setBmd(bmd:BitmapData,format:Context3DTextureFormat, optimizeForRenderToTexture:Bool=false, streamingLevels:Int=0):Void 
		{
			if (bmd == null) return;
			if (texture!=null) texture.dispose();
			var w:Int = 2048;
			var h:Int = 2048;
			for (i in 0...12 ) {
				var pow:Int = Std.int(Math.pow(2, i));
				if (pow>=bmd.width) {
					w = pow;
					width = w;
					break;
				}
			}
			for (i in 0...12 ) {
				var pow:Int = Std.int(Math.pow(2, i));
				if (pow>=bmd.height) {
					h = pow;
					height = h;
					break;
				}
			}
			
			texture = Instance3D.current.createTexture(w, h, Context3DTextureFormat.BGRA, optimizeForRenderToTexture,streamingLevels);
			ttexture = cast( texture,Texture);
			
			var level 		: Int 			= 0;
			var size		: Int 			= w > h ? w : h;
			var _bitmapData:BitmapData = new BitmapData(size, size, bmd.transparent, 0);
			_bitmapData.draw(bmd , new Matrix(size / bmd.width, 0, 0, size / bmd.height), null, null, null, true);
			var transform 	: Matrix 		= new Matrix();
			var tmp 		: BitmapData 	= new BitmapData(
				size,
				size,
				bmd.transparent,
				0
			);
			
			while (size >= 1)
			{
				tmp.draw(_bitmapData, transform, null, null, null, true);
				ttexture.uploadFromBitmapData(tmp, level);
				
				transform.scale(.5, .5);
				level++;
				size >>= 1;
				if (tmp.transparent)
					tmp.fillRect(tmp.rect, 0);
			}
			tmp.dispose();
			
			
			_bmd = bmd;
			changed = true;
		}
		
		public function createCubeTextureBy6Bitmap( _bitmapDatas:Array<BitmapData>) : Void {
			var _size:UInt = _bitmapDatas[0].width;
			var _resource:CubeTexture = Instance3D.current.createCubeTexture(_size, Context3DTextureFormat.BGRA, true);
			
			for ( side in 0...6)
			{
				var mipmapId	: UInt			= 0;
				var mySize		: UInt			= _size;
				var bitmapData	: BitmapData	= _bitmapDatas[side];
				
				while (mySize >= 1)
				{
					var tmpBitmapData	: BitmapData	= new BitmapData(mySize, mySize, bitmapData.transparent, 0x005500);
					var tmpMatrix		: Matrix		= new Matrix();
					
					tmpMatrix.a		= mySize / bitmapData.width;
					tmpMatrix.d		= mySize / bitmapData.height;
					
					tmpBitmapData.draw(bitmapData, tmpMatrix);
					_resource.uploadFromBitmapData(tmpBitmapData, side, mipmapId);
					
					++mipmapId;
					mySize = untyped(mySize/2);
				}
			}
			texture = _resource;
		}
		
		
		public static function getTempTexture():TextureSet {
			if (tempTexture == null) {
				var bmd:BitmapData = new BitmapData(128, 128, false);
				bmd.perlinNoise(100, 100, 3, 1, true, true);
				tempTexture = new TextureSet();
				tempTexture.setBmd(bmd, Context3DTextureFormat.BGRA);
			}
			return tempTexture;
		}
	}

//}