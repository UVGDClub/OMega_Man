class_name Level extends Node2D

const PLAYER = preload("res://objects/player.tscn")
const READY_PLAYER = preload("res://scenes/ready_player.tscn")

##Each level must have the following nodes:
@onready var spawn_points = $SpawnPoints
@onready var entities = $Entities
@onready var music = $music

var player_inst: CharacterBody2D = null;
var loop_music: bool = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ready_player();
	Global.can_pause = true;
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if(!music.playing && loop_music): music.play()
	pass

##displays the ready popup just before spawning the player
func ready_player():
	var ready_ = READY_PLAYER.instantiate()
	ready_.ready_spawn_player.connect(spawn_player)
	add_child(ready_);
	set_camera_spawn();

func set_camera_spawn():
	var spawn_point = determine_spawn_point();
	var snapX = floor(spawn_point.position.x / 256.0)
	var snapY = floor(spawn_point.position.y / 240.0)
	#the folling sets the proper y position for the camera when spawning the player.
	Global.camera.position.x = 128.0 + 256.0 * snapX;
	Global.camera.position.y = 120.0 + 240.0 * snapY;

func spawn_player():
	var spawn_point = determine_spawn_point();
	var spawn_location = spawn_point.global_position;
	var player = PLAYER.instantiate()
	entities.add_child(player)
	player.global_position = spawn_location;
	player_inst = player;
	player_inst.death.connect(stop_music);

func determine_spawn_point() -> SpawnPoint:
	var spawns = spawn_points.get_children()
	assert(len(spawns) > 0) #if you stop here, you have no spawn points!
	var spawn_point = spawns[Global.level_spawnpoint];
	assert(spawn_point is SpawnPoint) #if you stop here, there is a node in the spawnpoints tree that in not a valid spawn point.
	return spawn_point;

func stop_music():
	loop_music = false;
	music.stop()
