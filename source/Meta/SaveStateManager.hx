package;

import flixel.util.FlxSave;

class SaveStateManager
{
    static var savefile : String = "savestate";

    public static function savestateExists() : Bool
    {
        var save : FlxSave = new FlxSave();
        save.bind(savefile);
        trace(save.data);
        var exists : Bool = (save.data.active == 1);
        save.close();

        return exists;
    }

    public static function loadAndErase() : Dynamic
    {
        var save : FlxSave = new FlxSave();
        save.bind(savefile);

        // Read data
        var data : Dynamic = {
            grid: save.data.grid,
            flow: save.data.flow
        };

        // Clear data
        save.data.active = 0;
        save.data.grid = null;
        save.data.flow = null;
        save.close();

        return data;
    }

    public static function savePlayStateData(state : PlayState)
    {
        var save : FlxSave = new FlxSave();
        save.bind(savefile);

        var gridData : BubbleGrid.BubbleGridData = state.grid.getSaveData();
        var flowData : PlayFlowController.PlayFlowSaveData = state.flowController.getSaveData();

        save.data.active = 1;
        save.data.grid = gridData;
        save.data.flow = flowData;

        save.close();
    }
}
