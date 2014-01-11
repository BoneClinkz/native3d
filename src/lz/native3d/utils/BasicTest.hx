package lz.native3d.utils;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.display3D.Context3DTextureFormat;
import flash.events.Event;
import flash.geom.Vector3D;
import flash.Lib;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import lz.native3d.core.BasicLight3D;
import lz.native3d.core.BasicView;
import lz.native3d.core.Drawable3D;
import lz.native3d.core.Node3D;
import lz.native3d.core.TextureSet;
import lz.native3d.ctrls.FirstPersonCtrl;
import lz.native3d.materials.PhongMaterial;
import lz.native3d.materials.SkyboxMaterial;
import lz.native3d.meshs.MeshUtils;
import lz.native3d.parsers.ColladaParser;
import lz.native3d.utils.Stats;
import lz.net.LoaderBat;
#if flash
import lz.native3d.parsers.ObjParser;
#else
import openfl.Assets;
using OpenFLStage3D;
#end
/**
 * ...
 * @author lizhi
 */
class BasicTest extends Sprite
{
	public var bv:BasicView;
	private var light:BasicLight3D;
	public var root3d:Node3D;
	private var cubeDrawable:Drawable3D;
	public var ctrl:FirstPersonCtrl;
	public var loading:TextField;
	public function new() 
	{
		super();
		init();
	}
	
	public function init():Void {
		//bv = new BasicView(150, 150, false);
		bv = new BasicView(500, 500, true);
		bv.instance3Ds[0].addEventListener(Event.CONTEXT3D_CREATE, context3dCreate);
		addChild(bv);
		#if flash
			addChild(new Stats());
		loading = new TextField();
		loading.autoSize = TextFieldAutoSize.LEFT;
		addChild(loading);
		loading.x = 200;
		loading.textColor = 0xff0000;
		
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
		ctrl = new FirstPersonCtrl(bv.stage, bv.instance3Ds[0].camera);
		root3d = new Node3D();
		bv.instance3Ds[0].root.add(root3d);
		bv.instance3Ds[0].camera.z = -1300;
		initLight();
		initScene();
		custom();
	}
	
	public function custom():Void {
		
	}
	
	public function enterFrame(e:Event):Void 
	{
		root3d.rotationY += .2;
		root3d.rotationZ += .22;
		bv.instance3Ds[0].render();
	}
	
	public function initLight():Void {
		var numLight = 1;
		var c = numLight;
		while(c-->0){
			light = new BasicLight3D(BasicLight3D.TYPE_DISTANT);
			//light.shadowMapEnabled = true;
			bv.instance3Ds[0].addLight(light);
			light.setPosition(-10000,10000);
			light.color[0] = 1;
			light.color[1] = 1;
			light.color[2] = 1;
		}
	}
	
	public function initScene():Void {
		addCube();
	}
	
	public function addCube(parent:Node3D=null,x:Float=0,y:Float=0,z:Float=0,rotationX:Float=0,rotationY:Float=0,rotationZ:Float=0,scaleX:Float=1,scaleY:Float=1,scaleZ:Float=1):Node3D {
		if (parent == null) parent = root3d;
		if (cubeDrawable==null) {
			cubeDrawable=MeshUtils.createCube(1);
		}
		var node:Node3D = new Node3D();
		node.setPosition(x, y, z);
		node.setRotation(rotationX, rotationY, rotationZ);
		node.setScale(scaleX, scaleY, scaleZ);
		node.drawable = cubeDrawable;
		parent.add(node);
		node.material = new PhongMaterial(
		[.2, .2, .2],//AmbientColor
		[Math.random()/2+.5,Math.random()/2+.5,Math.random()/2+.5],//DiffuseColor
		[.8,.8,.8],//SpecularColor
		200,
		null
		);
		return node;
	}
	
	public function addSky():Void {
		var loader:LoaderBat = new LoaderBat();
		var skyurl = "../assets/skybox/";
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
		var drawable:Drawable3D = MeshUtils.createCube(2000,true);
		var textureset:TextureSet = new TextureSet();
		textureset.createCubeTextureBy6Bitmap([
			getImage("px",loader),
			getImage("nx",loader),
			getImage("py",loader),
			getImage("ny",loader),
			getImage("pz",loader),
			getImage("nz",loader)
		]);
		var skybox:Node3D = new Node3D();
		bv.instance3Ds[0].root.add(skybox);
		skybox.drawable = drawable;
		skybox.material = 
		new SkyboxMaterial(textureset.texture);
	}
	
	#if flash
	public function addObj():Void {
		var parser:ObjParser = new ObjParser(null,"sponza.mtl","../assets/model/sponza_texture",bv.instance3Ds[0],light);
		parser.addEventListener(Event.COMPLETE, obj_parser_complete);
		parser.fromUrlZip("../assets/model/sponza_obj.zip","sponza.obj");
		bv.instance3Ds[0].camera.frustumPlanes = null;
		loading.text = "loading......";
	}
	
	private function obj_parser_complete(e:Event):Void 
	{
		var parser:ObjParser = untyped e.currentTarget;
		bv.instance3Ds[0].root.add(parser.node);
		loading.text = "";
	}
	
	public function addDae():Void {
		var parser = new ColladaParser(null);
		parser.addEventListener(Event.COMPLETE, dae_parser_complete);
		parser.fromUrlZip("../assets/model/astroBoy_walk_Max.zip", "astroBoy_walk_Max.xml","boy_10.jpg");
	}
	
	private function dae_parser_complete(e:Event):Void 
	{
		var parser = untyped e.currentTarget;
		var c:Int = 1;
		for (x in 0...c ) {
			for(y in 0...c){
				var clone:Node3D = parser.node.clone();
				var d:Int = 60;
				clone.setPosition(d * (x / c - .5), 0 , d * (y / c - .5));
				clone.setRotation(-90);
				root3d.add(clone);
			}
		}
	}
	#end
	
}