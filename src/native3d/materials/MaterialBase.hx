package native3d.materials ;
import flash.display.BlendMode;
import flash.display3D.Context3D;
import flash.display3D.Context3DBlendFactor;
import flash.display3D.Context3DProgramType;
import flash.display3D.Context3DTriangleFace;
import flash.display3D.Program3D;
import flash.geom.Vector3D;
import flash.Vector;
import hxsl.Shader;
import hxsl.Shader.ShaderInstance;
import native3d.core.BasicPass3D;
import native3d.core.Instance3D;
import native3d.core.Node3D;
import flash.display3D.Context3DCompareMode;
/**
 * @author lizhi http://matrix3d.github.io/
 */
 class MaterialBase 
{
	public static var LAST:MaterialBase;
	public var isLastMe:Bool = false;//上个材质是否自身
	
	public var shader:Shader;
	public var shaderInstance:ShaderInstance;
	public var vertex:Vector<Float>;
	public var fragment:Vector<Float>;
	public var progrom:Program3D;
	public var sourceFactor:#if flash Context3DBlendFactor #else Int #end;// = Context3DBlendFactor.ONE; 
	public var destinationFactor:#if flash Context3DBlendFactor #else Int #end;// = Context3DBlendFactor.ZERO;
	public var passCompareMode:#if flash Context3DCompareMode #else Int #end;// = Context3DCompareMode.LESS;
	public var culling:#if flash Context3DTriangleFace #else Int #end;// = Context3DCompareMode.LESS;
	public var i3d:Instance3D;
	public var depthMaterial:MaterialBase;
	public function new() 
	{
		#if flash
		sourceFactor = Context3DBlendFactor.ONE;
		destinationFactor = Context3DBlendFactor.ZERO;
		passCompareMode = Context3DCompareMode.LESS;
		culling = Context3DTriangleFace.FRONT;
		#end
		i3d = Instance3D.current;
	}
	
	public function build():Void {
		shaderInstance = shader.getInstance();
		if (shaderInstance.program==null) {
			shaderInstance.program = i3d.createProgram();
			shaderInstance.program.upload(shaderInstance.vertexBytes.getData(), shaderInstance.fragmentBytes.getData());
			/*i3d.context.enableErrorChecking = true;
			trace("\n\n"+shader);
			trace("\n"+shader.getDebugShaderCode(true).split("\n").length);*/
			//trace("\n"+shader.getDebugShaderCode(true));
		}
		vertex = shaderInstance.vertexVars.toData().concat();
		fragment = shaderInstance.fragmentVars.toData().concat();
		progrom = shaderInstance.program;
	}
	
	public function draw(node:Node3D, pass:BasicPass3D):Void {
		i3d.setProgram(progrom);
		i3d.setDepthTest(true, passCompareMode);
		i3d.setBlendFactors(sourceFactor, destinationFactor);
		i3d.setCulling(culling);
		isLastMe = LAST == this;
		LAST = this;
	}
	
	public function setBlendModel(value:BlendMode):Void {
		switch (value) {
			case BlendMode.NORMAL:
				sourceFactor = Context3DBlendFactor.ONE;
				destinationFactor = Context3DBlendFactor.ZERO;
			case BlendMode.LAYER:
				sourceFactor = Context3DBlendFactor.SOURCE_ALPHA;
				destinationFactor = Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA;
			case BlendMode.MULTIPLY:
				sourceFactor = Context3DBlendFactor.ZERO;
				destinationFactor = Context3DBlendFactor.SOURCE_COLOR;
			case BlendMode.ADD:
				sourceFactor = Context3DBlendFactor.SOURCE_ALPHA;
				destinationFactor = Context3DBlendFactor.ONE;
			case BlendMode.ALPHA:
				sourceFactor = Context3DBlendFactor.ZERO;
				destinationFactor = Context3DBlendFactor.SOURCE_ALPHA;
		}
	}
	
	public function init(node:Node3D):Void {
		
	}
	
	public function arr2ve3(arr:Array<Float>,notNull:Bool=false):Vector3D {
		if (arr == null) {
			if (notNull) return new Vector3D();
			return null;
		}
		if (arr.length==1) {
			return new Vector3D(arr[0]);
		}else if (arr.length==2) {
			return new Vector3D(arr[0],arr[1]);
		}else if (arr.length==3) {
			return new Vector3D(arr[0],arr[1],arr[2]);
		}else if (arr.length>3) {
			return new Vector3D(arr[0],arr[1],arr[2],arr[3]);
		}
		return new Vector3D();
	}
	
}