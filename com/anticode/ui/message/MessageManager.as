package com.anticode.ui.message
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.getDefinitionByName;
	import flash.utils.Timer;
	import com.anticode.access.AccessManager;
	import com.anticode.access.Section;
	/**
	 * ...
	 * @author Santiago Franzani
	 * Requiere a textfield in the asset called: mensaje_field
	 * Implementation:
	 * SINLETON
	 * First:
	 * setAssetClassName(asset:String) // This set the textfield asset. It will look up the string in the flash library and then create it.
	 * addMessage(text:string, time:int, messageID[optional]) // add a new message and show it during the time. If time not set, it will show the message until endMessge it's called.
	 * endMessage(messageID:string) // used if the message has no time seted. 
	 */
	public class MessageManager extends MovieClip
	{
		private var messages_arr:Array;
		private var currentMessage:MessageBox;
		private var messageTimer:Timer;
		private var msgAsset_str:String;
		private var butAsset_str:String;

		private static var instance:MessageManager;
		private static var allowInstance:Boolean = false;

		public function MessageManager()
		{
			if (allowInstance)
			{
				messages_arr = new Array();
			}else {
				throw new Error("SINGLETON: use getInstance()");
			}
		}
		public static function getInstance():MessageManager
		{
			if (!instance)
			{
				allowInstance = true;
				instance = new MessageManager();
				allowInstance = false;
			}
			return instance;
		}
		public function setAssetClassName(msgAsset_str:String,butAsset_str:String):void
		{
			this.msgAsset_str = msgAsset_str;
			this.butAsset_str = butAsset_str;
		}
		//Add a message to the be shown. ms is te time, messageID is for the event dispatched when the message ends.
		public function addMessage(text:String,ms:int = 0,messageID:String = null,...button:Array):void
		{
			for (var i:int = 0; i < messages_arr.length; i++)
			{
				if ((messages_arr[i] as MessageBox).messageID == messageID)
				{
					return;
				}
			}
			var menssageAsset:Class = getDefinitionByName(msgAsset_str) as Class;
			var newMessage:MessageBox = new MessageBox(new menssageAsset(), text, ms, messageID,butAsset_str,button);
			messages_arr.push(newMessage);
			checkNextMessage();
		}
		public function endMessage(messageID:String):void
		{
			if (currentMessage.messageID == messageID)
			{
				currentMessage.hide();
			}else
			{
				eraseMessage(messageID);
			}
		}
		private function checkNextMessage():void
		{
			if (messages_arr.length != 0)
			{
				if (messages_arr[0].isShowing == false)
				{
					showNewMessage(messages_arr[0]);
				}
			}
		}

		private function showNewMessage(message:MessageBox):void
		{
			currentMessage = message;
			addChild(currentMessage);
			currentMessage.addEventListener("end", destroyMessage);

			if (currentMessage.ms != 0 && currentMessage.buttons_arr.length == 0)
			{
				messageTimer = new Timer(currentMessage.ms, 1);
				messageTimer.addEventListener(TimerEvent.TIMER_COMPLETE, messageTimeEnded);
				messageTimer.start();
			}
			currentMessage.show();
			AccessManager.getInstance().focusMessageBox();
		}

		private function messageTimeEnded(e:TimerEvent):void
		{
			messageTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, messageTimeEnded);
			currentMessage.hide();
		}

		private function destroyMessage(e:Event):void
		{
			if (messageTimer)
			{
				messageTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, messageTimeEnded);
				messageTimer = null
			}
			AccessManager.getInstance().unfocusMessageBox();
			eraseMessage(currentMessage.messageID);
			if (numChildren > 0)removeChild(currentMessage);
			checkNextMessage();
			dispatchEvent(new MessageEvent(MessageEvent.ENDED, currentMessage.messageID));
		}
		private function eraseMessage(messageID:String):void
		{
			for (var i:int = 0; i < messages_arr.length; i++)
			{
				if (messages_arr[i].messageID == messageID)
				{
					messages_arr.splice(i, 1);
				}
			}
		}
		public function getButtons():Array
		{
			return (messages_arr[messages_arr.length - 1] as MessageBox).getButtons();
		}
	}

}

