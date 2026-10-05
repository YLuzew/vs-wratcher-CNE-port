import funkin.backend.system.framerate.Framerate;
import openfl.text.TextFormat;
import lime.graphics.Image;
import openfl.text.TextFormat;
import funkin.backend.utils.NativeAPI;
import openfl.Lib;
import funkin.backend.utils.WindowUtils;
import openfl.ui.Mouse;

var updateTime:Int = 60;
var textFormat = new TextFormat("_sans", 14, 0xFFFFFF);

function new() {
    Mouse.cursor = 'arrow';
    preStateSwitch();
    if (NativeAPI.hasVersion("Windows 10")) NativeAPI.redrawWindowHeader();
}

function preStateSwitch() {
    if (NativeAPI.hasVersion("Windows 10")) NativeAPI.setDarkMode(Lib.application.window.title, false);
    FlxG.autoPause = false;
    Framerate.codenameBuildField.defaultTextFormat = textFormat;
    Framerate.codenameBuildField.x = 0;
    Framerate.codenameBuildField.y = 1;
    Framerate.memoryCounter.visible = false;
    Framerate.fpsCounter.visible = false;
}

var currentFPS:Int = 0;
var timer:Int = 0;
function postUpdate(elapsed) {
    if (timer % updateTime == 0) {
        currentFPS = Std.int(Framerate.fpsCounter.lastFPS);
        if (currentFPS > Options.framerate) currentFPS = Options.framerate;
    }

    var memoryMegas:Float = CoolUtil.quantize(Framerate.memoryCounter.memory / 1024 / 1024, 100);
    Framerate.codenameBuildField.text = "FPS: " + currentFPS + "\nMemory: " + memoryMegas + "MB";

    Framerate.codenameBuildField.textColor = 0xFFFFFFFF;
    if (memoryMegas > 3000 || Framerate.fpsCounter.lastFPS <= Options.framerate / 2)
		Framerate.codenameBuildField.textColor = 0xFFFF0000;

    timer++;
}

function destroy() {
    if (NativeAPI.hasVersion("Windows 10")) {
        NativeAPI.setDarkMode(Lib.application.window.title, true);
        NativeAPI.redrawWindowHeader();
    }
    Framerate.memoryCounter.visible = true;
    Framerate.fpsCounter.visible = true;
    Framerate.codenameBuildField.defaultTextFormat = Framerate.textFormat;
    Framerate.codenameBuildField.reload();
    Framerate.codenameBuildField.y = Framerate.memoryCounter.y + Framerate.memoryCounter.height;
    FlxG.autoPause = true;
}