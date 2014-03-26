package  
{
	import flash.events.Event;
	import flash.geom.Matrix3D;
	import flash.geom.Utils3D;
	import flash.geom.Vector3D;
	import native3d.core.BasicLight3D;
	import native3d.core.Camera3D;
	import native3d.core.Node3D;
	import native3d.materials.GraphicsMaterial;
	import native3d.materials.PhongMaterial;
	import native3d.utils.BasicTest;
	import native3d.utils.Stats;
	/**
	 * ...
	 * @author lizhi http://matrix3d.github.io/
	 */
	public class Test extends BasicTest
	{
		override public function initScene():void
		{
			var w:int = 5;
			var h:int = 5;
			var d:int = 5;
			var scale:int = 30;
			var gap:int = 100;
			for (var x:int = 0; x < w;x++) {
				for (var y:int = 0; y < h;y++ ) {
					for (var z:int = 0; z < d;z++ ) {
						var cube:Node3D = addCube(null, (x - w / 2) * gap, (y - h / 2) * gap, (z - d / 2) * gap, 0, 0, 0, scale, scale, scale);
						cube.material = new GraphicsMaterial(graphics);
					}
				}
			}
			addSky();
			
			ctrl.position.z = -1300;
			addChild(new Stats);
		}
		
		override public function enterFrame (e:Event) : void {
			graphics.clear();
			super.enterFrame(e);
		}
	}

}