package native3d.materials;
import flash.display.Graphics;
import flash.display.TriangleCulling;
import flash.geom.Matrix3D;
import flash.geom.Utils3D;
import flash.Vector.Vector;
import native3d.core.BasicPass3D;
import native3d.core.Instance3D;
import native3d.core.Node3D;

/**
 * ...
 * @author lizhi
 */
class GraphicsMaterial extends MaterialBase
{
	var graphice:Graphics;
	var help:Matrix3D;
	var vout:Vector<Float>;
	var uvts:Vector<Float>;
	public var fillColor:UInt;
	public function new(graphice:Graphics) 
	{
		super();
		fillColor = Std.random(0xffffff);
		this.graphice = graphice;
		help = new Matrix3D();
	}
	
	inline override public function draw(node:Node3D, pass:BasicPass3D):Void {
		help.copyFrom(node.worldMatrix);
		help.append(pass.camera.perspectiveProjectionMatirx);
		var len:Int =node.drawable.xyz.data.length;
		if (vout==null) {
			vout = new Vector<Float>();
			uvts = new Vector<Float>();
		}
		var len2:Int=Std.int( len*2/3);
		if (vout.length != len2) {
			vout.length = len2;
			uvts.length = len;
		}
		Utils3D.projectVectors(help, node.drawable.xyz.data, vout, uvts);
		var hw =  Instance3D.current.width / 2;
		var hh =  Instance3D.current.height / 2;
		var i:Int = 0;
		len = vout.length;
		while(i<len) {
			vout[i] = (1+vout[i]) * hw;
			i++;
			vout[i] = (1-vout[i]) * hh;
			i++;
		}
		
		graphice.lineStyle(0, 0xff0000);
		i = 0;
		var ins =node.drawable.indexBufferSet.data;
		len = ins.length;
		while (i < len) {
			var i0:Int = ins[i++]*2;
			var i1:Int = ins[i++]*2;
			var i2:Int = ins[i++]*2;
			var x0 = vout[i0];
			var y0 = vout[i0+1];
			var x1 = vout[i1];
			var y1 = vout[i1+1];
			var x2 = vout[i2];
			var y2 = vout[i2 + 1];
			if (!multiply(x0,y0,x1,y1,x2,y2)) {
				graphice.beginFill(fillColor);
				graphice.moveTo(x0, y0);
				graphice.lineTo(x1, y1);
				graphice.lineTo(x2, y2);
				graphice.lineTo(x0, y0);
				graphice.endFill();
			}
			
		}
	}
	
	inline public function multiply(v1x:Float,v1y:Float,v2x:Float,v2y:Float,v3x:Float,v3y:Float):Bool {
		return (v1x - v3x) * (v2y - v3y) > (v2x - v3x) * (v1y - v3y); 
	}
}