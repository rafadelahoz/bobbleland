package;

import flash.media.Sound;

import flixel.FlxG;

class BgmEngine
{
    static var Enabled : Bool = true;

    static var tunes : Map<BGM, Sound>;
    static var playing : Map<BGM, Bool>;

    public static function init()
    {
        tunes = new Map<BGM, Sound>();
        tunes.set(BGM.Title, (Enabled ? FlxG.sound.cache("assets/music/title.ogg") : null));

        playing = new Map<BGM, Bool>();
        for (tune in tunes.keys())
        {
            playing.set(tune, false);
        }
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
                if (Enabled) FlxG.sound.playMusic(tunes.get(bgm), volume);
                playing.set(bgm, true);
            }
        }
    }

    public static function stop(bgm : BGM)
    {
        trace("Stopping " +  bgm);
        if (playing.get(bgm))
        {
            if (Enabled) FlxG.sound.playMusic(tunes.get(bgm), 0.0);
            playing.set(bgm, false);
        }
    }
}

enum BGM {
    None;
    Title;
    Other;
}
