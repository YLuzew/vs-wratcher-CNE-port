//
import haxe.io.Path;
import flixel.text.FlxText.FlxTextBorderStyle;
import funkin.backend.system.Logs;
import funkin.backend.utils.FlxInterpolateColor;
import hxvlc.flixel.FlxVideoSprite;

var callback:Void->Void = null;
var vid:FlxVideoSprite;
var holdCircle:FlxSprite;
var skipText:FunkinText;
var skipColor:FlxInterpolateColor = new FlxInterpolateColor(0xFFFFFFFF);
var alphaTween:FlxTween;
var alphaTimer:Float = 0.0;
var holdTime:Float = 0.0;
var cutsceneCamera:FlxCamera = null;

var FULL_VOLUME:Bool = false;
var ratio:Float;

var oldVisible = [];
var vidName:String;
function startVideo(name:String, ?leCallback:Void->Void, ?ext:String, ?usePath:Bool) {
    vidName = name;
    for (cam in FlxG.cameras.list) {
        oldVisible.push(cam.visible);
        cam.visible = false;
    }

    callback = leCallback;
    ext ??= "mp4";

    cutsceneCamera = new FlxCamera();
    cutsceneCamera.bgColor = 0xFF000000;
    FlxG.cameras.add(cutsceneCamera, false);

    add(vid = new FlxVideoSprite());
    vid.cameras = [cutsceneCamera];
    var nonPixelyList = CoolUtil.coolTextFile(Paths.video("nonPixelyCutscenes", "txt"));
    vid.antialiasing = nonPixelyList != null && nonPixelyList.indexOf(new Path(name).file) != -1;
    vid.bitmap.onFormatSetup.add(function() if (vid.bitmap?.bitmapData != null) {
        final width = vid.bitmap.bitmapData.width;
        final height = vid.bitmap.bitmapData.height;
        final scale:Float = Math.min(FlxG.width / width, FlxG.height / height);
        vid.setGraphicSize(Std.int(width * scale), Std.int(height * scale));
        vid.updateHitbox();
        vid.screenCenter();
    });

    if (FULL_VOLUME) {
        vid.autoVolumeHandle = false;
        vid.bitmap.volume = 1;

        FULL_VOLUME = false;
    }

    add(skipText = new FunkinText(-28, FlxG.height - 50 - 6, FlxG.width, "按住 屏幕任意处 以跳过...").setFormat(Paths.font('vcr.ttf'), 32, 0xFFFFFFFF, "right", FlxTextBorderStyle.OUTLINE, 0xff000000));
    skipText.textField.antiAliasType = 0;
    skipText.textField.sharpness = 400;
    skipText.scrollFactor.set();
    skipText.borderSize = 3;
    skipText.cameras = [cutsceneCamera];

    // 创建 holdCircle 并安全初始化动画
    add(holdCircle = new FlxSprite());
    holdCircle.frames = Paths.getFrames(Paths.image("menus/holdCircle"), true);
    if (holdCircle.frames != null) {
        var frameRate = (holdCircle.frames.frames.length - 1) / 2;
        holdCircle.animation.addByPrefix("idle", "hold", frameRate, false);
        holdCircle.animation.frameIndex = 0;
        ratio = frameRate / 360; // 用于颜色插值
    } else {
        Logs.trace("holdCircle 资源加载失败，跳过动画", 2);
    }
    holdCircle.setGraphicSize(33 * (FlxG.width / 1280), 33 * (FlxG.width / 1280));
    holdCircle.updateHitbox();
    holdCircle.setPosition(FlxG.width - holdCircle.width - skipText.textField.textWidth - 40 - 8, FlxG.height - holdCircle.height - 10 - 10);
    holdCircle.cameras = [cutsceneCamera];
    
    ratio /= 360;  // before i forger  - Nex

    if (vid.load(usePath == false ? Paths.video(name, ext) : name)) {
        vid.bitmap.onEndReached.add(onFinish);
        vid.play();
    } else {
        Logs.trace("Failed to load the cutscene, finishing directly!!", 2);
        onFinish();
    }
}

var ratio:Float;
function update(elapsed:Float) if (vid != null) {
    // 在访问 animation 前添加空判断
    if (holdCircle?.animation != null) {
        if (!FlxG.mouse.pressed && !FlxG.keys.pressed.ENTER) {
            holdTime = 0;
            holdCircle.animation.stop();
            holdCircle.animation.frameIndex = 0;
            skipColor.color = 0xFFFFFFFF;
            if (alphaTimer > 1) doAlphaTween();
            else alphaTimer += elapsed;
        } else {
            alphaTween?.cancel();
            skipText.alpha = 1;
            alphaTimer = 0;
            holdCircle.animation.play("idle", false, false, 1);
            skipText.color = skipColor.fpsLerpTo(0xffff0000, ratio);
            if ((holdTime += elapsed) > 2) onFinish();
        }
        holdCircle.color = skipText.color = skipColor.color;
        holdCircle.alpha = skipText.alpha;
    } else {
        // 如果 holdCircle 未初始化，至少允许跳过逻辑
        if (FlxG.mouse.pressed || FlxG.keys.pressed.ENTER) {
            if ((holdTime += elapsed) > 2) onFinish();
        } else {
            holdTime = 0;
        }
    }
}
function doAlphaTween() {
    alphaTween?.cancel();
    alphaTween = FlxTween.tween(skipText, {alpha: 0}, 0.5);
}

import StringTools;

function onFinish() {
    vid.destroy();
    vid = null; // cuz it doesnt happen instantly and i need it for update  - Nex
    FlxG.cameras.remove(cutsceneCamera, true);

    if (!StringTools.contains(vidName, "end-cutscene")) {
        for (i => cam in FlxG.cameras.list)
            cam.visible = oldVisible[i];
    }
    
    if (callback != null) callback();
}