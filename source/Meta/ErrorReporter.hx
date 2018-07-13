package;

import haxe.CallStack;
import extension.share.Share;

class ErrorReporter
{
    public static function handle(error : Dynamic)
    {
        trace(error);
        var stack : String = CallStack.toString(CallStack.exceptionStack());
        trace(stack);

        Share.init(Share.TWITTER);
        Share.share(error + "\n" + stack, "Exception occurred", null, null, "the@badladns.com");
    }
}