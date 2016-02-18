package scenes.commands;

import scenes.Character;

class CharCommand extends Command
{
	public var character : String;
	public var expression : String;

	public function new(Character : String, ?Expression : String = null)
	{
		super();

		character = Character;
		expression = Expression;
	}
	
	override public function init(Scene : SceneState)
	{
		super.init(Scene);

		// Look for the character in the current manager
		var char : Character = scene.characterManager.get(character);
		
		// If it is not present, create it and reposition everyone accordingly
		if (char == null)
		{
			scene.characterManager.add(character, expression, onCharacterDisplayed);
		}
		// If it IS present, change its expression to match the provided one
		else 
		{
			char.changeExpression(expression, onCharacterDisplayed);
		}
	}

	public function onCharacterDisplayed() : Void
	{
		onComplete();
	}

	override public function print() : String
	{
		return "Character " + character + " appears" + (expression == null ? "" : ", " + expression);
	}

	public static function parse(line : String) : Command
	{
		var tokens : Array<String> = line.split(",");
		var char : String = StringTools.trim(tokens[0]);
		var expr : String = null;
		if (tokens.length > 1)
			expr = StringTools.trim(tokens[1]);

		var command : Command = new CharCommand(char, expr);
		return command;
	}
}
