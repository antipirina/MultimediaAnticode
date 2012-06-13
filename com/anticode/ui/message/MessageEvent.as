package com.anticode.ui.message 
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author Santiago Franzani
	 */
	public class MessageEvent extends Event 
	{
		public static var ENDED:String = "ended";
		public static var SHOWING_MESSAGE:String = "showingMessage";
		
		public var messageID:String;
		
		public function MessageEvent(type:String, messageID:String, bubbles:Boolean=false, cancelable:Boolean=false) 
		{ 
			super(type, bubbles, cancelable);
			this.messageID = messageID;
		} 
		
		public override function clone():Event 
		{ 
			return new MessageEvent(type, messageID, bubbles, cancelable);
		} 
		
		public override function toString():String 
		{ 
			return formatToString("MessageEvent", "messageID", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}