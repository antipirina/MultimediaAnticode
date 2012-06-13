package com.anticode.events 
{
	import flash.events.Event;
	import flash.text.TextField;
	
	/**
	 * ...
	 * @author Santiago J. Franzani
	 */
	public class GetTextEvent extends Event 
	{
		public var callbackFunction:Function;
		public var textField:TextField;
		public static var TEXT:String = "texto";
		public static var AUDIO_TEXT:String = "audioText";
		public var textID:String
		
		public function GetTextEvent(type:String, callbackFunction:Function, textID:String, textField:TextField = null, bubbles:Boolean=false, cancelable:Boolean=false) 
		{ 
			super(type, bubbles, cancelable);
			this.textField = textField;
			this.textID = textID;
			this.callbackFunction = callbackFunction;
		} 
		
		public override function clone():Event 
		{ 
			return new GetTextEvent(type, callbackFunction, textID, textField, bubbles, cancelable);
		} 
		
		public override function toString():String 
		{ 
			return formatToString("GetTextEvent", "type", "callbackFunction", "textID", "textField", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}