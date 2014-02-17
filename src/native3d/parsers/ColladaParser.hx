package native3d.parsers;
import flash.display.BitmapData;
import flash.display3D.Context3DTextureFormat;
import flash.display3D.Context3DVertexBufferFormat;
import flash.events.Event;
import flash.geom.Matrix3D;
import flash.utils.ByteArray;
import flash.Vector;
import native3d.core.animation.Animation;
import native3d.core.animation.AnimationPart;
import native3d.core.animation.Channel;
import native3d.core.animation.Skin;
import native3d.core.BasicLight3D;
import native3d.core.Drawable3D;
import native3d.core.IndexBufferSet;
import native3d.core.Instance3D;
import native3d.core.Node3D;
import native3d.core.TextureSet;
import native3d.core.VertexBufferSet;
import native3d.materials.PhongMaterial;
import native3d.meshs.MeshUtils;
import xml.XPath;

/**
 * 参考文献
 * 
 * http://blog.csdn.net/qyfcool/article/details/6775309
 * http://www.the3frames.com/?p=788
* http://www.wazim.com/Collada_Tutorial_1.htm
 * @author lizhi http://matrix3d.github.io/
 */
class ColladaParser extends AbsParser
{
	private var dae:Xml;
	public var anms:Animation;
	public var skins:Vector<Skin>;
	public var id2node:Map<String,Node3D>;
	public var sid2node:Map<String,Node3D>;
	public var jointRoot:Node3D;
	public var texture:TextureSet;
	public function new(data:Dynamic) 
	{
		super(data);
		texture = new TextureSet();
		
	}
	
	override public function parser():Void {
		texture.setBmd(bmd, Context3DTextureFormat.BGRA);
		jointRoot = new Node3D();
		var xml:Xml = Xml.parse(cast(cast(data,ByteArray).toString(),String));
		dae = XPath.xpath(xml, "*")[0];
		var root:Xml = XPath.xpath(dae, "scene/instance_visual_scene")[0];
		id2node = new Map<String, Node3D>();
		sid2node = new Map<String, Node3D>();
		skins = new Vector<Skin>();
		node.type = Node3D.NODE_TYPE;
		buildNode(root, node);
		for (skin in skins) {
			skin.joints = new Vector<Node3D>();
			for (name in skin.jointNames) {
				skin.joints.push(sid2node.get(name));
			}
		}
		buildAnimation();
		dispatchEvent(new Event(Event.COMPLETE));
	}
	
