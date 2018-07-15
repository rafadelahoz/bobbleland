package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.util.FlxSpriteUtil;
import flixel.util.FlxTimer;

import text.PixelText;
import text.TextUtils;

class Ticket extends FlxSpriteGroup
{
    var btnSignature : Button;
    var btnShare : Button;
    var bottomHider : Entity;

    var ticket : Entity;
    var score : Int;
    var time : String;

    var data : Dynamic;

    public var signatureCallback : Void -> Void;

    public function new()
    {
        super(0, 0);
    }

    public function init(data : Dynamic)
    {
        this.data = data;

        var top : FlxSprite = new FlxSprite(0, 0, "assets/ui/ticket-top.png");
        var bottom : FlxSprite = null;
        if (data.character != "bear")
            bottom = new FlxSprite(0, 96, "assets/ui/ticket-bottom.png");
        else
            bottom = new FlxSprite(0, 96, "assets/ui/ticket-bottom-bear.png");

        var contentsHeight : Int = 14*8;
        // Adjust to include record lines
        contentsHeight += 8*((data.scoreRecord ? 1 : 0) + (data.bubblesRecord ? 1 : 0) + (data.timeRecord ? 1 : 0) + (data.cleansRecord ? 1 : 0));

        var sprWidth : Int = Std.int(top.width);
        var sprHeight : Int = Std.int(top.height + contentsHeight + bottom.height);

        var sprite : Entity = new Entity(0, 0);
        sprite.makeGraphic(sprWidth, sprHeight, 0x00FFFFFF);

        sprite.stamp(top, 0, 0);
        sprite.stamp(bottom, 0, Std.int(top.height + contentsHeight));
        FlxSpriteUtil.drawRect(sprite, 0, top.height, top.width, contentsHeight, 0xFFFFF1E8);

        var baseY : Int = Std.int(top.height);
        text(sprite, getDate(), 8, baseY+8);
        text(sprite, getTime(), sprWidth - 48, baseY+8);
        baseY += 16;
        text(sprite, "DIFFICULTY ", 8, baseY);
        text(sprite, Palette.LightGray, "/////", sprWidth - 8 - 40, baseY);
        var difficultyText : String = "";
        for (i in 0...data.level)
            difficultyText += "/";
        // difficultyText = TextUtils.padWith(difficultyText, 5, " ");
        text(sprite, getDifficultyColor(data.level), difficultyText, sprWidth - 8 - 40, baseY);
        baseY += 16;

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

        if (data.character != "bear")
        {
            var signature : FlxSprite = new FlxSprite(0, 0, getCharSignature(data.character));
            sprite.stamp(signature, sprWidth - 72, sprHeight - 64);
        }

        // Store the generated ticket
        ticket = sprite;

        // Display it
        /*var spr : FlxSprite = new FlxSprite(Constants.Width/2 - sprWidth/2, 0);
        spr.pixels = sprite.pixels;
        add(spr);*/
        ticket.x = Constants.Width/2 - sprWidth/2;
        add(ticket);

        if (data.character == "bear")
        {
            bottomHider = new Entity(ticket.x, Std.int(top.height + contentsHeight));
            bottomHider.loadGraphic("assets/ui/ticket-bottom.png");
            add(bottomHider);
        }

        // Create buttons
        btnSignature = new Button(sprWidth-56, sprHeight-64, onSignReceipt);
        btnSignature.loadSpritesheet("assets/ui/btn-signature.png", 72, 56);
        add(btnSignature);

        btnShare = new Button(ticket.x + 8, sprHeight-48, onShare);
        btnShare.loadSpritesheet("assets/ui/btn-share.png", 56, 24);
        btnShare.visible = false;
        btnShare.active = false;
        add(btnShare);

        score = data.score;
        time = TextUtils.formatTime(data.time);
    }

    function getDifficultyColor(level : Int) : Int
    {
        return Palette.Black;

        /*if (level < 5)
            return Palette.Black;
        else
            return Palette.DarkPurple;

        switch (level)
        {
            case 1: return Palette.DarkGreen;
            case 2: return Palette.Yellow;
            case 3: return Palette.Orange;
            case 4: return Palette.Brown;
            case 5: return Palette.Red;
            default: return Palette.Black;
        }*/
    }

