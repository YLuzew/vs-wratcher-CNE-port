import funkin.backend.MusicBeatTransition;
import flixel.addons.display.FlxBackdrop;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import flixel.util.FlxStringUtil;
import flixel.util.FlxAxes;
import flixel.text.FlxText.FlxTextBorderStyle;
import StringTools;

import funkin.backend.utils.DiscordUtil;
import funkin.savedata.FunkinSave;
import funkin.menus.StoryMenuState;
import funkin.play.PlayState;
import funkin.backend.FunkinText;
import funkin.menus.MainMenuState;

// ===== 位置快捷修改区 =====
// 周目按钮
var WEEK_BTN_X:Float = 450;          // 第一个按钮的 X 坐标
var WEEK_BTN_Y:Float = 500;          // 按钮的基准 Y 坐标
var WEEK_BTN_SPACING:Float = 220;     // 按钮之间的水平间距（多周时有效）
var WEEK_SELECTED_OFFSET:Float = -20; // 选中时按钮向上移动的像素

// 箭头（左右）
var ARROW_LEFT_X:Float = FlxG.width / 2 - 150;   // 左箭头 X
var ARROW_LEFT_Y:Float = FlxG.height - 125;      // 左箭头 Y
var ARROW_RIGHT_X:Float = FlxG.width / 2 + 125;  // 右箭头 X
var ARROW_RIGHT_Y:Float = FlxG.height - 125;     // 右箭头 Y

// 当前难度图片
var DIFFICULTY_X:Float = FlxG.width / 2;         // 难度图片的 X 中心点
var DIFFICULTY_Y:Float = FlxG.height - 100;      // 难度图片的 Y 中心点

// 周目名称文本（如果需要）
var TEXT_OFFSET_Y:Float = 10;        // 按钮下方文字的垂直偏移
// =========================

// 手动定义周目数据（只有一个周，一首歌）
var weekData = [
    {
        id: "week1",                // 周ID，必须与周目配置文件一致
        name: " ",                  // 显示名称（可留空）
        songs: ["nevermore"],       // 歌曲ID
        unlocked: true
    }
];

var weekSprites:FlxGroup;
var selectedWeek:Int = 0;
var canSelect:Bool = true;
var exitingMenu:Bool = false;
var currentDifficulty:String = "hard";
var difficultySprite:FlxSprite;      // 当前难度图片
var arrowLeft:FlxSprite;             // 左箭头
var arrowRight:FlxSprite;            // 右箭头

function create() {
    // 背景（使用你原来的背景）
    var bg = new FunkinSprite();
    bg.frames = Paths.getFrames("menus/wratcher/storymenu/lvl2");
    
    // 添加动画
    bg.animation.addByPrefix("intro", "lvl2 intro", 24, false); // intro动画，不循环
    bg.animation.addByPrefix("shake", "lvl2 shake", 24, true);  // shake动画，循环播放
    
    // 播放intro动画
    bg.animation.play("intro");
    
    // 监听intro动画完成事件
    bg.animation.callback = function(animName:String, frameNumber:Int, frameIndex:Int) {
        // 当intro动画播放到最后一帧时
        if (animName == "intro" && frameNumber == bg.animation.curAnim.numFrames - 1) {
            // 切换到shake动画并循环播放
            bg.animation.play("shake");
            // 清除回调防止重复触发
            bg.animation.callback = null;
        }
    };
    
    bg.screenCenter();
    bg.scale.set(1.8, 1.8);
    add(bg);

    // 第二个背景层
    var background = new FunkinSprite().loadGraphic(Paths.image("menus/wratcher/storymenu/Level_selection_asset"));
    background.antialiasing = false;
    background.scale.set(0.67, 0.67);
    background.updateHitbox();
    background.screenCenter();
    background.scrollFactor.set(0.5, 0.5);
    add(background);

    // 周按钮组
    weekSprites = new FlxGroup();
    add(weekSprites);

    // 生成周按钮（只有一个）
    for (i in 0...weekData.length) {
        var week = weekData[i];
        // 周目图片路径：menus/storymenu/weeks/week1
        var btn = new FlxSprite(WEEK_BTN_X + i * WEEK_BTN_SPACING, WEEK_BTN_Y, Paths.image("menus/storymenu/weeks/week1"));
        btn.alpha = week.unlocked ? 1 : 0.5;
        weekSprites.add(btn);

        // 周目名称文本（可选）
        var txt = new FunkinText(btn.x + btn.width / 2, btn.y + btn.height + TEXT_OFFSET_Y, 0, week.name, 24);
        txt.alignment = "center";
        txt.color = week.unlocked ? FlxColor.WHITE : FlxColor.GRAY;
        add(txt);
    }

    // --- 难度选择区域（图片化）---
    // 加载箭头图集（menus/storymenu/assets.png + assets.xml）
    var arrowFrames = Paths.getFrames("menus/storymenu/assets");

    // 左箭头
    arrowLeft = new FlxSprite(ARROW_LEFT_X, ARROW_LEFT_Y);
    arrowLeft.frames = arrowFrames;
    arrowLeft.animation.addByPrefix("idle", "arrow left0000", 24, false);
    arrowLeft.animation.addByPrefix("push", "arrow push left0000", 24, false);
    arrowLeft.animation.play("idle");
    arrowLeft.scale.set(0.8, 0.8);
    arrowLeft.updateHitbox();
    arrowLeft.antialiasing = true;
    add(arrowLeft);

    // 右箭头
    arrowRight = new FlxSprite(ARROW_RIGHT_X, ARROW_RIGHT_Y);
    arrowRight.frames = arrowFrames;
    arrowRight.animation.addByPrefix("idle", "arrow right0000", 24, false);
    arrowRight.animation.addByPrefix("push", "arrow push right0000", 24, false);
    arrowRight.animation.play("idle");
    arrowRight.scale.set(0.8, 0.8);
    arrowRight.updateHitbox();
    arrowRight.antialiasing = true;
    add(arrowRight);

    // 当前难度图片
    difficultySprite = new FlxSprite(DIFFICULTY_X, DIFFICULTY_Y);
    difficultySprite.loadGraphic(Paths.image("menus/storymenu/difficulties/" + currentDifficulty));
    difficultySprite.setPosition(DIFFICULTY_X - difficultySprite.width / 2, DIFFICULTY_Y - difficultySprite.height / 2);
    difficultySprite.antialiasing = true;
    add(difficultySprite);

    if (this.addMobilePad != null) {
        this.addMobilePad('LEFT_FULL', 'A_B');
    } else if (this.addTouchPad != null) {
        this.addTouchPad('LEFT_FULL', 'A_B');
        this.addTouchPadCamera();
    } else if (this.addDPad != null) {
        addDPad("FULL");
        addDPadCamera(false);
        addButton("A_B");
        addButtonCamera(false);
    }
}