	private function buildNode(xml:Xml, node:Node3D,isJoint:Bool=false):Void {
		var url = xml.get("url");
		if (url != null) {
			xml =  XPath.xpathNode(dae,"library_visual_scenes/visual_scene@id="+url.substr(1));
		}
		for (child in xml.elements()) {
			if (child.nodeName == "instance_controller") {
				var controllerId = child.get("url").substr(1);
				var controller = XPath.xpathNode(dae, "library_controllers/controller@id="+ controllerId);
				for (skin in controller.elements()) {
					if (skin.nodeName=="skin") {
						var meshNode = new Node3D();
						node.add(meshNode);
						var source = skin.get("source").substr(1);
						var dskin = buildGeometry(source);
						var drawableNode = new Node3D();
						meshNode.add(drawableNode);
						
						dskin.node = drawableNode;
						skins.push(dskin);
						dskin.bindShapeMatrix = str2Matrix(XPath.xpathNodeValue(skin, "bind_shape_matrix"));
						var vertexWeights =XPath.xpathNode(skin, "vertex_weights");
						var jointId = XPath.xpathNode(vertexWeights,"input@semantic=JOINT").get("source").substr(1);
						dskin.jointNames = str2Strs(XPath.xpathNodeValue(skin, "source@id=" + jointId+"/Name_array"));
						var weightId = XPath.xpathNode(vertexWeights,"input@semantic=WEIGHT").get("source").substr(1);
						dskin.weights = str2Floats(XPath.xpathNodeValue(skin, "source@id="+weightId+"/float_array"));
						dskin.vcount = str2Ints(XPath.xpathNodeValue(vertexWeights, "vcount"));
						dskin.v = str2Ints(XPath.xpathNodeValue(vertexWeights, "v"));
						var invBindMatrixId = XPath.xpathNode(skin,"joints/input@semantic=INV_BIND_MATRIX").get("source").substr(1);
						dskin.invBindMatrixs = str2Matrixs(XPath.xpathNodeValue(skin,"source@id="+invBindMatrixId+"/float_array"));
					}
				}
			}
			if (child.nodeName == "instance_geometry") {
				var source = child.get("url").substr(1);
				var nskin = buildGeometry(source);
				var drawableNode = new Node3D();
				var drawable:Drawable3D = new Drawable3D();
				drawableNode.drawable = drawable;
				var vin = new Vector<Float>();
				var uv = new Vector<Float>();
				var indexs = new Vector<UInt>();
				var ci = 0;
				for (i in 0...nskin.daeIndexs.length) {
					var daeIndexs:Vector<Int> = nskin.daeIndexs[i];
					var daeUVIndexs:Vector<Int> = nskin.daeUVIndexs[i];
					for (j in 0...daeIndexs.length) {
						indexs.push(ci++);
						var ji = daeIndexs[j];
						var juvi = daeUVIndexs[j];
						vin.push(nskin.daeXyz[ji*3]);
						vin.push(nskin.daeXyz[ji*3+1]);
						vin.push(nskin.daeXyz[ji*3+2]);
						uv.push(nskin.daeUV[juvi*2]);
						uv.push(nskin.daeUV[juvi*2+1]);
					}
				}
				drawable.xyz = new VertexBufferSet(untyped(vin.length / 3), 3, vin, 0);
				drawable.uv = new VertexBufferSet(untyped(uv.length / 2), 2, uv, 0);
				drawable.indexBufferSet = new IndexBufferSet(indexs.length, indexs, 0);
				MeshUtils.computeNorm(drawable);
				drawableNode.material = new PhongMaterial(null,null,null,200,texture.texture);
				node.add(drawableNode);
			}
		}
		for (child in xml.elements()) {
			if (child.nodeName == "node") {
				var childNode = new Node3D();
				node.add(childNode);
				id2node.set(child.get("id"), childNode);
				if (child.get("type") == "NODE") {
					childNode.type = Node3D.NODE_TYPE;
				}else if (child.get("type") == "JOINT") {
					if (node.type==Node3D.NODE_TYPE&&!isJoint) {
						isJoint = true;
						jointRoot.add(node);
					}else {
					}
					sid2node.set(child.get("sid"), childNode);
					childNode.type = Node3D.JOINT_TYPE;
				}
				childNode.name = child.get("name");
				var matrixXml = XPath.xpathNode(child, "matrix");
				if(matrixXml!=null){
					var matrix:Matrix3D = str2Matrix(matrixXml.firstChild().nodeValue);
					childNode.matrix.copyFrom(matrix);
					childNode.matrixVersion++;
				}
				buildNode(child, childNode,isJoint);
			}
		}
	}
	
