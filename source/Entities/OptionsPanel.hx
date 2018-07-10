package;

import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.group.FlxSpriteGroup;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;

class OptionsPanel extends FlxGroup
{
    public var optionsTab : Button;
    public var optionsPanel : FlxSpriteGroup;
    var bgmButton : HoldButton;
    var sfxButton : HoldButton;

	var ingame : Bool;

    public function new(?Ingame : Bool = false)
    {
        super();

		ingame = Ingame;

        optionsTab = new Button(72, 0, onOptionsTabReleased);
		optionsTab.loadSpritesheet("assets/ui/options-tab.png", 40, 24);
		optionsTab.alpha = 0;
		add(optionsTab);
    }

    function onOptionsTabReleased()
	{
		optionsTab.active = false;
		optionsTab.visible = false;

		buildOptionsPanel();
		optionsPanel.active = true;
		optionsPanel.visible = true;
		optionsPanel.x = 32;
		optionsPanel.y = -optionsPanel.height;

		bgmButton.setPressed(BgmEngine.Enabled, false);
		sfxButton.setPressed(SfxEngine.Enabled, false);

		FlxTween.tween(optionsPanel, {y: 0}, 0.5, {ease: FlxEase.elasticOut});
	}

	function buildOptionsPanel()
	{
		if (optionsPanel == null)
		{
			optionsPanel = new FlxSpriteGroup();

			var panel : FlxSprite = new FlxSprite(0, -8, "assets/ui/options-panel.png");
			optionsPanel.add(panel);

			bgmButton = new HoldButton(22, 12, onBgmButtonPressed, onBgmButtonReleased);
			bgmButton.loadSpritesheet("assets/ui/btn-music.png", 32, 32);
			optionsPanel.add(bgmButton);

			sfxButton = new HoldButton(66, 12, onSfxButtonPressed, onSfxButtonReleased);
			sfxButton.loadSpritesheet("assets/ui/btn-sfx.png", 32, 32);
			optionsPanel.add(sfxButton);

			var closeButton : Button = new Button(44, 56, hideOptionsPanelCloseButton);
			closeButton.onPressCallback = function() {
				optionsPanel.y = 1;
			};
			closeButton.setSize(32, 16);
			optionsPanel.add(closeButton);

			add(optionsPanel);
		}
	}

    public function hideOptionsPanel(callback : FlxTween -> Void)
    {
        FlxTween.tween(optionsPanel, {y: -optionsPanel.height + 24 + 8}, 0.26, {ease: FlxEase.circOut, onComplete: callback});
    }

    function hideOptionsPanelCloseButton()
    {
        hideOptionsPanel(onOptionsPanelHidden);
    }

	function onOptionsPanelHidden(t:FlxTween)
	{
		optionsPanel.active = false;
		optionsPanel.visible = false;

		optionsTab.active = true;
		optionsTab.visible = true;
	}

	function onBgmButtonPressed()
	{
		BgmEngine.enable(!ingame);
	}

	function onBgmButtonReleased()
	{
		BgmEngine.disable();
	}

	function onSfxButtonPressed()
	{
		SfxEngine.enable();
        SfxEngine.play(SfxEngine.SFX.Accept);
	}

	function onSfxButtonReleased()
	{
		SfxEngine.disable();
	}
}
