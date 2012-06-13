package com.anticode.access
{
	import com.greensock.TweenLite;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.utils.Dictionary;
	import mx.core.ButtonAsset;
	import org.osflash.signals.DeluxeSignal;
	import org.osflash.signals.Signal;
	import com.anticode.access.AccessManager;
	import com.anticode.access.ButtonAccess;
	import com.greensock.plugins.*;
	TweenPlugin.activate([TintPlugin, ColorTransformPlugin]);
	import com.greensock.*; 
	import com.greensock.easing.*;

	/**
	 * ...
	 * @author Santiago J. Franzani
	 */
	public class Section extends Sprite
	{
		public var useFadeFX:Boolean = true;
		public var layerGroup:int = 0;
		public var sectionID:String;
		protected var content:DisplayObjectContainer;
		protected var textFields_arr:Array;
		protected var buttons_arr:Array;
		protected var interactiveElementsOrder_arr:Array
		public var windowOutSignal:DeluxeSignal;
		public var windowInSignal:DeluxeSignal;

		
		public function Section(content:DisplayObjectContainer) 
		{
			windowOutSignal = new DeluxeSignal(this);
			windowInSignal = new DeluxeSignal(this);
			this.content = content;
			addChild(content);
			
			textFields_arr = [];
			buttons_arr = [];
			interactiveElementsOrder_arr = [];
		}
		
		public function open():void 
		{
			AccessManager.getInstance().focusSection(this);
			if (useFadeFX)
			{
				TweenMax.from(this, 0.25, {ease:Quad.easeOut,colorTransform:{exposure:2}});
				TweenMax.to(this, 0.25, { ease:Quad.easeIn, onComplete:onOpen, colorTransform: { exposure:1 }} );
			}else {
				onOpen();
			}
		}
		
		protected function onOpen():void 
		{
			windowInSignal.dispatch();
		}
		public function close():void 
		{
			AccessManager.getInstance().closeSection(this);
			if (useFadeFX)
			{
				TweenMax.from(this, 0.15, {ease:Quad.easeOut,colorTransform:{exposure:1}});
				TweenMax.to(this, 0.15, { ease:Quad.easeIn, onComplete:onClose, colorTransform: { exposure:2 }} );
			}else {
				onClose();
			}
			
		}
		
		protected function onClose():void 
		{
			windowOutSignal.dispatch();
		}
		
		
		public function setTabElements(elements_arr:Array):void
		{
			interactiveElementsOrder_arr = elements_arr;
		}
		public function addTextField(tf:TextField):void
		{
			textFields_arr.push(tf);
		}
		
		public function addButton(button:MovieClip,onClick:Function,onRollOver:Function = null, onRollOut:Function = null):ButtonAccess
		{
			if (getButtonAccess(button.name))
			{
				var ba:ButtonAccess = getButtonAccess(button.name)
				ba.activate(true);
				return ba;
			}
			var buttonAccess:ButtonAccess = new ButtonAccess(button, onClick, onRollOver, onRollOut);
			
			var sectionName:String = sectionID;
			
			var accObj:Object = AccessModel.getInstance().getAccessData(buttonAccess.name, sectionName);
			
			buttonAccess.key = accObj.key;
			buttonAccess.alt = accObj.alt;
			buttonAccess.ctrl = accObj.ctrl;
			buttonAccess.shift = accObj.shift;

			var tooltip_str:String = accObj.tooltip;
			
			buttonAccess.globalAccess = accObj.global;
			
			if (buttonAccess.hasTextField())
			{
				var textObj:Object = AccessModel.getInstance().getText(buttonAccess.name, sectionName);
				var text_str:String = textObj.text;
				var audio_str:String = textObj.audio;
				var audio_url:String = audio_str;
			}
		
			
			buttonAccess.setText(text_str);
			if (StringUtils.hasText(tooltip_str))buttonAccess.setTooltip(tooltip_str);
	
			if (StringUtils.hasText(audio_str))buttonAccess.setSpeech(audio_url);

			
			buttons_arr.push(buttonAccess);
			return buttonAccess;
		}
		public function removeButton(butonName:String):void
		{
			for (var i:int = 0; i < buttons_arr.length; i++) 
			{
				if (butonName == buttons_arr[i].name)
				{
					(buttons_arr[i] as ButtonAccess).activate(false);
					buttons_arr.splice(i, 1);
					return;
				}
			}
		}
		public function getButtonAccess(name:String):ButtonAccess
		{
			for (var i:int = 0; i < buttons_arr.length; i++) 
			{
				if (name == buttons_arr[i].name)
				{
					return buttons_arr[i];
				}
			}
			return null;
		}
		public function renderTexts():void
		{		
			var maxTextFields:int = textFields_arr.length;
			for (var j:int = 0; j < maxTextFields; j++) 
			{
				(textFields_arr[j] as TextField).text = AccessModel.getInstance().getText((textFields_arr[j] as TextField).name, sectionID).text;
				//(textFields_arr[j] as TextField).text = (textFields_arr[j] as TextField).name; //cambiar
			}
			
		}
		
		public function getTextFields():Array
		{
			return textFields_arr;
		}
		public function getButtons():Array
		{
			return buttons_arr;
		}

		public function getTabElements():Array
		{
			return interactiveElementsOrder_arr;
		}
			
		public function destroy():void
		{
			windowInSignal.removeAll();
			windowOutSignal.removeAll();
			destroyAllButtons();
			textFields_arr = null;
			buttons_arr = null;
			content = null;
			interactiveElementsOrder_arr = null;
		}
		public function resetObjects():void
		{
			var max:int = buttons_arr.length;
			var currentButton:ButtonAccess;
			for (var i:int = 0; i < max; i++) 
			{
				currentButton = buttons_arr[i];
				currentButton.activate(false);
			}
			buttons_arr = [];
			interactiveElementsOrder_arr = [];
			textFields_arr = [];
		}
		protected function destroyAllButtons():void
		{
			var max:int = buttons_arr.length;
			var currentButton:ButtonAccess;
			for (var i:int = 0; i < max; i++) 
			{
				currentButton = buttons_arr[i];
				currentButton.destroy();
			}
		}
		
		
	}

}