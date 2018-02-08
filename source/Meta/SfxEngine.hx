package;

import flixel.FlxG;
import flixel.util.FlxSave;
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

        trace("SFX ENGINE INIT");

        load();

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
        save();
    }

    public static function disable()
    {
        stopAll();

        Enabled = false;
        save();
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

    static var savefile : String = "settings";
    public static function save()
    {
        var save : FlxSave = new FlxSave();
        save.bind(savefile);

        save.data.sfx = Enabled;
        save.close();
    }

    static function load()
    {
        var save : FlxSave = new FlxSave();
        save.bind(savefile);

        if (save.data.sfx != null)
        {
            Enabled = save.data.sfx;
            trace("Loaded SFX " + (Enabled ? "ON" : "OFF"));
        }
        else
            Enabled = true;

        save.close();
    }
}

enum SFX {
    None;
    Click;
    Clock;
}
