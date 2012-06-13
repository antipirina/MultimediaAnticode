package com.anticode.access
{
	import com.anticode.utils.ButtonFX;
	import com.curiousmedia.ui.Shortcut;
	import com.greensock.TweenMax;
	import com.greensock.TimelineLite;
	import com.hybrid.ui.ToolTip;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Stage;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import org.osflash.signals.DeluxeSignal;
	import org.osflash.signals.Signal;
	import com.anticode.access.AccessManager;
	import com.anticode.access.ShortcutMgr;
	
	import com.greensock.*; 
	import com.greensock.plugins.*;
	import com.greensock.easing.*;
	TweenPlugin.activate([ColorMatrixFilterPlugin, EndArrayPlugin]);
	
	/**
	 * ...
	 * @author Santiago J. Franzani
	 */
	public class ButtonAccess extends MovieClip
	{
		//esta variable se utiliza como nombre si el botón pertenece a una lista de botones con el mismo nombre. Cuando se lista se le cambia el nombre, pero buscaría el mismo ID en la base de datos de Texto
		public var content:MovieClip;
		private var rollOverFunc:Function;
		private var rollOutFunc:Function;
		private var clickFunc:Function;
		private var buttonText_arr:Array;
		private var tooltipText:String;
		private var tooltip:Tooltip;
		private var autosizeTooltip:Boolean;
		private var soundURL:String;
		private var isOverNow:Boolean;
		private var shortcutText:String;
		private var pressFunc:Function;
		static private var glowTimeline:TimelineLite;
		public var glowOnEnabled:Boolean;
		public var id:String;
		public var globalAccess:Boolean;
		public var focusInSignal:DeluxeSignal;
		public var focusOutSignal:DeluxeSignal;	
		public var overSignal:DeluxeSignal;
		public var outSignal:DeluxeSignal;
		public var key:String;
		public var alt:Boolean;
		public var ctrl:Boolean;
		public var shift:Boolean;
		private var _disableDefaultPress:Boolean;
		private var _buttonModeEnabled:Boolean
		private var _enabled:Boolean = true;
		
		public function ButtonAccess(content:MovieClip,onClick:Function,onRollOver:Function = null, onRollOut:Function = null, onPress:Function = null)
		{
			buttonModeEnabled = true;
			glowOnEnabled = false;
			globalAccess = false; 
			disableDefaultPress = false
			
			this.content = content;
			//addChild(content);
			if (!content) throw new Error("El contenido del ButtonAccess es nulo");
			if (content.id)id = content.id;
			
			buttonText_arr = findTextField();
			name = content.name;
			clickFunc = onClick;
			
			
			focusInSignal = new DeluxeSignal(this);
			focusOutSignal = new DeluxeSignal(this);
			
			overSignal = new DeluxeSignal(this);
			outSignal = new DeluxeSignal(this);
			
			if (onRollOver != null)
			{
				rollOverFunc = onRollOver;
			}else {
				rollOverFunc = onRollOverDefault;
			}
			
			if (onRollOut != null)
			{
				rollOutFunc = onRollOut;
			}else {
				rollOutFunc = onRollOutDefault;
			}
			
			
			if (onPress != null)
			{
				pressFunc = onPress;
			}else {
				if (content.totalFrames >= 3) pressFunc = onPressDefault;
			}
			activate(true);
		}
		public function hasTextField():Boolean
		{
		
		 	if (findTextField().length > 0) return true; 
			return false;
		}
		private function findTextField():Array
		{
			var max:int = content.numChildren
			
			var found_arr:Array = [];
			for (var i:int = 0; i <max; i++) 
			{
				var child:TextField = content.getChildAt(i) as TextField
			
				if (child is TextField)
				{
					child.mouseEnabled = false;
					found_arr.push(child);
				}
			}
			
			return found_arr;
		}
		public function setText(text:String):void
		{
			if (StringUtils.hasText(text))
			{
				if (buttonText_arr.length > 0)
				{
					mouseChildren = false;
					
					for (var i:int = 0; i < buttonText_arr.length; i++) 
					{
						(buttonText_arr[i] as TextField).text = text;
					}
				}else {
					throw new Error("Error XML: Se intentó ingresar un texto en un botón sin campo de texto: " + name);
				}
			}
		}
		public function setTooltip(text:String):void
		{
			tooltipText = text;
			
		autosizeTooltip = true;
			if (tooltipText.length < 30)
				autosizeTooltip = true;
			
			tooltip = AccessManager.getInstance().tooltip;
			
		}
		
		private function setShortCutTooltip(shortcut:String):void 
		{
			shortcutText = shortcut;
			autosizeTooltip = true;
			tooltip = AccessManager.getInstance().tooltip;
		}
		
		
		public function setSpeech(soundURL:String):void
		{
			this.soundURL = soundURL;
		}
		
		private function onRollOutDefault(e:MouseEvent ):void 
		{
			content.gotoAndStop(1);
		}	
		
		private function onPressDefault(e:MouseEvent ):void 
		{
			if (disableDefaultPress) return;
			content.gotoAndStop(3);
			(e.currentTarget as DisplayObject).stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUpDefault);
		}
		private function onMouseUpDefault(e:MouseEvent):void 
		{
			if (disableDefaultPress) return;
			content.gotoAndStop(1);
			
			(e.currentTarget as DisplayObject).stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUpDefault);
			
		}
		private function onMouseDownDefault(e:MouseEvent):void
		{
			if (disableDefaultPress) return;
		}
		
		
		private function onRollOverDefault(e:MouseEvent):void 
		{
			content.gotoAndStop(2);
		}
		private function onOutExtra(e:MouseEvent):void 
		{
			isOverNow = false;
			outSignal.dispatch(this);
			if (tooltip) tooltip.hide();
			if (soundURL) AccessManager.getInstance().stopSpeech(this.name);
		}
		
		private function onOverExtra(e:MouseEvent):void 
		{
			isOverNow = true;
			overSignal.dispatch(this);
			//stage.focus = null;
			if (tooltip)
			{
				showTooltip(false, 700);
			}
			if (soundURL) AccessManager.getInstance().playSpeech(soundURL);
		}
	
		private function onFocusOut(e:FocusEvent):void 
		{
			focusOutSignal.dispatch(this);
			//content.gotoAndStop(1);
			if (tooltip) tooltip.hide();
			if (soundURL) AccessManager.getInstance().stopSpeech(this.name);
		}
		
		private function onFocusIn(e:FocusEvent):void 
		{
			if (isOverNow) return;
			focusInSignal.dispatch(this);
			//content.gotoAndStop(2);
			if (tooltip)
			{
				showTooltip(false, 0);
			}
			if (soundURL) AccessManager.getInstance().playSpeech(soundURL);
		}
		
		public function showTooltip(followMouse:Boolean = true, delay:int = 0):void
		{
				tooltip.autoSize = autosizeTooltip;
				var finalTooltipText:String
				if (tooltipText && shortcutText)
				{
					
					
					finalTooltipText = tooltipText+"\n ["+shortcutText+"]";
				}else {
					
					if (StringUtils.hasText(shortcutText))
					{
						finalTooltipText = "[" + shortcutText + "]";
					}else {
						finalTooltipText = tooltipText;
					}
					if (!shortcutText && !tooltipText) return;
				}
				
				tooltip.show(content, finalTooltipText, followMouse, delay);
		}
		public function destroy():void
		{
			activate(false);
			
			content = null;
		}
		public function activate(value:Boolean):void
		{

			if (value && !_enabled) return;
			if (buttonModeEnabled)	content.buttonMode = value;
			
			content.tabEnabled = value;
			activateShortcut(value);

			if (!value)
			{
				if (tooltip)tooltip.hide();
				if (content.hasEventListener(MouseEvent.CLICK))content.removeEventListener(MouseEvent.CLICK, clickFunc);
				if (content.hasEventListener(MouseEvent.ROLL_OVER))content.removeEventListener(MouseEvent.ROLL_OVER, rollOverFunc);
				if (content.hasEventListener(MouseEvent.ROLL_OUT)) content.removeEventListener(MouseEvent.ROLL_OUT, rollOutFunc);
				if (content.hasEventListener(MouseEvent.ROLL_OVER)) content.removeEventListener(MouseEvent.ROLL_OVER, onOverExtra);
				if (content.hasEventListener(MouseEvent.ROLL_OUT)) content.removeEventListener(MouseEvent.ROLL_OUT, onOutExtra);		
				if (content.hasEventListener(FocusEvent.FOCUS_IN)) content.removeEventListener(FocusEvent.FOCUS_IN, onFocusIn);
				if (content.hasEventListener(FocusEvent.FOCUS_OUT)) content.removeEventListener(FocusEvent.FOCUS_OUT, onFocusOut);
				if (pressFunc != null) if (content.hasEventListener(MouseEvent.MOUSE_DOWN)) content.removeEventListener(MouseEvent.MOUSE_DOWN, pressFunc);				
				
				if (pressFunc != null) if (content.hasEventListener(MouseEvent.MOUSE_UP))
				{
					if (pressFunc == onPressDefault)
					{
						content.removeEventListener(MouseEvent.MOUSE_UP, onMouseUpDefault);
					}
					
						content.removeEventListener(MouseEvent.MOUSE_UP, rollOutFunc);
					
				}
				if (glowOnEnabled) stopGlowing();
				TweenMax.to(content, 0.4, {colorMatrixFilter:{brightness:0.8, saturation:0.2}});

			
			}else {
				if (glowOnEnabled) startGlowing();
				TweenMax.to(content, 0.4, { colorMatrixFilter: { brightness:1, saturation:1 }} );
				content.addEventListener(MouseEvent.CLICK, clickFunc);
				content.addEventListener(MouseEvent.ROLL_OVER, onOverExtra);
				content.addEventListener(MouseEvent.ROLL_OUT, onOutExtra);
				content.addEventListener(MouseEvent.ROLL_OVER, rollOverFunc);
				content.addEventListener(MouseEvent.ROLL_OUT, rollOutFunc);		
				content.addEventListener(FocusEvent.FOCUS_IN, onFocusIn);
				content.addEventListener(FocusEvent.FOCUS_OUT, onFocusOut);
				if (pressFunc != null)content.addEventListener(MouseEvent.MOUSE_DOWN, pressFunc);
				
				if (pressFunc != null)
				{
					 
					if (pressFunc == onPressDefault)
					{
						content.addEventListener(MouseEvent.MOUSE_UP, onMouseUpDefault);
						
					}
						content.addEventListener(MouseEvent.MOUSE_UP, rollOutFunc);
					
				}
			}
			
		}
		

		
		private function activateShortcut(value:Boolean):void 
		{
			
			if (value)
			{
				if (key)
				{
					var shortcut:String = ShortcutMgr.getInstance().createShortcut(name, clickFunc, ctrl, alt, shift, key,this);
					
					if (tooltip)
					{
						shortcutText = shortcut;
					}else
					{
						setShortCutTooltip(shortcut);
					}
				}
				
			}else {
				if (key)ShortcutMgr.getInstance().deleteShortcut(name);
			}
		}
		override public function gotoAndStop (frame:Object, scene:String = null) : void
		{
			content.gotoAndStop(frame, scene);
		}
		
		override public function gotoAndPlay (frame:Object, scene:String = null) : void
		{
			content.gotoAndPlay(frame, scene);
		}
		override public function get currentFrame () : int
		{
			return content.currentFrame;
		}	
		override public function get tabIndex () : int
		{
			return content.tabIndex;
		}
		override public function set tabIndex (index:int) : void
		{
			content.tabIndex = index;
		}
		override public function get tabEnabled () : Boolean
		{
			return content.tabEnabled;
		}
		override public function set tabEnabled (enabled:Boolean) : void
		{
			content.tabEnabled = enabled;
		}
		
	
		public function get buttonModeEnabled():Boolean 
		{
			return _buttonModeEnabled;
		}
		
		public function set buttonModeEnabled(value:Boolean):void 
		{
			if (!value)content.buttonMode = false;
			_buttonModeEnabled = value;
		}
		
		
		
		override public function get enabled () : Boolean
		{
			return _enabled;
		}
		
		override public function set enabled (value:Boolean) : void
		{
			_enabled = value;
		}
		
		public function get disableDefaultPress():Boolean 
		{
			return _disableDefaultPress;
		}
		
		public function set disableDefaultPress(value:Boolean):void 
		{
			_disableDefaultPress = value;
		}
		
		
		
		public function startGlowing():void
		{
			ButtonFX.startGlowing(content);
		}	
		public function stopGlowing():void
		{
			ButtonFX.stopGlowing(content);
		}
	}

}