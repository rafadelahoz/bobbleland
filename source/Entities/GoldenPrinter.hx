package;

class GoldenPrinter extends PrinterMachine
{
    public function new()
    {
        super();
    }

    override function getBgGraphic() : String
	{
		return "assets/ui/unlock-machine-bg.png";
	}

    override function getFgGraphic() : String
	{
		return "assets/ui/unlock-machine-fg.png";
	}

    override function buildButton() : Button
	{
		var button = new Button(16, 288 + 64, onCheckoutButtonPressed);
        button.loadSpritesheet("assets/ui/btn-unlock-checkout.png", 80, 24);
        return button;
	}
}