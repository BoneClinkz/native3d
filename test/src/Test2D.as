package  
{
	import flash.display.Sprite;
	import flash.display3D.Context3DTextureFormat;
	import flash.events.Event;
	import native2d.Layer2D;
	import native2d.Node2D;
	import native2d.SwfLoader;
	import native2d.SwfMovieClip2D;
	import native3d.core.BasicView;
	import native3d.core.Camera3D;
	import native3d.core.TextureSet;
	import native3d.materials.TwoDBatchMaterial;
	import native3d.utils.Stats;
	/**
	 * ...
	 * @author lizhi
	 */
	public class Test2D extends Sprite
	{
		private var loader:SwfLoader;
		private var bv:BasicView;
		private var layer:Layer2D;
		
		public function Test2D() 
		{
			loader = new SwfLoader("../assets/swfsheet/tank.zip");
			loader.addEventListener(Event.COMPLETE, loader_complete);
			loader.start();
		}
		
		private function initModel():void 
		{
			var c:int = 10;
			while(c-->0){
				var tank:SwfMovieClip2D = loader.getNode("tank_1201") as SwfMovieClip2D;
				var mc:SwfMovieClip2D = tank.getSwfChildByName("mc") as SwfMovieClip2D;
				mc.gotoAndStop(0);
				tank.setPosition(400 * Math.random(), 400 * Math.random());
				layer.add(tank);
			}
		}
		
		private function loader_complete(e:Event):void 
		{
			bv = new BasicView(200, 200, true);
			addChild(bv);
			bv.instance3Ds[0].addEventListener(Event.CONTEXT3D_CREATE, instance3Ds_context3dCreate);
		}
		
		private function instance3Ds_context3dCreate(e:Event):void 
		{
			addChild(new Stats);
			var textureset:TextureSet = new TextureSet();
			textureset.setBmd(loader.bmd,Context3DTextureFormat.BGRA);
			layer = new Layer2D(true, textureset.texture);
			(layer.material as TwoDBatchMaterial).gchanged = true;
			bv.instance3Ds[0].root.add(layer);
			bv.instance3Ds[0].passs[0].camera = new Camera3D(200, 200, true,.999999);
			initModel();
			addEventListener(Event.ENTER_FRAME, enterFrame);
		}
		
		private function enterFrame(e:Event):void 
		{
			bv.instance3Ds[0].render();
		}
		
		
		
	}

}