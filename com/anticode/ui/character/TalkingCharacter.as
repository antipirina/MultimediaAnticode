package com.anticode.ui.character
{
	import com.anticode.ui.sound.SoundManager;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.text.TextField;
	import org.osflash.signals.Signal;
	/**
	 * ..EJ:
		 *	personaje = new TalkingCharacter();
			addChild(personaje);
			personaje.addStandBy(new MujerStandBy_character(), "mujerStandBy");
			personaje.setTextField(content.getChildByName("textoPersonaje_txt") as TextField);
			personaje.setStandByDefault("mujerStandBy");
			var mujerHabla:MujerHabla_character = new MujerHabla_character();
			personaje.standBySignal.add(onPersonajeStandBy);
			personaje.addSpeech(mujerHabla, "","00.mp3");
			personaje.addSpeech(new HombreHabla_character(), "texto acá.","01.mp3");
			personaje.y = personaje.height;
			personaje.x = personaje.width;
			
	 * @author Santiago J. Franzani
	 */
	public class TalkingCharacter extends Sprite
	{
		public var subtitleMode:Boolean = false;
		public static const PALABRAS_POR_MINUTO:int = 200;
		
		private var defaultStandbyID:String;
		private var standBy_arr:Array;
		internal var currentTexts_arr:Array;
		private var _isPlaying:Boolean;
		private var view:TalkingCharacterView;
		public var standBySignal:Signal;
		public var newSpeechSignal:Signal;
		public var hideTextOnFinished:Boolean
		
		public function TalkingCharacter() 
		{
			hideTextOnFinished = false;
			standBySignal = new Signal();
			newSpeechSignal = new Signal(String);
			view = new TalkingCharacterView(this);
			standBy_arr = [];
			currentTexts_arr = [];
			isPlaying = false;
			addChild(view);
			
			
		}
		public function destroy():void
		{
			standBySignal.removeAll();
			newSpeechSignal.removeAll();
			standBySignal = null;
			newSpeechSignal = null;
			removeChild(view);
			view.destroy();
			view = null;
			reset();
		
		}
		public function reset():void
		{
			view.stopAll();
			standBy_arr = [];
			currentTexts_arr = [];
			defaultStandbyID = null;
			isPlaying = false;
		}
		
		public function standBy():void
		{
			checkStandBySetted();
			view.standBy();
		}
		public function continueSpeech():void
		{
			if (!isPlaying)view.playNextSpeech();
		}
		public function nextSpeech():void
		{
			view.jumpNextSpeech();
		}
		public function removeAllQueue():void
		{
			view.stopAll();
			currentTexts_arr = [];
		}
		
		public function addStandBy(content:MovieClip,standByID:String):void
		{
			standBy_arr[standByID] = content;
		}
		
		public function setTextField(tf:TextField):void
		{
			view.tf = tf;
		}
		public function setStandByDefault(standByID:String):void
		{
			defaultStandbyID = standByID;
		}
		public function addSpeech(animation_mc:MovieClip, text:String = "",audioFile:String = "",animationID:String = "",delay:int = 0):void
		{
			if (text) if (!view.tf) throw new Error("No fue seteado el campo de texto en el cual tiene que mostrar el texto. Utilizá [ setTextField(tf:TextField) ] primero.");
			checkStandBySetted();
			
			currentTexts_arr.push([animation_mc,text,audioFile,animationID,delay]);
			
			if (isPlaying) return;
			isPlaying = true;
			view.allTextsReadySignal.add(onCharacterStandBy);
			
			view.newSpeechSignal.remove(onCharacterNewSpeech);
			view.newSpeechSignal.add(onCharacterNewSpeech);
			view.playNextSpeech();
		}
		
		private function onCharacterStandBy():void 
		{
			view.allTextsReadySignal.remove(onCharacterStandBy);
			standBySignal.dispatch();
			
		}
		private function onCharacterNewSpeech():void
		{
			newSpeechSignal.dispatch(view.currentAnimationID);
		}
		
		private function checkStandBySetted():void 
		{
			if (!defaultStandbyID) throw new Error("No fue seteada la animación stand by que utilizará por defecto el personaje. Utilizar [ setStandByDefault(standByID:String) ] primero.");
			if (!standBy_arr[defaultStandbyID]) throw new Error("No se encontró el ID de standby: " + defaultStandbyID + ". Utilizá [ addStandBy(content:MovieClip,standByID:String) ] para agregarlo.");
		}
		
		public function get isPlaying():Boolean 
		{
			return _isPlaying;
		}
		
		public function set isPlaying(value:Boolean):void 
		{
			_isPlaying = value;
		}
		internal function getStandByAnimation():MovieClip
		{
			return standBy_arr[defaultStandbyID];
		}
		
		public static function getTimmingText(text:String):int
		{
			var split_arr:Array = text.split(" ");
			
			var nValidWords:Number = 0; 
			
			for (var i:int = 0; i < split_arr.length; i++) 
			{
				if(split_arr[i].length > 0)
				{
					nValidWords++;
				}
			}
			
			var timeMS:int = nValidWords/(PALABRAS_POR_MINUTO / 60000);
			
			return timeMS;
		}
		
	}

}