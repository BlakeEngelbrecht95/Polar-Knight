package states;

import actors.Enemies;
import actors.Player;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxState;
import flixel.addons.editors.ogmo.FlxOgmo3Loader;
import flixel.group.FlxGroup;
import flixel.tile.FlxTilemap;
import flixel.util.FlxCollision;

class PlayState extends FlxState
{
	private var player:Player;
	private var enemies:FlxTypedGroup<Enemy>;

	private var map:FlxOgmo3Loader;
	private var ground:FlxTilemap;
	private var background:FlxTilemap;
	private var foreground:FlxTilemap;
	private var snow:FlxTilemap;
	private var backgroundTrees:FlxTilemap;

	override public function create():Void
	{
		instantiateEntities();
		setUpLevel();
		addEntities();

		FlxG.camera.follow(player);

		super.create();
	}

	private function setUpLevel():Void
	{
		bgColor = 0xFF161c28;

		map = new FlxOgmo3Loader("assets/data/polar-knight-testLevel.ogmo", "assets/data/level01.json");
		ground = map.loadTilemap("assets/images/environment/pk-ground-tile.png", "ground");
		background = map.loadTilemap("assets/images/environment/pk-background-tile.png", "background");
		foreground = map.loadTilemap("assets/images/environment/pk-foreground-tile.png", "foreground");
		snow = map.loadTilemap("assets/images/environment/pk-snow-tile.png", "snow");
		backgroundTrees = map.loadTilemap("assets/images/environment/pk-tree-tile.png", "backgroundTrees");

		ground.follow();
		ground.setTileProperties(1, FlxObject.NONE);
		ground.setTileProperties(2, FlxObject.ANY);
		ground.setTileProperties(3, FlxObject.ANY);

		map.loadEntities(placeEntities, "entities"); // player spawn point position
	}

	private function instantiateEntities():Void
	{
		player = new Player();
		player.setSize(30, 45);
		player.offset.set(78, 70);

		enemies = new FlxTypedGroup<Enemy>();
	}

	private function addEntities():Void
	{
		add(background);
		// add(snow);
		add(backgroundTrees);
		add(ground);

		add(player);
		add(enemies);
		add(foreground);
	}

	private function placeEntities(entity:EntityData)
	{
		var x = entity.x;
		var y = entity.y;

		switch (entity.name)
		{
			case "player":
				player.setPosition(x, y);

			case "FlyingEye":
				enemies.add(new Enemy(x + 4, y, FlyingEye));
		}
	}

	function checkEnemyVision(enemy:Enemy)
	{
		if (ground.ray(enemy.getMidpoint(), player.getMidpoint()))
		{
			enemy.seesPlayer = true;
			enemy.playerPosition = player.getMidpoint();
		}
		else
		{
			enemy.seesPlayer = false;
		}
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		FlxG.collide(player, ground);
		enemies.forEachAlive(checkEnemyVision);
	}
}
