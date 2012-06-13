package com.anticode.ui.message 
{
	import com.anticode.access.AccessModel;
	/**
	 * ...
	 * @author Santiago Franzani
	 */
	public class MessageButton
	{
		public var audio:String;
		public var key:String;
		public var alt:Boolean;
		public var shift:Boolean;
		public var ctrl:Boolean;
		public var tooltip:String;
		public var text:String;
		public var butFunction:Function;
		
		public function MessageButton(buttonID:String, section:String = null, butFunction:Function = null) 
		{
			var text_obj:Object = AccessModel.getInstance().getText(buttonID, section);
			var access_obj:Object = AccessModel.getInstance().getAccessData(buttonID, section);
			
			this.tooltip = access_obj.tooltip;
			this.key = access_obj.key;
			this.alt = access_obj.alt;
			this.shift = access_obj.shift;
			this.ctrl = access_obj.ctrl;
			
			
			if (StringUtils.hasText(text_obj.audio))this.audio = text_obj.audio;
			this.text = text_obj.text;
			this.butFunction = butFunction;
		}
		
	}

}