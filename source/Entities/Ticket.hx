package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.util.FlxSpriteUtil;

import text.PixelText;
import text.TextUtils;

class Ticket extends FlxSpriteGroup
{
    var btnSignature : Button;
    var btnShare : Button;

    var ticket : FlxSprite;
    var score : Int;
    var time : String;

    public var signatureCallback : Void -> Void;

    public function new()
    {
        super(0, 0);
    }

    public function init(data : Dynamic)
    {
        var top : FlxSprite = new FlxSprite(0, 0, "assets/ui/ticket-top.png");
        var bottom : FlxSprite = new FlxSprite(0, 96, "assets/ui/ticket-bottom.png");
        var contentsHeight : Int = 13*8;
        // Adjust to include record lines
        contentsHeight += 8*((data.scoreRecord ? 1 : 0) + (data.bubblesRecord ? 1 : 0) + (data.timeRecord ? 1 : 0) + (data.cleansRecord ? 1 : 0));

        var sprWidth : Int = Std.int(top.width);
        var sprHeight : Int = Std.int(top.height + contentsHeight + bottom.height);

        var sprite : FlxSprite = new FlxSprite(0, 0);
        sprite.makeGraphic(sprWidth, sprHeight, 0x00FFFFFF);

        sprite.stamp(top, 0, 0);
        sprite.stamp(bottom, 0, Std.int(top.height + contentsHeight));
        FlxSpriteUtil.drawRect(sprite, 0, top.height, top.width, contentsHeight, 0xFFFFF1E8);

        var baseY : Int = Std.int(top.height);
        text(sprite, getDate(), 8, baseY+8);
        text(sprite, getTime(), sprWidth - 48, baseY+8);
        baseY += 24;

        text(sprite, "***GAME  OVER***", 8, baseY);
        baseY += 16;

        text(sprite, Palette.DarkGray, "SCORE", 16, baseY);
        text(sprite, TextUtils.padWith("" + data.score, 8, " "), sprWidth - 80, baseY);
        baseY += 16;
        if (data.scoreRecord)
            baseY = record(sprite, baseY);

        text(sprite, Palette.DarkGray, "TIME", 16, baseY);
        text(sprite, TextUtils.padWith(TextUtils.formatTime(data.time), 9), sprWidth - 80, baseY);
        baseY += 16;
        if (data.timeRecord)
            baseY = record(sprite, baseY);

        text(sprite, Palette.DarkGray, "BUBBLES", 16, baseY);
        text(sprite, TextUtils.padWith("" + data.bubbles, 6, " "), sprWidth - 64, baseY);
        baseY += 16;
        if (data.bubblesRecord)
            baseY = record(sprite, baseY);

        text(sprite, Palette.DarkGray, "CLEANS", 16, baseY);
        text(sprite, TextUtils.padWith("" + data.cleans, 3, " "), sprWidth - 40, baseY);
        baseY += 16;
        if (data.cleansRecord)
            baseY = record(sprite, baseY);

        var signature : FlxSprite = new FlxSprite(0, 0, getCharSignature(data.character));
        sprite.stamp(signature, sprWidth - 72, sprHeight - 64);

        // Store the generated ticket
        ticket = sprite;

        // Display it
        var spr : FlxSprite = new FlxSprite(FlxG.width/2 - sprWidth/2, 0);
        spr.pixels = sprite.pixels;
        add(spr);

        // Create buttons
        btnSignature = new Button(sprWidth-56, sprHeight-64, onSignReceipt);
        btnSignature.loadSpritesheet("assets/ui/btn-signature.png", 72, 56);
        add(btnSignature);

        btnShare = new Button(spr.x + 8, sprHeight-48, onShare);
        btnShare.loadSpritesheet("assets/ui/btn-share.png", 56, 24);
        btnShare.visible = false;
        btnShare.active = false;
        add(btnShare);

        score = data.score;
        time = TextUtils.formatTime(data.time);
    }

    function getCharSignature(character : String) : String
    {
        switch (character)
        {
            case "dog":
                return "assets/ui/signature-dog.png";
            case "cat":
                return "assets/ui/signature-cat.png";
            case "crab":
                return "assets/ui/signature-crab.png";
            default:
                return "assets/ui/signature-dog.png";
        }
    }

    function onSignReceipt()
    {
        btnSignature.visible = false;
        btnSignature.active = false;

        btnShare.active = true;
        btnShare.visible = true;

        if (signatureCallback != null)
            signatureCallback();
    }

    function onShare()
    {
        var bd : flash.display.Bitmap = new flash.display.Bitmap(ticket.pixels);
        var path : String = Screenshot.save(bd);
        BubbleShare.share("Check out my latest SOAP ALLEY ticket: " + score + " points in " + time + "!", path);
    }

    function record(sprite : FlxSprite, baseY : Int) : Int
    {
        // New Record
        baseY -= 8;
        text(sprite, Palette.DarkPurple, " **         **", 16, baseY);
        text(sprite, Palette.DarkPurple, "   NEW BEST!", 16, baseY);

        return baseY+16;
    }

    function text(sprite : FlxSprite, ?color : Int = 0xFF000000, string : String, x : Float, y : Float)
    {
        var t : flixel.text.FlxBitmapText = PixelText.New(0, 0, string);
        t.drawFrame(true);

        var temp : FlxSprite = new FlxSprite(0, 0);
        temp.makeGraphic(Std.int(t.width), Std.int(t.height), 0x00000000);
        temp.pixels.copyPixels(t.framePixels, t.framePixels.rect, new openfl.geom.Point(0,0));
        temp.color = color;

        sprite.stamp(temp, Std.int(x), Std.int(y));
    }

    function getDate() : String
    {
        var now : Date = Date.now();
        var str : String = TextUtils.padWith("" + now.getDate(), 2, "0") + "-" +
                           TextUtils.padWith("" + (now.getMonth()+1), 2, "0") +
                           "-" + now.getFullYear();
        return str;
    }

    function getTime() : String
    {
        var now : Date = Date.now();
        var str : String = TextUtils.padWith("" + now.getHours(), 2, "0") + ":" +
                           TextUtils.padWith("" + now.getMinutes(), 2, "0");
        return str;
    }

    override public function draw()
    {
        super.draw();
    }
}
