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

        load();

        initialized = true;

        tunes = new Map<BGM, FlxSound>();
        tunes.set(BGM.Title, FlxG.sound.load("assets/music/title.ogg"));
        tunes.set(BGM.Menu, FlxG.sound.load("assets/music/menu.ogg"));
        tunes.set(BGM.GameA, FlxG.sound.load("assets/music/gameA.ogg"));
        tunes.set(BGM.GameC, FlxG.sound.load("assets/music/gameC.ogg"));
        tunes.set(BGM.Danger, FlxG.sound.load("assets/music/danger.ogg"));

        playing = new Map<BGM, Bool>();
        for (tune in tunes.keys())
        {
            if (tunes.get(tune) != null)
            {
                tunes.get(tune).persist = true;
                tunes.get(tune).looped = true;
            }
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
            if (tunes.get(tune) != null && tunes.get(tune).playing)
                stop(tune);
        }

        current = None;
        Enabled = false;
        save();
    }

    public static function play(bgm : BGM, ?volume : Float = 0.75, ?restart : Bool = false)
    {
        // Better to stop than to play what we don't want
        if (current != bgm)
        {
            stop(current);
        }

        if (tunes.exists(bgm) && tunes.get(bgm) != null)
        {
            if (volume <= 0)
            {
                stop(bgm);
            }
            else
            {
                if (Enabled && (restart || !playing.get(bgm)))
                {
                    if (tunes.get(bgm).fadeTween != null)
                        tunes.get(bgm).fadeTween.cancel();
                    tunes.get(bgm).fadeIn(FadeTime, 0, volume);

                    playing.set(bgm, true);
                    current = bgm;
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
            if (Enabled && tunes.get(bgm) != null)
            {
                tunes.get(bgm).fadeOut(FadeTime*2, -10, function(_t:FlxTween) {tunes.get(bgm).stop();});
            }
            playing.set(bgm, false);
            current = None;
        }
    }

    public static function getBgm(bgmName : String) : BGM
    {
        return BGM.createByName(bgmName);
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
    GameA;
    GameC;
    Danger;
    Other;
}
