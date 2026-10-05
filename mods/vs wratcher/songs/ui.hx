import flixel.text.FlxTextBorderStyle;
import flixel.ui.FlxBar;
import flixel.text.FlxText;
import flixel.ui.FlxBarFillDirection;
import flixel.util.FlxStringUtil;

var timeTxt:FlxText;
var timeBar:FlxBar;
var timeBarBG:FlxSprite;
var songPercent:Float = 1;

var ratingStuff:Array<Dynamic> = [
	['You Suck!', 0.2], //From 0% to 19%
	['Shit', 0.4], //From 20% to 39%
	['Bad', 0.5], //From 40% to 49%
	['Bruh', 0.6], //From 50% to 59%
	['Meh', 0.69], //From 60% to 68%
	['Nice', 0.7], //69%
	['Good', 0.8], //From 70% to 79%
	['Great', 0.9], //From 80% to 89%
	['Sick!', 1], //From 90% to 99%
	['Perfect!!', 1] //The value on this one isn't used actually, since Perfect is always "1"
];
var scoreTxtTween:FlxTween;  // 添加此行

//function onPostCountdown(event) {
	//event.sprite.cameras = [camHUD];

	//event.spriteTween.cancel();
	//event.spriteTween = FlxTween.tween(event.sprite, {alpha: 0}, Conductor.crochet / 1000, {
		//ease: FlxEase.cubeInOut,
		//onComplete: function(twn:FlxTween) {
			//event.sprite.destroy();
			//remove(event.sprite, true);
		//}
	//});
//}

function postCreate() {
    scoreTxt.visible = false;
	missesTxt.visible = false;
	accuracyTxt.visible = false;

    scoreTxtPsych = new FlxText(0, healthBar.y + 30, FlxG.width, "1111", 20);
	scoreTxtPsych.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, "center", FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
	scoreTxtPsych.scrollFactor.set();
	scoreTxtPsych.borderSize = 1.25;
	scoreTxtPsych.cameras = [camHUD];
    add(scoreTxtPsych);

	// timeBar = new FlxSprite(0, healthBar.y - 25).makeGraphic(300, 6, 0xFFFF0000);
	// timeBar.scrollFactor.set();
	// timeBar.alpha = 1;
	// timeBar.cameras = [camHUD];
	// timeBar.centerOffsets();
	// timeBar.updateHitbox();
	// timeBar.screenCenter(FlxAxes.X);
	// add(timeBar);

	timeTxt = new FlxText(0, (FlxG.save.data.downscroll ? FlxG.height - 44 : 19), 400, SONG.meta.displayName, 32);
	timeTxt.setFormat(Paths.font("vcr.ttf"), 32, 0xFFFFFFFF, "center", FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
	timeTxt.scrollFactor.set();
	timeTxt.alpha = 1;
	timeTxt.borderSize = 2;
	timeTxt.cameras = [camHUD];
	timeTxt.centerOffsets();
	timeTxt.updateHitbox();
    timeTxt.alpha = 0;
	timeTxt.screenCenter(FlxAxes.X);

    timeBarBG = new FlxSprite(timeTxt.x, timeTxt.y + (timeTxt.height / 4)).makeGraphic(400, 19, 0xFF000000);
    timeBarBG.scrollFactor.set();
    timeBarBG.color = FlxColor.BLACK;
    timeBarBG.cameras = [camHUD];
    timeBarBG.alpha = 0;
    add(timeBarBG);

    timeBar = new FlxSprite(timeBarBG.x + 4, timeBarBG.y + 4).makeGraphic(timeBarBG.width - 8, timeBarBG.height - 8, 0xFFFFFFFF);
    timeBar.cameras = [camHUD];
    timeBar.alpha = 0;
	add(timeBar);
    add(timeTxt);
}

function onSongStart(){
    FlxTween.tween(timeBar, {alpha: 1}, 0.5, {ease: FlxEase.circOut});
    FlxTween.tween(timeTxt, {alpha: 1}, 0.5, {ease: FlxEase.circOut});
    FlxTween.tween(timeBarBG, {alpha: 1}, 0.5, {ease: FlxEase.circOut});
}

function update(elapsed) {
	scoreTxtPsych.alpha = scoreTxt.alpha;

	scoreTxtPsych.text = 'Score: ' + songScore
			+ ' | Misses: ' + misses
			+ ' | Rating: ' + ratingName
			+ (ratingName != '?' ?  ' (' + CoolUtil.quantize(accuracy * 100, 100) + '%) - ' + ratingFC : '');

	if (!played) ratingName = '?';
	else {
		// Rating Name
		if(accuracy >= 1) ratingName = ratingStuff[ratingStuff.length-1][0]; //Uses last string
		else {
			for (i in 0...ratingStuff.length-1) {
				if(accuracy < ratingStuff[i][1]) {
					ratingName = ratingStuff[i][0];
					break;
				}
			}
		}
	}

    timeBar.scale.x = Conductor.songPosition / inst.length;
    timeBar.x = timeBarBG.x + 4 - timeBar.width / 2 + timeBar.width * timeBar.scale.x / 2;
    timeTxt.text = FlxStringUtil.formatTime(Math.floor((inst.length - Conductor.songPosition) / 1000), false);

	// Rating FC
	ratingFC = "";
	if (sicks > 0) ratingFC = "SFC";
	if (goods > 0) ratingFC = "GFC";
	if (bads > 0 || shits > 0) ratingFC = "FC";
	if (misses > 0 && misses < 10) ratingFC = "SDCB";
	else if (misses >= 10) ratingFC = "Clear";
}


function postUpdate(elapsed:Float){
    var mult:Float = FlxMath.lerp(1, iconP1.scale.x, boundTo(1 - (elapsed * 9), 0, 1));
    iconP1.scale.set(mult, mult);
    iconP1.updateHitbox();

    var mult:Float = FlxMath.lerp(1, iconP2.scale.x, boundTo(1 - (elapsed * 9), 0, 1));
    iconP2.scale.set(mult, mult);
    iconP2.updateHitbox();
}

function beatHit() {
    iconP1.scale.set(1.2, 1.2);
    iconP2.scale.set(1.2, 1.2);

    iconP1.updateHitbox();
    iconP2.updateHitbox();
}

function boundTo(value:Float, min:Float, max:Float):Float {
    return Math.max(min, Math.min(max, value));
}

var ratingName:String = '?';
var ratingFC:String;
var played:Bool = false;

var sicks = 0;
var goods = 0;
var bads = 0;
var shits = 0;

function onPlayerMiss(event) {
	played = true;
}

function onPlayerHit(event) {
	if (event.rating == "sick") sicks++;
	if (event.rating == "good") goods++;
	if (event.rating == "bad") bads++;
	if (event.rating == "shit") shits++;

	played = true;

	if (event.note.isSustainNote) return;

	if(scoreTxtTween != null) scoreTxtTween.cancel();
	scoreTxtPsych.scale.x = 1.075;
	scoreTxtPsych.scale.y = 1.075;
	scoreTxtTween = FlxTween.tween(scoreTxtPsych.scale, {x: 1, y: 1}, 0.2, {
		onComplete: function(twn:FlxTween) {
			scoreTxtTween = null;
		}
	});
}

function onPostNoteHit(event) {
	comboGroup.forEachAlive(function (combo) {
		combo.cameras = [camHUD];
		combo.offset.set(-FlxG.save.data.ratingX + 250, -FlxG.save.data.ratingY);
	});
}