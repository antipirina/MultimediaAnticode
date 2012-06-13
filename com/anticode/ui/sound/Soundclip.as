package com.anticode.ui.sound 
{
	import com.greensock.TweenLite; 
	import com.greensock.plugins.TweenPlugin; 
	import com.greensock.plugins.SoundTransformPlugin; 
	TweenPlugin.activate([SoundTransformPlugin]);

	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundLoaderContext;
	import flash.media.SoundTransform;
	import flash.net.URLRequest;
	import org.osflash.signals.Signal;
	/**
	 * ...Prueba cambio...
	 * @author Santiago J. Franzani
	 */
	public class Soundclip implements ISoundclip 
	{
		private var id:String;
		private var _volume:Number;
		
		private var _errorSignal:Signal
		private var _startedSignal:Signal
		private var _finishedSignal:Signal
		private var _pausedSignal:Signal
		private var _stopedSignal:Signal
		private var _mutedSignal:Signal
		private var _disabledSignal:Signal
		private var _fadeSignal:Signal
		private var _fadeInMs:Number;
		private var _removeFromPool:Boolean = false;
		private var url:String;
		private var sound:Sound;
		private var loopeable:Boolean;
		private var clip_st:SoundTransform;
		private var track_st:SoundTransform;
		private var bufferTime:int;
		private var soundChannel:SoundChannel;
		private var muted:Boolean = false;
		private var disabled:Boolean = false;
		private var paused:Boolean = false;
		private var mutedTrack:Boolean = false;
		private var disabledTrack:Boolean = false;
		private var pausePoint:Number = 0;
		private var stopping:Boolean = false;
		
		public function Soundclip(id:String) 
		{
			this.id = id;
			_errorSignal = new Signal(ISoundclip,String);
			_startedSignal = new Signal(ISoundclip);
			_finishedSignal = new Signal(ISoundclip);
			_pausedSignal = new Signal(ISoundclip);
			_stopedSignal = new Signal(ISoundclip);
			_mutedSignal = new Signal(ISoundclip);
			_disabledSignal = new Signal(ISoundclip);
			_fadeSignal = new Signal(ISoundclip);
		}
		
		/* INTERFACE com.anticode.ui.sound.ISoundclip */
		
		public function play(soundFile:*, loopeable:Boolean, track_st:SoundTransform, clip_st:SoundTransform,fadeInMs:Number = 0, bufferTime:int = -1):void 
		{
			this.track_st = track_st;
			this.clip_st = clip_st;
			this.loopeable = loopeable;
			this.fadeInMs = fadeInMs;
			
			if (soundFile is Sound)
			{
				this.sound = soundFile;
				playSound();
			}else {
				this.bufferTime = bufferTime;
				this.sound = new Sound();
				url = soundFile;
				loadAndPlay();
			}
			
		}
		private function playSound():void
		{
			soundChannel = new SoundChannel();
			
			
			if (paused) return;
			
			var render_st:SoundTransform = new SoundTransform(clip_st.volume * track_st.volume, clip_st.pan * track_st.pan);
			if (muted || disabled || mutedTrack || disabledTrack)
			{
				render_st.volume = 0;
			}
			if (loopeable)
			{
				soundChannel = sound.play(0, 990, render_st);
			}else {
				soundChannel = sound.play(0, 0, render_st);
			}
			
			soundChannel.addEventListener(Event.SOUND_COMPLETE, onFinishSound);
			
			if (fadeInMs > 0)TweenLite.from(soundChannel, fadeInMs/1000, {soundTransform:{volume:0, pan:0}}); 
			
			startedSignal.dispatch(this);
		}
		
		private function loadAndPlay():void
		{
			var req:URLRequest = new URLRequest(url);
			
			var context:SoundLoaderContext
			
			if (bufferTime > 0)
			{
				context = new SoundLoaderContext(bufferTime);
				context.checkPolicyFile = false;
				sound.addEventListener(Event.COMPLETE, soundLoadComplete);
				sound.addEventListener(IOErrorEvent.IO_ERROR, onLoadError);
				sound.load(req, context);
			}
			else
			{
				context = new SoundLoaderContext();
				context.checkPolicyFile = false;
				sound.addEventListener(Event.COMPLETE, soundLoadComplete);
				sound.addEventListener(IOErrorEvent.IO_ERROR, onLoadError);
				sound.load(req);
			}
		
		}
		
		public function stop(fadeOutMs:Number = 0,removeFromPool:Boolean = false):void 
		{
			this.removeFromPool = removeFromPool;
			if (stopping) return;
			if (fadeOutMs > 0)
			{
				stopping = true;
				if (soundChannel)TweenLite.to(soundChannel, fadeOutMs / 1000, { soundTransform: { volume:0, pan:0 },onComplete:onStopComplete} );
			} else {
				if (soundChannel)soundChannel.stop();
				stopedSignal.dispatch(this);
			}
		}
		
		private function onStopComplete():void 
		{
			if (!soundChannel) return;
			soundChannel.stop();
			stopedSignal.dispatch(this);
			stopping = false;
		}
		
		public function pause(value:Boolean):void 
		{
			paused = value;
			pausedSignal.dispatch(this);
			if (!soundChannel)
			{
				pausePoint = 0;
				return;
			}
			if (value)
			{
				pausePoint = soundChannel.position;
				soundChannel.stop();
			} else {
				soundChannel = sound.play(pausePoint);
				soundChannel.soundTransform = new SoundTransform(clip_st.volume * track_st.volume,clip_st.pan * track_st.pan);
			}
		
		}
		
		public function fadeVol(vol:Number, timeMs:Number):void 
		{
			clip_st.volume = vol;
			refreshVolume(timeMs);
		}		
		public function fadePan(pan:Number, timeMs:Number):void 
		{
			clip_st.pan = pan;
			refreshPan(timeMs);
		}
		
		public function fadeTrackVol(vol:Number, timeMs:Number):void 
		{
			track_st.volume = vol;
			refreshVolume(timeMs);
		}
				
		public function fadeTrackPan(pan:Number, timeMs:Number):void 
		{
			track_st.pan = pan;
			refreshPan(timeMs);
		}
		public function refreshVolume(timeMs:Number):void
		{
			if (!soundChannel) return;
			if (muted || disabled || mutedTrack || disabledTrack) return;
			var renderVol:Number = clip_st.volume * track_st.volume;
			
			if (timeMs > 0)
			{
				TweenLite.to(soundChannel, timeMs / 1000, { soundTransform: { volume:renderVol }, onComplete:onRefreshVolume} );
			}else {
				var newSoundTransform:SoundTransform = new SoundTransform(renderVol, clip_st.pan);
				soundChannel.soundTransform = newSoundTransform;
				fadeSignal.dispatch(this);
			}
		}
		
		private function onRefreshVolume():void 
		{
			fadeSignal.dispatch(this);
		}
		
		public function refreshPan(timeMs:Number):void
		{
			if (!soundChannel) return;
			var renderPan:Number = clip_st.pan * track_st.pan;
			if (timeMs > 0)
			{
				TweenLite.to(soundChannel, timeMs / 1000, { soundTransform: { pan:renderPan }} );
			}else {
				var newSoundTransform:SoundTransform = new SoundTransform(clip_st.volume, renderPan);
				soundChannel.soundTransform = newSoundTransform;
			}
		}
		
		
		public function muteGUI(value:Boolean):void 
		{
			muted = value;
			refreshSilence();
		}
		public function disable(value:Boolean):void 
		{
			disabled = value;
			refreshSilence();
		}
		
		public function muteTrackGUI(value:Boolean):void 
		{
			mutedTrack = value;
			refreshSilence();
		}
		
		public function disableTrack(value:Boolean):void 
		{
			disabledTrack = value;
			refreshSilence();
		}
		
		private function silence(value:Boolean):void 
		{
			if (value)
			{
				if (!soundChannel) return;
				var newSoundTransform:SoundTransform = new SoundTransform(0, clip_st.pan);
				soundChannel.soundTransform = newSoundTransform;
				
			}else {
				refreshVolume(0);
			}
		}
		
		private function refreshSilence():void 
		{
			if (!muted && !mutedTrack && !disabled && !disabledTrack)
			{
				silence(false);
			}else {
				silence(true);
			}
		}
		
		
		
		public function isMutedGUI():Boolean
		{
			return muted;
		}
		public function isDisabled():Boolean
		{
			return disabled;
		}
		public function isPlaying():Boolean
		{
			return !paused;
		}	
		
		public function getPosition():Number
		{
			return soundChannel.position;
		}
		
		public function getPausePoint():Number
		{
			return pausePoint;
		}
		
		/* handlers */
		
		private function soundLoadComplete(e:Event):void 
		{
			
			sound.removeEventListener(Event.COMPLETE, soundLoadComplete);
			sound.removeEventListener(IOErrorEvent.IO_ERROR, onLoadError);
			sound = e.currentTarget as Sound;
			playSound();
		}
		
		private function onLoadError(e:IOErrorEvent):void 
		{
			sound.removeEventListener(Event.COMPLETE, soundLoadComplete);
			sound.removeEventListener(IOErrorEvent.IO_ERROR, onLoadError);
			errorSignal.dispatch(this, "["+id+"] "+url);
		}
		
		private function onFinishSound(e:Event):void 
		{
			soundChannel.removeEventListener(Event.SOUND_COMPLETE, onFinishSound);
			finishedSignal.dispatch(this);
		}
		
		
		/* destroy */
		
		public function destroy():void 
		{
			_errorSignal.removeAll();
			_startedSignal.removeAll();
			_finishedSignal.removeAll();
			_pausedSignal.removeAll();
			_stopedSignal.removeAll();
			_mutedSignal.removeAll();
			_disabledSignal.removeAll();
			_fadeSignal.removeAll();
			
			pausePoint = 0;
			clip_st = null;
			track_st = null;
			if (soundChannel) soundChannel.stop();
			soundChannel = null;
			
			paused = false;
			muted = false;
			disabled = false;
			
			if (sound)
			{
				if (sound.hasEventListener(Event.COMPLETE))sound.removeEventListener(Event.COMPLETE, soundLoadComplete);
				if (sound.hasEventListener(IOErrorEvent.IO_ERROR))sound.removeEventListener(IOErrorEvent.IO_ERROR, onLoadError);
				if (sound.bytesLoaded != sound.bytesTotal)sound.close();
				sound = null;
			}
		}
		
		/* getters and setters */
		
		public function getID():String
		{
			return id;
		}
		public function getSoundObject():Sound
		{
			return sound;
		}
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
		
		public function get fadeInMs():Number 
		{
			return _fadeInMs;
		}
		
		public function set fadeInMs(value:Number):void 
		{
			_fadeInMs = value;
		}
		
		public function get removeFromPool():Boolean 
		{
			return _removeFromPool;
		}
		
		public function set removeFromPool(value:Boolean):void 
		{
			_removeFromPool = value;
		}
		
		public function get volume():Number 
		{
			return _volume;
		}
		
		public function set volume(value:Number):void 
		{
			_volume = value;
		}
		
	
		
	}

}