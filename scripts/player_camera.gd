extends Camera2D


var follow = null;
var lerp_target: Vector2 = Vector2.ZERO;
var lerp_speed = 4;
var camera_scroll_active: bool = false;

@onready var World = $"../.."

#TODO:
# 1 Refactor camera transition lerping to take advantage of the follow point
	# just have the trigger create a follow point for the camera that moves
	# better than the garbage implemented right now!
# 2 Create a volume that restricts the camera movement 
# so it doesnt go out of the level geo
	

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	lerp_target = position;
	Global.camera_spawn.emit(self)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	find_player();
	handle_camera_transition_lerp();
	follow_instance_x();



func handle_camera_transition_lerp():
	if(!camera_scroll_active): return false;
	if(position == lerp_target): 
		camera_scroll_active = false; 
		return false;
	#Global.player.has_control = false;
	position.x = move_toward(position.x,lerp_target.x,lerp_speed);
	position.y = move_toward(position.y,lerp_target.y,lerp_speed);
	return true;
	
func set_camera_position(newX,newY):
	position.x = newX;
	position.y = newY;
	lerp_target = position;
	
func camera_lerp_Y(dir = -1):
	#default up
	lerp_target.y = position.y + 240 * dir;
	camera_scroll_active = true;
	if(follow == Global.player): follow.event_camera_scroll(Vector2(0,24*dir))
func camera_lerp_X(dir = 1):
	#default right
	lerp_target.x = position.x + 256 * dir;
	camera_scroll_active = true;
	if(follow == Global.player): follow.event_camera_scroll(Vector2(25*dir,0))
	
func follow_instance_x():
	if(follow == null): return;
	if(camera_scroll_active): return;
	position.x = follow.position.x;
	lerp_target = follow.position;
	#print("follow:" + str(follow));
	
func find_player():
	if(follow != null): return;
	#search for player
	follow = Global.player;
