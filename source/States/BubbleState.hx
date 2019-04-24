package;

import flixel.FlxG;
import flixel.util.FlxTimer;
import flixel.text.FlxText;
import flixel.addons.transition.FlxTransitionableState;

class BubbleState extends FlxTransitionableState
{
    var cameraInfo : FlxText;
    public var movingCamera : Bool;

    override public function create()
    {
        super.create();

        new FlxTimer().start(0.1, function(t:FlxTimer) {
            cameraInfo = new FlxText(Constants.Width, Constants.Height, 90, "CAMERA INFO");
            add(cameraInfo);
        });
    }

    override public function update(elapsed : Float)
    {
        if (cameraInfo != null)
        {
            cameraInfo.text = "HI! YOU SHOULDNT SEE THIS!\nCAMERA AT\n" + FlxG.camera.scroll + "\n" + FlxG.camera;
        }

        super.update(elapsed);

        if (!movingCamera)
        {
            FlxG.camera.scroll.set(0, 0);
        }
    }


}
