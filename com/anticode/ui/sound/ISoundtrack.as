package com.anticode.ui.sound 
{
	import org.osflash.signals.Signal;
	
	/**
	 * ...
	 * @author Santiago J. Franzani
	 */
	public interface ISoundtrack 
	{
		function play(soundID:String,soundFile:*,loopeable:Boolean = false, vol:Number = 1,fadeInMs:Number = 0):ISoundclip
		function stop(soundID:String = "", fadeOutMs:Number = 0,removeFromPool:Boolean = true):void 
		function pause(value:Boolean, soundID:String = ""):void
		function pauseMaster(value:Boolean):void
		
		function voiceOver(soundID:String,soundFile:*,oldSoundVol:Number = 0.5, newSoundVol:Number = 1,crossTime:Number = 1000):ISoundclip
		function crossFade(soundID:String,soundFile:*,loopeable:Boolean = false,newSoundVol:Number = 1,crossTime:Number = 1000):ISoundclip
		
		
		function setVol(vol:Number, soundID:String = "", fadeMs:Number = 0):void
		function setPan(pan:Number, soundID:String = "", fadeMs:Number = 0):void
		function setMasterVol(vol:Number, fadeMs:Number = 0):void
		function setMasterPan(pan:Number, fadeMs:Number = 0):void
		
		function muteGUI(value:Boolean, soundID:String = ""):void
		function disable(value:Boolean, soundID:String = ""):void	
		
		function muteMasterGUI(value:Boolean):void
		function masterDisable(value:Boolean):void
		
		function isMutedGUI(soundID:String = ""):Boolean
		function isDisabled(soundID:String = ""):Boolean
		function isPlaying(soundID:String = ""):Boolean
		function getSoundClip(soundID:String):ISoundclip
		
		
		function get disabledSignal():Signal 
		function get errorSignal():Signal 
		function get startedSignal():Signal 
		function get finishedSignal():Signal 
		function get pausedSignal():Signal 
		function get stopedSignal():Signal 
		function get mutedSignal():Signal 
		function get fadeSignal():Signal 
		
		 
		function destroy():void
	}
	
}