package;

import flixel.FlxG;

class SwipeManager
{
    public static var Enabled : Bool = false;

    public var leftCallback : Void -> Void;
    public var rightCallback : Void -> Void;

    public function new()
    {
        leftCallback = rightCallback = null;
    }

    public function update(elapsed : Float) : Void
    {
        if (!Enabled) {
            return;
        }

        for (swipe in FlxG.swipes)
        {
            // swipe.startPosition (FlxPoint)
            // swipe.endPosition (FlxPoint)
            // swipe.id (Int)
            // swipe.distance (Float)
            // swipe.angle (Float)
            // swipe.duration (Float)

            // trace("Swipe (" + swipe.ID + ") l: " + swipe.distance + ", a: " + swipe.angle + ", d: " + swipe.duration);

            // Handle only meaningful swipes
            if (swipe.distance > 30)
            {
                if (swipe.angle > 30 && swipe.angle < 120)
                {
                    // towards right swipe
                    if (rightCallback != null)
                        rightCallback();
                }
                else if (swipe.angle < -60 && swipe.angle > -120)
                {
                    // towards left swipe
                    if (leftCallback != null)
                        leftCallback();
                }
            }
        }
    }
}
