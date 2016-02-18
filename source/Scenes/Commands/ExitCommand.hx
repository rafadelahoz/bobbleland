package scenes.commands;

import scenes.Character;

class ExitCommand extends Command
{
	public var character : String;
	
    public function new(Character : String)
	{
		super();

		character = Character;
	}
	
	override public function init(Scene : SceneState)
	{
		super.init(Scene);

		// Look for the character in the current manager
		var char : Character = scene.characterManager.get(character);
		
		// If it IS present, make it exit
		if (char != null)
		{
			scene.characterManager.remove(character, onCharacterExited);
		}
        else 
        {
            onCharacterExited();
        }
	}

	public function onCharacterExited() : Void
	{
		onComplete();
	}

	override public function print() : String
	{
		return "Character " + character + " leaves";
	}

	public static function parse(line : String) : Command
	{
		var char : String = StringTools.trim(line);
		
		var command : Command = new ExitCommand(char);
		return command;
	}
}
