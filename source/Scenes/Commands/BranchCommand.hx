package scenes.commands;

class BranchCommand extends Command
{
	public var id : String;
	public var commands : Array<Command>;

	public function new(Id : String)
	{
		super();

		id = Id;
		commands = [];
	}

	override public function init(Scene : SceneState)
	{
		super.init(Scene);
        
        trace("Branch with " + commands.length + " commands executed");
        onComplete();
	}

	override public function print() : String
	{
		return "Branch with id " + id;
	}

	public static function parse(line : String) : Command
	{        
		var comps : Array<String> = line.split(" ");
		var id : String = StringTools.trim(comps[0]);
		
		var command : Command = new BranchCommand(id);
		return command;
	}
}
