package com.anticode.ui.character 
{
	import avmplus.finish;
	import flash.events.TimerEvent;
	import flash.text.TextField;
	import flash.utils.Timer;
	/**
	 * ...
	 * @author Santiago J. Franzani
	 */
	public class Subtitles 
	{
		private var unusedWords_arr:Array;
		private var usedWords_arr:Array;
		private var timeMS:int;
		private var tfWidth:Number;
		private var tfDummie:TextField;
		private var tf:TextField;
		private var subtitleLines_arr:Array;
		private var fullText:String;
		private var subtitleTimer:Timer;
		private var subtitleCounter:int;
		
		public function Subtitles() 
		{
			
		}
		
		public function showSubtitles(tf:TextField, text:String, timeMS:int):void 
		{
			this.fullText = text;
			this.tf = tf;
			this.timeMS = timeMS;
			
			tfDummie = new TextField();
			tfDummie.setTextFormat(tf.getTextFormat());
			tfDummie.defaultTextFormat = tf.defaultTextFormat;
			tfDummie.width = tf.width;
			tfDummie.height = tf.height;
			tfWidth = tfDummie.width-100;
			
			unusedWords_arr = text.split(" ");
			usedWords_arr = [];
			subtitleLines_arr = [];
			constructALine();
			
		}
		
		private function constructALine():void 
		{
			subtitleLines_arr.push("");
			tfDummie.text = "";
			var lineReady:Boolean = false;
			
			while (!lineReady)
			{
				subtitleLines_arr[subtitleLines_arr.length - 1] += unusedWords_arr[0] + " ";
				tfDummie.text = (subtitleLines_arr[subtitleLines_arr.length - 1] as String);
				usedWords_arr.push(unusedWords_arr[0]);
				unusedWords_arr.shift();
				if (unusedWords_arr.length == 0) lineReady = true;
				if (tfDummie.textWidth >= tfWidth)
				{
					unusedWords_arr.unshift(usedWords_arr[usedWords_arr.length - 1]);
					usedWords_arr.pop();
					subtitleLines_arr[subtitleLines_arr.length - 1] = beforeLast(subtitleLines_arr[subtitleLines_arr.length - 1], unusedWords_arr[0]);

					lineReady = true;
				}
			}
			if (unusedWords_arr.length > 0)
			{
				constructALine();
			}else {
				configureTiming();
			}
		}
		
		private function configureTiming():void 
		{
			var textRatio:Number;
			var currentText:String;
			
			for (var i:int = 0; i < subtitleLines_arr.length; i++) 
			{
				currentText = subtitleLines_arr[i];
				textRatio = currentText.length / fullText.length;
				subtitleLines_arr[i] = [subtitleLines_arr[i], Math.floor(timeMS * textRatio)];
			}
			startShow();
		}
		
		private function startShow():void 
		{
			subtitleCounter = 0;
			nextLine();
			
			
		}
		
		private function nextLine():void 
		{
			if (!subtitleLines_arr[subtitleCounter])
			{
				//end(); //el end lo llama desde TalkingCharacterView
				return;
			}
			var text:String = subtitleLines_arr[subtitleCounter][0];
			var ms:Number = subtitleLines_arr[subtitleCounter][1];
			
			subtitleTimer = new Timer(ms, 1);
			subtitleTimer.addEventListener(TimerEvent.TIMER_COMPLETE, onLineEnd)
			subtitleTimer.start();
			tf.text = text;
		}
		
		private function onLineEnd(e:TimerEvent):void 
		{
			subtitleTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, onLineEnd);
			subtitleCounter++;
			nextLine();
		}
		
		public function end():void 
		{
			if (tf)tf.text = "";
			removeTimer();
		}
		
		private function removeTimer():void 
		{
			if (subtitleTimer)
			{
				subtitleTimer.stop();
				if (subtitleTimer.hasEventListener(TimerEvent.TIMER_COMPLETE)) subtitleTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, onLineEnd);
				subtitleTimer = null;
			}
		}
		
		public function destroy():void
		{
			 removeTimer();
			 
		}
		public static function beforeLast(p_string:String, p_char:String):String {
			if (p_string == null) { return ''; }
			var idx:int = p_string.lastIndexOf(p_char);
        	if (idx == -1) { return ''; }
        	return p_string.substr(0, idx);
		}
		

		
	
		
	}

}