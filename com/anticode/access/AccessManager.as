package com.anticode.access
{
	import adobe.utils.CustomActions;
	import com.hybrid.ui.ToolTip;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.Stage;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import com.anticode.ui.message.MessageManager;
	import org.osflash.signals.Signal;
	import com.anticode.access.ButtonAccess;
	import com.anticode.access.Tooltip;
	import com.anticode.ui.sound.SoundManager;
	/**
	 * Maneja la accesibilidad en general
	 * @author Santiago J. Franzani
	 */
	public class AccessManager 
	{

		static private var instance:AccessManager;
		static private var allowInstance:Boolean;
		private var sectionFocused:Section;
		private var globalButtons_arr:Array;
		private var soundManager:SoundManager;
		private var stageRef:Stage;
		private var sectionFocusMgr:SectionFocusMgr;
		private var breadcrumb_arr:Array;
		public var breadcrumbSignal:Signal;
		public var tooltipEnabledSignal:Signal;
		public var tooltip:Tooltip;
		
		
		public function AccessManager() 
		{
			if (!allowInstance)throw new Error("Singleton: use getInstance()");
			
			tooltipEnabledSignal = new Signal(Boolean);
			soundManager = SoundManager.getInstance();
			globalButtons_arr = [];
			sectionFocusMgr = new SectionFocusMgr();
			breadcrumb_arr = [];
			breadcrumbSignal = new Signal(Array);
		}
		public static function getInstance():AccessManager
		{
			if (!instance)
			{
				allowInstance = true;
				instance = new AccessManager();
				allowInstance = false;
			}
			return instance;
			
		}
		public function init(stageRef:Stage):void
		{
			this.stageRef = stageRef;
			initTooltip();
			ShortcutMgr.getInstance().init(stageRef);
		}
		
		public function destroy():void 
		{
			tooltipEnabledSignal = null;
			soundManager = null;
			globalButtons_arr = null;
			stageRef = null;
			//tooltip = null;
			instance = null;
			sectionFocusMgr.destroy();
			sectionFocusMgr = null;
		}

		public function focusSection(section:Section):void
		{
			if (sectionFocused == section) return;
			
			var newSectionFocused:Section = sectionFocusMgr.openSection(section);
			if (sectionFocused == newSectionFocused) return;
			
			if (sectionFocused)
			{
				activateButtons(sectionFocused, false);
				refreshTabs(false);
			}
			sectionFocused = newSectionFocused;
			
			activateButtons(sectionFocused, true);
			refreshTabs(true);
		}	
		public function refreshCurrentSectionButtons():void
		{
			activateButtons(sectionFocused, true);
			refreshTabs(true);
		}
	
		public function closeSection(section:Section):void
		{
			activateButtons(sectionFocused, false);
			refreshTabs(false);
			sectionFocused = null;
			stageRef.focus = null;
			
			var newSectionFocused:Section = sectionFocusMgr.closeSection(section);

			if (newSectionFocused)focusSection(newSectionFocused);
		
		}
		

		
		
		
		
		
		
				

		public function addGlobalButton(buttonAccess:ButtonAccess):void
		{
			if (!isButtonAdded(buttonAccess))
			{
				globalButtons_arr.push(buttonAccess);
				buttonAccess.globalAccess = true;
				buttonAccess.activate(true);
			}
		}
		
		
		
		public function focusMessageBox():void
		{
			activateButtons(sectionFocused, false);
			activateGlobalButtons(false);
			refreshTabsMessageBox(MessageManager.getInstance().getButtons());
		}
		public function unfocusMessageBox():void
		{
			activateButtons(sectionFocused, true);
			activateGlobalButtons(true);
			refreshTabs(true);
		}
		
		
		
		public function playSpeech(url:String):void
		{
			//El ID "accessSpeech" lo mantengo fijo para que no se superpongan varios sonidos. Es un "monotrack".
			soundManager.play(SoundManager.ACCESS_TRACK, "accessSpeech", url);
		}
		
		public function stopSpeech(buttonID:String):void
		{
			soundManager.stop(SoundManager.ACCESS_TRACK, "accessSpeech");
		}
		
		public function enableTooltips(value:Boolean):void
		{
			tooltipEnabledSignal.dispatch(value);
			tooltip.enabled = value;
		}
		public function refreshTabs(value:Boolean = true):void
		{
			var textFieldFocused:Boolean = false;
			var tabElements_arr:Array = sectionFocused.getTabElements();
			var maxFocused:int = tabElements_arr.length;
			for (var j:int = 0; j < maxFocused; j++) 
			{
				(tabElements_arr[j]).tabIndex = j+1;
				(tabElements_arr[j]).tabEnabled = value;
				
				if ((tabElements_arr[j]) is TextField && !textFieldFocused && value)
				{
					textFieldFocused = true;
					if (!(tabElements_arr[j] as TextField).stage) continue;
					(tabElements_arr[j] as TextField).stage.focus = (tabElements_arr[j]);
				}
			}	
			
			
			var lastTab:int = maxFocused;
			
			var maxGlobal:int = globalButtons_arr.length;
			for (var i:int = 0; i < maxGlobal; i++) 
			{
				(globalButtons_arr[i] as ButtonAccess).tabIndex = lastTab + 1 + i;
				(globalButtons_arr[i] as ButtonAccess).tabEnabled = value;
			}
		}
		public function refreshTabsMessageBox(buttons_arr:Array):void
		{
			var tabElements_arr:Array = sectionFocused.getTabElements();
			var maxFocused:int = tabElements_arr.length;
			for (var j:int = 0; j < maxFocused; j++) 
			{
				(tabElements_arr[j]).tabEnabled = false;
			}	
			
			var maxGlobal:int = globalButtons_arr.length;
			for (var i:int = 0; i < maxGlobal; i++) 
			{
				(globalButtons_arr[i] as ButtonAccess).tabEnabled = false;
			}
			
			
			
			var max:int = buttons_arr.length;
			for (var k:int = 0; k < max; k++) 
			{
				(buttons_arr[k] as MovieClip).tabIndex = k;
			}
		}
		
		//Private functions
		
		private function initTooltip():void
		{
			tooltip = new Tooltip();
			enableTooltips(true);
		}
	
		private function isButtonAdded(buttonAccess:ButtonAccess):Boolean 
		{
			var max:int = globalButtons_arr.length;
			for (var i:int = 0; i < max; i++) 
			{
				if (buttonAccess == globalButtons_arr[i])
				{
					return true;
				}
			}
			return false;
		}
		


		private function activateButtons(sectionFocused:Section, value:Boolean):void 
		{
			if (!sectionFocused) return;
			var buttons_arr:Array = sectionFocused.getButtons();
			
			var currentButton:ButtonAccess
			if (!buttons_arr) return;
			var max:int = buttons_arr.length;
			for (var i:int = 0; i < max; i++) 
			{
				currentButton = buttons_arr[i] as ButtonAccess;
				currentButton.activate(value);
				
				if (value)
				{
					
					currentButton.focusInSignal.add(buttonFocusIn)
					currentButton.focusOutSignal.add(buttonFocusOut)
					
					currentButton.overSignal.add(buttonRollOver)
					currentButton.outSignal.add(buttonRollOut)
				}else {
					currentButton.focusInSignal.remove(buttonFocusIn)
					currentButton.focusOutSignal.remove(buttonFocusOut)
				}
			}
		}

		private function activateGlobalButtons(value:Boolean):void 
		{
			var currentButton:ButtonAccess
			var max:int = globalButtons_arr.length;
			for (var i:int = 0; i < max; i++) 
			{
				currentButton = globalButtons_arr[i] as ButtonAccess;
				currentButton.activate(value);
			}	
		}
		public function setSectionBreadcrumb(name:String, depthIndex:int):void
		{
			
			//borra todo lo superior
			while (breadcrumb_arr[depthIndex + 1])
			{
				breadcrumb_arr.splice(depthIndex + 1, 1);
			}
			
			
			breadcrumb_arr[depthIndex] = name;
			
			breadcrumbSignal.dispatch(breadcrumb_arr);
		}
		public function getBreadcrumbs():Array
		{
			return breadcrumb_arr;
		}
		
		private function buttonFocusIn(button:ButtonAccess):void 
		{
			
		}
		
		private function buttonFocusOut(button:ButtonAccess):void 
		{

		}
	
				
		private function buttonRollOut(button:ButtonAccess):void 
		{
			
		}
		
		private function buttonRollOver(button:ButtonAccess):void 
		{
			
		}

		public function getAccessData(textID:String, sectionID:String = ""):Object
		{
			return AccessModel.getInstance().getAccessData(textID, sectionID);
		}
		
		public function getText(textID:String, sectionID:String):Object
		{
			return AccessModel.getInstance().getText(textID, sectionID);
		}
		

		
		
	}

}