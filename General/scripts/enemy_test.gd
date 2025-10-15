extends Enemy

const SPEED = 300.0
const JUMP_VELOCITY = -400.0
@onready var detection_range = $detection_range
@onready var detection_circle = $detection_range/detection_circle

func _ready():
	state = state_Idle;
	state.call()
	pass

func _physics_process(delta):
	stateDriver();
	handle_gravity(delta);
	handle_death();
	move_and_slide()
	
#region STATES
var state_Idle = func():
	_stateID		= "Idle";
	stateTime   = -1; # how long should the state run for. set to -1 if the state does not have a timed end
	stateNext	= null; # normal exit
	
	onEnter = func(): # run once, on entering the state. may not be necessary
		#anim_state = ANIM.IDLE;
		return
			
	main	= func(): # run continuously
		face_player();
		return
		
	onLeave = func(): # run only when the state is changed. may not be necessary
		return
		
	exitConditions = func():
		if(detect_player()): state_forceExit(state_Attack_1);
		return
		
var state_Attack_1 = func():
	_stateID		= "Attack_1";
	stateTime   = -1; # how long should the state run for. set to -1 if the state does not have a timed end
	stateNext	= state_Idle; # normal exit
	
	onEnter = func(): # run once, on entering the state. may not be necessary
		velocity = Vector2(0,-300);
		#velocity.x = -facing*100;
		return
			
	main	= func(): # run continuously
		return
		
	onLeave = func(): # run only when the state is changed. may not be necessary
		return
		
	exitConditions = func():
		if(is_on_floor()): state_forceExit(state_Idle)
		return
			
