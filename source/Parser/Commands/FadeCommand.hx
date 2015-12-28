package parser.commands;

class FadeCommand extends Command
{
	public static var MODE_IN : Int = 0;
	public static var MODE_OUT : Int = 1;
	
	public var mode : Int;
	public var duration : Float;
	public var color : Int;
	
	public function new(Mode : Int, ?Duration : Float = 1, ?Color : Int = 0xFF000000)
	{
		super();
		
		mode = Mode;
		duration = Duration;
		color = Color;
	}
	
	override public function execute()
	{
		// ?
	}
	
	override public function print() : String
	{
		return "Fade " + (mode == MODE_IN ? " in to " : " out from ") + color + " in " + duration + " seconds";
	}
	
	public static function parse(line : String) : Command
	{
		var components : Array<String> = line.split(" ");
		
		var mode : Int = -1;
		var duration : Float = 1.0;
		var color : Int = 0xFF000000;
		
		for (comp in components)
		{
			switch (comp)
			{
				case "in":
					mode = MODE_IN;
				case "out":
					mode = MODE_OUT;
				// case 
			}
		}
		
		var command : Command = new BgCommand(id);
		return command;
	}
}