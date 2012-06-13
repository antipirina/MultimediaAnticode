package com.anticode.ui.character
{
	import com.anticode.ui.sound.SoundEvent;
	import com.anticode.ui.sound.SoundManager;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.media.Sound;
	import flash.text.TextField;
	import flash.utils.Timer;
	import org.osflash.signals.Signal;
	import com.anticode.utils.mcUtil;
	import com.anticode.utils.MovieEffects;
	/**
	 * ...
	 * @author Santiago J. Franzani
	 */
	public class TalkingCharacterView extends Sprite
	{
		private var lastAnimationUsed:MovieClip;
		private var model:TalkingCharacter;
		private var textDelay_timer:Timer;
		private var waitAni_timer:Timer;
		private var currentAnimation_mc:MovieClip;
		private var currentText:String;
		private var currentAudioFile:String;
		private var currentDelay:int;
		private var waitTextAndAudio_timer:Timer;
		private var subtitles:Subtitles;
		internal var currentAnimationID:String;
		internal var newSpeechSignal:Signal;
		internal var allTextsReadySignal:Signal;
		internal var tf:TextField;
	
		public function TalkingCharacterView(model:TalkingCharacter) 
		{
			this.model = model;
			allTextsReadySignal = new Signal();
			newSpeechSignal = new Signal();
			subtitles = new Subtitles();
		}
		
		internal function destroy():void 
		{
			if (numChildren > 0)removeChildAt(0);
			currentAnimation_mc = null;
			currentText = null;
			currentAudioFile = null;
			currentDelay = 0;
			currentAnimationID = null;
			tf = null;
			if (subtitles) subtitles.destroy();
			subtitles = null;
			removeAllTimers();
			
			allTextsReadySignal.removeAll();
			allTextsReadySignal = null;
			
			newSpeechSignal.removeAll();
			newSpeechSignal = null;
		}
		
		private function removeAllTimers():void 
		{
			if (textDelay_timer)
			{
				textDelay_timer.stop();
				if (textDelay_timer.hasEventListener(TimerEvent.TIMER_COMPLETE))textDelay_timer.removeEventListener(TimerEvent.TIMER_COMPLETE, onTextReady);
				textDelay_timer = null;
			}
			
			if (waitAni_timer)
			{
				waitAni_timer.stop();
				if (waitAni_timer.hasEventListener(TimerEvent.TIMER_COMPLETE))waitAni_timer.addEventListener(TimerEvent.TIMER_COMPLETE, waitPlayAni);
				waitAni_timer = null;
			}
			
			if (waitTextAndAudio_timer)
			{
				waitTextAndAudio_timer.stop();
				if (waitTextAndAudio_timer.hasEventListener(TimerEvent.TIMER_COMPLETE))waitTextAndAudio_timer.removeEventListener(TimerEvent.TIMER_COMPLETE, showTextAndAudio);
				waitTextAndAudio_timer = null;
			}
			
			SoundManager.getInstance().finishedSignal.remove(onSpeechReady);
		}
		internal function standBy():void
		{
			stopAll();
			playStandBy();
		}
		internal function jumpNextSpeech():void
		{
			stopAll();
			checkNext();
		}
		internal function playNextSpeech():void 
		{
			if (model.isPlaying)stopAll();
			
			model.isPlaying = true;
			
			currentAnimation_mc = model.currentTexts_arr[0][0];
			currentText = model.currentTexts_arr[0][1];
			currentAudioFile = model.currentTexts_arr[0][2];
			currentAnimationID = model.currentTexts_arr[0][3];
			currentDelay = model.currentTexts_arr[0][4];

			if (currentDelay > 0) playStandBy();
			
			waitTextAndAudio_timer = new Timer(currentDelay, 1);
			waitTextAndAudio_timer.addEventListener(TimerEvent.TIMER_COMPLETE, showTextAndAudio);
			waitTextAndAudio_timer.start();
			
		}
		
		internal function stopAll():void 
		{
			removeAllTimers();
			if (currentAnimation_mc)currentAnimation_mc.stop();
			SoundManager.getInstance().stop(SoundManager.SPEECH_TRACK, "character");
			model.isPlaying = false;
		}
		private function showTextAndAudio(e:TimerEvent):void
		{
			waitTextAndAudio_timer.removeEventListener(TimerEvent.TIMER_COMPLETE, showTextAndAudio);
			
			//show text
			if (!model.subtitleMode && StringUtils.hasText(currentText))
			{
				tf.text = currentText;
				tf.height = tf.textHeight + 20;				
			}
			
			if (StringUtils.hasText(currentAudioFile))
			{
				
				//play animation
				useAnimation(currentAnimation_mc, currentDelay, true);
				
				//play sound
				SoundManager.getInstance().play(SoundManager.SPEECH_TRACK, "character", currentAudioFile);
				SoundManager.getInstance().finishedSignal.add(onSpeechReady);
				SoundManager.getInstance().errorSignal.add(onSoundLoadError);
				
				return;
			}else
			{
				showNoAudioAlternatives();
			}
			useAnimation(currentAnimation_mc, currentDelay);
		}
		

			
		
		
		private function onSoundLoadError(trackID:String,soundID:String,error:String):void 
		{
			SoundManager.getInstance().errorSignal.remove(onSoundLoadError);
			SoundManager.getInstance().finishedSignal.remove(onSpeechReady);
			showNoAudioAlternatives();
		}
		private function showNoAudioAlternatives():void
		{
			 if (StringUtils.hasText(currentText)) {
				//wait for text
				waitTextRead(currentText);
			}else {
				//wait for animation
				waitEndAnimation(currentAnimation_mc);
			}
		}
		
		private function waitEndAnimation(ani_mc:MovieClip):void 
		{
			ani_mc.addEventListener(Event.ENTER_FRAME, onAnimationReady);
		}
		
		private function onAnimationReady(e:Event):void 
		{
			if ((e.currentTarget as MovieClip).currentFrame  == (e.currentTarget as MovieClip).totalFrames)
			{
				currentAnimation_mc.removeEventListener(Event.ENTER_FRAME, onAnimationReady);
				model.isPlaying = false;
				checkNext();
			}
			
		}
		private function waitTextRead(text:String):void
		{

			
			var timeMS:int = TalkingCharacter.getTimmingText(text);
			
			textDelay_timer = new Timer(timeMS, 1);
			textDelay_timer.addEventListener(TimerEvent.TIMER_COMPLETE, onTextReady);
			textDelay_timer.start();
			//show subtitules
			if (model.subtitleMode)subtitles.showSubtitles(tf, text, timeMS);
		}
		
		private function onTextReady(e:TimerEvent):void 
		{
			textDelay_timer.removeEventListener(TimerEvent.TIMER_COMPLETE, onTextReady);
			model.isPlaying = false;
			checkNext();			
		}
		
		private function onSpeechReady(trackID:String,soundID:String):void 
		{
			if (soundID == "character")
			{
				SoundManager.getInstance().errorSignal.remove(onSoundLoadError);
				SoundManager.getInstance().finishedSignal.remove( onSpeechReady);
				model.isPlaying = false;
				checkNext();
			}
		}
		

		
		internal function playStandBy():void 
		{
			useAnimation(model.getStandByAnimation());
			model.isPlaying = false;
		}
		
		private function useAnimation(ani_mc:MovieClip,delay:int = 0,waitLoadSound:Boolean = false):void
		{
	
			
			if (lastAnimationUsed != ani_mc)
			{
				if (numChildren > 0)removeChild(lastAnimationUsed);
				lastAnimationUsed = ani_mc;
				addChild(ani_mc);
				mcUtil.stopChildrenFrame1(ani_mc,true);
				
				
				if (waitLoadSound)
				{
					SoundManager.getInstance().startedSignal.add(waitPlayAniSound);
				}else {
					waitAni_timer = new Timer(delay, 1);
					waitAni_timer.addEventListener(TimerEvent.TIMER_COMPLETE, waitPlayAni);
					waitAni_timer.start();
				}
			
			}else {
				if (waitLoadSound)
				{
					mcUtil.stopChildrenOf(ani_mc,true);
					SoundManager.getInstance().startedSignal.add(waitPlayAniSound);
				}else {
					mcUtil.playAllChildrenOf(ani_mc,true);
				}
			}
		}
		
		private function waitPlayAni(e:TimerEvent):void 
		{
			waitAni_timer.removeEventListener(TimerEvent.TIMER_COMPLETE, waitPlayAni);
			mcUtil.playAllChildrenOf(currentAnimation_mc,true);
			currentAnimation_mc.play();
		}
		private function waitPlayAniSound(trackID:String,soundID:String,soundObj:Sound):void
		{
			if (model.subtitleMode)subtitles.showSubtitles(tf, currentText, soundObj.length);
			SoundManager.getInstance().startedSignal.remove(waitPlayAniSound);
			mcUtil.playAllChildrenOf(currentAnimation_mc,true);
			currentAnimation_mc.play();
		}
		
		private function checkNext():void 
		{
			model.currentTexts_arr.shift();
			subtitles.end();
			if (model.currentTexts_arr.length == 0)
			{
				playStandBy();
				if (currentText && model.hideTextOnFinished && !model.subtitleMode) tf.text = "";
				
				allTextsReadySignal.dispatch();
			}else {
				newSpeechSignal.dispatch();
				playNextSpeech();
			}
		}
		

	}

}