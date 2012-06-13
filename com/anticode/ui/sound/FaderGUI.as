package com.anticode.ui.sound 
{
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	/**
	 * ...
	 * @author Santiago J. Franzani
	 */
	public class FaderGUI 
	{
		private var back_mc:MovieClip;
		private var handler_mc:MovieClip;
		private var mute_mc:MovieClip;
		protected var trackID:String;
		private var _muted:Boolean = false;
		
		public function FaderGUI(trackID:String = "") 
		{
			this.trackID = trackID;
		}
		public function setHandler(mc:MovieClip):void
		{
			handler_mc = mc;
		}
		public function setBack(mc:MovieClip):void
		{
			back_mc = mc;
		}
		public function setMute(mc:MovieClip):void
		{
			mute_mc = mc;
		}
		public function init():void 
		{
			if (handler_mc && !back_mc) throw new Error("Se ha configurado un handler, pero no un Back");
			if (handler_mc && back_mc)
			{
				handler_mc.x = back_mc.x + back_mc.width - handler_mc.width / 2;
				handler_mc.y = back_mc.y;
				handler_mc.addEventListener(MouseEvent.MOUSE_DOWN, onHandlerPress);
				handler_mc.addEventListener(MouseEvent.MOUSE_UP, onHandlerRelease);
				handler_mc.buttonMode = true;
				
				back_mc.addEventListener(MouseEvent.MOUSE_DOWN, onBackPress);
				back_mc.buttonMode = true;
				
				
			}
			
			if (mute_mc)
			{
				mute_mc.addEventListener(MouseEvent.CLICK, onMuteClic);
				mute_mc.buttonMode = true;
			}
			
		}
		

		
		private function onHandlerPress(e:MouseEvent = null ):void 
		{
			handler_mc.stage.addEventListener(MouseEvent.MOUSE_UP, onHandlerRelease);
			handler_mc.startDrag(false, new Rectangle(back_mc.x+handler_mc.width/2, back_mc.y, back_mc.width-handler_mc.width, 0));
			handler_mc.addEventListener(Event.ENTER_FRAME, onRefreshVolume);
		}
		
		private function onBackPress(e:MouseEvent):void 
		{
			handler_mc.x = back_mc.mouseX+handler_mc.width/2;
			onHandlerPress();
		}
		
		private function onRefreshVolume(e:Event):void 
		{
			var min:Number = back_mc.x + handler_mc.width / 2;
			var max:Number = back_mc.x + back_mc.width - handler_mc.width/2;
			
			var finalVol:Number = (handler_mc.x - min) / (max - min);
			SoundManager.getInstance().setVol(finalVol, trackID);
		}
		
		private function onHandlerRelease(e:MouseEvent):void 
		{
			handler_mc.stopDrag();
			handler_mc.stage.removeEventListener(MouseEvent.MOUSE_UP, onHandlerRelease);
			handler_mc.removeEventListener(Event.ENTER_FRAME, onRefreshVolume);
		}
		
		private function onMuteClic(e:MouseEvent):void 
		{
			muted = !muted;
			SoundManager.getInstance().muteGUI(muted, trackID);
			SoundManager.getInstance().isMutedGUI(trackID);
		}
		
		public function get muted():Boolean 
		{
			return _muted;
		}
		
		public function set muted(value:Boolean):void 
		{
			_muted = value;
			if (_muted) {
				mute_mc.gotoAndStop(2);
			}else {
				mute_mc.gotoAndStop(1);
			}
		}
		
	}

}