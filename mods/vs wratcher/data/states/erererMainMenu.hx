//
import funkin.backend.MusicBeatTransition;
import flixel.addons.util.FlxSimplex;
import funkin.editors.EditorPicker;
import funkin.menus.ModSwitchMenu;
import funkin.menus.credits.CreditsMain;
import funkin.options.OptionsMenu;

var background:FunkinSprite;
var mv:FunkinSprite;

var _list = CoolUtil.coolTextFile(Paths.txt("config/menuItems"));
var options:Array<FunkinSprite> = [];
var curSelected:Int = 0;

var intro:Bool = true;
static var firstIntro:Bool = true;

var optionXOffset:Float = -400;
var optionYStartPercent:Float = 0.1;
var optionYEndPercent:Float = 0.65;

function create() {
    FlxG.camera.bgColor = 0xFF000000;
    FlxG.mouse.visible = !controls.touchC;
    CoolUtil.playMenuSong();
    // 保险：从标题页切过来时，旧的音乐对象可能还在但已停止，这里确保菜单音乐真的在响
    if (FlxG.sound.music == null || !FlxG.sound.music.playing) {
        CoolUtil.playMusic(Paths.music("freakyMenu"), true, 1);
    }

    background = new FunkinSprite().loadGraphic(Paths.image("menus/wratcher/mmenu/Edited_Menu"));
    background.antialiasing = false;
    background.scale.set(0.67, 0.67);
    background.updateHitbox();
    background.screenCenter();
    background.scrollFactor.set(0.5, 0.5);
    add(background);

    mv = new FunkinSprite().loadGraphic(Paths.image("menus/wratcher/mmenu/menu_vignette"));
    mv.antialiasing = false;
    mv.scale.set(0.67, 0.67);
    mv.updateHitbox();
    mv.screenCenter();
    mv.scrollFactor.set(0.5, 0.5);
    add(mv);

    for (idx => optionName in _list) {
        var itemNameLower = optionName.toLowerCase();
        var menuItem = new FunkinSprite();
        
        menuItem.frames = Paths.getSparrowAtlas('menus/mainmenu/$optionName');
        
        menuItem.animation.addByPrefix('basic', '$itemNameLower basic', 24);
        menuItem.animation.addByPrefix('white', '$itemNameLower white', 24);
        
        menuItem.animation.play('basic');
        menuItem.ID = idx;
        menuItem.antialiasing = true;
        menuItem.scrollFactor.set();
        menuItem.scale.set(0.8,0.8);
        
        add(menuItem);
        options.push(menuItem);
    }

    changeSelection(0, true);

    //妈妈再也不用担心我因该引擎移植的人不同导致添加了个滚木触摸板了
    if (this.addMobilePad != null) {
        this.addMobilePad('UP_DOWN', 'A_B_M_E');
    } else if (this.addTouchPad != null) {
        addTouchPad('UP_DOWN', 'A_B_M_E');
        addTouchPadCamera();
    } else if (this.addDPad != null) {
        addDPad("FULL");
        addDPadCamera(false);
        addButton("A_B_M_E");
        addButtonCamera(false);
    }
}

function update(elapsed:Float):Void {
 
    var change = (FlxG.keys.justPressed.UP ? -1 : 0) + (FlxG.keys.justPressed.DOWN ? 1 : 0) - FlxG.mouse.wheel;
    if (controls.UP_P) change = -1;
    if (controls.DOWN_P) change = 1;
    if (change != 0) changeSelection(change, false);

    var shouldSelect = ((firstIntro ? !intro : true) && (FlxG.keys.justPressed.ENTER || FlxG.mouse.justPressed)) || controls.ACCEPT;
    if (shouldSelect) {
        for (btn in options) {
            if (FlxG.mouse.overlaps(btn) || controls.ACCEPT) {
                select();
                break;
            }
        }
    }

    if (controls.BACK) {
        FlxG.sound.play(Paths.sound("cancelMenu"), 0.7);
        FlxG.switchState(new TitleState());
    }

    if (this.addMobilePad != null) {

    if (mobilePadJustPressed('M')) {
        FlxG.sound.play(Paths.sound("menu/select"), 0.7);
        openSubState(new ModSwitchMenu());
        persistentUpdate = false;
        persistentDraw = true;
    }

    if (!FlxG.save.data.devMode && (mobilePadJustPressed("E"))) {
        FlxG.sound.play(Paths.sound("menu/select"), 0.7);
        persistentUpdate = false;
        persistentDraw = true;
        openSubState(new EditorPicker());
    }
    
    } else if (this.addTouchPad != null) {

    if (touchPad.buttonM.justPressed) {
        FlxG.sound.play(Paths.sound("menu/select"), 0.7);
        openSubState(new ModSwitchMenu());
        persistentUpdate = false;
        persistentDraw = true;
    }

    if (touchPad.buttonE.justPressed) {
        FlxG.sound.play(Paths.sound("menu/select"), 0.7);
        persistentUpdate = false;
        persistentDraw = true;
        openSubState(new EditorPicker());
    }
    } else if (this.addDPad != null) {
    
    if (!Options.devMode && (FlxG.keys.justPressed.SEVEN || mobileManager.checkState("M", "justPressed"))) {
        openSubState(new EditorPicker());
        persistentUpdate = false;
        persistentDraw = true;
    }
        
    if (controls.SWITCHMOD || mobileManager.checkState("M", "justPressed")) {
        openSubState(new ModSwitchMenu());
        persistentUpdate = false;
        persistentDraw = true;
    }
    }
}

var prevSelected = 0;
function changeSelection(amt:Int = 0, force:Bool = false) {
    prevSelected = curSelected;
    curSelected = force ? amt : FlxMath.wrap(curSelected + amt, 0, options.length - 1);

    for (btn in options) {
        if (btn.ID == curSelected) {
            btn.animation.play('white');
        } else {
            btn.animation.play('basic');
        }
    }

    if (prevSelected != curSelected) {
        FlxG.sound.play(Paths.sound("menu/scroll"), 0.5);
    }
}

function postUpdate(elapsed:Float) {
    var minY = FlxG.height * optionYStartPercent;
    var maxY = FlxG.height * optionYEndPercent;
    var totalHeight = maxY - minY;
    
    var buttonsTotalHeight = 0.0;
    for (btn in options) buttonsTotalHeight += btn.height;
    
    var gap = (totalHeight - buttonsTotalHeight) / (options.length - 1);
    var curY = minY;
    for (btn in options) {
        btn.x = FlxG.width / 2 - btn.width / 2 + optionXOffset;
        btn.y = curY;
        curY += btn.height + gap;
    }
}

function select() {
    FlxG.sound.play(Paths.sound("menu/select"), 0.9);
    switch (_list[curSelected]) {
        case "Story mode": FlxG.switchState(new ModState("NewStoryMenu"));
        case "Options": FlxG.switchState(new OptionsMenu());
        case "Youtube": CoolUtil.openURL("https://youtu.be/frGinNRhmpI?si=6keb6EBQ6XkV0dNK"); //在某些人移植的手机版cne中会报错
        case "Credits": FlxG.switchState(new ModState("CreditsState"));
        default: trace('未知选项: ${_list[curSelected]}');
    }
}