class_name OmegaCamera2D
extends Camera2D

#TODO:
# 1 Refactor camera transition lerping to take advantage of the follow point
	# just have the trigger create a follow point for the camera that moves
	# better than the garbage implemented right now!
# 2 Create a volume that restricts the camera movement 
# so it doesnt go out of the level geo

var follow: Node2D = null
var camera_page_screen_active := false
var screenSize = Vector2(ProjectSettings.get_setting("display/window/size/viewport_width"),
						ProjectSettings.get_setting("display/window/size/viewport_height"))

var lerp_speed := 4
var player_nudge_direction = Vector2.ZERO
var player_nudge_dim = Vector2.ZERO
@onready var lerp_target := position
@onready var World = $"../.."

func _ready() -> void:
	Global.camera_spawn.emit(self)
	print(screenSize)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	find_player()
	
	process_camera_page_screen()
	follow_instance_horizontally()
	auto_pan_vertical()

# Set target as player
func find_player():
	if follow != null: return
	if Global.player != null: follow = Global.player
	else: printerr("Camera: could not find player!!")
	
func auto_pan_vertical():
	if(camera_page_screen_active): return
	if(Global.player.in_camera_transition_trigger == null): return
	player_nudge_dim = Global.player.in_camera_transition_trigger.collision_shape_2d.shape.size
	player_nudge_dim.y = 8 #this allows for any size trigger and still clear the threshold
	var upperBound = get_screen_center_position().y - 120
	var lowerBound = get_screen_center_position().y  + 120
	if(Global.player.center.global_position.y > lowerBound):
		camera_page_screen_vertically(1)
	if(Global.player.center.global_position.y < upperBound):
		camera_page_screen_vertically(-1)
	

func process_camera_page_screen():
	if not camera_page_screen_active: return
	if position == lerp_target:
		camera_page_screen_active = false 
		return
	position.x = move_toward(position.x,lerp_target.x,lerp_speed)
	position.y = move_toward(position.y,lerp_target.y,lerp_speed)
	#this is some lengthy shit right here
	#nudge the player in the direction the cameras moving in
	#amount to nudge is the size of the transition trigger, synced with lerp_speed
	Global.player.position += player_nudge_direction * player_nudge_dim * Vector2.ONE/(screenSize/lerp_speed)

# Immediately snap camera to a position
func set_camera_position(newX: float, newY: float):
	position.x = newX
	position.y = newY
	lerp_target = position
	
# Pan camera one screen height, -1=UP, 1=DOWN
func camera_page_screen_vertically(dir := -1):
	lerp_target.y = position.y + screenSize.y * dir
	camera_page_screen_active = true
	player_nudge_direction = Vector2(0,dir)
	
# Pan camera one screen width, -1=LEFT, 1=RIGHT	
func camera_page_screen_horizontally(dir := 1):
	lerp_target.x = position.x + screenSize.x * dir
	camera_page_screen_active = true
	player_nudge_direction = Vector2(dir,0)

# Lerp camera horizontally toward the follow target
func follow_instance_horizontally():
	if follow == null: return
	if camera_page_screen_active: return
	
	position.x = follow.position.x
	lerp_target = follow.position