    function getCharSignature(character : String) : String
    {
        switch (character)
        {
            case "pug":
                return "assets/ui/signature-dog.png";
            case "cat":
                return "assets/ui/signature-cat.png";
            case "crab":
                return "assets/ui/signature-crab.png";
            case "frog":
                return "assets/ui/signature-frog.png";
            case "catbomb":
                return "assets/ui/signature-catbomb.png";
            default:
                return "assets/ui/signature-dog.png";
        }
    }

    function onSignReceipt()
    {
        // Make ticket vibrate
        ticket.vibrate(true, 2, true);
        btnShare.vibrate(true, 2, true);
        // And stop after a while
        new FlxTimer().start(0.2, function(t:FlxTimer){
            t.destroy();
            ticket.vibrate(false);
            btnShare.vibrate(false);
        });

        // Shade ticket
        ticket.color = Palette.DarkGray;
        btnShare.color = Palette.DarkGray;
        // But not for long
        flixel.tweens.FlxTween.color(ticket, 0.3, ticket.color, 0xFFFFFFFF, {ease: flixel.tweens.FlxEase.circOut});
        flixel.tweens.FlxTween.color(btnShare, 0.3, btnShare.color, 0xFFFFFFFF, {ease: flixel.tweens.FlxEase.circOut});

        switch (data.character)
        {
            case "pug":
                SfxEngine.play(SfxEngine.SFX.StickerB, 1);
            case "cat":
                // Play tear sound
                SfxEngine.play(SfxEngine.SFX.TearTicket, 0.4);
            case "crab":
                SfxEngine.play(SfxEngine.SFX.SignatureShort, 0.8);
            case "frog":
                SfxEngine.play(SfxEngine.SFX.SignatureLong, 0.8);
            case "bear":
                if (bottomHider != null)
                {
                    // Play tear sound
                    SfxEngine.play(SfxEngine.SFX.TearTicket);
                    // Hide the hider
                    bottomHider.destroy();
                }
            case "catbomb":
                SfxEngine.play(SfxEngine.SFX.StickerA, 1);
        }

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

        // Scale the ticket at 3x
        var scale : Int = 3;
        var border : Int = 24;

        var width : Int = Std.int(bd.bitmapData.rect.width + border) * scale;
        var height : Int = Std.int(bd.bitmapData.rect.height + border) * scale;

        var scaledBitmap : flash.display.Bitmap = new flash.display.Bitmap(new flash.display.BitmapData(width, height, true, 0x00000000));

        // Fill with background
        var bgSprite : FlxSprite = new FlxSprite(0, 0, database.BackgroundDatabase.GetRandomBackgroundAsset());
        var bgBitmap : flash.display.Bitmap = new flash.display.Bitmap(bgSprite.pixels);
        var bgWidth : Int = Std.int(bgBitmap.bitmapData.rect.width);
        var bgHeight : Int = Std.int(bgBitmap.bitmapData.rect.height);
        var bgMatrix : openfl.geom.Matrix = new openfl.geom.Matrix();

        var bgX : Int = 0;
        var bgY : Int = Std.int(-bgHeight/2);
        while (bgY < height)
        {
            bgX = Std.int(-bgWidth/2);

            while (bgX < width)
            {
                bgMatrix.identity();
                bgMatrix.translate(bgX, bgY);
                scaledBitmap.bitmapData.draw(bgBitmap.bitmapData, bgMatrix);

                bgX += bgWidth;
            }

            bgY += bgHeight;
        }

        // Draw ticket scaled
        var matrix : openfl.geom.Matrix = new openfl.geom.Matrix();
        matrix.translate(border/2, border/2);
        matrix.scale(scale, scale);
        scaledBitmap.bitmapData.draw(bd.bitmapData, matrix);

        var path : String = Screenshot.save(scaledBitmap);
        BubbleShare.share("Check out my latest SOAP ALLEY ticket: " + score + " points in " + time + "!", path);
        // sys.FileSystem.deleteFile(path);
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
        // temp.angle = FlxG.random.int(-2, 2);

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
