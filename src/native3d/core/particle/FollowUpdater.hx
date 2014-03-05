package native3d.core.particle;
import flash.geom.Vector3D;
import native3d.core.Node3D;

/**
 * ...
 * @author lizhi
 */
class FollowUpdater extends ParticleUpdater
{
	var target:Node3D;
	var ease:Float;
	var pos:Vector3D;
	public function new(target:Node3D,ease:Float=.5) 
	{
		super();
		pos = new Vector3D();
		this.ease = ease;
		this.target = target;
		
	}
	
	override public function update(pw:ParticleWrapper):Void {
		var drawable:ParticleDrawable3D =untyped pw.drawable;
		var xyz = drawable.startPosVariance.data;
		var last:Particle=null;
		for (pi in 0...pw.particles.length) {
			var p:Particle = pw.particles[pi];
			if (pi == 0) {
				pos.setTo(0, 0, 0);
				pos = target.worldMatrix.transformVector(pos);
				p.copyFrom(pos);
			}else {
				p.x = p.x + (last.x - p.x) * ease;
				p.y = p.y + (last.y - p.y) * ease;
				p.z = p.z + (last.z - p.z) * ease;
			}
			last = p;
			var x = p.x;
			var y = p.y;
			var z = p.z;
			for (i in p.indexs) {
				var i3 = i * 3;
				var i2 = i * 2;
				var i4 = i * 4;
				xyz[i3] = x;
				xyz[i3+1] = y;
				xyz[i3 + 2] = z;
			}
		}
		drawable.startPosVariance.upload();
	}
	
}