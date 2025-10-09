extends Node2D

@onready var debug_visual = $Sprite2D
@export var boss_to_spawn:Resource;

var BOSS_RESOURCE = null;

func _ready():
	if(boss_to_spawn != null):
		BOSS_RESOURCE = load(str(boss_to_spawn.resource_path));
	debug_visual.visible = false;
	Global.spawn_boss.connect(_spawn_boss)

func _spawn_boss():
	assert(BOSS_RESOURCE != null)
	var boss = BOSS_RESOURCE.instantiate()
	assert(boss is Boss); #if you stop here, you've passed an incorrect object! it must be of type Boss
	boss.position = position
	add_sibling(boss)
	assert(is_instance_valid(boss)) #if you stop here, god help you!
	print("spawned:" + str(boss))