	private function buildGeometry(source:String):Skin {
		var geometry = XPath.xpathNode(dae, "library_geometries/geometry@id="+source);
		var mesh = XPath.xpathNode(geometry, "mesh");
		var vertices = XPath.xpathNode(mesh, "vertices");
		var vlib = getVerticesById(vertices.get("id"), mesh);
		
		var dskin = new Skin();
		dskin.texture = texture;
		var vs = str2Floats(XPath.xpathNodeValue(vlib, "float_array"));
		dskin.daeXyz = vs;
		dskin.daeIndexs = new Vector<Vector<Int>>();
		dskin.daeUVIndexs = new Vector<Vector<Int>>();
		for (triangle in mesh.elements()) {
			// TODO : polylist
			if (triangle.nodeName == "triangles") {
				if (dskin.daeUV==null) {
					dskin.daeUV = str2Floats(XPath.xpathNodeValue(getVerticesById(
						XPath.xpathNode(triangle, "input@semantic=TEXCOORD").get("source").substr(1), mesh)
						,"float_array"));
				}
				var inc:Vector<Int> = new Vector<Int>();
				var uv:Vector<Int> = new Vector<Int>();
				dskin.daeIndexs.push(inc);
				dskin.daeUVIndexs.push(uv);
				var materialName = triangle.get("material");
				var parray = str2Ints(XPath.xpathNodeValue(triangle, "p"));
				var i = 0;
				var len = parray.length;
				var maxOffset = 0;
				var vertexOffset = 0;
				var uvOffset = 0;
				for (child in triangle.elements()) {
					if (child.nodeName == "input") {
						var offset = Std.parseInt(child.get("offset"));
						if (offset > maxOffset) maxOffset = offset;
						if (child.get("semantic")=="VERTEX") {
							vertexOffset = offset;
						}else if (child.get("semantic")=="TEXCOORD") {
							uvOffset = offset;
						}
					}
				}
				var adder = maxOffset + 1;
				dskin.maxOffset = maxOffset;
				dskin.vertexOffset = vertexOffset;
				dskin.uvOffset = uvOffset;
				while (i < len) {
					inc.push(parray[i+vertexOffset]);
					inc.push(parray[i  +vertexOffset +adder*2]);
					inc.push(parray[i +vertexOffset+ adder]);
					
					uv.push(parray[i + uvOffset]);
					uv.push(parray[i + uvOffset+adder*2]);
					uv.push(parray[i + uvOffset+adder]);
					i += adder*3;
				}
			}
		}
		return dskin;
	}
	
	private function buildAnimation():Void {
		var areg = ~/(.+)\/(.+)\((\d+)\)\((\d+)\)/;
		var areg2 = ~/(.+)\/(.+)/;
		anms = new Animation();
		anms.jointRoot = jointRoot;
		for (child in dae.elements()) {
			if (child.nodeName == "library_animations") {
				for (xa in child.elements()) {
					if (xa.nodeName=="animation") {
						var anm = new AnimationPart();
						anms.parts.push(anm);
						for (channel in xa.elements()) {
							if (channel.nodeName == "channel") {
								var sourceId = channel.get("source").substr(1);
								var sampler = XPath.xpathNode(xa, "sampler@id="+sourceId);
								var inputId =XPath.xpathNode(sampler,"input@semantic=INPUT").get("source").substr(1);
								var outputId = XPath.xpathNode(sampler, "input@semantic=OUTPUT").get("source").substr(1);
								var input = str2Floats(XPath.xpathNodeValue(xa, "source@id=" + inputId + "/float_array"));
								var output = str2Floats(XPath.xpathNodeValue(xa, "source@id=" + outputId + "/float_array"));
								for (tt in input) {
									if (anms.maxTime < tt) anms.maxTime = tt;
								}
								var target = channel.get("target");
								var can = new Channel();
								if (areg.match(target)) {
									var targetId = areg.matched(1);
									anm.target = id2node.get(targetId);
									var targetKey = areg.matched(2);
									if(targetKey=="transform"){
										var x = Std.parseInt(areg.matched(3));
										var y = Std.parseInt(areg.matched(4));
										can.input = input;
										can.output = output;
										can.index = y + x * 4;
										if (can.index != 15) {
											anm.channels.push(can);
										}
									}
									
								}else {
									if (areg2.match(target)) {
										var targetId = areg2.matched(1);
										anm.target = id2node.get(targetId);
										var targetKey = areg2.matched(2);
										if(targetKey=="transform"){
											can.input = input;
											can.outputMatrix3Ds = floats2Matrixs(output);
											can.index = -1;
											anm.channels.push(can);
										}
									}else {
										throw "error";
									}
								}
							}
						}
					}
				}
			}
		}
		
		anms.startCache(skins);
	}
}