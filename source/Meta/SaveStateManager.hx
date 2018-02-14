package;

import flixel.util.FlxSave;

class SaveStateManager
{
    static var savefile : String = "savestate";

    public static function savestateExists() : Bool
    {
        var save : FlxSave = new FlxSave();
        save.bind(savefile);
        var exists : Bool = (save.data.active == 1);
        save.close();

        return exists;
    }

    public static function loadAndErase() : Dynamic
    {
        var save : FlxSave = new FlxSave();
        save.bind(savefile);

        var data : Dynamic = null;

        if (save.data.active == 1)
        {
            // Read data
            data = {
                grid: save.data.grid,
                flow: save.data.flow,
                session: save.data.session
            };
        }

        // Clear data
        save.data.active = 0;
        save.data.grid = null;
        save.data.flow = null;
        save.data.session = null;

        save.close();

        return data;
    }

    public static function savePlayStateData(state : PlayState)
    {
        var save : FlxSave = new FlxSave();
        save.bind(savefile);

        var gridData : BubbleGrid.BubbleGridData = state.grid.getSaveData();
        var flowData : PlayFlowController.PlayFlowSaveData = state.flowController.getSaveData();
        var sessionData : PlaySessionData = state.playSessionData;

        save.data.active = 1;
        save.data.grid = gridData;
        save.data.flow = flowData;
        save.data.session = sessionData;
        
        save.close();
    }
}
