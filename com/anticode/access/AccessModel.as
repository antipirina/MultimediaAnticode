package com.anticode.access
{
	import br.com.stimuli.loading.BulkLoader;
	import br.com.stimuli.loading.BulkProgressEvent;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import mx.controls.Alert;
	import org.osflash.signals.Signal;
	/**
	 * ...
	 * @author Santiago Franzani
	 * SINGLETON
	 */
	public class AccessModel extends EventDispatcher
	{
		private static var instance:AccessModel;
		private static var allowInstance:Boolean = false;
		private var mainLoader:BulkLoader;
		private var text_xml:XML;
		private var access_xml:XML;
		public var testVallas_xml:XML;
		public var autoevaluacion_xml:XML;
		public var readySignal:Signal;

		public function AccessModel()
		{
			if (allowInstance)
			{
				readySignal = new Signal();

			}else
			{
				throw new Error("SINGLETON: use getInstance()");
			}
		}
		public static function getInstance():AccessModel
		{
			if (!instance)
			{
				allowInstance = true;
				instance = new AccessModel();
				allowInstance = false;
			}
			return instance;
		}
		public function getSpeechPath():String
		{
			return ModelManager.getInstance().getGlobalPath()+"mp3/"
		}
		
		public function setTextXML(xml:XML):void
		{
			this.text_xml = xml;
			
		}
			
		public function setAccessXML(xml:XML):void
		{
			this.access_xml = xml;
			
		}
		
		public function getAccessData(textID:String, sectionID:String = ""):Object
		{
			var access_obj:Object = searchAccessData(textID, sectionID);
			checkObjectEmpty(access_obj,"access",textID,sectionID);
			return access_obj;
		}
		
		public function getText(textID:String, section:String):Object
		{
			return getXMLText("texts", textID, section);
		}
		
		public function getXMLText(XMLId:String, textID:String, sectionID:String = ""):Object
		{
			var text_obj:Object = searchTextData(XMLId, textID, sectionID);
			checkObjectEmpty(text_obj,XMLId,textID,sectionID);
			return text_obj;
		}
		
		private function checkObjectEmpty(obj:Object,XMLId:String,textID:String,sectionID:String):void 
		{
			if (!obj)
			{
				throw new Error("Error XML: No se encontró la etiqueta: ["+textID+"] en la seccion ["+sectionID+"] del XMLId: "+XMLId);
			}
		}
		
			
		public function searchAccessData(buttonID:String, sectionID:String):Object
		{
			var globalAccess:Boolean = false;
			var currentXML:XMLList
			if (StringUtils.hasText(sectionID))
			{
			if (access_xml[sectionID].length() > 0)
			{
				if (access_xml[sectionID][buttonID].length())
				{
					currentXML = access_xml[sectionID][buttonID];
				}
			}
			}
			
			if (access_xml.global[buttonID].length())
			{
				globalAccess = true;
				currentXML = access_xml.global[buttonID];
			}
			if (!currentXML) return null;
			
			var key_str:String = currentXML.@key;
			var alt_bol:Boolean = Boolean(int(currentXML.@alt));
			var ctrl_bol:Boolean = Boolean(int(currentXML.@ctrl));
			var shift_bol:Boolean = Boolean(int(currentXML.@shift));
			var tooltip_str:String  = currentXML.@tooltip_id;

			if (tooltip_str)tooltip_str = getXMLText("texts",tooltip_str, sectionID).text;
				
			return {section:sectionID, key:key_str,alt:alt_bol,ctrl:ctrl_bol,shift:shift_bol,tooltip:tooltip_str,global:globalAccess};
		}
		

		
		public function searchTextData(XMLId:String,nodeID:String,sectionID:String = ""):Object
		{
			var currentXML:XML = text_xml;
			
				if (currentXML[sectionID].length() > 0)
				{
					if (currentXML[sectionID][nodeID].length())
					{
						var audio_str:String = currentXML[sectionID][nodeID].@audio;
						if (StringUtils.hasText(audio_str))audio_str = getSpeechPath() + audio_str;				
						return {text:currentXML[sectionID][nodeID],audio:audio_str};
					}
				}
				if (currentXML.global[nodeID].length())
				{
					var audioS_str:String = currentXML.global[nodeID].@audio;
					if (StringUtils.hasText(audioS_str)) audioS_str = getSpeechPath() + audioS_str;	
					return {text:currentXML.global[nodeID],audio:audioS_str};
				}
			
			return null;
		}
		

		
		
	}

}

