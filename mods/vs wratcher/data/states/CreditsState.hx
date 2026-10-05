var creditsStuff:Array<Array<String>> = [ //Name - Icon name - Description - Link - BG Color
    ['星译团队'],
    ['Yuan Yubu',		'yyb',		'你知道我想说什么吗，好吧我也不知道我想说什么',								'https://b23.tv/K2NEsrJ'	 ],
    ['ChangYe_Official',		'cy',		'请输入文本',								'https://b23.tv/XmaOPYk'	 ],
    ['Psych Engine Team'],
    ['Shadow Mario',		'shadowmario',		'Main Programmer of Psych Engine',								'https://twitter.com/Shadow_Mario_'	 ],
    ['RiverOaken',			'river',			'Main Artist/Animator of Psych Engine',							'https://twitter.com/RiverOaken'	 ],
    [''],
    ['Former Engine Members'],
    ['bb-panzu',			'bb',				'Ex-Programmer of Psych Engine',								'https://twitter.com/bbsub3'		 ],
    [''],
    ["Funkin' Crew"],
    ['ninjamuffin99',		'ninjamuffin99',	"Programmer of Friday Night Funkin'",							'https://twitter.com/ninja_muffin99' ],
    ['PhantomArcade',		'phantomarcade',	"Animator of Friday Night Funkin'",								'https://twitter.com/PhantomArcade3K'],
    ['evilsk8r',			'evilsk8r',			"Artist of Friday Night Funkin'",								'https://twitter.com/evilsk8r'		 ],
    ['kawaisprite',			'kawaisprite',		"Composer of Friday Night Funkin'",								'https://twitter.com/kawaisprite'	 ]
];

var quitting:Bool = false;
static var curSelected:Int = -1;
var descText:FlxText;
var descBox:FlxSprite;
var grpOptions:FlxTypedGroup<Alphabet>;
var iconArray:Array<FlxSprite> = [];
var offsetThing:Float = -75;
var tracked:Array<FlxSprite> = [];
function create() {
    var bg = new FlxSprite(0, 0).loadGraphic(Paths.image("menus/optionsBG"));
    bg.setGraphicSize(FlxG.width, FlxG.height);
    bg.screenCenter();
    bg.antialiasing = Options.antialiasing;
    add(bg);

    grpOptions = new FlxTypedGroup<Alphabet>();
    add(grpOptions);

    for (i in 0...creditsStuff.length) {
        var isSelectable:Bool = !unselectableCheck(i);
        var optionText:Alphabet = new Alphabet(FlxG.width / 2, 300, creditsStuff[i][0], !isSelectable);
        optionText.targetY = i;
        grpOptions.add(optionText);

        if(isSelectable) {
            tracked.push(optionText);
            var icon:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('credits/' + creditsStuff[i][1]));

            // using a FlxGroup is too much fuss!
            iconArray.push(icon);
            add(icon);
        }
    }

    descBox = new FlxSprite(0, 0).makeGraphic(1, 1, FlxColor.BLACK);
    descBox.alpha = 0.6;
    add(descBox);

    descText = new FlxText(50, FlxG.height + offsetThing - 25, 1180, "", 32);
    descText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, 'center');
    descText.scrollFactor.set();
    add(descText);

    grpOptions.forEachAlive(function (item) {
        item.x -= item.textWidth / 2;
	    if (item.font == 'normal') item.color = 0xFF000000;
    });

    var starting = 0;
    if (curSelected == -1) do {
        starting++;
    } while(unselectableCheck(starting));
    
    changeSelection(starting);
    
    if (this.addMobilePad != null) {
        this.addMobilePad('UP_DOWN', 'B');
    } else if (this.addTouchPad != null) {
        this.addTouchPad('UP_DOWN', 'B');
        this.addTouchPadCamera();
    } else if (this.addDPad != null) {
        addDPad("UP_DOWN");
        addDPadCamera(false);
        addButton("B");
        addButtonCamera(false);
    }
}

var quitting:Bool = false;
var holdTime:Float = 0;
var cancel:FlxSound = null;
function update(elapsed:Float) {
    
    if (controls.BACK) {
        cancel = FlxG.sound.play(Paths.sound('menu/cancel'));
        quitting = true;
        startTransition(new ModState("erererMainMenu"));
    }

    if (quitting) cancel.resume();

    if (!quitting) {
        descBox.x = descText.x - 10;
        descBox.y = descText.y - 10;

        var lerpVal:Float = boundTo(elapsed * 12, 0, 1);
        for (text in grpOptions.members) {
            text.y = FlxMath.lerp(text.y, text.targetY * 1.3 * 120 + 290, boundTo(elapsed * 9.6, 0, 1));
            if (text.font == 'normal') {
                if(text.targetY == 0) {
                    var lastX:Float = text.x;
                    text.screenCenter(0x01);
                    text.x = FlxMath.lerp(lastX, text.x - 70, lerpVal);
                } else {
                    // text.screenCenter(0x01);
                    text.x = FlxMath.lerp(text.x, 200 + -40 * Math.abs(text.targetY), lerpVal);
                }
            }
        }
        
        for (i in 0...iconArray.length) {
            var icon = iconArray[i];
            var option = tracked[i];

            icon.x = option.x + option.width + 10;
            icon.y = option.y;
        }

        var upP = controls.UP_P;
        var downP = controls.DOWN_P;

        var shiftMult:Int = 1;
        if(FlxG.keys.pressed.SHIFT) shiftMult = 3;

        if (upP) {
            changeSelection(-1);
            holdTime = 0;
        }
        if (downP) {
            changeSelection(1);
            holdTime = 0;
        }

        if(controls.UP || controls.DOWN) {
            var checkLastHold:Int = Math.floor((holdTime - 0.5) * 10);
            holdTime += elapsed;
            var checkNewHold:Int = Math.floor((holdTime - 0.5) * 10);

            if(holdTime > 0.5 && checkNewHold - checkLastHold > 0)
                changeSelection((checkNewHold - checkLastHold) * (controls.UP ? -shiftMult : shiftMult));
        }
    }
}

var moveTween:FlxTween = null;
function changeSelection(change:Int = 0) {
    do {
        curSelected += change;
        if (curSelected < 0)
            curSelected = creditsStuff.length - 1;
        if (curSelected >= creditsStuff.length)
            curSelected = 0;
    } while(unselectableCheck(curSelected));

    var bullShit:Int = 0;
    grpOptions.forEachAlive(function (item) {
        item.targetY = bullShit - curSelected;
        bullShit++;

        if(!unselectableCheck(bullShit-1)) {
            item.alpha = 0.6;
            if (item.targetY == 0) {
                item.alpha = 1;
            }
        }
    });

    descText.text = creditsStuff[curSelected][2];
    descText.y = FlxG.height - descText.height + offsetThing - 60;

    if(moveTween != null) moveTween.cancel();
		moveTween = FlxTween.tween(descText, {y : descText.y + 75}, 0.25, {ease: FlxEase.sineOut});

    descBox.setGraphicSize(Std.int(descText.width + 20), Std.int(descText.height + 25));
    descBox.updateHitbox();

    FlxG.sound.play(Paths.sound('menu/scroll'));
}

function unselectableCheck(num:Int):Bool {
    return creditsStuff[num].length <= 1;
}

function boundTo(value:Float, min:Float, max:Float):Float {
    return Math.max(min, Math.min(max, value));
}