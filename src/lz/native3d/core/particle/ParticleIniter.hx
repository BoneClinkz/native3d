package lz.native3d.core.particle;
import flash.display3D.Context3DVertexBufferFormat;
import flash.Vector;
import lz.native3d.core.Drawable3D;
import lz.native3d.core.IndexBufferSet;
import lz.native3d.core.Instance3D;
import lz.native3d.core.VertexBufferSet;
import lz.native3d.materials.ParticleMaterial;

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
		var mat:ParticleMaterial = untyped wrapper.material;
		wrapper.drawable = new ParticleDrawable3D();
		var shader = mat.shader;
		var timeLefeVariance=null;
		if(shader.hasTimeLifeVariance)timeLefeVariance= new Vector<Float>(2 * wrapper.particles.length * 4, true);
		var startPosVariance = null;
		if (shader.hasStartPosVariance)startPosVariance = new Vector<Float>(3 * wrapper.particles.length * 4, true);
		var endPosVariance = null;
		if (shader.hasEndPosVariance) endPosVariance = new Vector<Float>(3 * wrapper.particles.length * 4, true);
		var startEndScaleVariance = null;
		if (shader.hasStartEndScaleVariance) startEndScaleVariance = new Vector<Float>(2*wrapper.particles.length * 4, true);
		var startColorVariance = null;
		if (shader.hasStartColorVariance) startColorVariance = new Vector<Float>(4 * wrapper.particles.length * 4, true);
		var endColorVariance = null;
		if (shader.hasEndColorVariance) endColorVariance = new Vector<Float>(4 * wrapper.particles.length * 4, true);
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
			
			if(timeLefeVariance!=null){
				timeLefeVariance[i * 8] =  
				timeLefeVariance[i * 8+2] =  
				timeLefeVariance[i * 8+4] = 
				timeLefeVariance[i * 8 + 6] = 100000 * Math.random(); 
				timeLefeVariance[i * 8+1] =  
				timeLefeVariance[i * 8+3] =  
				timeLefeVariance[i * 8+5] = 
				timeLefeVariance[i * 8 + 7] = mat.lifeVar * (Math.random() - .5); 
			}
			
			if(startPosVariance!=null){
				startPosVariance[i*12]= 
				startPosVariance[i*12+3]= 
				startPosVariance[i*12+6]= 
				startPosVariance[i * 12 + 9] = mat.startPosVar[0]* (Math.random() - .5); 
				startPosVariance[i*12+1]= 
				startPosVariance[i*12+4]= 
				startPosVariance[i*12+7]= 
				startPosVariance[i * 12 + 10] = mat.startPosVar[1]* (Math.random() - .5); 
				startPosVariance[i*12+2]= 
				startPosVariance[i*12+5]= 
				startPosVariance[i*12+8]= 
				startPosVariance[i * 12 + 11] = mat.startPosVar[2] * (Math.random() - .5);  
			}
			
			if(endPosVariance!=null){
				endPosVariance[i*12]= 
				endPosVariance[i*12+3]= 
				endPosVariance[i*12+6]= 
				endPosVariance[i * 12 + 9] = mat.endPosVar[0]* (Math.random() - .5); 
				endPosVariance[i*12+1]= 
				endPosVariance[i*12+4]= 
				endPosVariance[i*12+7]= 
				endPosVariance[i * 12 + 10] = mat.endPosVar[1]* (Math.random() - .5); 
				endPosVariance[i*12+2]= 
				endPosVariance[i*12+5]= 
				endPosVariance[i*12+8]= 
				endPosVariance[i * 12 + 11] = mat.endPosVar[2] * (Math.random() - .5); 
			}
			
			if(startEndScaleVariance!=null){
				startEndScaleVariance[i * 8] =  
				startEndScaleVariance[i * 8+2] =  
				startEndScaleVariance[i * 8+4] = 
				startEndScaleVariance[i * 8 + 6] = mat.startScaleVar * (Math.random() - .5); 
				startEndScaleVariance[i * 8+1] =  
				startEndScaleVariance[i * 8+3] =  
				startEndScaleVariance[i * 8+5] = 
				startEndScaleVariance[i * 8 + 7] = mat.endScaleVar * (Math.random() - .5); 
			}
			
			if(startColorVariance!=null){
				startColorVariance[i*16]= 
				startColorVariance[i*16+4]= 
				startColorVariance[i*16+8]= 
				startColorVariance[i * 16 + 12] = mat.startRGBAVar[0]* (Math.random() - .5); 
				startColorVariance[i*16+1]= 
				startColorVariance[i*16+5]= 
				startColorVariance[i*16+9]= 
				startColorVariance[i * 16 + 13] = mat.startRGBAVar[1]* (Math.random() - .5); 
				startColorVariance[i*16+2]= 
				startColorVariance[i*16+6]= 
				startColorVariance[i*16+10]= 
				startColorVariance[i * 16 + 14] = mat.startRGBAVar[2]* (Math.random() - .5); 
				startColorVariance[i*16+3]= 
				startColorVariance[i*16+7]= 
				startColorVariance[i*16+11]= 
				startColorVariance[i * 16 + 15] = mat.startRGBAVar[3] * (Math.random() - .5); 
			}
			
			if(endColorVariance!=null){
				endColorVariance[i*16]= 
				endColorVariance[i*16+4]= 
				endColorVariance[i*16+8]= 
				endColorVariance[i * 16 + 12] = mat.endRGBAVar[0]* (Math.random() - .5); 
				endColorVariance[i*16+1]= 
				endColorVariance[i*16+5]= 
				endColorVariance[i*16+9]= 
				endColorVariance[i * 16 + 13] = mat.endRGBAVar[1]* (Math.random() - .5); 
				endColorVariance[i*16+2]= 
				endColorVariance[i*16+6]= 
				endColorVariance[i*16+10]= 
				endColorVariance[i * 16 + 14] = mat.endRGBAVar[2]* (Math.random() - .5); 
				endColorVariance[i*16+3]= 
				endColorVariance[i*16+7]= 
				endColorVariance[i*16+11]= 
				endColorVariance[i * 16 + 15] = mat.endRGBAVar[3] * (Math.random() - .5); 
			}
			
		}
		var drawable:ParticleDrawable3D = untyped wrapper.drawable;
		
		if(timeLefeVariance!=null){
			drawable.timeLifeVariance = new VertexBufferSet(wrapper.particles.length*4, 2, timeLefeVariance, 0,i3d);
			drawable.timeLifeVariance.init();
		}
		if(startPosVariance!=null){
			drawable.startPosVariance = new VertexBufferSet(wrapper.particles.length*4, 3, startPosVariance, 0,i3d);
			drawable.startPosVariance.init();
		}
		if(endPosVariance!=null){
			drawable.endPosVariance = new VertexBufferSet(wrapper.particles.length*4, 3, endPosVariance, 0,i3d);
			drawable.endPosVariance.init();
		}
		drawable.offset = new VertexBufferSet(wrapper.particles.length*4, 2, odata, 0,i3d);
		drawable.uv = new VertexBufferSet(wrapper.particles.length * 4, 2, uvdata, 0, i3d);
		if(startEndScaleVariance!=null){
			drawable.startEndScaleVariance = new VertexBufferSet(wrapper.particles.length*4, 2, startEndScaleVariance, 0,i3d);
			drawable.startEndScaleVariance.init();
		}
		if(startColorVariance!=null){
			drawable.startColorVariance = new VertexBufferSet(wrapper.particles.length*4, 4, startColorVariance, 0,i3d);
			drawable.startColorVariance.init();
		}
		if(endColorVariance!=null){
			drawable.endColorVariance = new VertexBufferSet(wrapper.particles.length*4, 4, endColorVariance, 0,i3d);
			drawable.endColorVariance.init();
		}
		drawable.indexBufferSet = new IndexBufferSet(iData.length, iData, 0, i3d);
		
		drawable.startPosVariance.init();
		drawable.uv.init();
		drawable.offset.init();
		drawable.indexBufferSet.init();
	}
	
}