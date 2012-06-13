package com.curiousmedia.ui
{
	import flash.display.DisplayObject;
	/**
	 * represents a keyboard shortcut as an object
	 * 
	 * @author Doug McCluer
	 */	
	 
	public class Shortcut extends Object
	{
		public var targetFunction:Function;
		private var _keys:Array;
		public var ctrlKey:Boolean = false;
		public var altKey:Boolean = false;
		public var shiftKey:Boolean = false;
		private var _comboString:String;
		public var buttonRef:DisplayObject;
		public var label:String;
				
		/**
		 *Constructor
		 * 
		 * @param label 
		 * 	the name of this shortcut
		 * 
		 * @param targetFunction 
		 * 	the function to be called when this shorcut is invoked
		 * 
		 * @param ctrl
		 * 	indicates whether the ctrl (Cmd) key must be pressed to invoke this shorcut.
		 * 	Note: Due to inconsistent behavior across browsers, use of the ctrl key for shortcuts is discouraged.
		 * 	
		 * @param alt
		 * 	indicates whether the Alt (Option) key must be pressed to invoke this shorcut. 
		 * 
		 * @param shift
		 * 	indicates whether the Shift key must be pressed to invoke this shorcut.
		 * 
		 * @param keyCodes  
		 * 	Array of uints representing keyCodes.  The keys which must be pressed to invoke this shortcut.
		 */
		public function Shortcut(label:String, targetFunction:Function, ctrl:Boolean, alt:Boolean, shift:Boolean, keyCodes_arr:Array=null,buttonRef:DisplayObject = null)
		{
			this.buttonRef = buttonRef;
			_keys = new Array();
			this.targetFunction = targetFunction;
			this.label = label;
			this.ctrlKey = ctrl;
			this.altKey = alt;
			this.shiftKey = shift;
			if(keyCodes_arr)
			{
				for(var i:int=0; i<keyCodes_arr.length; i++)
				{
					if(keyCodes_arr[i] is uint)
					{
						addKey(keyCodes_arr[i]);
					}
					else
					{
						throw new Error("Error in Shortcut(): " + keyCodes_arr[i].toString() + "is not uint.");
					}
				}
			}

			_comboString = createComboString();
		} //END Shortcut()
		
		
		/**
		 * adds another keyCode to the list of keys required to invoke this shortcut.
		 * 
		 * @param keyCode
		 * 	keyCode for the key to add
		 */
		public function addKey(keyCode:uint):void
		{
			if( keyCode == 17 )
			{
				ctrlKey = true;
			}
			else if (keyCode == 16)
			{
				shiftKey = true;
			}
			
			if(keyCode < 256)
			{
				_keys.push(keyCode);
				_keys.sort(Array.NUMERIC);
			}
			else
			{
				throw new Error("Error in "+this+".addKey():  keyCodes higher than 255 are not supported");
			}
			_comboString = createComboString();
		}
		
		
		/**
		 * allows you to check the keys required to invoke this shortcut.
		 * 
		 * @return Array of uints.  Note: this does not include keyCodes for the modifier keys (ctrl, alt, shift).
		 * 	Use the ctrlKey, altKey, and shiftKey properties to check modifier keys.   	
		 */
		public function get keys():Array
		{
			return _keys.concat();
		}
		
		
		/**
		 * @return String representation of the key combination required to invoke this shortcut.  
		 * 	Note: this is different from the toString() method.
		 */
		public function get comboString():String
		{
			return _comboString;
		}
		
		
		private function createComboString():String
		{
			var outString:String = "";
			if(ctrlKey)
			{
				if(outString.length >0)
				{
					outString += "+";
				}
				outString += "Ctrl";
			}
			else
			{
				
			}
			
			if(altKey)
			{
				if(outString.length >0)
				{
					outString += "+";
				}
				outString += "Alt";
			}
			
			if(shiftKey)
			{
				if(outString.length >0)
				{
					outString += "+";
				}
				outString += "Shift";
			}
			
			for(var i:int=0; i<_keys.length; i++)
			{
				if(outString.length >0)
				{
					outString += "+";
				}
				switch(_keys[i])
				{
					case 8:
						outString += "Backspace";
						break;
					case 9:
						outString += "Tab";
						break;
					case 13:
						outString += "Enter";
						break;
					case 14:
						outString += "CapsLock";
						break;
					case 27:
						outString += "Esc";
						break;
					case 32:
						outString += "Space";
						break;
					case 33:
						outString += "PageUp";
						break;
					case 34:
						outString += "PageDn";
						break;
					case 35:
						outString += "End";
						break;
					case 36:
						outString += "Home";
						break;
					case 37:
						outString += "Left";
						break;
					case 38:
						outString += "Up";
						break;
					case 39:
						outString += "Right";
						break;
					case 40:
						outString += "Down";
						break;
					case 45:
						outString += "Insert";
						break;
					case 46:
						outString += "Del";
						break;
					case 144:
						outString += "NumLock";
						break;
					case 145:
						outString += "ScrLk";
						break;
					case 19:
						outString += "Pause/Break";
						break;
				case 112:
					outString +=  "F1";
				break;								
				case 113:
					outString +=  "F2";
				break;								
				case 114:
					outString +=  "F3";
				break;								
				case 115:
					outString +=  "F4";
				break;								
				case 116:
					outString +=  "F5";
				break;								
				case 117:
					outString +=  "F6";
				break;								
				case 118:
					outString +=  "F7";
				break;								
				case 119:
					outString +=  "F8";
				break;								
				case 120:
					outString +=  "F9";
				break;								
				case 121:
					outString +=  "F10";
				break;								
				case 122:
					outString +=  "F11";
				break;								
				case 123:
					outString +=  "F12";
				break;
				
				default:
						outString += String.fromCharCode(_keys[i]);
				}	
			}
			//trace("comboString set to " + outString);
			return outString;
		} //END createComboString()
		
		public function toString():String
		{
			var outString:String = "[shortcut " + label + "] - " + _comboString;
			return outString;
		}
		public function getComboString():String
		{
			return _comboString
			
		}
		
	} //END class
}