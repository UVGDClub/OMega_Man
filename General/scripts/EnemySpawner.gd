extends VisibleOnScreenNotifier2D
@onready var debug_visual = $debug_visual
@export var enemy_to_spawn: Resource;

var ENEMY_RESOURCE;
var ENEMY_INST = null;
var ENEMY_INST_ID:int = -1;
var SPAWN_TRIGGER:bool = true;

# Called when the node enters the scene tree for the first time.
func _ready():
	if(enemy_to_spawn != null):
		ENEMY_RESOURCE = load(str(enemy_to_spawn.resource_path));
	debug_visual.visible = false;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if(enemy_to_spawn == null): return
	handle_enemy_spawn();

func handle_enemy_spawn():
	if(Global.camera.camera_page_screen_active): return; #HACK dont spawn when camera is moving
	if(!is_on_screen()): SPAWN_TRIGGER = true; return; #reload the spawner when off screen
	if(!SPAWN_TRIGGER): return;
	#if(is_instance_id_valid(ENEMY_INST_ID)): return
	#spawn enemy if an enemy has not been spawned yet.
	ENEMY_INST = ENEMY_RESOURCE.instantiate()
	ENEMY_INST.position = position
	ENEMY_INST_ID = ENEMY_INST.get_instance_id();
	ENEMY_INST.connect_with_spawner(self.get_instance_id());
	add_sibling(ENEMY_INST)
	assert(is_instance_valid(ENEMY_INST))
	print("spawned:" + str(ENEMY_INST))
	SPAWN_TRIGGER = false;
