function postCreate () {
    if(FlxG.save.data.botplay) {
         importScript("data/scripts/botplay");
    }
    if(FlxG.save.data.MiddleScroll) {
         importScript("data/scripts/MiddleScroll");
    }
}