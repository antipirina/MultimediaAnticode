package com.anticode.access
{
    import flash.ui.Keyboard;


    public class KeyCodeUtil {
         /*
                The below codes is used for generating KEYCODES. Some formating is needed to be done by hand after getting the outputStr.

                var outputStr:String = "";
                function onPress(evt:KeyboardEvent):void {
                        outputStr += "'" + evt.charCode + "':" + evt.keyCode + ", //"+String.fromCharCode(evt.charCode)+"\n";
                }
        */
        static public const KEYCODES:Object = {
                        27: 27,         //esc
                        96: 192,        //`
                        49: 49,         //1
                        50: 50,         //2
                        51: 51,         //3
                        52: 52,         //4
                        53: 53,         //5
                        54: 54,         //6
                        55: 55,         //7
                        56: 56,         //8
                        57: 57,         //9
                        48: 48,         //0
                        45: 189,        //-
                        61: 187,        //=
                        8: 8,           //backspace
                        9: 9,           //tab
                        113: 81,        //q
                        119: 87,        //w
                        101: 69,        //e
                        114: 82,        //r
                        116: 84,        //t
                        121: 89,        //y
                        117: 85,        //u
                        105: 73,        //i
                        111: 79,        //o
                        112: 80,        //p
                        91: 219,        //[
                        93: 221,        //]
                        92: 220,        //\
                        97: 65,         //a
                        115: 83,        //s
                        100: 68,        //d
                        102: 70,        //f
                        103: 71,        //g
                        104: 72,        //h
                        106: 74,        //j
                        107: 75,        //k
                        108: 76,        //l
                        59: 186,        //;
                        39: 222,        //'
                        13: 13,         //enter
                        122: 90,        //z
                        120: 88,        //x
                        99: 67,         //c
                        118: 86,        //v
                        98: 66,         //b
                        110: 78,        //n
                        109: 77,        //m
                        44: 188,        //,
                        46: 190,        //.
                        47: 191,        ///
                        32: 32,         //space
                        127: 46,        //delete
                        126: 192,       //~
                        33: 49,         //!
                        64: 50,         //@
                        35: 51,         //#
                        36: 52,         //$
                        37: 53,         //%
                        94: 54,         //^
                        38: 55,         //&
                        42: 56,         //*
                        40: 57,         //(
                        41: 48,         //)
                        95: 189,        //_
                        43: 187,        //+
                        81: 81,         //Q
                        87: 87,         //W
                        69: 69,         //E
                        82: 82,         //R
                        84: 84,         //T
                        89: 89,         //Y
                        85: 85,         //U
                        73: 73,         //I
                        79: 79,         //O
                        80: 80,         //P
                        123: 219,       //{
                        125: 221,       //}
                        124: 220,       //|
                        65: 65,         //A
                        83: 83,         //S
                        68: 68,         //D
                        70: 70,         //F
                        71: 71,         //G
                        72: 72,         //H
                        74: 74,         //J
                        75: 75,         //K
                        76: 76,         //L
                        58: 186,        //:
                        34: 222,        //"
                        90: 90,         //Z
                        88: 88,         //X
                        67: 67,         //C
                        86: 86,         //V
                        66: 66,         //B
                        78: 78,         //N
                        77: 77,         //M
                        60: 188,        //<
                        62: 190,        //>
                        63: 191         //?
                }
        /**
         * @param char Can be String or charCode(Number).
         * @param numpad If set to true, the function will return the keyCode for numpad. Ignored if numpad have no such key.
         */
        static public function getKeyCodeOf(char:*):Array {
                var charCodes_arr:Array = [];

                if (char is String)
				{
					var currentCode:int
					var chars_arr:Array = (char as String).split(",");
					
					var max:int = chars_arr.length;
					for (var i:int = 0; i < max; i++) 
					{
						if ((chars_arr[i] as String).length > 1)
						{
							currentCode = getSpecialKeyCode(chars_arr[i]);
							//currentCode = KEYCODES[currentCode] ? KEYCODES[currentCode] : -1
						}else {
							
							currentCode = ((chars_arr[i] as String).toUpperCase()).charCodeAt();
							//currentCode = KEYCODES[currentCode] ? KEYCODES[currentCode] : -1
						}
						charCodes_arr.push(currentCode);
					}
					
                }else{
                        charCodes_arr.push(char);
				}
                return charCodes_arr;
        }
		
		static private function getSpecialKeyCode(char:String):uint
		{
			switch (char.toLowerCase())
			{
				case "backspace":
					return 8;
				break;
				
				case "tab":
					return 9;
				break;
				
				case "enter":
					return 13;
				break;
				
				case "capslock":
					return 20;
				break;
				
				case "esc":
					return 27;
				break;
				
				case "spacebar":
					return 32;
				break;
				
				case "pageup":
					return 33;
				break;
				
				case "pagedown":
					return 34;
				break;
				
				case "end":
					return 35;
				break;
				
				case "home":
					return 36;
				break;
				
				case "leftarrow":
					return 37;
				break;
				
				case "uparrow":
					return 38;
				break;
								
				case "downarrow":
					return 40;
				break;
				
				case "rightarrow":
					return 39;
				break;
				
				case "insert":
					return 45;
				break;
								
				case "delete":
					return 46;
				break;
								
				case "numlock":
					return 144;
				break;								
				case "f1":
					return 112;
				break;								
				case "f2":
					return 113;
				break;								
				case "f3":
					return 114;
				break;								
				case "f4":
					return 115;
				break;								
				case "f5":
					return 116;
				break;								
				case "f6":
					return 117;
				break;								
				case "f7":
					return 118;
				break;								
				case "f8":
					return 119;
				break;								
				case "f9":
					return 120;
				break;								
				case "f10":
					return 121;
				break;								
				case "f11":
					return 122;
				break;								
				case "f12":
					return 123;
				break;
			}
			return 0;

		}

    }
}