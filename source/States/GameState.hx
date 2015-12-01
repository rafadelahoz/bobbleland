package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.FlxSprite;

/**
 * Parent to our game states, handles the GamePad update
 **/
class GameState extends FlxState
{
	public var frame : FlxSprite;

	public function new()
	{
		super();
	}
	
	override public function create()
	{
		// Delegate
		super.create();
		
		GamePad.resetInputs();
		FlxG.inputs.reset();
	}
	
	override public function update()
	{
		// Update the GamePad state
		GamePad.handlePadState();
		
		// Before performing the actual update
		super.update();
	}
	
	/**
	 * Override for changing the frame loaded
	 */
	public function loadFrame()
	{
		frame = new FlxSprite(0, 0, "assets/images/frame.png");
		frame.scrollFactor.set();
	}
}