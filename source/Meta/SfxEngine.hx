package;

import flixel.FlxG;
import flixel.util.FlxSave;
import flixel.system.FlxSound;
import flixel.tweens.FlxTween;

enum SFX {
    None;
    Click;
    Clock;
    BubbleBounce;
    BubbleStop;
    BubbleFall;
    NiceSmall;
    NiceBig;
    Lost;
    Print;
    RowGeneration;
    Rumble;
    PresentOpen;
    Blocker;
    Accept;
    StickerA;
    StickerB;
    Chime;
    SmallFanfare;
    BigFanfare;
    CleanFanfare;
    UnlockHum;
    UnlockShine;
}

class SfxEngine
{
    static var path : String = "assets/sounds/";

    public static var Enabled : Bool = true;

    static var initialized : Bool = false;

    static var sfx : Map<SFX, FlxSound>;
    static var sfxFiles : Map<SFX, String>;

    public static function init()
    {
        if (initialized)
            return;

        trace("SFX ENGINE INIT");

        load();

        initialized = true;

        sfxFiles = new Map<SFX, String>();
        sfxFiles.set(SFX.Click,          path + "btn_click.wav");
        sfxFiles.set(SFX.Clock,          path + "btn_clock.wav");
        sfxFiles.set(SFX.BubbleBounce,   path + "bubble-stop.wav");
        sfxFiles.set(SFX.BubbleStop,     path + "bubble-bounce.wav");
        sfxFiles.set(SFX.BubbleFall,     path + "bubble-fall.wav");
        sfxFiles.set(SFX.NiceSmall,      path + "nice-small.wav");
        sfxFiles.set(SFX.NiceBig,        path + "nice-big.wav");
        sfxFiles.set(SFX.Lost,           path + "lose.wav");
        sfxFiles.set(SFX.Print,          path + "low-vibration.wav");
        sfxFiles.set(SFX.RowGeneration,  path + "row.wav");
        sfxFiles.set(SFX.Rumble,         path + "low-vibration.wav");
        sfxFiles.set(SFX.PresentOpen,    path + "temp-present-open.wav");
        sfxFiles.set(SFX.Blocker,        path + "blocker.wav");
        sfxFiles.set(SFX.Accept,         path + "accept.wav");
        sfxFiles.set(SFX.StickerA,       path + "sticker-paste.wav");
        sfxFiles.set(SFX.StickerB,       path + "sticker-paste-b.wav");
        sfxFiles.set(SFX.Chime,          path + "temp-chime.wav");
        sfxFiles.set(SFX.SmallFanfare,   path + "small-fanfare.wav");
        sfxFiles.set(SFX.BigFanfare,     path + "big-fanfare.wav");
        sfxFiles.set(SFX.CleanFanfare,   path + "clear-fanfare-loud.wav");
        sfxFiles.set(SFX.UnlockHum,      path + "unlock-hum-fader.wav");
        sfxFiles.set(SFX.UnlockShine,    path + "399904_e.wav");

        sfx = new Map<SFX, FlxSound>();
        for (sf in sfxFiles.keys())
        {
            sfx.set(SFX.Click, loadSfx(sfxFiles.get(sf)));
        }

        for (sf in sfx.keys())
        {
            sfx.get(sf).persist = true;
        }
    }

    static function loadSfx(name : String) : FlxSound
    {
        return FlxG.sound.load(name);
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

    public static function play(sf : SFX, ?volume : Float = 1, ?loop : Bool = false)
    {
        if (Enabled && sfx.exists(sf))
        {
            sfx.set(sf, FlxG.sound.play(sfxFiles.get(sf), volume, loop));
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
