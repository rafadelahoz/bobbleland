package;

import flixel.FlxG;
import flixel.system.FlxSound;
import flixel.tweens.FlxTween;

class SfxEngine
{
    public static var Enabled : Bool = true;

    static var initialized : Bool = false;

    static var sfx : Map<SFX, FlxSound>;

    public static function init()
    {
        if (initialized)
            return;

        trace("BGM ENGINE INIT");

        initialized = true;

        sfx = new Map<SFX, FlxSound>();
        sfx.set(SFX.Click, FlxG.sound.load("assets/sounds/btn_click.wav"));
        sfx.set(SFX.Clock, FlxG.sound.load("assets/sounds/btn_clock.wav"));

        for (sf in sfx.keys())
        {
            sfx.get(sf).persist = true;
        }
    }

    public static function enable()
    {
        Enabled = true;
    }

    public static function disable()
    {
        stopAll();

        Enabled = false;
    }

    public static function play(sf : SFX, ?volume : Float = 1)
    {
        if (Enabled && sfx.exists(sf))
        {
            sfx.get(sf).play();
        }
    }

    public static function stopAll()
    {
        for (sf in sfx.keys())
        {
            if (sfx.get(sf).playing)
                stop(sf);
        }
    }

    public static function stop(sf : SFX)
    {
        if (Enabled)
        {
            sfx.get(sf).stop();
        }
    }
}

enum SFX {
    None;
    Click;
    Clock;
}
