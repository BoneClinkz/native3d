package lz.native3d.core.particle;

/**
 * ...
 * @author lizhi http://matrix3d.github.io/
 */
class ParticleUpdater
{

	public function new() 
	{
		
	}
	
	public function update(pw:ParticleWrapper):Void {
		var xyz = pw.drawable.xyz.data;
		var color = pw.drawable.color.data;
		var scale = pw.drawable.scale.data;
		for (p in pw.particles) {
			var x = p.x;
			var y = p.y;
			var z = p.z;
			for (i in p.indexs) {
				var i3 = i * 3;
				var i4 = i * 4;
				xyz[i3] = x;
				xyz[i3+1] = y;
				xyz[i3 + 2] = z;
				scale[i] = p.w;
				color[i4] = p.color.x;
				color[i4+1] = p.color.y;
				color[i4+2] = p.color.z;
				color[i4+3] = p.color.w;
			}
		}
		pw.drawable.xyz.upload();
		pw.drawable.scale.upload();
		pw.drawable.color.upload();
	}
	
}