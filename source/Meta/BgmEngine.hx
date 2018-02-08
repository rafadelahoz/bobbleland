package;

import flixel.FlxG;
import flixel.util.FlxSave;
import flixel.system.FlxSound;
import flixel.tweens.FlxTween;

class BgmEngine
{
    static var FadeTime : Float = 0.5;

    public static var Enabled : Bool = false;

    static var initialized : Bool = false;

    static var tunes : Map<BGM, FlxSound>;
    static var playing : Map<BGM, Bool>;
    public static var current : BGM;

    public static function init()
    {
        if (initialized)
            return;

        trace("BGM ENGINE INIT");

        load();

        initialized = true;

        tunes = new Map<BGM, FlxSound>();
        tunes.set(BGM.Title, FlxG.sound.load("assets/music/title.ogg"));
        tunes.set(BGM.Menu, FlxG.sound.load("assets/music/menu.ogg"));

        playing = new Map<BGM, Bool>();
        for (tune in tunes.keys())
        {
            tunes.get(tune).persist = true;
            tunes.get(tune).looped = true;
            playing.set(tune, false);
        }

        current = None;
    }

    public static function enable()
    {
        Enabled = true;
        save();
    }

    public static function disable()
    {
        for (tune in tunes.keys())
        {
            if (tunes.get(tune).playing)
                stop(tune);
        }

        current = None;
        Enabled = false;
        save();
    }

    public static function play(bgm : BGM, ?volume : Float = 0.75, ?restart : Bool = false)
    {
        if (tunes.exists(bgm))
        {
            if (volume <= 0)
            {
                stop(bgm);
            }
            else
            {
                trace(current + " to " +  bgm);
                if (current != bgm)
                {
                    stop(current);
                }

                if (Enabled && (restart || !playing.get(bgm)))
                {
                    trace(tunes.get(bgm).fadeTween);
                    if (tunes.get(bgm).fadeTween != null)
                        tunes.get(bgm).fadeTween.cancel();
                    tunes.get(bgm).fadeIn(FadeTime, 0, volume);

                    playing.set(bgm, true);
                    current = bgm;
                    trace("Current: " + current);
                }
            }
        }
    }

    public static function stopCurrent()
    {
        stop(current);
    }

    public static function stop(bgm : BGM)
    {
        if (playing.get(bgm))
        {
            trace("Stopping " + bgm);
            if (Enabled)
            {
                trace(tunes.get(bgm).fadeTween);
                tunes.get(bgm).fadeOut(FadeTime*2, -10, function(_t:FlxTween) {trace("stop!"); tunes.get(bgm).stop();});
                trace(tunes.get(bgm).fadeTween);
            }
            playing.set(bgm, false);
            current = None;
        }
    }

    static var savefile : String = "settings";
    public static function save()
    {
        var save : FlxSave = new FlxSave();
        save.bind(savefile);

        save.data.bgm = Enabled;
        save.close();
    }

    static function load()
    {
        var save : FlxSave = new FlxSave();
        save.bind(savefile);

        if (save.data.bgm != null)
        {
            Enabled = save.data.bgm;
            trace("Loaded BGM " + (Enabled ? "ON" : "OFF"));
        }
        else
            Enabled = true;

        save.close();
    }
}

enum BGM {
    None;
    Title;
    Menu;
    Other;
}
