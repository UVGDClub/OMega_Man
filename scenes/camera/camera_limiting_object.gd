class_name camera_limiiting_object
extends Area2D

@onready var player := Global.player
@onready var camera := Global.camera
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var height = (collision_shape_2d.shape as RectangleShape2D).size.y

var prev_limit_left
var prev_limit_right
var new_limit_left
var new_limit_right
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	prev_limit_left = camera.limit_left
	prev_limit_right = camera.limit_right
	new_limit_left = prev_limit_left
	new_limit_right = prev_limit_right
	
	if player.global_position.x > global_position.x:
		new_limit_left = global_position.x + 16
	if player.global_position.x < global_position.x:
		new_limit_right = global_position.x
		

func _process(delta: float) -> void:
	#print (global_position.y)
	#print (camera.global_position.y)
	#print(camera.global_position.y-camera.get_viewport_rect().size.y/2)
	#print(camera.get_viewport_rect().size)
	#print()
	var r = collision_shape_2d.shape.get_rect()
	var top_left = r.position * scale.x
	var bottom_right = r.end * scale.y
	print (collision_shape_2d.global_position + top_left)
	print (collision_shape_2d.global_position + bottom_right)
	print (r.get_center())
	print()
	if camera.global_position.y-camera.get_viewport_rect().size.y/2 < global_position.y or camera.global_position.y+camera.get_viewport_rect().size.y/2 > global_position.y +  height:
		camera.limit_left = prev_limit_left
		camera.limit_right = prev_limit_right
	else:
		camera.limit_left = new_limit_left
		camera.limit_right = new_limit_right
