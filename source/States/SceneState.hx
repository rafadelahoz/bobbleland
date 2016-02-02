package;

import flixel.FlxState;

import parser.commands.Command;

class SceneState extends FlxState
{
    public var commandQueue : Array<Command>;
    public var currentCommand : Command;

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

        var parser : parser.SceneParser = new parser.SceneParser(sceneFile);
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
