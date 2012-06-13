package com.anticode.utils
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	/**
	 * ...
	 * @author Santiago J. Franzani
	 */
	public class mcUtil 
	{
		
		public function mcUtil() 
		{
			
		}
		public static function stopChildrenOf(clip:DisplayObjectContainer,stopTimeline:Boolean = false):void
		{
		  var i:int = clip.numChildren;
		  var child:DisplayObject;
		  while (i--)
		  {
			child = clip.getChildAt(i);
			if (child is MovieClip) (child as MovieClip).stop();
			if (child is DisplayObjectContainer) 
				stopChildrenOf(child as DisplayObjectContainer);
		  }
		  if (stopTimeline && clip is MovieClip)(clip as MovieClip).stop();
		}	
		public static function stopChildrenFrame1(clip:DisplayObjectContainer,stopTimeline:Boolean = false):void
		{
		  var i:int = clip.numChildren;
		  var child:DisplayObject;
		  while (i--)
		  {
			child = clip.getChildAt(i);
			if (child is MovieClip) (child as MovieClip).gotoAndStop(1);
			if (child is DisplayObjectContainer) 
				stopChildrenFrame1(child as DisplayObjectContainer);
		  }
		 if (stopTimeline && clip is MovieClip) (clip as MovieClip).gotoAndStop(1);
		}	
		public static function playAllChildrenOfFrame1(clip:DisplayObjectContainer,playClip:Boolean = false):void
		{
		  var i:int = clip.numChildren;
		  var child:DisplayObject;
		  while (i--)
		  {
			child = clip.getChildAt(i);
			if (child is MovieClip) (child as MovieClip).gotoAndPlay(1);
			if (child is DisplayObjectContainer) 
				playAllChildrenOf(child as DisplayObjectContainer);
		  }
		  if (playClip && clip is MovieClip)(clip as MovieClip).gotoAndPlay(1);
		}	
		
		public static function playAllChildrenOf(clip:DisplayObjectContainer,playClip:Boolean = false):void
		{
		  var i:int = clip.numChildren;
		  var child:DisplayObject;
		  while (i--)
		  {
			child = clip.getChildAt(i);
			if (child is MovieClip) (child as MovieClip).play();
			if (child is DisplayObjectContainer) 
				playAllChildrenOf(child as DisplayObjectContainer);
		  }
		  if (playClip && clip is MovieClip) (clip as MovieClip).play();
		}
		
		public static function positionElementsInGrid(place:DisplayObjectContainer, objects_arr:Array, width:int, marginX:int, marginY:int,centred:Boolean = true):void
		{
			var maxLineWidth:int = width;
			var lineHeight:int = getMaxHeight(objects_arr)+marginY;
			var currentLine:int = 0;
			var currentLineWidth:int = 0;
			var currentLineHeight:int = 0;
			var currentElementWidth:int
			
			for (var i:int = 0; i < objects_arr.length; i++)
			{
				var posX:int = currentLineWidth;
				var posY:int
				
				var currentElement:DisplayObject = objects_arr[i];
				
				currentElementWidth = currentElement.width;
				
				currentLineWidth += currentElementWidth + marginX;
				
				if (currentLineWidth > maxLineWidth)
				{
					currentLineWidth = currentElement.width+marginX;
					currentLine++
						currentLineHeight += lineHeight;
					posX = 0;
				}
				
				posY = currentLineHeight;
				
				currentElement.y = posY;
				currentElement.x = posX;
				
				place.addChild(currentElement);
				
			}
			
		}
		
		static private function getMaxHeight(objects_arr:Array):int
		{
			var max:int = 0;
			for (var i:int = 0; i < objects_arr.length; i++)
			{
				var currentHeight:int = (objects_arr[i] as DisplayObject).height
				if (max < currentHeight)
				{
					max = currentHeight;
				}
			}
			return max;
		}
		

	}

}