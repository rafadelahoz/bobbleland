package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;

import database.BackgroundDatabase;

import scenes.SceneParser;
import scenes.commands.Command;

import scenes.CharacterManager;

class SceneState extends FlxState
{
    public var commandQueue : Array<Command>;
    public var currentCommand : Command;

    public var characterManager : CharacterManager;
    public var characters : FlxGroup;

    public var background : FlxSprite;
    public var border : FlxSprite;
    public var sceneButtons : SceneButtons;

    public var sceneFile : String;

    public function new(SceneFile : String)
    {
        super();

        sceneFile = SceneFile;
        if (sceneFile == null)
            sceneFile = "sample-script.scene";
    }

    override public function create()
    {
        super.create();

        GamePad.init();
        BackgroundDatabase.Init();

        characterManager = new CharacterManager(this);

        background = new FlxSprite(0, 0);
        background.makeGraphic(Std.int(FlxG.width), Std.int(FlxG.height), 0xFF000000);
        add(background);

        characters = new FlxGroup();
        add(characters);

        border = new FlxSprite(0, 240).makeGraphic(Std.int(FlxG.width), 80, 0xFF000000);
        add(border);

        sceneButtons = new SceneButtons(0, 0);
        add(sceneButtons);

        var parser : SceneParser = new SceneParser(sceneFile);
		commandQueue = parser.parse();

        if (commandQueue != null)
        {
            nextCommand();
        }
    }

    override public function update(elapsed:Float)
    {
        GamePad.handlePadState();

        if (currentCommand != null)
        {
            currentCommand.update(elapsed);
        }

        super.update(elapsed);
    }

    override public function draw()
    {
        if (currentCommand != null)
        {
            currentCommand.draw();
        }

        super.draw();
    }

    public function onCommandFinish()
    {
        // Get next command, init it, execute
        // Maybe wait before doing that?
        nextCommand();
    }

    public function changeBackground(backgroundId : String) : Void
    {
        background.loadGraphic(BackgroundDatabase.GetBackground(backgroundId));
    }

    function nextCommand()
    {
        if (currentCommand != null)
            currentCommand.destroy();

        currentCommand = commandQueue.shift();
        if (currentCommand != null)
        {
            currentCommand.init(this);
        }
    }
}
