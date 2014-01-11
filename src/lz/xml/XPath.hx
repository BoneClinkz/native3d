package lz.xml;

/**
 * var xml = Xml.parse("<x><n id='2'>a<a>av</a></n></x>");
 * trace(XPath.xpath(xml,"x.n@id=2.a"));//[<a>av</a>]
 * 
 * @author lizhi
 */
class XPath
{

	public function new() 
	{
		
	}
	
	static public function xpath(xml:Xml,exp:String):Dynamic {
		var exps = exp.split(".");
		var xmls = [xml];
		for (exp in exps) {
			var newXmls = new Array<Xml>();
			for (x in xmls) {
				for (cx in x.elements()) {
					newXmls.push(cx);
				}
			}
			xmls = get(newXmls, exp);
		}
		return xmls;
	}
	
	static public function get(list:Array<Xml>, exp:String):Array<Xml> {
		var xmls = new Array<Xml>();
		var attIndex = exp.indexOf("@");
		var name:String;
		var attName:String=null;
		var attValue:String=null;
		if (attIndex>0) {
			name = exp.substr(0, attIndex);
			var eqIndex = exp.indexOf("=");
			if (eqIndex>0) {
				attName = exp.substr(attIndex + 1, eqIndex - attIndex - 1);
				attValue = exp.substr(eqIndex + 1);
			}
		}else {
			name = exp;
		}
		for (xml in list) {
			
			if (xml.nodeName == name) {
				if(attName==null||xml.get(attName)==attValue)
					xmls.push(xml);
			}
		}
		return xmls;
	}
}