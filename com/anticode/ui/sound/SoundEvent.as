package com.anticode.ui.sound
{
	import flash.events.Event;
	import flash.media.Sound;

	/**
	 * ...
	 * @author Santiago J. Franzani
	 */
	public class SoundEvent extends Event
	{
		static public var TRIGGER_SOUND:String = "triggerSound";
		
		static public var NORMAL_MODE:String = "normal";
		static public var CROSSFADE_MODE:String = "crossfade";
		static public var VOICEOVER_MODE:String = "voiceOver";
		
		public var soundID:String;
		public var mode:String;
		public var fadeInMs:Number;
		public var volume:Number;

		public function SoundEvent(type:String, soundID:String = null, fadeInMs:Number = 0, volume:Number = 1, mode:String = "normal", bubbles:Boolean = true, cancelable:Boolean = false)
		{
			super(type, bubbles, cancelable);
			this.volume = volume;
			this.fadeInMs = fadeInMs;
			this.mode = mode;
			this.soundID = soundID;
		}

		public override function clone():Event
		{
			return new SoundEvent(type, soundID, fadeInMs, volume, mode, bubbles, cancelable);
		}

		public override function toString():String
		{
			return formatToString("SoundEvent", "soundID", "fadeInMs", "volume", "mode", "bubbles", "cancelable", "eventPhase");
		}

	}

}
