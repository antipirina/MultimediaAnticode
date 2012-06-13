package com.anticode.ui.message
{
	import com.greensock.easing.Sine;
	import com.greensock.TweenLite;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import com.anticode.access.ButtonAccess;
	import com.anticode.ui.message.MessageEvent;
	import flash.utils.getDefinitionByName;
	/**
	 * ...
	 * @author Santiago Franzani
	 *
	 */
	public class MessageBox extends MovieClip
	{
		private var mensaje_txt:TextField;
		public var isShowing:Boolean;
		public var messageID:String;
		public var ms:int;
		private var _text:String;
		private var asset:MovieClip;
		private var background_mc:MovieClip;
		private var minHeight:int = 30;
		public var buttons_arr:Array;
		private var butAsset_str:String;
		private var buttonGeneric_mc:MovieClip;
		private const buttonXspace:int = 15;
		private var accessButtons_arr:Array;
		private var buttonsGroup_spt:Sprite;

		public function MessageBox(asset:MovieClip, text:String,ms:int = 0, messageID:String = null, butAsset_str:String = null, buttons:Array = null)
		{
			this.butAsset_str = butAsset_str;
			this.asset = asset;
			addChild(asset);
			isShowing = false;
			this.messageID = messageID;
			this.ms = ms;
			buttons_arr = buttons;
			accessButtons_arr = [];
			buttonGeneric_mc = asset.getChildByName("button_mc") as MovieClip; //APAGA EL BOTON QUE NO SE USA.
			buttonGeneric_mc.visible = false;

			background_mc = asset.getChildByName("background_mc") as MovieClip;
			mensaje_txt = asset.getChildByName("mensaje_field") as TextField;


			
			this.text = text;
		}
		public function show():void
		{
			
			setButtons();
			
			var extraSpace:int = (buttons_arr.length != 0)? buttonGeneric_mc.height:0;
			background_mc.width = buttonsGroup_spt.width + extraSpace * 2;
			if (background_mc.width < 400) background_mc.width = 400;
			mensaje_txt.width = background_mc.width - extraSpace * 2;
			mensaje_txt.x = -mensaje_txt.width / 2;
			mensaje_txt.height = mensaje_txt.textHeight+10;
			
			buttonsGroup_spt.y = mensaje_txt.height + minHeight+10;
			buttonsGroup_spt.x = -buttonsGroup_spt.width / 2;
			
			
			background_mc.height = mensaje_txt.height + minHeight + extraSpace;
			///FALTARÍA HACER background_mc.width DEPENDIENDO DEL ANCHO QUE OCUPAN LOS BOTONES.
			
			
			this.y = stage.stageHeight / 2 - background_mc.height / 2 ;
			this.x = stage.stageWidth / 2;
			visible = true;
			isShowing = true;
			alpha = 0;
			TweenLite.to(this, 0.3, { alpha:1, ease:Sine.easeOut } );

		}

		private function setButtons():void
		{
			var buttonAsset:Class = getDefinitionByName(butAsset_str) as Class;

			buttonsGroup_spt = new Sprite();

			asset.addChild(buttonsGroup_spt);

			for (var i:int = 0; i < buttons_arr.length; i++)
			{

				var currentMessageButon:MessageButton = buttons_arr[i] as MessageButton;
				
				var currentButton:MovieClip = new buttonAsset() as MovieClip;
				
				
				var buttonAcc:ButtonAccess = new ButtonAccess(currentButton, hide);

				buttonAcc.key = currentMessageButon.key;
				buttonAcc.alt = currentMessageButon.alt;
				buttonAcc.ctrl = currentMessageButon.ctrl;
				buttonAcc.shift = currentMessageButon.shift;
			
				buttonAcc.activate(true);
				buttonAcc.mouseChildren = false;
				buttonAcc.setText(currentMessageButon.text);
				
				


				
				if (StringUtils.hasText((buttons_arr[i] as MessageButton).audio))buttonAcc.setSpeech((buttons_arr[i] as MessageButton).audio);
				
				if (StringUtils.hasText((buttons_arr[i] as MessageButton).tooltip)) buttonAcc.setTooltip((buttons_arr[i] as MessageButton).tooltip);
				
				
				
				accessButtons_arr.push(buttonAcc);
				
				
				//buttonsGroup_spt.addChild(buttonAcc);
				buttonsGroup_spt.addChild(currentButton);

				var button_background:MovieClip = currentButton.getChildByName("background_mc") as MovieClip;
				var button_field:TextField = currentButton.getChildByName("button_field") as TextField;
				button_field.text = (buttons_arr[i] as MessageButton).text;

				////BUTTON HANDLERS////
				if ((buttons_arr[i] as MessageButton).butFunction != null)
				{
					//buttonAcc.addEventListener(MouseEvent.CLICK, (buttons_arr[i] as MessageButton).butFunction);
					currentButton.addEventListener(MouseEvent.CLICK, (buttons_arr[i] as MessageButton).butFunction);
					
				}

				
				//buttonAcc.x = (buttonAcc.width * i)+(buttonXspace*i)+buttonAcc.width/2;
				currentButton.x = (currentButton.width * i)+(buttonXspace*i)+currentButton.width/2;
			}
			

		}
		
		public function getButtons():Array
		{
			return accessButtons_arr;
		}
		public function hide(e:* = null):void
		{
			TweenLite.to(this, 0.1, { alpha:0, ease:Sine.easeIn, onComplete:endMessage} );
		}
		


		private function endMessage(e:* = null):void
		{
			visible = false;
			isShowing = false;
			
			var max:int = accessButtons_arr.length;
			for (var i:int = 0; i < max; i++) 
			{
				(accessButtons_arr[i] as ButtonAccess).activate(false);
			
			}	
			accessButtons_arr = [];
			dispatchEvent(new MessageEvent("end", this.messageID));
		}
		public function get text():String { return _text; }

		public function set text(value:String):void
		{
			mensaje_txt.text = value;
			mensaje_txt.height = mensaje_txt.textHeight+10;
			_text = value;
		}

		///////////////////BUTTONS HANDLERS////////////////////////
		private function buttonOver(e:MouseEvent):void
		{
			(e.currentTarget as MovieClip).gotoAndStop(2);
		}
		private function buttonOut(e:MouseEvent):void
		{
			(e.currentTarget as MovieClip).gotoAndStop(1);
		}
		private function buttonDown(e:MouseEvent):void
		{
			(e.currentTarget as MovieClip).gotoAndStop(3);
		}

	}

}

