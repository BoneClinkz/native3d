package lz.native3d.core.particle;
import flash.display3D.Context3DVertexBufferFormat;
import flash.Vector;
import lz.native3d.core.Drawable3D;
import lz.native3d.core.IndexBufferSet;
import lz.native3d.core.Instance3D;
import lz.native3d.core.VertexBufferSet;

/**
 * ...
 * @author lizhi http://matrix3d.github.io/
 */
class ParticleIniter
{

	public var i3d:Instance3D;
	public function new(i3d:Instance3D) 
	{
		this.i3d = i3d;
	}
	
	public function init(wrapper:ParticleWrapper):Void {
		wrapper.drawable = new ParticleDrawable3D();
		var timeLefeVariance = new Vector<Float>(2*wrapper.particles.length * 4, true);
		var startPosVariance = new Vector<Float>(3 * wrapper.particles.length * 4, true);
		var endPosVariance = new Vector<Float>(3 * wrapper.particles.length * 4, true);
		var startEndScaleVariance = new Vector<Float>(2*wrapper.particles.length * 4, true);
		var startColorVariance = new Vector<Float>(4 * wrapper.particles.length * 4, true);
		var endColorVariance = new Vector<Float>(4 * wrapper.particles.length * 4, true);
		var odata = new Vector<Float>(2 * wrapper.particles.length * 4, true);
		var uvdata = new Vector<Float>(2 * wrapper.particles.length * 4, true);
		var iData = new Vector<UInt>(wrapper.particles.length * 6);
		
		for (i in 0...wrapper.particles.length) {
			var p = wrapper.particles[i];
			p.indexs.push(i*4);
			p.indexs.push(i*4+1);
			p.indexs.push(i*4+2);
			p.indexs.push(i * 4+3);
			odata[i * 8] = -1;
			odata[i * 8+1] = -1;
			odata[i * 8+2] = 1;
			odata[i * 8+3] = -1;
			odata[i * 8+4] = -1;
			odata[i * 8+5] = 1;
			odata[i * 8+6] = 1;
			odata[i * 8 + 7] = 1;
			
			uvdata[i * 8] = 0;
			uvdata[i * 8+1] = 1;
			uvdata[i * 8+2] = 1;
			uvdata[i * 8+3] = 1;
			uvdata[i * 8+4] = 0;
			uvdata[i * 8+5] = 0;
			uvdata[i * 8+6] = 1;
			uvdata[i * 8 + 7] = 0;
			
			iData[i * 6] = i * 4;
			iData[i * 6+1] = i * 4+1;
			iData[i * 6+2] = i * 4+2;
			iData[i * 6+3] = i * 4+2;
			iData[i * 6+4] = i * 4+1;
			iData[i * 6 + 5] = i * 4 + 3;
			
			timeLefeVariance[i * 8] =  
			timeLefeVariance[i * 8+2] =  
			timeLefeVariance[i * 8+4] = 
			timeLefeVariance[i * 8 + 6] = 100000 * Math.random(); 
			timeLefeVariance[i * 8+1] =  
			timeLefeVariance[i * 8+3] =  
			timeLefeVariance[i * 8+5] = 
			timeLefeVariance[i * 8 + 7] = 1000*Math.random(); 
			
		}
		var drawable:ParticleDrawable3D = untyped wrapper.drawable;
		drawable.timeLifeVariance = new VertexBufferSet(wrapper.particles.length*4, 2, timeLefeVariance, 0,i3d);
		
		drawable.startPosVariance = new VertexBufferSet(wrapper.particles.length*4, 3, startPosVariance, 0,i3d);
		drawable.endPosVariance = new VertexBufferSet(wrapper.particles.length*4, 3, endPosVariance, 0,i3d);
		drawable.offset = new VertexBufferSet(wrapper.particles.length*4, 2, odata, 0,i3d);
		drawable.uv = new VertexBufferSet(wrapper.particles.length*4, 2, uvdata, 0,i3d);
		drawable.startEndScaleVariance = new VertexBufferSet(wrapper.particles.length*4, 2, startEndScaleVariance, 0,i3d);
		drawable.startColorVariance = new VertexBufferSet(wrapper.particles.length*4, 4, startColorVariance, 0,i3d);
		drawable.endColorVariance = new VertexBufferSet(wrapper.particles.length*4, 4, endColorVariance, 0,i3d);
		drawable.indexBufferSet = new IndexBufferSet(iData.length, iData, 0,i3d);
	}
	
}