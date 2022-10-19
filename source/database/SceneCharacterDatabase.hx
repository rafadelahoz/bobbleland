package database;

class SceneCharacterDatabase
{
    static var database : Map<String, CharacterData>;
    
    public static var defaultExpression : String = "idle";
    
    public static function Init()
    {
        if (database == null)
        {
            database = new Map<String, CharacterData>();
            
            database.set("character", {
                id: "character",
                sprite: "character",
                color: 0xFFFFFFFF,
                width: 32,
                height: 24,
                expressions: [
                    "idle"=>{id: "idle", frames:[0, 7], fps: 4, loop: true},
                    "happy"=>{id: "happy", frames:[14, 15, 16, 17, 17, 16, 15, 14], fps: 20, loop: true}
                ]
            });
            
            database.set("characterB", {
                id: "characterB",
                sprite: "character",
                color: 0xFFFF5151,
                width: 32,
                height: 24,
                expressions: [
                    "idle"=>{id: "idle", frames:[0, 7], fps: 1, loop: true},
                    "happy"=>{id: "happy", frames:[14, 15, 16, 17, 17, 16, 15, 14], fps: 40, loop: true}
                ]
            });
            
            database.set("charC", {
                id: "charC",
                sprite: "character",
                color: 0xFF51FF51,
                width: 32,
                height: 24,
                expressions: [
                    "idle"=>{id: "idle", frames:[0, 7], fps: 20, loop: true},
                    "happy"=>{id: "happy", frames:[14, 15, 16, 17, 17, 16, 15, 14], fps: 10, loop: true}
                ]
            });
            
            database.set("charD", {
                id: "charD",
                sprite: "character",
                color: 0xFF5151FF,
                width: 32,
                height: 24,
                expressions: [
                    "idle"=>{id: "idle", frames:[0, 7], fps: 30, loop: true},
                    "happy"=>{id: "happy", frames:[14, 15, 16, 17, 17, 16, 15, 14], fps: 5, loop: true}
                ]
            });
        }
    }
    
    public static function get(character : String) : CharacterData
    {
        return database.get(character);
    }
}

typedef CharacterData =
{
    var id : String;
    var sprite : String;
    var color : Int;
    var width : Int;
    var height : Int;
    var expressions : Map<String, CharacterExpression>;
}

typedef CharacterExpression =
{
    var id : String;
    var frames : Array<Int>;
    var fps : Int;
    var loop : Bool;
}