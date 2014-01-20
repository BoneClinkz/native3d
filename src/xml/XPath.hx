package xml;

/**
 * var xml = Xml.parse("<x><n id='2'>a<a>av</a></n></x>");
 * 
 * trace(XPath.xpath(xml,"x.n@id=2.a"));
 * //[<a>av</a>]
 * 
 * trace(XPath.xpathNodeValue(xml,"x.n@id=2.a"));
 * //av
 * 
 * trace(XPath.xpathAttValue(xml,"x.n","id"));
 * 2
 * 
 * @author lizhi
 */
class XPath
{
	static public function xpathAttValue(xml:Xml, exp:String,attName:String):String {
		var xmls = xpath(xml, exp);
		if (xmls.length>0) {
			return xmls[0].get(attName);
		}
		return null;
	}
	static public function xpathNodeValue(xml:Xml, exp:String):String {
		var xmls = xpath(xml, exp);
		if (xmls.length>0) {
			return xmls[0].firstChild().nodeValue;
		}
		return null;
	}
	static public function xpath(xml:Xml,exp:String):Array<Xml> {
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