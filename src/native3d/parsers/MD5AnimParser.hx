package native3d.parsers;
import flash.geom.Vector3D;
import flash.utils.ByteArray;
import native3d.core.animation.AnimationItem;
import native3d.core.math.Quaternion;

/**
 * ...
 * @author lizhi
 */
class MD5AnimParser extends AbsParser
{
	public var aname:String;
	public var md5anim:MD5Anim;
	public var item:AnimationItem;
	public function new(aname:String) 
	{
		super(null);
		this.aname = aname;
		
	}
	override public function parser():Void {
		md5anim = new MD5Anim();
		var txt = cast(data, ByteArray).toString();
		txt= ~/\/\/.*/g.replace(txt, "");
		var lines = ~/[\r\n]+/g.split(txt);
		var result;
		var numJoints = 0;
		var numFrames = 0;
		var numAnimatedComponents = 0;
		while(lines.length>0) {
			var line = lines.shift();
			if ((result= ~/MD5Version (\d+)/).match(line)) {
			}else if ((result = ~/numFrames (\d+)/).match(line)) {
				numFrames = Std.parseInt(result.matched(1));
			}else if ((result = ~/numJoints (\d+)/).match(line)) {
				numJoints = Std.parseInt(result.matched(1));
			}else if ((result = ~/frameRate (\d+)/).match(line)) {
				md5anim.frameRate = Std.parseInt(result.matched(1));
			}else if ((result =~/numAnimatedComponents (\d+)/).match(line)) {
				numAnimatedComponents = Std.parseInt(result.matched(1));
			}else if ((result=~/hierarchy {/).match(line)) {
				for (i in 0...numJoints) {
					line = lines.shift();
					(result = ~/"(.+)"\s+(\S+)\s+(\S+)\s+(\S+)/).match(line);
					var info = new MD5JointInfo();
					info.name = result.matched(1);
					info.parent = Std.parseInt(result.matched(2));
					info.flags = Std.parseInt(result.matched(3));
					info.startIndex = Std.parseInt(result.matched(4));
					md5anim.jointInfos.push(info);
				}
			}else if ((result=~/bounds {/).match(line)) {
				for (i in 0...numFrames) {
					line = lines.shift();
					(result = ~/\(\s*(\S+)\s+(\S+)\s+(\S+)\s*\)\s*\(\s*(\S+)\s+(\S+)\s+(\S+)\s*\)/).match(line);
				}
			}else if ((result=~/baseframe {/).match(line)) {
				for (i in 0...numJoints) {
					line = lines.shift();
					(result = ~/\(\s*(\S+)\s+(\S+)\s+(\S+)\s*\)\s*\(\s*(\S+)\s+(\S+)\s+(\S+)\s*\)/).match(line);
					var baseFrame = new MD5BaseFrameJoint();
					baseFrame.pos = new Vector3D(Std.parseFloat(result.matched(1)),Std.parseFloat(result.matched(2)), Std.parseFloat(result.matched(3)));
					baseFrame.quat = new Quaternion(Std.parseFloat(result.matched(4)), Std.parseFloat(result.matched(5)), Std.parseFloat(result.matched(6)));
					md5anim.baseFrameJoints.push(baseFrame);
				}
			}else if ((result = ~/frame (\d+)/).match(line)) {
				var fsValue = [];
				md5anim.components[Std.parseInt(result.matched(1))]=fsValue;
				var i = 0;
				while(i<numAnimatedComponents) {
					line = lines.shift();
					var reg:EReg = ~/\s+/g;
					var fs = reg.split(line);
					while (fs.length > 0) {
						var f:String = fs.shift();
						if (f!="") {
							fsValue.push(Std.parseFloat(f));
							i++;
						}
					}
				}
			}
		}
		prepare();
	}
	
	private function prepare():Void {
		item = new AnimationItem();
		item.name = aname;
		item.frames = [];
		for (i in 0...md5anim.components.length) {
			var component = md5anim.components[i];
			var frame = new MD5Frame();
			md5anim.frames.push(frame);
			var iframe = [];
			item.frames.push(iframe);
			for (j in 0...md5anim.jointInfos.length) {
				var info = md5anim.jointInfos[j];
				var baseframe = md5anim.baseFrameJoints[j];
				var joint = new MD5Joint();
				frame.joints.push(joint);
				joint.pos = baseframe.pos.clone();
				joint.quat = baseframe.quat.clone();
				var index = info.startIndex;
				if (info.flags&1>0) {
					joint.pos.x = component[index++];
				}
				if (info.flags&2>0) {
					joint.pos.y = component[index++];
				}
				if (info.flags&4>0) {
					joint.pos.z = component[index++];
				}
				if (info.flags&8>0) {
					joint.quat.x = component[index++];
				}
				if (info.flags&16>0) {
					joint.quat.y = component[index++];
				}
				if (info.flags&32>0) {
					joint.quat.z = component[index++];
				}
				joint.quat.computeW();
				joint.toMatrix();
				iframe.push(joint.matr.clone());
				if (info.parent!=-1) {
					var parent = frame.joints[info.parent];
					joint.matr.append(parent.matr);
					//joint.pos = joint.pos.add(parent.pos);
				}
			}
		}
	}
}

class MD5JointInfo {
	public var name:String;
	public var parent:Int;
	public var flags:Int;
	public var startIndex:Int;
	public function new(){}
}

class MD5BaseFrameJoint {
	public var pos:Vector3D;
	public var quat:Quaternion;
	public function new(){}
}

class MD5Frame {
	public var joints:Array<MD5Joint>;
	public function new() {
		joints = [];
	}
}

class MD5Anim {
	public var jointInfos:Array<MD5JointInfo>;
	public var baseFrameJoints:Array<MD5BaseFrameJoint>;
	public var components:Array<Array<Float>>;
	public var frames:Array<MD5Frame>;
	public var frameRate:Int=60;
	public function new() {
		jointInfos = [];
		baseFrameJoints = [];
		components = [];
		frames = [];
	}
}

