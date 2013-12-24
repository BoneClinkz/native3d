package 
{
	import adobe.utils.CustomActions;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	import lz.native3d.core.BasicLight3D;
	import lz.native3d.core.BasicTest;
	import lz.native3d.core.BasicView;
	import lz.native3d.core.Drawable3D;
	import lz.native3d.core.IndexBufferSet;
	import lz.native3d.core.Node3D;
	import lz.native3d.core.VertexBufferSet;
	import lz.native3d.materials.PhongMaterial;
	import lz.native3d.meshs.MeshUtils;
	import net.hires.debug.Stats;
	import org.bulletphysics.btAxisSweep3;
	import org.bulletphysics.btBoxShape;
	import org.bulletphysics.btBvhTriangleMeshShape;
	import org.bulletphysics.btCollisionDispatcher;
	import org.bulletphysics.btDbvtBroadphase;
	import org.bulletphysics.btDefaultCollisionConfiguration;
	import org.bulletphysics.btDefaultCollisionConstructionInfo;
	import org.bulletphysics.btDefaultMotionState;
	import org.bulletphysics.btDiscreteDynamicsWorld;
	import org.bulletphysics.btIndexedMesh;
	import org.bulletphysics.btRigidBody;
	import org.bulletphysics.btRigidBodyConstructionInfo;
	import org.bulletphysics.btSequentialImpulseConstraintSolver;
	import org.bulletphysics.btTransform;
	import org.bulletphysics.btTriangleIndexVertexArray;
	import org.bulletphysics.btVector3;
	import org.bulletphysics.CModule;
	import org.bulletphysics.positionAndRotateMesh;
	
	/**
	 * ...
	 * @author lizhi http://matrix3d.github.io/
	 */
	public class BulletTest extends BasicTest
	{
		private var broadphase:btDbvtBroadphase;
		private var defCollisionInfo:btDefaultCollisionConstructionInfo;
		private var collisionConfig:btDefaultCollisionConfiguration;
		private var dispatcher:btCollisionDispatcher;
		private var solver:btSequentialImpulseConstraintSolver;
		private var world:btDiscreteDynamicsWorld;
		private var trans:btTransform;

		private var bods:Vector.<btRigidBody>;
		private var meshes:Vector.<Node3D>;
		private var helpTrans:btTransform;
		private var helpM44:Vector.<Number> = new Vector.<Number>(16);
		override public function initScene():void
		{
			CModule.rootSprite = this;
			if (CModule.runningAsWorker()) {
				return;
			}
			CModule.startAsync(this);
			addChild(new Stats);
			createWorld();
			ctrl.position.setTo(-90, 107, -68);
			ctrl.rotation.setTo(43, 55,0);
			addSky();
		}
		
		private function createWorld():void
		{
			helpTrans = btTransform.create();
			helpM44[15] = 1;
			
			bods = new Vector.<btRigidBody>();
			meshes = new Vector.<Node3D>();

			var maxNumOutstandingTasks:int = 2;

			defCollisionInfo = btDefaultCollisionConstructionInfo.create();
			//defCollisionInfo.m_defaultMaxPersistentManifoldPoolSize = 32768;
			defCollisionInfo.m_defaultMaxPersistentManifoldPoolSize = 1024;
			collisionConfig = btDefaultCollisionConfiguration.create(defCollisionInfo.swigCPtr)

			dispatcher = btCollisionDispatcher.create(collisionConfig.swigCPtr)
			solver = btSequentialImpulseConstraintSolver.create()

			broadphase =  btDbvtBroadphase.create(0);
			world = btDiscreteDynamicsWorld.create(dispatcher.swigCPtr, broadphase.swigCPtr, solver.swigCPtr, collisionConfig.swigCPtr)
			world.setGravity(vector(0, -20, 0));
			
			//world.getDispatchInfo().m_enableSPU = true;

			// Create some massless (static) cubes
			/*spawnCube(-50, 0, 0, 0, 5, 5, 100)
			spawnCube(50, 0, 0, 0, 5, 5, 100)
			spawnCube(0, 0, 50, 0, 100, 5, 5)
			spawnCube(0, 0, -50, 0, 100, 5, 5)
			spawnCube(0, -1, 0, 0, 100, 0.1, 100)*/

			spawnPlane();
			
			var numCols:int = 6;
			var w:Number = 2.0;
			var s:Number = 4.0;
			
			var boxShape:btBoxShape = btBoxShape.create(vector(w , w, w));
			for(var i:int=0; i<200; i++) {
				//spawnCube(((i%numCols)) * 10  - 30, 10.0 + ((i/numCols) * s), 0, 10, w*2, w*2, w*2)
				spawnRigidBody(
					boxShape,
					w*2,w*2,w*2,
					10,
					0, 10.0 + (i/numCols) * s, (i%numCols) * 10  - 30
				)
			}
		}
		
		private function spawnPlane():void 
		{
			var w:int = 100;
            var ins:Vector.<uint> = new Vector.<uint>;
			var vin:Vector.<Number> = new Vector.<Number>;
            var bmd:BitmapData = new BitmapData(w, w);
            bmd.perlinNoise(32, 32, 3, 10000 * Math.random(), true, true);
            for (var y:int = 0; y < w;y++ ) {
                for (var x:int = 0; x < w;x++ ) {
                    vin.push((x / w - .5)*1000, ((0xff&bmd.getPixel(x,y))/0xff-.5)*100, (y / w - .5)*1000);
                    if (x!=w-1&&y!=w-1) {
                        ins.push(y * w + x, y * w + x + 1, (y + 1) * w + x);
                        ins.push(y * w + x + 1, (y + 1) * w + 1 + x, (y + 1) * w + x);
                    }
                }
            }
			var node:Node3D = new Node3D;
			node.frustumCulling = null;
			var drawable:Drawable3D = new Drawable3D;
			drawable.indexBufferSet = new IndexBufferSet(ins.length, ins, 0, bv.instance3Ds[0]);
			drawable.xyz = new VertexBufferSet(vin.length / 3, 3, vin, 0, bv.instance3Ds[0]);
			MeshUtils.computeNorm(drawable);
			node.drawable = drawable;
			node.material = new PhongMaterial(bv.instance3Ds[0], light, [.2, .2, .2], [Math.random()/2+.5,Math.random()/2+.5,Math.random()/2+.5], [.8, .8, .8], 200);
			root3d.add(node);
			
			var triangleIndexArray:btTriangleIndexVertexArray = btTriangleIndexVertexArray.create();
			var iptr:int = CModule.alloca(4 * ins.length);
			CModule.writeIntVector(iptr, Vector.<int>(ins));
			
			var vptr:int = CModule.alloca(8 * vin.length);
			var p:int = vptr;
			for (var i:int = 0; i < vin.length;i++,p+=8 ) {
				CModule.writeDouble(p, vin[i]);
			}
			
			var imesh:btIndexedMesh = btIndexedMesh.create();
			imesh.m_numTriangles = ins.length/3;
			imesh.m_numVertices = vin.length/3;
			imesh.m_triangleIndexBase = iptr;
			imesh.m_vertexBase = vptr;
			imesh.m_triangleIndexStride = 3 * 4;
			imesh.m_vertexStride = 8*3;
			
			triangleIndexArray.addIndexedMesh(imesh.swigCPtr,0);
			var bvhTriangleShape:btBvhTriangleMeshShape = btBvhTriangleMeshShape.create(triangleIndexArray.swigCPtr, false,true);
			spawnRigidBody(bvhTriangleShape, 1, 1, 1, 0, 0, 5, 0,node);
		}
		
		private function spawnCube(x:Number, y:Number, z:Number, mass:Number, w:Number, h:Number, d:Number):btRigidBody
	    {
	    	return spawnRigidBody(
	    		btBoxShape.create(vector(w/2,h/2,d/2)),
	    		w,h,d,
	    		mass,
	    		x, y, z
			);
	    }
		
		private function spawnRigidBody(shape:*, w:Number,h:Number,d:Number, mass:Number, x:Number, y:Number, z:Number,node3d:Node3D=null):btRigidBody
	    {
			var inertia:btVector3 = btVector3.create()
			if(mass != 0)
				shape.calculateLocalInertia(mass, inertia.swigCPtr);
			trans = btTransform.create()
			trans.setIdentity()
			trans.setOrigin(vector(x, y, z))
			var ms:btDefaultMotionState = btDefaultMotionState.create(trans.swigCPtr, btTransform.getIdentity())

			var rbci:btRigidBodyConstructionInfo = btRigidBodyConstructionInfo.create(mass, ms.swigCPtr, shape.swigCPtr, inertia.swigCPtr)
			rbci.m_restitution = 0.1;
			rbci.m_friction = 1.0;

			var rb:btRigidBody = btRigidBody.create(rbci.swigCPtr)
			world.addRigidBody(rb.swigCPtr)

			meshes.push(node3d||addCube(null, x, y, z,0,0,0,w/2,h/2,d/2));
			
			bods.push(rb)

			return rb
	    }
		
		private static function vector(x:Number, y:Number, z:Number):int {
	      var vec:btVector3 = btVector3.create()
	      vec.setX(x)
	      vec.setY(y)
	      vec.setZ(z)
	      return vec.swigCPtr
	    }
		
		override public function enterFrame(e:Event):void 
		{
			CModule.serviceUIRequests();
			var i:int;
			for(i=0; i<1; i++)
				world.stepSimulation(1/60.0, 0, 0)

	        for (i = 0; i < meshes.length; i++) {
	        	//positionAndRotateMesh(meshes[i], bods[i])
	        	positionAndRotateMesh2(meshes[i], bods[i])
	        }
			bv.instance3Ds[0].render();	
			//trace(ctrl.position,ctrl.rotation);
		}
		
		private function positionAndRotateMesh2(node:Node3D, body:btRigidBody):void {
			helpTrans.swigCPtr = body.getWorldTransform();
			var m44:int = helpTrans.getBasis();
			helpM44[0] = CModule.readDouble(m44);
			helpM44[1] = CModule.readDouble(m44 + 32);//4
			helpM44[2] = CModule.readDouble(m44 + 64);//8
			helpM44[4] = CModule.readDouble(m44 + 8);//1
			helpM44[5] = CModule.readDouble(m44 + 40);//5
			helpM44[6] = CModule.readDouble(m44 + 72);//9
			helpM44[8] = CModule.readDouble(m44 + 16);//2
			helpM44[9] = CModule.readDouble(m44 + 48);//6
			helpM44[10] = CModule.readDouble(m44 + 80);//10
			var origin:int = helpTrans.getOrigin();
			helpM44[12] = CModule.readDouble(origin);//12
			helpM44[13] = CModule.readDouble(origin+8);//13
			helpM44[14] = CModule.readDouble(origin + 16);//14
			node.matrix.copyRawDataFrom(helpM44);
			node.matrix.prependScale(node.scale.x, node.scale.y, node.scale.z);
			node.matrixVersion++;
		}
		
	}
	
}