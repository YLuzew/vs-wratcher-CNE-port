import flixel.tweens.FlxTweenType;
import flixel.text.FlxTextBorderStyle;

function postCreate() {
    var bty:Float;
    if (FlxG.save.data.MiddleScroll){
        bty = healthBar.y - 500;
    } else {
        bty = healthBar.y - 570;
    }
    
	botplayTxt = new FlxText(400, bty, FlxG.width - 800, "程序操控", 32);
	botplayTxt.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, "center", FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
	botplayTxt.scrollFactor.set();
	botplayTxt.cameras = [camHUD];
	botplayTxt.borderSize = 1.25;
	add(botplayTxt);

	FlxTween.tween(botplayTxt, {alpha: 0}, 1, {type: FlxTweenType.PINGPONG, ease: FlxEase.sineInOut});
	for (line in strumLines.members) {
		for (strum in line) {
			strum.cpu = true;
		}
		line.onNoteUpdate.add(function(e) {
			if (e.__autoCPUHit && !e.note.avoid && !e.note.wasGoodHit && e.note.strumTime < line.__updateNote_songPos) {
				PlayState.instance.goodNoteHit(line, e.note);
			}
		});
	}
}

function onInputUpdate(e) {
	e.cancel();
}