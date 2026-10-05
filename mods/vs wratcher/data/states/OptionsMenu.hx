//
import sys.FileSystem;
import funkin.options.type.TextOption;
import funkin.options.type.Checkbox;
import funkin.options.type.NumOption;
import funkin.options.keybinds.KeybindsOptions;
import funkin.options.TreeMenuScreen;
import funkin.savedata.FunkinSave;
import funkin.backend.assets.ModsFolder;
import funkin.backend.system.framerate.Framerate;

import flixel.text.FlxText.FlxTextFormat;
import flixel.text.FlxText.FlxTextFormatMarkerPair;

using StringTools;

var menuLength:Int = -1;

function postCreate() {
	bg.loadGraphic(Paths.image('menus/optionsBG'));
	bg.scale.set(0.67, 0.67);
	bg.updateHitbox();
	bg.antialiasing = false;
}

function update(elapsed:Float) {
    if(menuLength != treeLength) {
        menuLength = treeLength;
        for (menu in tree) {
            if (menu.health != -1) {
                menu.health = -1;
                switch (menu.rawName) {
                    case "optionsTree.gameplay-name":

                        var botplayCheckbox:Checkbox = null;
                        var middleScrollCheckbox:Checkbox = null;

                        menu.insert(1, middleScrollCheckbox = new Checkbox("中间滚动", "若勾选，将音符轨道移至屏幕中央，并隐藏对手轨道。", "MiddleScroll", null, FlxG.save.data));
                        menu.add(botplayCheckbox = new Checkbox("程序操控", "如果你手动操作能力较差，就开启这个选项。", "botplay", null, FlxG.save.data));
                }
            }
        }
    }
}