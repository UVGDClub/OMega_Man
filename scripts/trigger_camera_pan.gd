extends Area2D
class_name TriggerCameraPan
@onready var World = $"../.."
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var label: Label = $Label

enum DIRECTION {PAN_Y, PAN_X}
@export var direction_move: DIRECTION
@export var boss_door: bool = false

signal player_entered(direction)

func _ready() -> void:
	label.visible = get_tree().debug_collisions_hint
	match direction_move:
		DIRECTION.PAN_X:
			label.text = "PAN_X"
		DIRECTION.PAN_Y:
			label.text = "PAN_Y"
			
func _process(_delta):
	detect_player_center_cross()

func detect_player_center_cross():
	if(boss_door): return
	if(Global.player == null): return;
	if !overlaps_body(Global.player): return
	if (Global.camera.camera_page_screen_active): return
	if not isPointInArea(Global.player.center.global_position): return
	
	var camerapos = Global.camera.get_screen_center_position()
	var upperBoundY = camerapos.y - 120
	var lowerBoundY = camerapos.y  + 120
	var upperBoundX = camerapos.x - 128
	var lowerBoundX = camerapos.x  + 128
	if(direction_move == DIRECTION.PAN_Y):
		if(Global.player.center.global_position.y > lowerBoundY):
			Global.camera.camera_page_screen_vertically(1, 8)
		elif(Global.player.center.global_position.y < upperBoundY):
			Global.camera.camera_page_screen_vertically(-1, 8)
	if(direction_move == DIRECTION.PAN_X):
		var nudge = player_center_to_trigger_center() + 8
		if(Global.player.center.global_position.x > lowerBoundX):
			Global.camera.camera_page_screen_horizontally(1, nudge)
		elif(Global.player.center.global_position.x < upperBoundX):
			Global.camera.camera_page_screen_horizontally(-1, nudge)
		
func isPointInArea(point:Vector2):
	#scaling the area does NOT account for the collision shape's size. so mult by scale
	var area:Rect2 = Rect2(global_position,collision_shape_2d.shape.size * scale)
	return area.has_point(point);
	
func player_center_to_trigger_center():
	var trigger_size_x = collision_shape_2d.shape.size.x * scale.x
	var trigger_center = global_position.x + trigger_size_x/2
	return abs(Global.player.global_position.x - trigger_center) + trigger_size_x/2
	
func _on_body_entered(body):
	if(body.is_in_group("player")):
		player_entered.emit(body.velocity)
