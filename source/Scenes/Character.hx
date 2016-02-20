package scenes;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

import database.SceneCharacterDatabase;
import database.SceneCharacterDatabase.CharacterData;

class Character extends FlxSprite
{
    static var spritePath : String = "assets/portraits/";

    public static var MoveDuration : Float = 0.5;
    public static var ExitTime : Float = 0.5;

    var id : String;
    var expression : String;

    var data : CharacterData;

    public function new(X : Float, Y : Float, Id : String, ?Expression : String = null)
    {
        super(X, Y);

        id = Id;
        expression = Expression;
        if (expression == null)
            expression = SceneCharacterDatabase.defaultExpression;

        // TODO: Load graphic from CharacterDB
        data = SceneCharacterDatabase.get(id);
        if (data != null)
        {
            trace(data);
            loadGraphic(spritePath + data.sprite + ".png", data.width, data.height);
            for (exprId in data.expressions.keys())
            {
                var expression : CharacterExpression = data.expressions.get(exprId);
                animation.add(expression.id, expression.frames, expression.fps, expression.loop);
            }

            animation.play(expression);

            color = data.color;
        }

        scale.x = 3;
        scale.y = 3;

        centerOffsets(true);
        offset.y = height * scale.y/2;
        // offset.set(width/2, height);
    }

    public function getId() : String
    {
        return id;
    }

    public function getExpression() : String
    {
        return expression;
    }

    public function changeExpression(expression : String, ?callback : Void -> Void = null)
    {
        if (expression == null)
            expression = SceneCharacterDatabase.defaultExpression;
        this.expression = expression;

        if (animation.getByName(expression) != null)
        {
            animation.play(expression);
        }

        // TODO: Change graphic to appropriate one
        if (callback != null)
            callback();
    }

    public function moveTo(targetX : Float)
    {
        FlxTween.tween(this, {x : targetX}, 0.5, {ease : FlxEase.cubeInOut});
    }

    public function exit(direction : Int, ?callback : Void -> Void = null)
    {
        var targetX : Float = x;
        var targetY : Float = y;

        switch (direction)
        {
            case FlxObject.DOWN:
                targetY = y + height * 3;
            case FlxObject.LEFT:
                targetX = -(width * 2);
            case FlxObject.RIGHT:
                targetX = FlxG.width  + width * 2;
        }

        FlxTween.tween(this, {x:targetX, y:targetY}, ExitTime, {onComplete: function(t:FlxTween){
            if (callback != null)
                callback();
        }});
    }

    override public function update(elapsed:Float)
    {
        // Face towards the center!
        if (x < FlxG.width/2)
            flipX = false;
        else
            flipX = true;

        super.update(elapsed);
    }
}
