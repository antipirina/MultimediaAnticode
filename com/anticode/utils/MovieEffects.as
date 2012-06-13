package com.anticode.utils 
{
	import com.greensock.TweenMax;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.Stage;
	import flash.events.Event;
	import com.greensock.*; 
	import com.greensock.plugins.*;
	import com.greensock.easing.*;
	TweenPlugin.activate([ColorMatrixFilterPlugin, EndArrayPlugin]);
	import flash.events.MouseEvent;
	
	

	/**
	 * ...
	 * @author Santiago J. Franzani
	 */
	public class MovieEffects 
	{
		
		public function MovieEffects() 
		{
			
		}
		
		
		static public function flyInto(mc:DisplayObjectContainer,stageRef:Stage,callback:Function = null):void 
		{
			TweenMax.from(mc, 0.4, {x:-mc.width,ease:Quad.easeOut,onComplete:callback});
		}	
		
		static public function flyIntoInv(mc:DisplayObjectContainer,stageRef:Stage,callback:Function = null):void 
		{
			TweenMax.from(mc, 0.4, {x:stageRef.stageWidth+40,ease:Quad.easeOut,onComplete:callback});
		}	
		
		static public function flyOut(mc:DisplayObjectContainer,stageRef:Stage,callback:Function  = null):void 
		{
			TweenMax.to(mc, 0.35, {x:stageRef.stageWidth+40,ease:Quad.easeIn,onComplete:callback});
			
		}
		static public function flyOutInv(mc:DisplayObjectContainer,stageRef:Stage,callback:Function  = null):void 
		{
			TweenMax.to(mc, 0.35, {x:-mc.width,ease:Quad.easeIn,onComplete:callback});
			
		}
		
		static public function fadeIn(mc:DisplayObjectContainer,callback:Function = null):void 
		{
			TweenMax.from(mc, 0.4, {alpha:0,ease:Quad.easeOut,onComplete:callback});
		}
		static public function fadeOut(mc:DisplayObjectContainer,callback:Function = null):void 
		{
			TweenMax.to(mc, 0.35, {alpha:0,ease:Quad.easeIn,onComplete:callback});
		}
		
/*		public static function onOverBright(e:MouseEvent):void
		{
			var target:DisplayObject = e.currentTarget as DisplayObject;
			
			TweenMax.to(target, 0.2, {colorTransform:{exposure:1.1}} );
			
		}		
		
		public static function onOutBright(e:MouseEvent):void
		{
			var target:DisplayObject = e.currentTarget as DisplayObject;
			
			TweenMax.to(target, 0.3, {colorTransform:{exposure:1}} );
			
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
		}*/
		
	}

}