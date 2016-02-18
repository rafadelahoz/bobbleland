package scenes;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.util.FlxTimer;

class CharacterManager
{
    var scene : SceneState;
    
    var characterMap : Map<String, Character>;
    var characterPlaces : Array<String>;
    
    var width : Int;
    var baseHeight : Int;
    
    public function new(Scene : SceneState)
    {
        scene = Scene;
        
        characterMap = new Map<String, Character>();
        characterPlaces = [];
        
        width = Std.int(FlxG.width * 0.8);
        baseHeight = 240;
    }
    
    public function get(characterId : String) : Character
    {
        return characterMap.get(characterId);
    }
    
    public function add(characterId : String, ?expression : String = null, ?callback : Void -> Void = null)
    {
        if (!characterMap.exists(characterId))
        {
            var character : Character = new Character(FlxG.width, baseHeight, characterId, expression);
            characterMap.set(characterId, character);
            characterPlaces.push(characterId);
            
            scene.add(character);
            
            reposition(callback);
        }
    }
    
    public function remove(characterId : String, ?callback : Void -> Void = null)
    {
        if (characterMap.exists(characterId))
        {
            var char : Character = get(characterId);
            var direction : Int = FlxObject.DOWN;
            
            var pos : Float = characterPlaces.indexOf(characterId) / characterPlaces.length;
            direction = getExitDirection(pos);
            
            // Make the character leave
            char.exit(direction, function() {
                // Then from the scene
                scene.remove(char);
                // Destroy its memory (mwaha!)
                char.destroy();
            });
            
            // Once left, remove it from the maps
            characterPlaces.remove(characterId);
            characterMap.remove(characterId);
            
            // And reposition the others, then callback
            reposition(callback);
        }
    }
    
    function reposition(callback : Void -> Void)
    {
        var numCharacters : Int = characterPlaces.length;
        if (numCharacters > 0)
        {
            var delta : Float = 1/numCharacters * width;
            var position = FlxG.width/2 - width/2;
            
            for (charId in characterPlaces)
            {
                var char : Character = characterMap.get(charId);
                char.moveTo(position);
                position += delta;
            }
            
            if (callback != null)
            {
                new FlxTimer(Character.MoveDuration * 1.5, function(_t:FlxTimer) {
                    callback();
                });
            }
        }
    }
    
    function getExitDirection(pos : Float) : Int
    {
        var direction : Int = FlxObject.DOWN;
        
        if (pos <= 0.33)
        {
            direction = FlxObject.LEFT;
        } 
        else if (pos > 0.33 && pos <= 0.66)
        {
            direction = FlxObject.DOWN;
        }
        else 
        {
            direction = FlxObject.RIGHT;
        }
        
        return direction;
    }
}