package com.anticode.ui.sound 
{
	import com.greensock.TweenLite;
	import flash.media.Sound;
	import flash.utils.Dictionary;
	import org.osflash.signals.Signal;
	/**
	 * ...
	 * @author Santiago J. Franzani
	 */
	public class SoundManager 
	{
		static public var ACCESS_TRACK:String = "accessTrack";
		static public var SPEECH_TRACK:String = "speechTrack";
		static public var EVENTS_TRACK:String = "eventsTrack";
		static public var FEEDBACK_TRACK:String = "feedTrack";
		static public var MUSIC_TRACK:String = "musicTrack";
		static public var ZONE_TRACK:String = "zoneTrack";
		static public var AMBIENT_TRACK:String = "ambientTrack";
		static public var OFF_TRACK:String = "offTrack";
		
		static private var _instance:SoundManager;
		static private var allowInstance:Boolean = false;
		
		private var trackDict:Dictionary;
		private var muted:Boolean = false;
		private var disabled:Boolean = false;
		private var masterVolume:Number = 1;
		private var masterPan:Number = 0;
		private var paused:Boolean;
		
		public var errorSignal:Signal;
		public var startedSignal:Signal;
		public var finishedSignal:Signal;
		public var pausedSignal:Signal;
		public var stopedSignal:Signal;
		public var mutedSignal:Signal;
		public var disabledSignal:Signal;
		public var fadeSignal:Signal;
		
		
		
		public function SoundManager()
		{
			if (!allowInstance) throw Error ("Singleton: use getInstance()");
			
			trackDict = new Dictionary();
			
			errorSignal = new Signal(String,String,String);
			startedSignal = new Signal(String,String,Sound);
			finishedSignal = new Signal(String,String);
			pausedSignal = new Signal(String,String,Boolean);
			stopedSignal = new Signal(String,String);
			mutedSignal = new Signal(String,String,Boolean);
			disabledSignal = new Signal(String,String,Boolean);
			fadeSignal = new Signal(String, String,Number);
			
		}
		public static function getInstance():SoundManager
		{
			if (!_instance)
			{
				allowInstance = true;
				_instance = new SoundManager();
				allowInstance = false;
			}
			return _instance
		}
		public function addTrack(trackID:String, initVol:Number = 1):ISoundtrack
		{
			trackDict[trackID] = new Soundtrack(trackID, masterVolume,masterPan, muted,disabled,initVol,0);
			return trackDict[trackID];
		}
		public function getTrack(trackID:String):ISoundtrack
		{
			return trackDict[trackID];
		}
		public function getSoundClip(trackID:String, soundID:String):ISoundclip
		{
			if (!isTrackExist(trackID)) return null;
			return (trackDict[trackID] as ISoundtrack).getSoundClip(soundID);
		}
		
		private function isTrackExist(trackID:String):Boolean
		{
			if (!(trackDict[trackID] as ISoundtrack)) return false;
			return true;
		}
		//TODO: agregar un onComplete function.
		public function play(trackID:String, soundID:String, soundFile:*, loopeable:Boolean = false, vol:Number = 1,fadeInMs:Number = 0):ISoundclip
		{
			if (!isTrackExist(trackID)) addTrack(trackID);
			(trackDict[trackID] as ISoundtrack).finishedSignal.addOnce(onFinished);
			(trackDict[trackID] as ISoundtrack).startedSignal.addOnce(onStarted);
			(trackDict[trackID] as ISoundtrack).errorSignal.addOnce(onLoadError);
			return (trackDict[trackID] as ISoundtrack).play(soundID, soundFile, loopeable, vol,fadeInMs);
		}
		
		///TODO: revisar si está corriendo y ejecutar un stop. (para evitar el isPlaying en el client)
		public function stop(trackID:String = "", soundID:String = "",fadeOutMs:Number = 0):void
		{
			if (trackID != "")
			{
				if (!isTrackExist(trackID)) return;
				(trackDict[trackID] as ISoundtrack).stopedSignal.addOnce(onStopped);
				(trackDict[trackID] as ISoundtrack).stop(soundID, fadeOutMs,true);			
			}
			for each (var soundtrack:ISoundtrack in trackDict)
			{
				soundtrack.stop("", fadeOutMs);
			}
			if (trackID == "") TweenLite.delayedCall(fadeOutMs / 1000, onStopped, ["",""]);
		}
		public function pause(value:Boolean, trackID:String = "", soundID:String = ""):void
		{
			if (trackID != "")
			{
				if (!isTrackExist(trackID)) return;
				(trackDict[trackID] as ISoundtrack).pausedSignal.addOnce(onPaused);
				(trackDict[trackID] as ISoundtrack).pause(value, soundID);
				return;
			}
			for each (var soundtrack:ISoundtrack in trackDict)
			{
				//soundtrack.pausedSignal.addOnce(onPaused);
				soundtrack.pauseMaster(value);
			}
			paused = value;
			soundtrack.pausedSignal.dispatch("", "", value);
		}
		public function voiceOver(trackID:String, soundID:String, soundFile:*, oldSoundVol:Number = 0.5, newSoundVol:Number = 1, crossTime:Number = 1000):ISoundclip
		{
			if (!isTrackExist(trackID)) addTrack(trackID);
			(trackDict[trackID] as ISoundtrack).startedSignal.addOnce(onStarted);
			(trackDict[trackID] as ISoundtrack).errorSignal.addOnce(onLoadError);
			return (trackDict[trackID] as ISoundtrack).voiceOver(soundID, soundFile, oldSoundVol, newSoundVol, crossTime);
		}
		public function crossFade(trackID:String, soundID:String, soundFile:*, loopeable:Boolean = false, newSoundVol:Number = 1, crossTime:Number = 1000):ISoundclip
		{
			if (!isTrackExist(trackID)) addTrack(trackID);
			(trackDict[trackID] as ISoundtrack).startedSignal.addOnce(onStarted);
			(trackDict[trackID] as ISoundtrack).errorSignal.addOnce(onLoadError);
			return (trackDict[trackID] as ISoundtrack).crossFade(soundID, soundFile, loopeable, newSoundVol, crossTime);
		}

		public function setVol(vol:Number, trackID:String = "", soundID:String = "", fadeMs:Number = 0):void
		{
			if (trackID != "")
			{
				if (!isTrackExist(trackID)) addTrack(trackID);
				(trackDict[trackID] as ISoundtrack).fadeSignal.addOnce(onFaded);
				(trackDict[trackID] as ISoundtrack).setVol(vol, soundID, fadeMs);
				return;
			}
			for each (var soundtrack:ISoundtrack in trackDict)
			{
				soundtrack.setMasterVol(vol, fadeMs);
			}
			masterVolume = vol;
			fadeSignal.dispatch(trackID, soundID,vol);
		}
		public function setPan(pan:Number, trackID:String = "", soundID:String = "", fadeMs:Number = 0):void
		{
			if (trackID != "")
			{
				if (!isTrackExist(trackID)) return;
				(trackDict[trackID] as ISoundtrack).setPan(pan, soundID, fadeMs);
				return;
			}
			for each (var soundtrack:ISoundtrack in trackDict)
			{
				soundtrack.setMasterPan(pan, fadeMs);
			}
			masterPan = pan;
		}
		public function muteGUI(value:Boolean, trackID:String = "", soundID:String = ""):void
		{
			if (trackID != "")
			{
				if (!isTrackExist(trackID)) return;
				(trackDict[trackID] as ISoundtrack).mutedSignal.addOnce(onMuted);
				(trackDict[trackID] as ISoundtrack).muteGUI(value, soundID);
				return;
			}
			
			for each (var soundtrack:ISoundtrack in trackDict)
			{
				soundtrack.muteMasterGUI(value);
			}
			mutedSignal.dispatch("", "", value);
			muted = value;
		}
		public function disable(value:Boolean, trackID:String = "", soundID:String = ""):void
		{
			if (trackID != "")
			{
				if (!isTrackExist(trackID)) return;
				(trackDict[trackID] as ISoundtrack).disabledSignal.addOnce(onDisabled);
				(trackDict[trackID] as ISoundtrack).disable(value, soundID);
				return;
			}
			for each (var soundtrack:ISoundtrack in trackDict)
			{
				soundtrack.masterDisable(value);
			}
			disabledSignal.dispatch("", "", value);
			disabled = value;
		}
		
		public function isMutedGUI(trackID:String = "", soundID:String = ""):Boolean
		{
			if (trackID != "")
			{
				if (!isTrackExist(trackID)) return false;
				return (trackDict[trackID] as ISoundtrack).isMutedGUI(soundID);
			}
			return muted;
		}
		public function isDisabled(trackID:String = "", soundID:String = ""):Boolean
		{
			if (trackID != "")
			{
				if (!isTrackExist(trackID)) return false;
				return (trackDict[trackID] as ISoundtrack).isDisabled(soundID);
			}
			return disabled;
		}
		public function isPlaying(trackID:String = "", soundID:String = ""):Boolean
		{
			if (trackID != "")
			{
				if (!isTrackExist(trackID)) return false;
				return (trackDict[trackID] as ISoundtrack).isPlaying(soundID);
			}
			return !paused;
		}
		
		public function reset():void
		{
			for each (var soundtrack:ISoundtrack in trackDict)
			{
				soundtrack.destroy();
			}
			
			errorSignal.removeAll();
			startedSignal.removeAll();
			finishedSignal.removeAll();
			pausedSignal.removeAll();
			stopedSignal.removeAll();
			mutedSignal.removeAll();
			disabledSignal.removeAll();
			fadeSignal.removeAll();
			trackDict = new Dictionary();
			muted = false;
			disabled = false;
		}
		
		
		
		/* signal handlers */
		
		private function onLoadError(trackID:String,clipID:String,error:String):void 
		{
			if (errorSignal.numListeners < 2)
			{
				trace("Falló la carga del archivo: " + clipID + " en la pista " + trackID + " / " + error);
			}else {
				errorSignal.dispatch(trackID, clipID, error);
			}
		}
		private function onFinished(trackID:String,clipID:String):void 
		{
			finishedSignal.dispatch(trackID, clipID);
		}
		private function onStarted(trackID:String,clipID:String,soundObject:Sound):void 
		{
			startedSignal.dispatch(trackID, clipID,soundObject);
		}
		private function onStopped(trackID:String,clipID:String):void 
		{
			stopedSignal.dispatch(trackID, clipID);
		}
		private function onPaused(trackID:String,clipID:String,value:Boolean):void 
		{
			pausedSignal.dispatch(trackID, clipID, value);
		}
		private function onMuted(trackID:String,clipID:String,value:Boolean):void 
		{
			mutedSignal.dispatch(trackID, clipID, value);
		}
		private function onDisabled(trackID:String,clipID:String,value:Boolean):void 
		{
			disabledSignal.dispatch(trackID, clipID, value);
		}
		private function onFaded(trackID:String,clipID:String,volume:Number):void 
		{
			fadeSignal.dispatch(trackID, clipID, volume);
		}
		
		
		
	}

}