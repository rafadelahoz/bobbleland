package;

import flixel.FlxG;
import flixel.system.FlxSound;
import flixel.tweens.FlxTween;

class BgmEngine
{
    static var FadeTime : Float = 0.5;

    static var Enabled : Bool = true;

    static var initialized : Bool = false;

    static var tunes : Map<BGM, FlxSound>;
    static var playing : Map<BGM, Bool>;
    public static var current : BGM;

    public static function init()
    {
        if (initialized)
            return;

        initialized = true;

        tunes = new Map<BGM, FlxSound>();
        tunes.set(BGM.Title, (Enabled ? FlxG.sound.load("assets/music/title.ogg") : null));
        tunes.set(BGM.Menu, (Enabled ? FlxG.sound.load("assets/music/menu.ogg") : null));

        playing = new Map<BGM, Bool>();
        for (tune in tunes.keys())
        {
            tunes.get(tune).persist = true;
            playing.set(tune, false);
        }

        current = None;
    }

    public static function play(bgm : BGM, ?volume : Float = 0.75, ?restart : Bool = false)
    {
        if (tunes.exists(bgm))
        {
            if (volume <= 0)
            {
                stop(bgm);
            }
            else if (restart || !playing.get(bgm))
            {
                trace(current + " to " +  bgm);
                if (current != bgm)
                {
                    stop(current);
                }

                if (Enabled)
                {
                    tunes.get(bgm).fadeIn(FadeTime, 0, volume);
                }

                playing.set(bgm, true);
                current = bgm;
                trace("Current: " + current);
            }
        }
    }

    public static function stopCurrent()
    {
        stop(current);
    }

    public static function stop(bgm : BGM)
    {
        trace("Stopping " + bgm);
        if (playing.get(bgm))
        {
            if (Enabled) tunes.get(bgm).fadeOut(FadeTime, 0, function(_t:FlxTween) {tunes.get(bgm).stop();});
            playing.set(bgm, false);
            current = None;
        }
    }
}

enum BGM {
    None;
    Title;
    Menu;
    Other;
}
