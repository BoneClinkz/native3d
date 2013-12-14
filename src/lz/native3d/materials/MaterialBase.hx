package lz.native3d.materials ;
import flash.display3D.Context3D;
import flash.display3D.Context3DBlendFactor;
import flash.display3D.Context3DProgramType;
import flash.display3D.Context3DTriangleFace;
import flash.display3D.Program3D;
import flash.geom.Vector3D;
import flash.Vector;
import lz.native3d.core.BasicPass3D;
import lz.native3d.core.Node3D;
import flash.display3D.Context3DCompareMode;
/**
 * @author lizhi http://matrix3d.github.io/
 */
 class MaterialBase 
{
	public var vertex:Vector<Float>;
	public var fragment:Vector<Float>;
	public var progrom:Program3D;
	public var sourceFactor:#if flash Context3DBlendFactor #else Int #end;// = Context3DBlendFactor.ONE; 
	public var destinationFactor:#if flash Context3DBlendFactor #else Int #end;// = Context3DBlendFactor.ZERO;
	public var passCompareMode:#if flash Context3DCompareMode #else Int #end;// = Context3DCompareMode.LESS;
	public var culling:#if flash Context3DTriangleFace #else Int #end;// = Context3DCompareMode.LESS;
	public var c3d:Context3D;
	public function new() 
	{
		#if flash
		sourceFactor = Context3DBlendFactor.ONE;
		destinationFactor = Context3DBlendFactor.ZERO;
		passCompareMode = Context3DCompareMode.LESS;
		culling = Context3DTriangleFace.FRONT;
		#end
	}
	
	public function draw(node:Node3D, pass:BasicPass3D):Void {
		c3d = pass.i3d.c3d;
		c3d.setDepthTest(true, passCompareMode);
		c3d.setBlendFactors(sourceFactor, destinationFactor);
		c3d.setProgram(progrom);
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