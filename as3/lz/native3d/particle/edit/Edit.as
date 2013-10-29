package lz.native3d.particle.edit 
{
	import com.bit101.charts.BarChart;
	import com.bit101.charts.Chart;
	import com.bit101.charts.LineChart;
	import com.bit101.charts.PieChart;
	import com.bit101.components.FPSMeter;
	import com.bit101.components.HUISlider;
	import com.bit101.components.InputButton;
	import com.bit101.components.Label;
	import com.bit101.components.PushButton;
	import com.bit101.components.Window;
	import com.bit101.utils.MinimalConfigurator;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	/**
	 * ...
	 * @author lizhi
	 */
	public class Edit extends Sprite
	{
		
		public function Edit() 
		{
			var num:String = "0123456789";
			var xml:XML =
				<comps>
					<Panel/>
					<Window width="400" height="400" hasMinimizeButton="true" hasCloseButton="true">
						<VBox>
							<HBox>
								<CheckBox label="dsafd"/><HUISlider minimum="-100"/><InputText restrict={num}/>
							</HBox>
							<HBox><HUISlider/></HBox>
							<HBox><Label text="mlable"/></HBox>
							<HBox><Label text="mlable"/></HBox>
						</VBox>
					</Window>
					<Window>
					</Window>
				</comps>
			//http://www.minimalcomps.com/?page_id=14
			var config:MinimalConfigurator = new MinimalConfigurator(this);
			//config.parseXML(xml);
			
			var inputBtn:InputButton = new InputButton;
			addChild(inputBtn);
		}
		
		private function btn_mouseDown(e:MouseEvent):void 
		{
			
		}
		
	}

}