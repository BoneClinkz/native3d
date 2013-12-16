package lz.native3d.core.animation;
import flash.geom.Matrix3D;
import flash.Vector;
import lz.native3d.core.Node3D;

/**
 * ...
 * @author lizhi http://matrix3d.github.io/
 */
class AnimationPart
{
	public var channels:Vector<Channel>;
	public var target:Node3D;
	public function new() 
	{
		channels = new Vector<Channel>();
	}
	
	public function doAnimation(time:Float,maxTime:Float):Void {
		var rd:Vector<Float> = target.matrix.rawData;
		for (channel in channels) {
			var i = 0;
			var len = channel.input.length;
			while (i < len) {
				if (channel.input[i] > time) {
					break;
				}
				i++;
			}
			var j = i - 1;
			var v:Float = 0;
			if (j < 0) {
				j = len - 1;
				v =(time-channel.input[j]+maxTime) / (channel.input[i] - channel.input[j]+maxTime);
			}else if (i>=len) {
				i = 0;
				v = (time-channel.input[j]) / (channel.input[i]+maxTime - channel.input[j]);
			}else {
				v = (time-channel.input[j]) / (channel.input[i] - channel.input[j]);
			}
			if (channel.index == -1) {
				var mj:Matrix3D = channel.outputMatrix3Ds[j];
				var mi:Matrix3D = channel.outputMatrix3Ds[i];
				mj.interpolateTo(mi, v);
				mj.copyRawDataTo(rd);
			}else {
				rd[channel.index] = channel.output[j] + (channel.output[i] - channel.output[j]) * v;
			}
		}
		target.matrix.copyRawDataFrom(rd); 
		target.matrixVersion++;
	}
}