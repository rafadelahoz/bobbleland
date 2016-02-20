package text;

import flixel.text.FlxBitmapText;
import flixel.graphics.frames.FlxBitmapFont;

import openfl.Assets;

class PixelText
{
	private static var fontFile : String = "assets/fonts/nes";

	// System pixel font
	public static var font : FlxBitmapFont;

	static var initialized : Bool;

	public static function Init()
	{
		// if (!initialized)
		{
			// Load system font
			// AngelCode
			/*var textBytes = Assets.getText(fontFile + ".fnt");
			var XMLData = Xml.parse(textBytes);*/
			// font = new PxBitmapFont().loadAngelCode(Assets.getBitmapData(fontFile + "_0.png"), XMLData);

			// Monospace
			var monospaceLetters = "!\"#$%&'()*+,-./0123456789:;<=>?@"+
									"ABCDEFGHIJKLMNOPQRSTUVWXYZ[]^_ab"+
									"cdefghijklmnopqrstuvwxyz{|}~\\";
			font = FlxBitmapFont.fromMonospace("assets/fonts/famicom.png", monospaceLetters, charSize);

			initialized = true;
		}
	}

	public static function New(X : Float, Y : Float, Text : String, ?Color : Int = 0xFFFFFFFF, ?Width : Int = -1) : FlxBitmapText
	{
		Init();

		var text : FlxBitmapText = new FlxBitmapText(font);
		text.x = X;
		text.y = Y - 4;
		text.text = Text;
		text.color = Color;
		text.useTextColor = false;

		if (Width > 0)
		{
			text.wordWrap = true;
			text.fixedWidth = true;
			text.width = Width;
			text.multiLine = true;
			// text.lineSpacing = -154;
		}

		return text;
	}
}
