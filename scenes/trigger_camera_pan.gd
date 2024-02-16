extends Area2D
class_name TriggerCameraPan
var activated = false
@onready var World = $"../.."
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var label: Label = $Label

enum DIRECTION {UP, RIGHT, DOWN, LEFT}
@export var direction_move: DIRECTION

func _ready() -> void:
	match direction_move:
		DIRECTION.UP:
			label.text = "UP"
		DIRECTION.DOWN:
			label.text = "DOWN"
		DIRECTION.LEFT:
			label.text = "LEFT"
		DIRECTION.RIGHT:
			label.text = "RIGHT"

func _on_body_entered(body: Node2D) -> void:
	if activated: return
	if not body.is_in_group("group_player"): return
	if not coming_in_from_the_right_direction(get_entering_direction(body)): return
	# move the camera in the right direction, and force player to exit area
	# by locking their back tracking control input
	match direction_move:
		DIRECTION.UP:
			Global.camera.camera_lerp_Y(-1)
			Global.player.locked_directional_input = Vector2.DOWN
		DIRECTION.DOWN:
			Global.camera.camera_lerp_Y(1)
			Global.player.locked_directional_input = Vector2.UP			
		DIRECTION.LEFT:
			Global.camera.camera_lerp_X(-1)
			Global.player.locked_directional_input = Vector2.RIGHT
		DIRECTION.RIGHT:
			Global.camera.camera_lerp_X(1)
			Global.player.locked_directional_input = Vector2.LEFT
	activated = true

func _on_body_exited(body):
	if(!body.is_in_group("group_player")): return
	if activated:
		# player has left camera panning area so unlock their movement
		Global.player.locked_directional_input = Vector2.ZERO
	activated = false

func coming_in_from_the_right_direction(direction_player_from: DIRECTION):
	match direction_player_from:
		DIRECTION.UP:
			if direction_move == DIRECTION.DOWN: return true
		DIRECTION.DOWN:
			if direction_move == DIRECTION.UP: return true
		DIRECTION.LEFT:
			if direction_move == DIRECTION.RIGHT: return true
		DIRECTION.RIGHT:
			if direction_move == DIRECTION.LEFT: return true
	return false

func get_entering_direction(body: Node2D) -> DIRECTION:
	# Get the global position of the body and the rectangular body
	var playerGlobalPosition = (body as Player).collision_shape_2d.global_position
	var bodyGlobalPosition = collision_shape_2d.global_position
	
	# Calculate the vector from the body to the player
	var directionVector = playerGlobalPosition - bodyGlobalPosition
	
	return getHighestMagnitudeDirection(directionVector)

func getHighestMagnitudeDirection(vector: Vector2) -> DIRECTION:
	var normalizedVector = vector.normalized()
	
	if abs(normalizedVector.x) > abs(normalizedVector.y):
		return DIRECTION.RIGHT if normalizedVector.x > 0 else DIRECTION.LEFT
	else:
		return DIRECTION.DOWN if normalizedVector.y > 0 else DIRECTION.UP
