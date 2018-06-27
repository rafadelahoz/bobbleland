package;

import flixel.FlxG;

class Screenshot
{
    public static function take(?fname : String = null) : String
    {
        #if (android || ios)
        var b : flash.display.Bitmap = flixel.addons.plugin.screengrab.FlxScreenGrab.grab();
        return save(b, fname);
        #else
        return "";
        #end
    }

    public static function save(bitmap : flash.display.Bitmap, ?fname : String = null) : String
    {
        #if mobile
            // return;
        #end

        if (fname == null)
            fname = "soap-alley-" + Date.now().getTime();

        fname += ".png";

        var path : String = ".";

        #if android
            #if !lime_legacy
            path = lime.system.System.userDirectory;
            #else
            path = openfl.utils.SystemPath.userDirectory;
            #end

            // path += "/SOAP ALLEY/screenshots";
        #end

        try
        {
            #if (android || ios)
                sys.FileSystem.createDirectory(path);
                trace("Saving to " + sys.FileSystem.absolutePath(path));
                var ba : openfl.utils.ByteArray = bitmap.bitmapData.encode(bitmap.bitmapData.rect, new openfl.display.PNGEncoderOptions());
                var fo : sys.io.FileOutput = sys.io.File.write(path + "/" + fname, true);
                fo.writeBytes(ba, 0, ba.length);
                fo.close();
            #end
        } catch (e:Dynamic) {
            trace("Save failed");
            trace(e);
        }

        return path + "/" + fname;
    }

    public static function memtake() : openfl.display.BitmapData
    {
        #if (android || ios)
            return flixel.addons.plugin.screengrab.FlxScreenGrab.grab().bitmapData;
        #else
            return null;
        #end
    }
}
