package ;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.display3D.Context3DTextureFormat;
import flash.events.Event;
import flash.filters.BlurFilter;
import flash.geom.Vector3D;
import flash.Lib;
import native3d.core.BasicLight3D;
import native3d.core.BasicView;
import native3d.core.Node3D;
import native3d.core.particle.FollowUpdater;
import native3d.core.particle.Particle;
import native3d.core.particle.ParticleWrapper;
import native3d.core.TextureSet;
import native3d.materials.ParticleMaterial;
import native3d.materials.PhongMaterial;
import native3d.meshs.MeshUtils;
import native3d.utils.Stats;

/**
 * ...
 * @author lizhi http://matrix3d.github.io/
 */
class ParticleExample2 extends Sprite
{
	private var bv:BasicView;
	private var pw:ParticleWrapper;
	private var node:Node3D;
	public function new() 
	{
		super();
		bv = new BasicView(800,600);
		addChild(bv);
		bv.instance3Ds[0].addEventListener(Event.CONTEXT3D_CREATE, bv_context3dCreate);
	}
	
	private function bv_context3dCreate(e:Event):Void 
	{
		var light = new BasicLight3D(BasicLight3D.TYPE_DISTANT);
		bv.instance3Ds[0].addLight(light);
		light.setPosition(0,0,-100);
		light.color[0] = 1;
		light.color[1] = 1;
		light.color[2] = 1;
		
		node = new Node3D();
		node.drawable = MeshUtils.createCube(.4);
		node.material  = new PhongMaterial();
		bv.instance3Ds[0].root.add(node);
		pw = new ParticleWrapper(bv.instance3Ds[0]);
		pw.updater = new FollowUpdater(node);
		var d = 10;
		for (i in 0...100) {
			var p:Particle = new Particle();
			pw.particles.push(p);
		}
		var shadow = new BitmapData(32, 32, true, 0);
		var pen = new Sprite();
		pen.graphics.beginFill(0xffffff);
		pen.graphics.drawCircle(16, 16, 10);
		pen.graphics.endFill();
		pen.filters = [new BlurFilter(4,4,3)];
		shadow.draw(pen);
		var texture = new TextureSet();
		texture.setBmd(shadow, Context3DTextureFormat.BGRA, false, 0);
		pw.material = new ParticleMaterial( texture.texture,1000,0,null,[0,0,0],null,null,.2,0,.4,0,[.5,0,0,1],[.1,1,.1,0]);
		
		pw.init();
		bv.instance3Ds[0].root.add(pw);
		bv.instance3Ds[0].camera.z = -10;
		addEventListener(Event.ENTER_FRAME, enterFrame);
		addChild(new Stats());
		
	}
	
	private function enterFrame(e:Event):Void 
	{
		var time:Float = Lib.getTimer();
		node.x = Math.sin(time/3000)*3;
		node.y = Math.cos(time/1000)*3;
		node.z = Math.cos(time / 7000) * 3;
		node.rotationX++;
		node.rotationY += 2;
		pw.update();
		bv.instance3Ds[0].render();
	}
	public static function main() {
		Lib.current.addChild(new ParticleExample2());
	}
	
}