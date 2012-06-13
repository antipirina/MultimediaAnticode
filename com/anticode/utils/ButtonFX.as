package com.anticode.utils 
{
	import com.greensock.TweenMax;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.events.Event;
	import com.greensock.*; 
	import com.greensock.plugins.*;
	import com.greensock.easing.*;
	import flash.text.TextField;
	TweenPlugin.activate([ColorMatrixFilterPlugin, EndArrayPlugin]);
	import flash.events.MouseEvent;
	
	

	/**
	 * ...
	 * @author Santiago J. Franzani
	 */
	public class ButtonFX 
	{
		static private var currentButton:MovieClip;
		
		public function ButtonFX() 
		{
			
		}
		public static function onOverBright(e:MouseEvent):void
		{
			var target:DisplayObject = e.currentTarget as DisplayObject;
			
			TweenMax.to(target, 0.2, {colorTransform:{exposure:1.1}} );
			
		}		
		
		public static function onOutBright(e:MouseEvent):void
		{
			var target:DisplayObject = e.currentTarget as DisplayObject;
			
			TweenMax.to(target, 0.3, {colorTransform:{exposure:1}} );
			
		}
		
		public static function onOut(e:MouseEvent):void 
		{
			(e.currentTarget as MovieClip).gotoAndStop(1);
		}
		
		public static function onOver(e:MouseEvent):void
		{
			(e.currentTarget as MovieClip).gotoAndStop(2);
		}
		
		public static function onDown(e:MouseEvent):void
		{
			currentButton = e.currentTarget as MovieClip;
			currentButton.gotoAndStop(3);
			
			currentButton.stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUpDefault);
		}
		
		private static function onMouseUpDefault(e:MouseEvent):void
		{
				currentButton.gotoAndStop(1);
				(e.currentTarget as DisplayObject).stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUpDefault);
		}
		public static function addButtonListeners(button:MovieClip,clicFunc:Function):void
		{
			button.addEventListener(MouseEvent.CLICK, clicFunc);
			button.addEventListener(MouseEvent.ROLL_OVER, ButtonFX.onOver);
			button.addEventListener(MouseEvent.ROLL_OUT, ButtonFX.onOut);
			button.addEventListener(MouseEvent.MOUSE_DOWN, ButtonFX.onDown);
			button.buttonMode = true;
		}
		public static function removeButtonListeners(button:MovieClip, clicFunc:Function):void
		{
			button.removeEventListener(MouseEvent.CLICK, clicFunc);
			button.removeEventListener(MouseEvent.ROLL_OVER, ButtonFX.onOver);
			button.removeEventListener(MouseEvent.ROLL_OUT, ButtonFX.onOut);
			button.removeEventListener(MouseEvent.MOUSE_DOWN, ButtonFX.onDown);
			button.buttonMode = false;
		}
		
		static public function toggleButton(button:MovieClip,value:Boolean):void 
		{
			button.mouseEnabled = value;
			button.buttonMode = value;
			if (!value)
			{
				TweenMax.to(button, 0.4, {colorMatrixFilter:{brightness:0.8, saturation:0.6}});
				//TweenMax.to(button, 0.4, { colorTransform: { saturation:.5, exposure:.7 }} );
			}else {
				TweenMax.to(button, 0.4, {colorMatrixFilter:{brightness:1, saturation:1}});
				//TweenMax.to(button, 0, { colorTransform: { saturation:1, exposure:1 }} );
			}
		}
		public static function startGlowing(mc:DisplayObject):void
		{
			TweenMax.to(mc, 0.5, {yoyo:1, repeat:-1,colorMatrixFilter:{contrast:1.1, brightness:1.1}, glowFilter:{color:0xffffff, alpha:1, blurX:15, blurY:15},ease:Quad.easeInOut,repeatDelay:0.3});
		}
		
		public static function stopGlowing(mc:DisplayObject):void
		{
			TweenMax.to(mc, 0.5, {colorMatrixFilter:{contrast:1, brightness:1},glowFilter:{remove:true}});
		}
		
		
		
		///SET TEXT TO MC
		
		public static function setTextToMc(mc:DisplayObjectContainer,text:String):void
		{
			setText(text, findTextField(mc));
		}
		
		private static function setText(text:String,textFields_arr:Array):void
		{
			if (StringUtils.hasText(text))
			{
				if (textFields_arr.length > 0)
				{
					for (var i:int = 0; i < textFields_arr.length; i++) 
					{
						(textFields_arr[i] as TextField).text = text;
					}
				}
			}
		}
		
		private static function findTextField(mc:DisplayObjectContainer):Array
		{
			var max:int = mc.numChildren;
			
			var found_arr:Array = [];
			for (var i:int = 0; i <max; i++) 
			{
				var textChild:TextField = mc.getChildAt(i) as TextField;
			
				if (textChild is TextField)
				{
					textChild.mouseEnabled = false;
					found_arr.push(textChild);
				}
			}
			return found_arr;
		}
		
		
	}

}