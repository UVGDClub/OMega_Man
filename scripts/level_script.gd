class_name Level extends Node2D

const PLAYER = preload("res://objects/player.tscn")
##Each level must have the following nodes:
@onready var spawn_points = $SpawnPoints
@onready var entities = $Entities

var player_inst: CharacterBody2D = null;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	spawn_player();
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func spawn_player():
	var spawn_point = determine_spawn_point();
	var spawn_location = spawn_point.global_position;
	var player = PLAYER.instantiate()
	entities.add_child(player)
	player.global_position = spawn_location;
	#the folling sets the proper y position for the camera when spawning the player.
	Global.camera.position.y = 120.0 + 240.0 * spawn_point.camera_y_screen; #HACK

func determine_spawn_point() -> SpawnPoint:
	var spawns = spawn_points.get_children()
	assert(len(spawns) > 0) #if you stop here, you have no spawn points!
	var spawn_point = spawns[Global.level_spawnpoint];
	assert(spawn_point is SpawnPoint) #if you stop here, there is a node in the spawnpoints tree that in not a valid spawn point.
	return spawn_point;
