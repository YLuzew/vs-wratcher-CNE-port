import funkin.backend.MusicBeatState;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.util.FlxTimer;

// ----- 标题 UI 元素 -----
var logo:FunkinSprite;
var border:FunkinSprite;
var enterText:FunkinSprite;

// ----- 控制变量 -----
var inputEnabled:Bool = false;      // 视频播放完之前不允许操作
var videoCompleted:Bool = false;

// ----- 视频脚本 -----
var script = importScript("data/scripts/skippableVideoUndertale");

function create() {
    MusicBeatState.skipTransIn = true;

    // ==========================================
    // 1. 提前加载标题页所有资源（先隐藏）
    // ==========================================
    border = new FunkinSprite().loadGraphic(Paths.image("menus/wratcher/intro/bg"));
    border.setPosition(-320, -180);
    border.scale.set(0.7, 0.7);
    border.visible = false;
    add(border);

    logo = new FunkinSprite();
    logo.frames = Paths.getFrames("menus/wratcher/intro/logoBumpin");
    logo.animation.addByPrefix("logo bumpin", "logo bumpin", 24);
    logo.animation.play("logo bumpin");
    logo.screenCenter();
    logo.y = -200;
    logo.scale.set(0.5, 0.5);
    logo.visible = false;
    add(logo);

    enterText = new FunkinSprite();
    enterText.frames = Paths.getFrames("menus/titlescreen/titleEnter");
    enterText.animation.addByPrefix("pressEnter", "Press Enter to Begin", 24);
    enterText.animation.addByPrefix("enterPressed", "ENTER PRESSED", 24);
    enterText.animation.play("pressEnter");
    enterText.screenCenter();
    enterText.y = 575;          // 调整到合适位置
    enterText.x += 250;
    enterText.visible = false;
    add(enterText);

    // ==========================================
    // 2. 播放视频（结束后直接显示标题，不切状态）
    // ==========================================
    script.call("startVideo", ["intro", () -> {
        videoCompleted = true;
        inputEnabled = true;

        // 隐藏视频画面（释放更新占用）
        var vid = script.get("vid");
        if (vid != null) {
            vid.visible = false;
            vid.active = false;
        }

        // 瞬间显示标题 UI（无卡顿）
        border.visible = true;
        logo.visible = true;
        enterText.visible = true;

        // 开场动画结束：整屏白闪一下作为转场
        var flash = new FlxSprite(0, 0);
        flash.makeGraphic(FlxG.width, FlxG.height, 0xFFFFFFFF);
        flash.alpha = 1;
        flash.scrollFactor.set();
        add(flash);
        FlxTween.tween(flash, {alpha: 0}, 1.5, {
            ease: FlxEase.quadOut,
            onComplete: (_) -> remove(flash)
        });

        // 标题淡入（让出现更自然）
        logo.alpha = 0;
        enterText.alpha = 0;
        FlxTween.tween(logo, {alpha: 1}, 0.3, {ease: FlxEase.quadOut});
        FlxTween.tween(enterText, {alpha: 1}, 0.3, {ease: FlxEase.quadOut});

    }, "mp4", false]);

    // ==========================================
    // 3. 背景音乐
    // ==========================================
    if (FlxG.sound.music == null || !FlxG.sound.music.active) {
        CoolUtil.playMusic(Paths.music("freakyMenu"), true, 1);
    }
}

// ==========================================
// 4. 更新逻辑（视频阶段 + 标题阶段）
// ==========================================
function update() {
    // ----- 视频播放阶段（处理抗锯齿切换） -----
    if (!videoCompleted) {
        var vid = script.get("vid");
        if (vid != null && !vid.antialiasing && vid.bitmap.time > 70000) {
            vid.antialiasing = Options.antialiasing;
        }
        return; // 视频没播完就不处理标题输入
    }

    // ----- 标题阶段（原 CoolerTitle 的输入逻辑） -----
    var touchInput = false;
    #if mobile
    for (touch in FlxG.touches.list) {
        if (touch.justPressed) {
            touchInput = true;
            break;
        }
    }
    #end

    if (inputEnabled && (controls.ACCEPT || touchInput)) {
        inputEnabled = false;
        enterText.animation.play("enterPressed");
        FlxG.sound.play(Paths.sound("menu/confirm"));

        // 白色闪屏效果
        var whiteFlash = new FlxSprite(0, 0);
        whiteFlash.makeGraphic(FlxG.width, FlxG.height, 0xFFFFFFFF);
        whiteFlash.alpha = 1;
        add(whiteFlash);

        FlxTween.tween(whiteFlash, {alpha: 0}, 1.5, {
            ease: FlxEase.quadOut,
            onComplete: () -> {
                remove(whiteFlash);
                
                // 黑屏切换至主菜单
                logo.alpha = 1;
                enterText.alpha = 0;
                FlxG.sound.play(Paths.sound("menu/click"));
                
                new FlxTimer().start(1.0, (_) -> {
                    FlxG.switchState(new MainMenuState());
                });
            }
        });
    }
}