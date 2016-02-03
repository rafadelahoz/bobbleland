package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;

import scenes.SceneParser;
import scenes.BackgroundDatabase;
import scenes.commands.Command;

class SceneState extends FlxState
{
    public var commandQueue : Array<Command>;
    public var currentCommand : Command;
    
    public var background : FlxSprite;
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

        background = new FlxSprite(0, 0);
        background.makeGraphic(Std.int(FlxG.width), Std.int(FlxG.height), 0xFF000000);
        add(background);
        
        sceneButtons = new SceneButtons(0, 0);
        add(sceneButtons);

        var parser : SceneParser = new SceneParser(sceneFile);
		commandQueue = parser.parse();

        if (commandQueue != null)
        {
            nextCommand();
        }
    }

    override public function update()
    {
        GamePad.handlePadState();

        if (currentCommand != null)
        {
            currentCommand.update();
        }

        super.update();
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
        /*var scaleX : Float = (FlxG.width / background.width);
        var scaleY : Float = (FlxG.height / background.height);
        trace("Scale: " + scaleX + " " + scaleY);
        background.scale.x = scaleX;
        background.scale.y = scaleY;*/
        background.setGraphicSize(FlxG.width);
        background.setGraphicSize(FlxG.height);
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
