## This boss has an extremely simple attack pattern
## powered by a small state machine
## Most megaman boss attack patterns are simple.

extends Boss

var hop_count:int = 0; #used for attack pattern

func _ready():
	initialize_boss(state_Idle);

func _physics_process(delta):
	stateDriver();
	handle_gravity(delta);
	handle_health_and_death();
	move_and_slide()

#region STATES

var state_Idle = func():
	_stateID		= "Idle";
	stateTime   = -1; # how long should the state run for. set to -1 if the state does not have a timed end
	stateNext	= null; # normal exit
	
	onEnter = func(): # run once, on entering the state. may not be necessary
		return
			
	main	= func(): # run continuously
		face_player();
		if(is_on_floor()):
			velocity = Vector2(0,-300);
			hop_count += 1;
		return
		
	onLeave = func(): # run only when the state is changed. may not be necessary
		hop_count = 0;
		return
		
	exitConditions = func():
		if(hop_count) > 3: state_forceExit(state_Attack1_A)
		return

var state_Attack1_A = func():
	_stateID		= "Attack1_A";
	stateTime   = -1; # how long should the state run for. set to -1 if the state does not have a timed end
	stateNext	= null; # normal exit
	
	onEnter = func(): # run once, on entering the state. may not be necessary
		face_player();
		ignore_gravity = true;
		velocity = Vector2(0,0);
		return
			
	main	= func(): # run continuously
		global_position.x = move_toward(global_position.x, Global.player.global_position.x, 4.0);
		global_position.y = move_toward(global_position.y, Global.player.global_position.y - 100, 5.0);
		return
		
	onLeave = func(): # run only when the state is changed. may not be necessary
		ignore_gravity = false;
		return
		
	exitConditions = func():
		if(is_equal_approx(global_position.x, Global.player.global_position.x)
		&& is_equal_approx(global_position.y, Global.player.global_position.y-100)):
			state_forceExit(state_Idle);
		return

#endregion