function update(elapsed:Float):Void {
    
        var touchLeft = controls.LEFT_P;
        var touchRight = controls.RIGHT_P;
        var touchUp = controls.UP_P;
        var touchDown = controls.DOWN_P;
        var touchA = controls.ACCEPT;
        var touchB = controls.BACK;

        if (touchA) onConfirm();
        if (touchLeft) changeDifficulty(-1);
        if (touchRight) changeDifficulty(1);
        if (touchUp) changeWeek(-1);
        if (touchDown) changeWeek(1);
        if (touchB) goBack();

    // --- 键盘输入 ---
    if (FlxG.keys.justPressed.ENTER || FlxG.keys.justPressed.SPACE) onConfirm();
    if (FlxG.keys.justPressed.LEFT) changeDifficulty(-1);
    if (FlxG.keys.justPressed.RIGHT) changeDifficulty(1);
    if (FlxG.keys.justPressed.UP) changeWeek(-1);
    if (FlxG.keys.justPressed.DOWN) changeWeek(1);
    if (FlxG.keys.justPressed.ESCAPE || FlxG.keys.justPressed.BACKSPACE) goBack();

    // 按钮浮动效果
    for (i in 0...weekSprites.members.length) {
        var btn = weekSprites.members[i];
        var targetY = WEEK_BTN_Y + (i == selectedWeek ? WEEK_SELECTED_OFFSET : 0);
        btn.y = FlxMath.lerp(btn.y, targetY, 0.2);
    }
}

function changeWeek(dir:Int):Void {
    if (!canSelect || exitingMenu || weekData.length == 0) return;
    selectedWeek = (selectedWeek + dir + weekData.length) % weekData.length;
    FlxG.sound.play(Paths.sound("scrollMenu"), 0.7);
}

function changeDifficulty(dir:Int):Void {
    if (!canSelect || exitingMenu) return;
    var diffs = ["hard", "Wretched"];
    var idx = diffs.indexOf(currentDifficulty);
    idx = (idx + dir + diffs.length) % diffs.length;
    currentDifficulty = diffs[idx];
    FlxG.sound.play(Paths.sound("scrollMenu"), 0.7);

    // 播放箭头按下动画（键盘/触摸板触发）
    if (dir < 0 && arrowLeft != null) {
        arrowLeft.animation.play("push");
        new FlxTimer().start(0.15, function(_) {
            if (arrowLeft != null) arrowLeft.animation.play("idle");
        });
    } else if (dir > 0 && arrowRight != null) {
        arrowRight.animation.play("push");
        new FlxTimer().start(0.15, function(_) {
            if (arrowRight != null) arrowRight.animation.play("idle");
        });
    }

    // 更新难度图片
    if (difficultySprite != null) {
        difficultySprite.loadGraphic(Paths.image("menus/storymenu/difficulties/" + currentDifficulty));
        difficultySprite.setPosition(DIFFICULTY_X - difficultySprite.width / 2, DIFFICULTY_Y - difficultySprite.height / 2);
    }
}

function onConfirm():Void {
    if (!canSelect || exitingMenu || weekData.length == 0) return;
    var week = weekData[selectedWeek];
    if (!week.unlocked) {
        FlxG.sound.play(Paths.sound("cancelMenu"), 0.7);
        return;
    }
    canSelect = false;
    FlxG.sound.play(Paths.sound("confirmMenu"), 1);

    // 使用自由选曲相同的方法加载歌曲
    // 参数：歌曲ID（如 "nevermore"），难度（如 "hard"），是否为故事模式（false），是否跳过过渡（false）
    PlayState.loadSong(week.songs[0], currentDifficulty, false, false);

    new FlxTimer().start(1, function(_) {
        FlxG.switchState(new PlayState());
    });
}

function goBack():Void {
    if (exitingMenu) return;
    exitingMenu = true;
    FlxG.sound.play(Paths.sound("cancelMenu"), 0.7);
    FlxG.switchState(new ModState("erererMainMenu")); // 如果主菜单不是 MainMenuState，请修改
}