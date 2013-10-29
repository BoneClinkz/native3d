package com.bit101.components 
{
	/**
	 * ...
	 * @author lizhi
	 */
	public class InputButton extends Component
	{
		public var input:InputText;
		public var button:PushButton;
		public function InputButton() 
		{
			input = new InputText(this);
			button = new PushButton(this);
		}
		
	}

}