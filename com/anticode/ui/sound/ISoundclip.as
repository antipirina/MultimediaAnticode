package com.anticode.ui.sound 
{
	import flash.media.Sound;
	import flash.media.SoundTransform;
	import org.osflash.signals.Signal;
	
	/**
	 * ...
	 * @author Santiago J. Franzani
	 */
	public interface ISoundclip 
	{
		function play(soundFile:*, loopeable:Boolean, track_st:SoundTransform, clip_st:SoundTransform,fadeInMs:Number = 0, bufferTime:int = -1):void 
		function stop(fadeOutMs:Number = 0,removeFromPool:Boolean = false):void
		function pause(value:Boolean):void
			
		function fadeVol(vol:Number, timeMs:Number):void
		function fadePan(pan:Number, fadeMs:Number):void;
		
		function fadeTrackVol(vol:Number, timeMs:Number):void
		function fadeTrackPan(pan:Number, timeMs:Number):void
		
		function muteGUI(value:Boolean):void
		function disable(value:Boolean):void
		
		function muteTrackGUI(value:Boolean):void
		function disableTrack(value:Boolean):void
		
		function destroy():void
		
		function get volume():Number 
		function set volume(value:Number):void 
		
		function getID():String
		
		function isMutedGUI():Boolean
		function isDisabled():Boolean
		function isPlaying():Boolean
		function getPosition():Number
		function getPausePoint():Number
		function getSoundObject():Sound;
		
		function get disabledSignal():Signal 
		function get errorSignal():Signal 
		function get startedSignal():Signal 
		function get finishedSignal():Signal 
		function get pausedSignal():Signal 
		function get stopedSignal():Signal 
		function get mutedSignal():Signal 
		function get fadeSignal():Signal 
		function get fadeInMs():Number 		
		function set fadeInMs(value:Number):void 
		function get removeFromPool():Boolean
		function set removeFromPool(value:Boolean):void 

	}
	
}