importScript("data/openfl");

import funkin.backend.utils.WindowUtils;
import lime.graphics.Image;
import funkin.backend.system.framerate.Framerate;
import openfl.text.TextFormat;
import openfl.text.TextField;
import funkin.backend.MusicBeatTransition;
import funkin.backend.scripting.GlobalScript;
import funkin.backend.assets.ModsFolder;
import openfl.display.Sprite;

public static var cursor = Assets.getBitmapData(Paths.image('cursor'));
public static var click = Assets.getBitmapData(Paths.image('click'));

public static function changeMouse(mouse:String) FlxG.mouse.load(mouse, 0.3);
