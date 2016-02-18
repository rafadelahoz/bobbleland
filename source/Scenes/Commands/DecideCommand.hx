package scenes.commands;

class DecideCommand extends Command
{
	public var labels : Array<String>;
	public var branches : Array<String>;

	public function new(Id : String)
	{
		super();
	}

	override public function init(Scene : SceneState)
	{
		super.init(Scene);
        onComplete();
	}

	override public function print() : String
	{
		return "Decide...";
	}

	public static function parse(line : String) : Command
	{        
		var comps : Array<String> = line.split(" ");
		var id : String = StringTools.trim(comps[0]);
		
		var command : Command = new DecideCommand(null);
		return command;
	}
}
