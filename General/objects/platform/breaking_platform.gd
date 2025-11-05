extends StaticBody2D

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

@export var warning_time: float = 0.5
@export var respawn_time: float = 2.0

var is_breaking: bool = false
var is_broken: bool = false

enum State { Alive, Breaking }

@onready var state = State.Alive

func trigger_break():
	if state == State.Alive:
		state = State.Breaking
		start_warning()
		

func start_warning():
	warn_it()
	await get_tree().create_timer(warning_time).timeout
	break_it()
	await get_tree().create_timer(respawn_time).timeout
	respawn_it()

func warn_it():
	sprite_2d.modulate = Color(1,0.5,0.5)

func break_it():
	sprite_2d.hide()
	print("ASD")
	collision_shape_2d.set_deferred("disabled", true)
	
func respawn_it():
	sprite_2d.show()
	collision_shape_2d.set_deferred("disabled", false)
	sprite_2d.modulate = Color(1,1,1)
	state = State.Alive
