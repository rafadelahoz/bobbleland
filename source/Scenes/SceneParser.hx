package scenes;

import openfl.Assets;

import scenes.commands.*;

class SceneParser
{
	public var filename : String;

	public var commands : Array<Command>;
	public var currentBlock : Array<Command>;

	public function new(filename : String)
	{
		this.filename = filename;

		commands = [];		
	}

	public function print()
	{
		trace("Script: " + filename);
		trace("Commands: " + commands.length);
		for (index in 0...commands.length)
		{
			var command : Command = commands[index];
			trace(index + " |\t" + command.print());
		}
	}

	public function parse() : Array<Command>
	{
		var basePath : String = "assets/scenes/";

		commands = [];
		currentBlock = commands;

		var fileContents : String = Assets.getText(basePath + filename);
		var lines : Array<String> = fileContents.split("\n");

		for (line in lines)
		{
			parseLine(line);
		}

		return commands;
	}

	function parseLine(line : String)
	{
		// Is it a comment?
		if (line.charAt(0) == "#")
			return;

		var command : Command = null;

		// Trim the line
		line = StringTools.trim(line);

		// Locate command
		var spacePos : Int = line.indexOf(" ");
		if (spacePos >= 0)
		{
			var commandName : String = line.substring(0, spacePos);
			line = line.substring(spacePos+1, line.length);

			switch (commandName)
			{
				case "char":
					command = CharCommand.parse(line);
				case "exit":
					command = ExitCommand.parse(line);
				case "say":
					command = SayCommand.parse(line);
				case "bg":
					command = BgCommand.parse(line);
				case "fade":
					command = FadeCommand.parse(line);
				case "puzzle":
					command = PuzzleCommand.parse(line);
				case "wait":
					command = WaitCommand.parse(line);
				/*case "decide":
					command = DecideCommand.parse(line);
				case "branch":
					// When a branch command is found
					command = BranchCommand.parse(line);
					// Use its command list as the current block
					var commAsBranch : BranchCommand = cast command;
					currentBlock = commAsBranch.commands;
					// Until the end element is found, all commands will be
					// stored inside the branch command command list
				case "end":
					currentBlock = commands;*/
				default:
					trace("Unrecognized command: " + line);
			}
		}

		// Store command
		storeCommand(command);
	}
	
	function storeCommand(command)
	{
		if (command != null)
		{
			commands.push(command);
		}
	}
}
