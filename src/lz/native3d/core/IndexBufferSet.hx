package lz.native3d.core ;
//{
	import flash.display3D.IndexBuffer3D;
	import flash.Vector;
	/**
	 * ...
	 * @author lizhi http://matrix3d.github.io/
	 */
	class IndexBufferSet 
	{
		public var num:Int;
		private var start:Int;
		public var data:Vector<UInt>;
		public var indexBuff:IndexBuffer3D;
		
		public function new(num:Int,data:Vector<UInt>,start:Int) 
		{
			this.start = start;
			this.num = num;
			this.data = data;
		}
		public function init():Void {
			if(indexBuff==null){
			indexBuff = Instance3D.current.createIndexBuffer(num);
			upload();
			}
		}
		
		public function upload():Void {
			indexBuff.uploadFromVector(data, start, num);
		}
	}

//}