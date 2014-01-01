package ;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.display3D.Context3DTextureFormat;
import flash.events.Event;
import flash.filters.BlurFilter;
import flash.geom.Vector3D;
import flash.Lib;
import lz.native3d.core.BasicLight3D;
import lz.native3d.core.BasicView;
import lz.native3d.core.Node3D;
import lz.native3d.core.particle.Particle;
import lz.native3d.core.particle.ParticleWrapper;
import lz.native3d.core.PickPass;
import lz.native3d.core.TextureSet;
import lz.native3d.materials.IDMaterial;
import lz.native3d.materials.MaterialBase;
import lz.native3d.materials.ParticleMaterial;
import lz.native3d.materials.PhongMaterial;
import lz.native3d.meshs.MeshUtils;
import lz.native3d.utils.Stats;

/**
 * ...
 * @author lizhi http://matrix3d.github.io/
 */
class PickExample extends Sprite
{
	private var bv:BasicView;
	private var node:Node3D;
	private var pickPass:PickPass;
	private var m1:MaterialBase;
	private var m2:MaterialBase;
	public function new() 
	{
		super();
		bv = new BasicView();
		addChild(bv);
		bv.instance3Ds[0].addEventListener(Event.CONTEXT3D_CREATE, bv_context3dCreate);
	}
	
	private function bv_context3dCreate(e:Event):Void 
	{
		pickPass = new PickPass();
		bv.instance3Ds[0].passs.unshift(pickPass);
		bv.instance3Ds[0].camera.z = -100;
		
		node = new Node3D();
		//node.setScale(10, 10, 10);
		node.drawable = MeshUtils.createCube(10);// .createTeaPot(bv.instance3Ds[0]);
		var light:BasicLight3D = new BasicLight3D();
		light.z = -1000;
		bv.instance3Ds[0].addLight(light);
		light.x = 500;
		m1=new PhongMaterial(
		[.2, .2, .2],//AmbientColor
		[Math.random()/2+.5,Math.random()/2+.5,Math.random()/2+.5],//DiffuseColor
		[.8,.8,.8],//SpecularColor
		200
		);
		m2 = new PhongMaterial(
		[.2, .2, .2],//AmbientColor
		[Math.random()/2+.5,Math.random()/2+.5,Math.random()/2+.5],//DiffuseColor
		[.8,.8,.8],//SpecularColor
		200
		);
		node.material = m1;
		bv.instance3Ds[0].root.add(node);
		
		addEventListener(Event.ENTER_FRAME, enterFrame);
		addChild(new Stats());
		
		var image:Bitmap = new Bitmap(pickPass.targetBmd);
		addChild(image);
		image.x = 400;
		
	}
	
	private function enterFrame(e:Event):Void 
	{
		//node.x = mouseX-200;
		//node.y = -mouseY+200;
		node.z = 100;
		node.rotationY++;
		node.rotationX++;
		pickPass.before(mouseX,mouseY);
		bv.instance3Ds[0].render();
		if (node==pickPass.mouseNode) {
			node.material = m2;
		}else {
			node.material = m1;
		}
	}
	public static function main() {
		Lib.current.addChild(new PickExample());
	}
	
}