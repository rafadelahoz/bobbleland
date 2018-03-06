package;

import extension.share.Share;

class BubbleShare
{
    static var initialized : Bool = false;

    public static function share(msg : String, ?savedImagePath : String = null, ?includeScreenshot : Bool = true)
    {
        if (!initialized)
		{
			Share.init(Share.TWITTER); // for non supported targets, we share on Twitter (you can also use Share.FACEBOOK)
			Share.defaultURL='http://badladns.com/'; // url to add at the end of each share (optional).
			Share.defaultSubject='A BADLADNS SHARE'; // in case the user choose to share by email, set the subject.
		}

		// var image : openfl.display.BitmapData = Screenshot.memtake();
		// Share.share('Hi, I\'m testing the OpenFL-Sharing extension!', image);

		var imagePath : String = null;
        if (savedImagePath == null && includeScreenshot)
            imagePath = Screenshot.take();
        else if (savedImagePath != null)
            imagePath = savedImagePath;

		Share.share(msg, null, imagePath);

        trace("share ok");
    }
}
