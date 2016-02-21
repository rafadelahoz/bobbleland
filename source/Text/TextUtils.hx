package text;

class TextUtils
{
    /* Pads the provided string with the given character */
	public static function padWith(string : String, length : Int, ?char : String = " ") : String
	{
		while (string.length < length)
		{
			string = char + string;
		}

		return string;
	}

    public static function formatTime(seconds : Int) : String
    {
        var str : String = "";
        var minutes = Std.int(seconds / 60);
        var hours = Std.int(minutes / 60);
        seconds = seconds % 60;

        if (hours > 0)
            str += hours + ":";
        if (minutes > 0 || hours > 0)
            str += minutes + ":";
        str += seconds + "'";

        return str;
    }
}
