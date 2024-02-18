class_name OmegaCamera
extends Camera2D

#TODO:
# 1 Refactor camera transition lerping to take advantage of the follow point
	# just have the trigger create a follow point for the camera that moves
	# better than the garbage implemented right now!
# 2 Create a volume that restricts the camera movement 
# so it doesnt go out of the level geo

var follow: Node2D = null
var lerp_speed := 4
var camera_scroll_active := false

@onready var lerp_target := position
@onready var World = $"../.."

func _ready() -> void:
	Global.camera_spawn.emit(self)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	find_player()
	handle_camera_transition_lerp()
	follow_instance_x()

# Set target as player
func find_player():
	if follow != null: return
	follow = Global.player

func handle_camera_transition_lerp():
	if not camera_scroll_active: return false
	if position == lerp_target:
		camera_scroll_active = false 
		return false
	position.x = move_toward(position.x,lerp_target.x,lerp_speed)
	position.y = move_toward(position.y,lerp_target.y,lerp_speed)
	return true

func set_camera_position(newX: float, newY: float):
	position.x = newX
	position.y = newY
	lerp_target = position
	
# Pan camera one screen height, -1=UP, 1=DOWN
func camera_page_screen_vertically(dir := -1):
	lerp_target.y = position.y + 240 * dir
	camera_scroll_active = true
	if follow == Global.player: (follow as Player).event_camera_scroll(Vector2(0,24*dir))
	
# Pan camera one screen width, -1=LEFT, 1=RIGHT	
func camera_page_screen_horizontally(dir := 1):
	lerp_target.x = position.x + 256 * dir
	camera_scroll_active = true
	if follow == Global.player: (follow as Player).event_camera_scroll(Vector2(25*dir,0))
	
func follow_instance_x():
	if follow == null: return
	if camera_scroll_active: return
	
	position.x = follow.position.x
	lerp_target = follow.position
