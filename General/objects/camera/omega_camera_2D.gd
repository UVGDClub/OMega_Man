class_name OmegaCamera2D
extends Camera2D

#TODO:
# 1 Refactor camera transition lerping to take advantage of the follow point
	# just have the trigger create a follow point for the camera that moves
	# better than the garbage implemented right now!

var follow: Node2D = null
var camera_page_screen_active := false
var screenSize = Vector2(ProjectSettings.get_setting("display/window/size/viewport_width"),
						ProjectSettings.get_setting("display/window/size/viewport_height"))

var lerp_speed := 4
var player_nudge_direction = Vector2.ZERO
var player_nudge_dim = Vector2.ZERO
var restrict_x := Vector2(-1,-1);

var newPos : Vector2;

@onready var lerp_target := position
@onready var World = $"../.."

signal start_pan
signal end_pan

func _ready() -> void:
	Global.camera_spawn.emit(self)
	print(screenSize)
	#newPos = position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	find_player()
	
	_process_camera_page_screen()
	follow_instance_horizontally()
	_restrict_camera_x()
	#position = newPos

# Set target as player
func find_player():
	if follow != null: return
	if Global.player != null: follow = Global.player
	#else: printerr("Camera: could not find player!!")

## incrementally processes the movement of the camera and player
## done every frame
func _process_camera_page_screen():
	if not camera_page_screen_active: return
	if position == lerp_target:
		
		camera_page_screen_active = false
		end_pan.emit()
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
func camera_page_screen_vertically(dir:int, nudgeY: float = 8.0):
	start_pan.emit()
	player_nudge_dim.y = nudgeY
	lerp_target.x = position.x
	lerp_target.y = position.y + screenSize.y * dir
	camera_page_screen_active = true
	player_nudge_direction = Vector2(0,dir)
	
# Pan camera one screen width, -1=LEFT, 1=RIGHT	
func camera_page_screen_horizontally(dir:int, nudgeX: float):
	start_pan.emit()
	player_nudge_dim.x = nudgeX;
	lerp_target.x = position.x + screenSize.x * dir
	lerp_target.y = position.y
	camera_page_screen_active = true
	player_nudge_direction = Vector2(dir,0)
	restrict_x += Vector2(256,256)*dir; #adjust restrictions automatically
	

# Lerp camera horizontally toward the follow target
func follow_instance_horizontally():
	if follow == null: return
	if camera_page_screen_active: return
	position.x = follow.global_position.x
	#lerp_target = follow.position

#doesnt let the camera's center go past the boundaries set
#cant use things like limit_left because it doesnt actually prevent position from moving
func _restrict_camera_x():
	if camera_page_screen_active: return
	if(restrict_x[0] == restrict_x[1]): return
	var leftBoundary = position.x - 128
	var rightBoundary = position.x + 128
	if(leftBoundary < restrict_x[0]): 
		position.x = restrict_x[0] + 128
	if(rightBoundary > restrict_x[1]): 
		position.x = restrict_x[1] - 128
	
