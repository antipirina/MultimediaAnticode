package com.anticode.access
{
	import com.hybrid.ui.ToolTip;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.StageScaleMode;
	import flash.display.StageAlign;
	import flash.text.TextFormat;
	import com.anticode.access.AccessManager;
	
	
			
	/**
	 * ...
	 * @author Santiago J. Franzani
	 */
	public class Tooltip
	{
		
		private var _enabled:Boolean
		
		private var tooltipObject:ToolTip
		private var tooltipShowing:Boolean;
		
		public function Tooltip() 
		{
			
			
			var tf:TextFormat = new TextFormat();
			tf.bold = true;
			tf.size = 12;
			tf.color = 0x000;
			tf.align = "center";
 
			
			tooltipObject = new ToolTip();
			tooltipObject.hook = true;
			tooltipObject.hookSize = 10;
			tooltipObject.cornerRadius = 5;
			tooltipObject.colors = [0xffffff, 0xffffff];
			tooltipObject.align = "center";
			tooltipObject.autoSize = false;
			tooltipObject.titleFormat = tf;
			tooltipObject.tipWidth = 50;
			
			

		}
		public function hide():void
		{
			if (tooltipShowing)
			{
				tooltipObject.hide();
				tooltipShowing = false;
			}
		}
		public function show(p:DisplayObject, title:String, followMouse:Boolean = true, delay:int = 0):void
		{
			
			if (!tooltipShowing)
			{
				tooltipShowing = true;
				
				if (enabled) tooltipObject.show(p, title, null,followMouse, delay);
				
			}
		}
		
		///getters & setters		
		public function set autoSize(value:Boolean):void 
		{
			tooltipObject.autoSize = true;
		}
		
		public function get enabled():Boolean 
		{
			return _enabled;
		}
		
		public function set enabled(value:Boolean):void 
		{
			_enabled = value;
		}
		
		
	}

}