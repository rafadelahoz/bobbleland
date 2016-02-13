package scenes.commands;

import flixel.util.FlxTimer;
import flixel.tweens.FlxTween;

class PuzzleCommand extends Command
{
	public var puzzle : String;
	public var nextScene : String;

	var announcement : PuzzleAnnouncement;

	public function new(Puzzle : String, Scene : String)
	{
		super();

		puzzle = Puzzle;
		nextScene = Scene;
	}

	override public function init(Scene : SceneState)
	{
		super.init(Scene);

		announcement = new PuzzleAnnouncement(0, 0);
		scene.add(announcement);
		announcement.init(400, onAnnouncementPositioned);
	}

	function onAnnouncementPositioned() : Void
	{
		var timer : FlxTimer = new FlxTimer(0.6, function(_t:FlxTimer) {
			FlxTween.tween(announcement.scale, {x : 10, y: 10}, 1, {
					complete : function(_t:FlxTween) {
						onComplete();
					}
				});
		});
	}

	override function onComplete()
	{
		GameController.OnSceneCompleted(puzzle, nextScene);
	}

	override public function print() : String
	{
		return "Next puzzle is: " + puzzle + ", and then scene " + nextScene;
	}

	public static function parse(line : String) : Command
	{
		var components : Array<String> = line.split(" ");

		if (components.length < 2)
			throw "Invalid puzzle command, missing arguments: " + line;

		var command : Command =
			new PuzzleCommand(StringTools.trim(components[0]),
								StringTools.trim(components[1]));
		return command;
	}
}
