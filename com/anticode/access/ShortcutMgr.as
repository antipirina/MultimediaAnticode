package com.anticode.access
{
	import com.curiousmedia.ui.Shortcut;
	import com.curiousmedia.ui.ShortcutManager;
	import flash.display.DisplayObject;
	import flash.display.Stage;
	/**
	 * ...
	 * @author Santiago J. Franzani
	 */
	public class ShortcutMgr
	{
		static private var instance:ShortcutMgr;
		static private var allowInstance:Boolean;
		private var sm:ShortcutManager;
		
		public function ShortcutMgr() 
		{
			if (!allowInstance) throw new Error("Singleton: use getInstance()");
			sm = com.curiousmedia.ui.ShortcutManager.getInstance();
		}
		public static function getInstance():ShortcutMgr
		{
			if (!instance)
			{
				allowInstance = true;
				instance = new ShortcutMgr();
				allowInstance = false;
			}
			return instance;
		}
		public function init(stageRef:Stage):void
		{
			ShortcutManager.getInstance().stageRef = stageRef;
		}
		public function createShortcut(id:String,func:Function,ctrl:Boolean,alt:Boolean,shift:Boolean,key:String,buttonRef:DisplayObject = null):String
		{
			var codes_arr:Array = KeyCodeUtil.getKeyCodeOf(key);
			var shortcutsString_arr:Array = [];
			var max:int = codes_arr.length;
			for (var i:int = 0; i < max; i++) 
			{
				shortcutsString_arr.push((sm.createShortcut(id, func, ctrl, alt, shift, [codes_arr[i]],buttonRef) as Shortcut).getComboString());
			}
			return shortcutsString_arr.join(" / ");
		}
		public function deleteShortcut(id:String):void
		{
			sm.deleteByLabel(id);
		}
		
		
	}

}