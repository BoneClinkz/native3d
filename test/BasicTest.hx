package ;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.display3D.Context3DTextureFormat;
import flash.events.Event;
import flash.geom.Vector3D;
import flash.Lib;
import lz.native3d.core.BasicLight3D;
import lz.native3d.core.BasicView;
import lz.native3d.core.DrawAble3D;
import lz.native3d.core.Node3D;
import lz.native3d.core.TextureSet;
import lz.native3d.ctrls.FirstPersonCtrl;
import lz.native3d.materials.PhongMaterial;
import lz.native3d.materials.SkyboxMaterial;
import lz.native3d.meshs.MeshUtils;
import lz.net.LoaderBat;
import openfl.Assets;
#if flash
import net.hires.debug.Stats;
#end
using OpenFLStage3D;
/**
 * ...
 * @author lizhi
 */
class BasicTest extends Sprite
{
	private var bv:BasicView;
	private var light:BasicLight3D;
	private var root3d:Node3D;
	private var cubeDrawAble:DrawAble3D;
	public function new() 
	{
		super();
		init();
	}
	
	public function init():Void {
		bv = new BasicView(400, 400, true);
		bv.instance3Ds[0].addEventListener(Event.CONTEXT3D_CREATE, context3dCreate);
		addChild(bv);
		#if flash
		addChild(new Stats());
		#end
	}
	
	private function context3dCreate(e:Event):Void 
	{
		#if flash
		addEventListener(Event.ENTER_FRAME, enterFrame);
		#else
		bv.instance3Ds[0].c3d.setRenderCallback( enterFrame);
		bv.instance3Ds[0].camera.frustumPlanes = null;
		#end
		root3d = new Node3D();
		bv.instance3Ds[0].root.add(root3d);
		bv.instance3Ds[0].camera.z = -1300;
		initLight();
		initScene();
		var ctrl = new FirstPersonCtrl(bv.stage, bv.instance3Ds[0].camera);
		ctrl.position.z = -1300;
		custom();
	}
	
	public function custom():Void {
		
	}
	
	private function enterFrame(e:Event):Void 
	{
		root3d.rotationY += .2;
		root3d.rotationZ += .22;
		bv.instance3Ds[0].render();
	}
	
	public function initLight():Void {
		light = new BasicLight3D();
		bv.instance3Ds[0].root.add(light);
		bv.instance3Ds[0].lights.push(light);
		light.x = 100;
		light.y = 50;
		light.z = -200;
	}
	
	public function initScene():Void {
		addCube();
	}
	
	public function addCube(parent:Node3D=null,x:Float=0,y:Float=0,z:Float=0,rotationX:Float=0,rotationY:Float=0,rotationZ:Float=0,scaleX:Float=1,scaleY:Float=1,scaleZ:Float=1):Node3D {
		if (parent == null) parent = root3d;
		if (cubeDrawAble==null) {
			cubeDrawAble=MeshUtils.createCube(1,bv.instance3Ds[0]);
		}
		var node:Node3D = new Node3D();
		node.setPosition(x, y, z);
		node.setRotation(rotationX, rotationY, rotationZ);
		node.setScale(scaleX, scaleY, scaleZ);
		node.frustumCulling = null;
		node.drawAble = cubeDrawAble;
		node.radius = -cubeDrawAble.radius * .3*scaleX;
		parent.add(node);
		node.material = new PhongMaterial(bv.instance3Ds[0], light,
		new Vector3D(.2, .2, .2),//AmbientColor
		new Vector3D(Math.random()/2+.5,Math.random()/2+.5,Math.random()/2+.5),//DiffuseColor
		new Vector3D(.8,.8,.8),//SpecularColor
		200,
		null
		//texture
		);
		return node;
	}
	
	public function addSky():Void {
		var loader:LoaderBat = new LoaderBat();
		var skyurl = "assets/skybox/";
		loader.addImageLoader(skyurl+"px.jpg","px");
		loader.addImageLoader(skyurl+"nx.jpg","nx");
		loader.addImageLoader(skyurl+"py.jpg","py");
		loader.addImageLoader(skyurl+"ny.jpg","ny");
		loader.addImageLoader(skyurl+"pz.jpg","pz");
		loader.addImageLoader(skyurl + "nz.jpg", "nz");
		loader.addEventListener(Event.COMPLETE, sky_loader_complete);
		loader.start();
	}
	
	private function getImage(id:String,loader:LoaderBat):BitmapData {
		#if flash
		return loader.getImage(id);
		#else
		var bmd:BitmapData = new BitmapData(512, 512, false, 0xff0000);
		return bmd;
		//return Assets.getBitmapData("assets/skybox/" + id+".jpg");
		#end
	}
	
	private function sky_loader_complete(e:Event):Void 
	{
		var loader:LoaderBat = cast(e.currentTarget, LoaderBat);
		var drawAble:DrawAble3D = MeshUtils.createCube(2000,bv.instance3Ds[0],true);
		var textureset:TextureSet = new TextureSet(bv.instance3Ds[0]);
		textureset.createCubeTextureBy6Bitmap([
			getImage("px",loader),
			getImage("nx",loader),
			getImage("py",loader),
			getImage("ny",loader),
			getImage("pz",loader),
			getImage("nz",loader)
		]);
		var skybox:Node3D = new Node3D();
		skybox.frustumCulling = null;
		bv.instance3Ds[0].root.add(skybox);
		skybox.drawAble = drawAble;
		skybox.material = 
		new SkyboxMaterial(bv.instance3Ds[0],textureset.texture);
	}
}