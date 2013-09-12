package  
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Vector3D;
	import lz.native3d.core.BasicLight3D;
	import lz.native3d.core.BasicView;
	import lz.native3d.core.DrawAble3D;
	import lz.native3d.core.Node3D;
	import lz.native3d.materials.PhongMaterial;
	import lz.native3d.meshs.MeshUtils;
//	import net.hires.debug.Stats;
	/**
	 * ...
	 * @author lizhi http://matrix3d.github.io/
	 */
	public class Test extends Sprite
	{
		private var bv:BasicView;
		private var drawAble:DrawAble3D;
		private var node:Node3D;
		private var light:BasicLight3D = new BasicLight3D;
		public function Test() 
		{
			bv = new BasicView(1,1,true);
			addChild(bv);
			bv.instance3Ds[0].addEventListener(Event.CONTEXT3D_CREATE, instance3D_context3dCreate);
			light.z = -1000;
			
		}
		
		private function instance3D_context3dCreate(e:Event):void 
		{
			bv.instance3Ds[0].root.add(light);
			drawAble = MeshUtils.createTeaPot(bv.instance3Ds[0]);
			node = new Node3D;
			node.radius = -drawAble.radius;
			node.drawAble = drawAble;
			bv.instance3Ds[0].root.add(node);
			node.set_material(
				new PhongMaterial(bv.instance3Ds[0], light,
				new Vector3D(.2, .2, .2),//AmbientColor
				new Vector3D(Math.random()/2+.5,Math.random()/2+.5,Math.random()/2+.5),//DiffuseColor
				new Vector3D(.8,.8,.8),//SpecularColor
				200,
				null)
			);
			
			bv.instance3Ds[0].camera.z=-100;
			addEventListener(Event.ENTER_FRAME, enterFrame);
			
		//	addChild(new Stats);
		}
		
		private function enterFrame(e:Event):void 
		{
			node.setPosition(1, 1, 1);
			node.x=(mouseX-bv.width3d/2)/10;
			node.y = -(mouseY - bv.height3d/2) / 10;
			node.z =  node.y;
			node.rotationX += .2;
			node.rotationY += .4;
			bv.instance3Ds[0].render();
		}
		
	}

}