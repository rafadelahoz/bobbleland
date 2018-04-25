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
    NiceSmall;
    NiceBig;
    Lost;
    Print;
    RowGeneration;
    Accept;
    StickerA;
    StickerB;
}

class SfxEngine
{
    static var path : String = "assets/sounds/";

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
        sfx.set(SFX.Click,          loadSfx("btn_click.wav"));
        sfx.set(SFX.Clock,          loadSfx("btn_clock.wav"));
        sfx.set(SFX.BubbleBounce,   loadSfx("bubble-stop.wav"));
        sfx.set(SFX.BubbleStop,     loadSfx("bubble-bounce.wav"));
        sfx.set(SFX.NiceSmall,      loadSfx("nice-small.wav"));
        sfx.set(SFX.NiceBig,        loadSfx("nice-big.wav"));
        sfx.set(SFX.Lost,           loadSfx("lose.wav"));
        sfx.set(SFX.Print,          loadSfx("low-vibration.wav"));
        sfx.set(SFX.RowGeneration,  loadSfx("row.wav"));
        sfx.set(SFX.Accept,         loadSfx("accept.wav"));
        sfx.set(SFX.StickerA,        loadSfx("sticker-paste.wav"));
        sfx.set(SFX.StickerB,        loadSfx("sticker-paste-b.wav"));

        for (sf in sfx.keys())
        {
            sfx.get(sf).persist = true;
        }
    }

    static function loadSfx(name : String) : FlxSound
    {
        return FlxG.sound.load(path + name);
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
            sfx.get(sf).looped = loop;
            sfx.get(sf).volume = volume;
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
