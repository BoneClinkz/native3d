package native3d.core ;
//{
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DBlendFactor;
	import flash.display3D.Context3DCompareMode;
	import flash.display3D.Context3DMipFilter;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DStencilAction;
	import flash.display3D.Context3DTextureFilter;
	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.Context3DTriangleFace;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.display3D.Context3DWrapMode;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.Program3D;
	import flash.display3D.textures.CubeTexture;
	import flash.display3D.textures.Texture;
	import flash.display3D.textures.TextureBase;
	import flash.display3D.VertexBuffer3D;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.geom.Matrix3D;
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;
	import flash.Lib;
	import flash.utils.ByteArray;
	import flash.Vector;
	import native3d.core.animation.Skin;
	import native3d.materials.PhongMaterial;
	/**
	 * ...
	 * @author lizhi http://matrix3d.github.io/
	 */
	class Instance3D extends EventDispatcher
	{
		public static var current:Instance3D;
		
		var nodess:Vector<Vector<Node3D>>;
		public static var _instances:Vector<Instance3D>=new Vector<Instance3D>();
		public var context:Context3D;
		public var drawCounter:Int = 0;
		public var drawTriangleCounter:Int = 0;
		public var root:Node3D;// = new Node3D();
		public var roots:Vector<Node3D>;
		public var camera:Camera3D;// = new Camera3D();
		public var doTransform:BasicDoTransform3D;// = new BasicDoTransform3D();
		public var passs:Vector<BasicPass3D>;// = new Vector<BasicPass3D>();
		public var shadowLight:BasicLight3D;
		public var shadowLightPass:BasicPass3D;
		public var lights:Vector<BasicLight3D>;
		public var width:Int=400;
		public var height:Int = 400;
		public var  antiAlias:Int = 0;
		
		public var lastBuffs:Array<VertexBuffer3D>;
		public var nowBuffs:Array<VertexBuffer3D>;
		public var buffsFormats:Array<Context3DVertexBufferFormat>;
		public var buffsOffsets:Array<Int>;
		public var lastTextures:Array<TextureBase>;
		public var nowTextures:Array<TextureBase>;
		public var shape:Sprite;
		
		public var frame:Int = 0;
		
		public var widthHeightVersion:Int = 1;
		public function new() 
		{
			super();
			current = this;
			lastBuffs = new Array<VertexBuffer3D>();
			nowBuffs = new Array<VertexBuffer3D>();
			buffsFormats=new Array<Context3DVertexBufferFormat>();
			buffsOffsets=new Array<Int>();
			lastTextures = new Array<TextureBase>();
			nowTextures = new Array<TextureBase>();
			root = new Node3D();
			camera = new Camera3D(width,height);
			 doTransform = new BasicDoTransform3D();
			 passs = new Vector<BasicPass3D>();
			 lights = new Vector<BasicLight3D>();
			 roots = new Vector<Node3D>();
			 roots.push(root);
		}
		 static public function getInstance(i:Int=0):Instance3D
		{
			return _instances[i];
		}
		
		public function init(c3d:Context3D):Void {
			context = c3d;
			passs.push(new BasicPass3D());
			resize(width, height);
			dispatchEvent(new Event(Event.CONTEXT3D_CREATE));
		}
		
		public function render():Void {
			if (shape!=null) {
				shape.graphics.clear();
			}
			drawCounter = drawTriangleCounter = 0;
			
			if (shadowLight != null) {
				shadowLightPass.camera.matrix.identity();
				shadowLightPass.camera.matrix.appendTranslation(.000001,100,0);
				shadowLightPass.camera.matrix.pointAt(new Vector3D(),Vector3D.Z_AXIS,new Vector3D(0,-1,0));
				shadowLightPass.camera.matrixVersion++;
			}
			nodess = new Vector<Vector<Node3D>>();
			for (r in roots) {
				nodess.push(doTransform.doTransform(r.children));
			}
			for (i in 0...passs.length) {
				var pass:BasicPass3D = passs[i];
				var nodes:Vector<Node3D> = nodess[pass.rootIndex];
				if (pass.camera!=null) doTransform.doTransformCamera(pass.camera);
				pass.pass(pass.cnodes!=null?doTransform.doTransform(pass.cnodes):nodes);
			}
			frame++;
		}
		
		public function resize(width:Int, height:Int):Void {
			this.width = width;
			this.height = height;
			widthHeightVersion++;
			if (context!=null) {
				configureBackBuffer(width, height, antiAlias);
				for (i in 0...passs.length) {
					var pass:BasicPass3D = passs[i];
					if (pass.camera != null) {
						pass.camera.resize(width, height);
					}
				}
				camera.resize(width, height);
			}
		}
		
		public function addLight(light:BasicLight3D):Void {
			if (light != null) {
				if(shadowLight==null&&light.shadowMapEnabled){
					var pass = new BasicPass3D();
					pass.cnodes = root.children;
					pass.camera = new Camera3D(400, 400);
					pass.camera.perspectiveFieldOfViewLH(Math.PI / 6, 1, 1, 40000000);
					pass.target = new PassTarget(light.shadowMapSize);
					pass.material = new PhongMaterial(null, null, null, 200, null, null, true);
					pass.skinMaterial=new PhongMaterial(null, null, null, 200, null,new Skin(), true);
					passs.unshift(pass);
					shadowLight = light;
					shadowLightPass = pass;
				}
				
				root.add(light);
				var newlights = new Vector<BasicLight3D>();
				var added = false;
				for (i in 0...lights.length) {
					if (!added&&light.type<lights[i].type) {
						newlights.push(light);
						added = true;
						break;
					}
					newlights.push(lights[i]);
				}
				if(!added)
				newlights.push(light);
				lights = newlights;
			}
		}
		
		public inline function clear(red : Float = 0, green : Float = 0, blue : Float = 0, alpha : Float = 1, depth : Float = 1, stencil : UInt = 0, mask : UInt = 0xFFFFFFFF) : Void {
			context.clear(red, green, blue, alpha, depth, stencil, mask);
		}
		public inline function configureBackBuffer(width : Int, height : Int, antiAlias : Int, enableDepthAndStencil : Bool = true, wantsBestResolution : Bool = false) : Void {
			context.configureBackBuffer(width, height, antiAlias, enableDepthAndStencil/*, wantsBestResolution*/);
		}
		public inline function createCubeTexture(size : Int, format : Context3DTextureFormat, optimizeForRenderToTexture : Bool, streamingLevels : Int = 0) : CubeTexture {
			return context.createCubeTexture(size, format, optimizeForRenderToTexture/*, streamingLevels*/);
		}
		public inline function createIndexBuffer(numIndices : Int) : IndexBuffer3D {
			return context.createIndexBuffer(numIndices);
		}
		public inline function createProgram() : Program3D {
			return context.createProgram();
		}
		public inline function createTexture(width : Int, height : Int, format : Context3DTextureFormat, optimizeForRenderToTexture : Bool, streamingLevels : Int = 0) : Texture {
			return context.createTexture(width, height, format, optimizeForRenderToTexture/*, streamingLevels*/);
		}
		public inline function createVertexBuffer(numVertices : Int, data32PerVertex : Int) : VertexBuffer3D {
			return context.createVertexBuffer(numVertices, data32PerVertex);
		}
		public inline function dispose(recreate : Bool = true) : Void {
			context.dispose(recreate);
		}
		public inline function drawToBitmapData(destination : BitmapData) : Void {
			beginDraw();
			context.drawToBitmapData(destination);
		}
		public inline function drawTriangles(indexBuffer : IndexBuffer3D, firstIndex : Int = 0, numTriangles : Int = -1) : Void {
			beginDraw();
			context.drawTriangles(indexBuffer, firstIndex, numTriangles);
		}
		public inline function beginDraw():Void {
			var len = lastBuffs.length;
			if (nowBuffs.length > len) len = nowBuffs.length;
			for (i in 0...len) {
				var lastBuff = lastBuffs[i];
				var nowBuff = nowBuffs[i];
				if (nowBuff != lastBuff) {
					context.setVertexBufferAt(i, nowBuff, buffsOffsets[i], buffsFormats[i]);
				}
			}
			len = lastTextures.length;
			if (nowTextures.length > len) len = nowTextures.length;
			for (i in 0...len) {
				var lastTexture = lastTextures[i];
				var nowTexture = nowTextures[i];
				if (nowTexture != lastTexture) {
					context.setTextureAt(i, nowTexture);
				}
			}
			lastBuffs = nowBuffs;
			lastTextures = nowTextures;
			nowBuffs = new Array<VertexBuffer3D>();
			nowTextures = new Array<TextureBase>();
		}
		
		public inline function present() : Void {
			context.present();
		}
		public inline function setBlendFactors(sourceFactor : Context3DBlendFactor, destinationFactor : Context3DBlendFactor) : Void {
			context.setBlendFactors(sourceFactor, destinationFactor);
		}
		public inline function setColorMask(red : Bool, green : Bool, blue : Bool, alpha : Bool) : Void {
			context.setColorMask(red, green, blue, alpha);
		}
		public inline function setCulling(triangleFaceToCull : Context3DTriangleFace) : Void {
			context.setCulling(triangleFaceToCull);
		}
		public inline function setDepthTest(depthMask : Bool, passCompareMode : Context3DCompareMode) : Void {
			context.setDepthTest(depthMask, passCompareMode);
		}
		public inline function setProgram(program : Program3D) : Void {
			context.setProgram(program);
		}
		public inline function setProgramConstantsFromByteArray(programType : Context3DProgramType, firstRegister : Int, numRegisters : Int, data : ByteArray, byteArrayOffset : UInt) : Void {
			context.setProgramConstantsFromByteArray(programType, firstRegister, numRegisters, data, byteArrayOffset);
		}
		public inline function setProgramConstantsFromMatrix(programType : Context3DProgramType, firstRegister : Int, matrix : Matrix3D, transposedMatrix : Bool = false) : Void {
			context.setProgramConstantsFromMatrix(programType, firstRegister, matrix, transposedMatrix);
		}
		public inline function setProgramConstantsFromVector(programType : Context3DProgramType, firstRegister : Int, data : flash.Vector<Float>, numRegisters : Int = -1) : Void {
			context.setProgramConstantsFromVector(programType, firstRegister, data, numRegisters);
		}
		public inline function setRenderToBackBuffer() : Void {
			context.setRenderToBackBuffer();
		}
		public inline function setRenderToTexture(texture : TextureBase, enableDepthAndStencil : Bool = false, antiAlias : Int = 0, surfaceSelector : Int = 0) : Void {
			context.setRenderToTexture(texture, enableDepthAndStencil, antiAlias, surfaceSelector);
		}
		public inline function setSamplerStateAt(sampler : Int, wrap : Context3DWrapMode, filter : Context3DTextureFilter, mipfilter : Context3DMipFilter) : Void {
			//context.setSamplerStateAt(sampler, wrap, filter, mipfilter);
		}
		public inline function setScissorRectangle(rectangle : Rectangle) : Void {
			context.setScissorRectangle(rectangle);
		}
		public inline function setStencilActions(triangleFace : Context3DTriangleFace, compareMode : Context3DCompareMode, actionOnBothPass : Context3DStencilAction, actionOnDepthFail : Context3DStencilAction, actionOnDepthPassStencilFail : Context3DStencilAction) : Void {
			context.setStencilActions(triangleFace, compareMode, actionOnBothPass, actionOnDepthFail, actionOnDepthPassStencilFail);
		}
		public inline function setStencilReferenceValue(referenceValue : UInt, readMask : UInt = 255, writeMask : UInt = 255) : Void {
			context.setStencilReferenceValue(referenceValue, readMask, writeMask);
		}
		public inline function setTextureAt(sampler : Int, texture : TextureBase) : Void {
			//context.setTextureAt(sampler, texture);
			nowTextures[sampler] = texture;
		}
		public inline function setVertexBufferAt(index : Int, buffer : VertexBuffer3D, bufferOffset : Int = 0, format : Context3DVertexBufferFormat) : Void {
			//context.setVertexBufferAt(index, buffer, bufferOffset, format);
			nowBuffs[index] = buffer;
			buffsOffsets[index] = bufferOffset;
			buffsFormats[index] = format;
		}
		
	}

//}