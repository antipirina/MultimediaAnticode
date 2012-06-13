package com.anticode.ui.sound 
{
	import flash.media.Sound;
	import flash.media.SoundTransform;
	import flash.utils.Dictionary;
	import org.osflash.signals.Signal;
	/**
	 * ...
	 * @author Santiago J. Franzani
	 */
	public class Soundtrack implements ISoundtrack 
	{
		private var id:String;
		private var volume:Number;
		private var pan:Number;
		
		private var clipDict:Dictionary;
		private var muted:Boolean = false;
		private var disabled:Boolean = false;
		private var playing:Boolean;
		private var voiceOverVol:Number = -1;
		private var crossFadeVol:Number = -1;
		private var volumeRender:Number;
		private var panRender:Number;
		private var masterVol:Number;
		private var masterPan:Number;
		private var mutedMaster:Boolean;
		private var disabledMaster:Boolean;
		
		private var _errorSignal:Signal
		private var _startedSignal:Signal
		private var _finishedSignal:Signal
		private var _pausedSignal:Signal
		private var _stopedSignal:Signal
		private var _mutedSignal:Signal
		private var _disabledSignal:Signal
		private var _fadeSignal:Signal
		private var currentProcessedClip:ISoundclip;
		
		
		public function Soundtrack(trackID:String, masterVol:Number, masterPan:Number, mutedMaster:Boolean, disabledMaster:Boolean, initVol:Number = 1, initPan:Number = 0)
		{
			this.id = trackID;
			this.masterVol = masterVol;
			this.masterPan = masterPan;
			this.disabledMaster = disabledMaster;
			this.mutedMaster = mutedMaster;
			this.volume = initVol;
			this.pan = initPan;
			this.volumeRender = masterVol*initVol;
			this.panRender = this.pan*masterPan;
			
			_errorSignal = new Signal(String,String,String);
			_startedSignal = new Signal(String,String,Sound);
			_finishedSignal = new Signal(String,String);
			_pausedSignal = new Signal(String,String,Boolean);
			_stopedSignal = new Signal(String,String);
			_mutedSignal = new Signal(String,String,Boolean);
			_disabledSignal = new Signal(String,String,Boolean);
			_fadeSignal = new Signal(String,String,Number);
			
			clipDict = new Dictionary();
		}
		
		/* INTERFACE com.anticode.ui.sound.ISoundtrack */
		
		public function play(soundID:String, soundFile:*, loopeable:Boolean = false, vol:Number = 1,fadeInMs:Number = 0):ISoundclip
		{
			if (clipDict[soundID])
			{
				var currentClip:ISoundclip = clipDict[soundID] as ISoundclip;
				if (!(!currentClip.isPlaying() && currentClip.getPausePoint() == 0))
				{
					currentClip.stop(0,true);
					currentClip.destroy();
				}
			}
			
			clipDict[soundID] = new Soundclip(soundID);
			if (muted || mutedMaster)(clipDict[soundID] as ISoundclip).muteTrackGUI(true)
			
			if (disabled || disabledMaster)(clipDict[soundID] as ISoundclip).disableTrack(true);
			(clipDict[soundID] as ISoundclip).finishedSignal.addOnce(onClipFinished);
			(clipDict[soundID] as ISoundclip).finishedSignal.addOnce(onClipStoppedRemove);
			(clipDict[soundID] as ISoundclip).startedSignal.addOnce(onClipStarted);
			(clipDict[soundID] as ISoundclip).errorSignal.addOnce(onClipLoadError);
			var finalVol:Number = volumeRender;
			var finalPan:Number = panRender;
			if (voiceOverVol > -1)finalVol = volumeRender * voiceOverVol;
			if (crossFadeVol > -1)finalVol = volumeRender * crossFadeVol;
			(clipDict[soundID] as ISoundclip).play(soundFile, loopeable, new SoundTransform(finalVol, finalPan), new SoundTransform(vol, 0), fadeInMs);
			return (clipDict[soundID] as ISoundclip);
		}
		

		
		public function stop(soundID:String = "",fadeOutMs:Number = 0,removeFromPool:Boolean = true):void 
		{
			if (soundID != "")
			{
				if (!isClipExist(soundID)) return;
				(clipDict[soundID] as ISoundclip).stopedSignal.addOnce(onClipStopped);
				(clipDict[soundID] as ISoundclip).stop(fadeOutMs,removeFromPool);
				return;
			}
			
			for each (var soundClip:ISoundclip in clipDict)
			{
				soundClip.removeFromPool = removeFromPool;
				soundClip.stopedSignal.addOnce(onClipStoppedRemove);
				soundClip.stop(fadeOutMs,removeFromPool);
			}
			playing = false;
			stopedSignal.dispatch(id, "");
		}
		
		public function pause(value:Boolean, soundID:String = ""):void 
		{
			if (soundID != "")
			{
				if (!isClipExist(soundID)) clipDict[soundID] = new Soundclip(soundID);
				(clipDict[soundID] as ISoundclip).pausedSignal.addOnce(onClipPaused);
				(clipDict[soundID] as ISoundclip).pause(value);
				return;
			}
			
			if (!value == playing) return;
			
			for each (var soundClip:ISoundclip in clipDict)
			{
				//soundClip.pausedSignal.addOnce(onClipPaused);
				soundClip.pause(value);
			}
			playing = value;
			pausedSignal.dispatch(id, "",playing);
		}
		

		public function pauseMaster(value:Boolean):void
		{
			if (!value && !playing) return;
			
			for each (var soundClip:ISoundclip in clipDict)
			{
				//soundClip.pausedSignal.addOnce(onClipPaused);
				soundClip.pause(value);
			}
		}
		
		
		public function voiceOver(soundID:String, soundFile:*, oldSoundVol:Number = 0.5, newSoundVol:Number = 1, crossTime:Number = 1000):ISoundclip 
		{
			this.voiceOverVol = oldSoundVol;
			clipDict[soundID] = new Soundclip(soundID);
			(clipDict[soundID] as ISoundclip).startedSignal.addOnce(onVoiceOverLoaded);
			(clipDict[soundID] as ISoundclip).startedSignal.addOnce(onClipStarted);
			(clipDict[soundID] as ISoundclip).finishedSignal.addOnce(onVoiceOverFinishedStoped);
			(clipDict[soundID] as ISoundclip).stopedSignal.addOnce(onVoiceOverFinishedStoped);
			if (muted || mutedMaster)(clipDict[soundID] as ISoundclip).muteTrackGUI(true)
			if (disabled || disabledMaster)(clipDict[soundID] as ISoundclip).disableTrack(true);
			currentProcessedClip = clipDict[soundID] as ISoundclip;
			(clipDict[soundID] as ISoundclip).play(soundFile, false, new SoundTransform(volumeRender, panRender), new SoundTransform(newSoundVol, 0), crossTime);
			return (clipDict[soundID] as ISoundclip);
		}
		
		private function onVoiceOverLoaded(clip:ISoundclip):void
		{
			var oldSoundVolRender:Number = voiceOverVol * volumeRender;
			for each (var soundClip:ISoundclip in clipDict)
			{
				if (soundClip == clip) continue;
				soundClip.fadeTrackVol(oldSoundVolRender, clip.fadeInMs);
			}
		}
		
		private function onVoiceOverFinishedStoped(clip:ISoundclip):void 
		{
			clip.finishedSignal.remove(onVoiceOverFinishedStoped);
			clip.stopedSignal.remove(onVoiceOverFinishedStoped);
			
			for each (var soundClip:ISoundclip in clipDict)
			{
				soundClip.fadeTrackVol(volumeRender, clip.fadeInMs);
			}
			voiceOverVol = -1;
			currentProcessedClip = null;
		}
		
		
		public function crossFade(soundID:String, soundFile:*, loopeable:Boolean = false, newSoundVol:Number = 1, crossTime:Number = 1000):ISoundclip 
		{
			this.crossFadeVol = newSoundVol;
			clipDict[soundID] = new Soundclip(soundID);
			var clipVolRender:Number = newSoundVol * volumeRender;
			(clipDict[soundID] as ISoundclip).startedSignal.addOnce(onCrossFade);
			if (muted || mutedMaster)(clipDict[soundID] as ISoundclip).muteTrackGUI(true);
			if (disabled || disabledMaster)(clipDict[soundID] as ISoundclip).disableTrack(true);
			(clipDict[soundID] as ISoundclip).finishedSignal.addOnce(onClipStopped);
			(clipDict[soundID] as ISoundclip).startedSignal.addOnce(onClipStarted);
			currentProcessedClip = clipDict[soundID] as ISoundclip;
			(clipDict[soundID] as ISoundclip).play(soundFile, loopeable, new SoundTransform(volumeRender, panRender), new SoundTransform(newSoundVol, 0), crossTime);
			return (clipDict[soundID] as ISoundclip);
		}
		
		private function onCrossFade(clip:ISoundclip):void 
		{
			var once:Boolean = false;
			for each (var soundClip:ISoundclip in clipDict)
			{
				if (soundClip == clip) continue;
				if (!once)
				{
					once = true;
					soundClip.stopedSignal.addOnce(onCrossFadeOver);
				}
				soundClip.stopedSignal.addOnce(onClipStoppedRemove);
				soundClip.stop(clip.fadeInMs, true);
			}
		}
		
		private function onCrossFadeOver(clip:ISoundclip):void 
		{
			crossFadeVol = -1;
			currentProcessedClip = null;
		}
		
		public function setVol(vol:Number, soundID:String = "", fadeMs:Number = 0):void 
		{
			if (soundID != "")
			{
				if (!isClipExist(soundID)) return;
				(clipDict[soundID] as ISoundclip).fadeSignal.addOnce(onClipFaded);
				(clipDict[soundID] as ISoundclip).fadeVol(vol, fadeMs);
				return;
			}		
			
			this.volume = vol;
			this.volumeRender = volume * masterVol;
			
			var finalFadeMs:Number = fadeMs;
			var finalVol:Number = volumeRender;
			var finalProcessedVol:Number
			
			if (voiceOverVol > -1)
			{
				finalProcessedVol = volumeRender;
				finalVol = volumeRender * voiceOverVol;
			}
			
			if (crossFadeVol > -1)
			{
				finalProcessedVol = volumeRender * crossFadeVol;
				finalVol = 0;
			}

			
			for each (var soundClip:ISoundclip in clipDict)
			{
				if (currentProcessedClip == soundClip)
				{
					soundClip.fadeTrackVol(finalProcessedVol, finalFadeMs);
					continue;
				}
				soundClip.fadeTrackVol(finalVol, finalFadeMs);
			}
			fadeSignal.dispatch(id, "", this.volume);
		}
		
		public function setPan(pan:Number,soundID:String = "", fadeMs:Number = 0):void 
		{
			if (soundID != "")
			{
				if (!isClipExist(soundID)) return;
				(clipDict[soundID] as ISoundclip).fadePan(pan, fadeMs);
				return;
			}			
			this.pan = pan;
			this.panRender = this.pan * masterPan;
			for each (var soundClip:ISoundclip in clipDict)
			{
				soundClip.fadeTrackPan(panRender, fadeMs);
			}
		}
		public function setMasterVol(vol:Number, fadeMs:Number = 0):void 
		{
			this.masterVol = vol;
			this.volumeRender = volume * masterVol;
			
			var finalVol:Number = volumeRender;
			if (voiceOverVol > -1) finalVol = volumeRender * voiceOverVol;
			if (crossFadeVol > -1) finalVol = volumeRender * crossFadeVol;
			
			for each (var soundClip:ISoundclip in clipDict)
			{
				if (currentProcessedClip == soundClip)
				{
					soundClip.fadeTrackVol(volumeRender, fadeMs);
					continue;
				}
				soundClip.fadeTrackVol(finalVol, fadeMs);
			}
		}
		
		public function setMasterPan(pan:Number, fadeMs:Number = 0):void 
		{
			this.masterPan = pan;
			this.panRender = pan * masterPan;
			
			for each (var soundClip:ISoundclip in clipDict)
			{
				soundClip.fadeTrackPan(panRender, fadeMs);
			}
		}
		
		private function isClipExist(soundID:String):Boolean 
		{
			if ((clipDict[soundID] as ISoundclip)) return true;
			return false;
		}
		
		
		public function muteGUI(value:Boolean, soundID:String = ""):void 
		{
			if (soundID != "")
			{
				if (!isClipExist(soundID)) return;
				(clipDict[soundID] as ISoundclip).mutedSignal.addOnce(onClipMuted);
				(clipDict[soundID] as ISoundclip).muteGUI(value);
				return;
			}
			
			muted = value;
			mutedSignal.dispatch(this.id, "", value);
			if (disabled) return;
			
			for each (var soundClip:ISoundclip in clipDict)
			{
				//soundClip.mutedSignal.addOnce(onClipMuted);
				soundClip.muteTrackGUI(value);
			}
			
		}
		

		
		public function disable(value:Boolean, soundID:String = ""):void 
		{
			if (soundID != "")
			{
				if (!isClipExist(soundID)) return;
				(clipDict[soundID] as ISoundclip).disabledSignal.addOnce(onClipDisabled);
				(clipDict[soundID] as ISoundclip).disable(value);
				return;
			}
			
			disabled = value;
			disabledSignal.dispatch(this.id, "", value);
			if (muted) return;
			
			for each (var soundClip:ISoundclip in clipDict)
			{
				//soundClip.disabledSignal.addOnce(onClipDisabled);
				soundClip.disableTrack(value);
			}
			
		}
		
		public function muteMasterGUI(value:Boolean):void
		{
			this.mutedMaster = value;
			if (muted) return;
			for each (var soundClip:ISoundclip in clipDict)
			{
				//soundClip.mutedSignal.addOnce(onClipMuted);
				soundClip.muteTrackGUI(value);
			}
		}
		public function masterDisable(value:Boolean):void
		{
			this.disabledMaster = value;
			if (disabled) return;
			for each (var soundClip:ISoundclip in clipDict)
			{
				//soundClip.disabledSignal.addOnce(onClipDisabled);
				soundClip.disableTrack(value);
			}
		}
		
		
		public function isMutedGUI(soundID:String = ""):Boolean 
		{
			if (soundID != "")
			{
				if (isClipExist(soundID)) return (clipDict[soundID] as ISoundclip).isMutedGUI();
				return false;
			}
			
			return muted;
		}
		
		public function isDisabled(soundID:String = ""):Boolean 
		{
			if (soundID != "")
			{
				if (isClipExist(soundID)) return (clipDict[soundID] as ISoundclip).isDisabled();
				return false;
			}
			
			return disabled;
		}
		
		public function isPlaying(soundID:String = ""):Boolean 
		{
			if (soundID != "")
			{
				if (isClipExist(soundID)) return (clipDict[soundID] as ISoundclip).isPlaying();
				return false;
			}
			
			return playing;
		}
		
		public function getSoundClip(soundID:String):ISoundclip
		{
			return clipDict[soundID] as ISoundclip;
		}
		public function destroy():void 
		{
			for each (var soundClip:ISoundclip in clipDict)
			{
				soundClip.destroy();
			}	
			clipDict = null;
			_errorSignal.removeAll();
			_startedSignal.removeAll();
			_finishedSignal.removeAll();
			_pausedSignal.removeAll();
			_stopedSignal.removeAll();
			_mutedSignal.removeAll();
			_disabledSignal.removeAll();
			_fadeSignal.removeAll();
		}
		
		
		/* soundclip handlers */
		
		private function onClipLoadError(clip:ISoundclip,error:String):void 
		{
			errorSignal.dispatch(id, clip.getID(), error);
		}
		
		private function onClipStarted(clip:ISoundclip):void 
		{
			clip.errorSignal.remove(onClipLoadError);
			startedSignal.dispatch(id, clip.getID(),clip.getSoundObject());
		}
		
		private function onClipStopped(clip:ISoundclip):void 
		{
			clip.errorSignal.remove(onClipLoadError);
			if (clip.removeFromPool)
			{
				(clipDict[clip.getID()] as ISoundclip).destroy();
				delete clipDict[clip.getID()];
			}
			stopedSignal.dispatch(id, clip.getID());
		}
		
		private function onClipStoppedRemove(clip:ISoundclip):void 
		{
			clip.errorSignal.remove(onClipLoadError);
			if (clip.removeFromPool)
			{
				//(clipDict[clip.getID()] as ISoundclip).destroy();
				clip.destroy();
				delete clipDict[clip.getID()];
			}
		}
		private function onClipFinished(clip:ISoundclip):void 
		{
			finishedSignal.dispatch(id,clip.getID());
			
		}
		private function onClipPaused(clip:ISoundclip):void 
		{
			pausedSignal.dispatch(id, clip.getID(), !clip.isPlaying());
		}
		private function onClipMuted(clip:ISoundclip):void 
		{
			mutedSignal.dispatch(id, clip.getID(), clip.isMutedGUI());
		}
		private function onClipDisabled(clip:ISoundclip):void 
		{
			disabledSignal.dispatch(id, clip.getID(), clip.isDisabled());
		}
		private function onClipFaded(clip:ISoundclip):void 
		{
			fadeSignal.dispatch(id, clip.getID(), clip.volume);
		}
		
		/* signals getters */
		
		public function get errorSignal():Signal 
		{
			return _errorSignal;
		}
		
		public function get startedSignal():Signal 
		{
			return _startedSignal;
		}
		
		public function get finishedSignal():Signal 
		{
			return _finishedSignal;
		}
	
		public function get pausedSignal():Signal 
		{
			return _pausedSignal;
		}
		
		public function get stopedSignal():Signal 
		{
			return _stopedSignal;
		}
		
		public function get mutedSignal():Signal 
		{
			return _mutedSignal;
		}		
		public function get disabledSignal():Signal 
		{
			return _disabledSignal;
		}
		
		public function get fadeSignal():Signal 
		{
			return _fadeSignal;
		}
	}

}