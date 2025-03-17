extends Area2D
class_name TriggerCameraPan
@onready var World = $"../.."
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var label: Label = $Label

enum DIRECTION {PAN_Y, PAN_X}
@export var direction_move: DIRECTION

func _ready() -> void:
	match direction_move:
		DIRECTION.PAN_X:
			label.text = "PAN_X"
		DIRECTION.PAN_Y:
			label.text = "PAN_Y"
			
func _process(_delta):
	if !overlaps_body(Global.player): return
	if isPointInArea(Global.player.center.global_position):
		Global.player.in_camera_transition_trigger = self
	else:
		Global.player.in_camera_transition_trigger = null
		
func isPointInArea(point:Vector2):
	#scaling the area does NOT account for the collision shape's size. so mult by scale
	var area:Rect2 = Rect2(global_position,collision_shape_2d.shape.size * scale)
	return area.has_point(point);
