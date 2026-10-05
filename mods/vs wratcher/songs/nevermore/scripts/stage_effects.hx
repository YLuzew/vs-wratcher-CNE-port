// ===== VS Wratcher / Nevermore 演出脚本 =====
// 由原模组 Psych 的 script.lua 移植到 Codename Engine
// 负责：镜头移动与缩放、闪白转场、黑屏、贴图淡入淡出

var zoomshadow:FunkinSprite;
var midmevent:FunkinSprite;
var blackScreen:FunkinSprite;
var whiteflashstuff:FunkinSprite;
var screenedgeshade:FunkinSprite;
var cavecolor:FunkinSprite;
var cavecolor1:FunkinSprite;

var IMG:String = 'stages/cave/';

function postCreate() {
	// zoomshadow：全屏渐变遮罩，固定在屏幕层（不随镜头滚动）
	zoomshadow = new FunkinSprite(0, 0, Paths.image(IMG + 'zoomshadow'));
	zoomshadow.setGraphicSize(FlxG.width, FlxG.height);
	zoomshadow.updateHitbox();
	zoomshadow.screenCenter();
	zoomshadow.alpha = 0;
	zoomshadow.cameras = [camHUD];
	add(zoomshadow);

	// midmevent：688x388 的演出动画，铺满整屏
	midmevent = new FunkinSprite(0, 0, Paths.image(IMG + 'midmevent'));
	midmevent.addAnim('nyoom', 'midmevent idle', 50, false);
	midmevent.setGraphicSize(FlxG.width, FlxG.height);
	midmevent.updateHitbox();
	midmevent.screenCenter();
	midmevent.alpha = 0;
	midmevent.cameras = [camHUD];
	add(midmevent);

	blackScreen = new FunkinSprite(0, 0, Paths.image(IMG + 'blackScreen'));
	blackScreen.setGraphicSize(FlxG.width, FlxG.height);
	blackScreen.updateHitbox();
	blackScreen.screenCenter();
	blackScreen.alpha = 0;
	blackScreen.cameras = [camHUD];
	add(blackScreen);

	whiteflashstuff = new FunkinSprite(0, 0, Paths.image(IMG + 'whiteflashstuff'));
	whiteflashstuff.setGraphicSize(FlxG.width, FlxG.height);
	whiteflashstuff.updateHitbox();
	whiteflashstuff.screenCenter();
	whiteflashstuff.alpha = 0;
	whiteflashstuff.cameras = [camHUD];
	add(whiteflashstuff);

	screenedgeshade = new FunkinSprite(0, 0, Paths.image(IMG + 'screenedgeshade'));
	screenedgeshade.setGraphicSize(FlxG.width, FlxG.height);
	screenedgeshade.updateHitbox();
	screenedgeshade.screenCenter();
	screenedgeshade.alpha = 0;
	screenedgeshade.cameras = [camHUD];
	add(screenedgeshade);

	cavecolor = new FunkinSprite(0, 0, Paths.image(IMG + 'Lighting_overlay'));
	cavecolor.setGraphicSize(FlxG.width, FlxG.height);
	cavecolor.updateHitbox();
	cavecolor.screenCenter();
	cavecolor.alpha = 0.5;
	cavecolor.cameras = [camHUD];
	add(cavecolor);

	cavecolor1 = new FunkinSprite(0, 0, Paths.image(IMG + 'cavecolor'));
	cavecolor1.setGraphicSize(FlxG.width, FlxG.height);
	cavecolor1.updateHitbox();
	cavecolor1.screenCenter();
	cavecolor1.alpha = 0.5;
	cavecolor1.cameras = [camHUD];
	add(cavecolor1);
}

// 透明度补间
function fadeTo(spr:FunkinSprite, value:Float, duration:Float) {
	if (spr == null) return;
	FlxTween.cancelTweensOf(spr);
	FlxTween.tween(spr, {alpha: value}, duration, {ease: FlxEase.linear});
}

// 锁定镜头位置；不传参数则恢复跟随角色
function focusCam(x:Float = -99999, y:Float = -99999) {
	if (x == -99999) {
		camFollowChars = true;
		return;
	}
	camFollowChars = false;
	camFollow.setPosition(x, y);
	FlxG.camera.snapToTarget();
}

// 逐小节触发，步数对应原 script.lua 的 curStep
function stepHit(curStep:Int) {
	switch (curStep) {
		case 245:
			fadeTo(midmevent, 1, 0.01);
			midmevent.playAnim('nyoom', false);
		case 258:
			fadeTo(whiteflashstuff, 0, 0.01);
		case 260:
			fadeTo(midmevent, 0, 0.01);
			fadeTo(whiteflashstuff, 0, 0.2);
		case 512:
			fadeTo(zoomshadow, 0.35, 0.2);
			focusCam(450, 500);
		case 543:
			focusCam();
		case 544:
			fadeTo(zoomshadow, 0, 0.2);
		case 576:
			fadeTo(zoomshadow, 0.35, 0.2);
			focusCam(970, 600);
		case 592:
			focusCam(970, 550);
		case 605:
			focusCam();
		case 606:
			fadeTo(zoomshadow, 0, 0.2);
		case 640:
			fadeTo(zoomshadow, 0.35, 0.2);
			focusCam(450, 500);
		case 672:
			focusCam();
			fadeTo(zoomshadow, 0, 0.2);
		case 704:
			fadeTo(zoomshadow, 0.35, 0.2);
			focusCam(970, 600);
		case 719:
			focusCam(970, 550);
		case 732:
			defaultCamZoom = 0.8;
		case 734:
			focusCam();
			fadeTo(zoomshadow, 0, 0.2);
		case 752:
			focusCam(680, 500);
		case 758:
			defaultCamZoom = 0.75;
		case 763:
			fadeTo(whiteflashstuff, 1, 0.3);
		case 768:
			fadeTo(whiteflashstuff, 0, 0.3);
			fadeTo(screenedgeshade, 1, 0.01);
		case 1016:
			fadeTo(blackScreen, 1, 0.01);
			fadeTo(cavecolor, 0, 0.01);
			fadeTo(cavecolor1, 0, 0.01);
		case 1024:
			fadeTo(blackScreen, 0, 0.01);
			fadeTo(cavecolor, 0.5, 0.01);
			fadeTo(cavecolor1, 0.5, 0.01);
		case 1279:
			fadeTo(whiteflashstuff, 1, 0.06);
			fadeTo(screenedgeshade, 0, 0.01);
		case 1280:
			fadeTo(whiteflashstuff, 0, 0.2);
			focusCam();
			defaultCamZoom = 0.8;
	}
}
