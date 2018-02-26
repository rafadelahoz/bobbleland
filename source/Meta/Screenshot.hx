package;

import flixel.FlxG;

class Screenshot
{
    public static function take(?fname : String = null)
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
            path = lime.system.System.documentsDirectory;
            #else
            path = openfl.utils.SystemPath.documentsDirectory;
            #end

            path += "/SOAP ALLEY/screenshots";
        #end

        trace(path + "/" + fname);

        try
        {
            sys.FileSystem.createDirectory(path);
            trace(sys.FileSystem.absolutePath(path));
            var b : flash.display.Bitmap = flixel.addons.plugin.screengrab.FlxScreenGrab.grab();
            var ba : openfl.utils.ByteArray = b.bitmapData.encode(b.bitmapData.rect, new openfl.display.PNGEncoderOptions());
            var fo : sys.io.FileOutput = sys.io.File.write(path + "/" + fname, true);
            fo.writeBytes(ba, 0, ba.length);
            fo.close();
        } catch (e:Dynamic) {
            trace(e);
        }
    }
}
