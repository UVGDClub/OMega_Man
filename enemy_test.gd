extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const EXPLOSION_PARTICLE = preload("res://scenes/explosion_particle.tscn")
const ITEM_PICKUP = preload("res://scenes/item_pickup.tscn")
const detection_range_scale = 32
@onready var detection_range = $detection_range
@onready var detection_circle = $detection_range/detection_circle



var health = 3;
var facing = -1;

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var ignore_gravity = false;

#STATE INITIALIZE (godot needs this?)
var state_Idle = func(): return;
var state_Attack_1 = func(): return;

#region STATE MACHINE BACK END

#STATE DRIVERS
var state = func(): return
var onEnter = func(): return
var main = func(): return
var onLeave = func(): return
var exitConditions = func(): return

var stateNext = func(): return
var stateChanged: bool = false
var stateTime: int = 0
var _stateID: String = "NULL";
var _statePrevID: String = "NULL";

func state_run_onEnter_once(stateTimeNew):
	if(_stateID != _statePrevID):
		stateChanged = true
		_statePrevID = _stateID;
		stateTime = stateTimeNew
		onEnter.call()
		print("----ENEMY_STATE----: "+_stateID);
		
func state_run_onLeave_whenStateDone():
	if(stateTime == -1): return
	if(stateChanged): return
	if(stateTime == 0):
		onLeave.call()
		_statePrevID = _stateID;
		state = stateNext;
		stateChanged = true;
		state.call() # update enter, main, leave and exit funcs
		#state_onEnter(stateTime) # force onEnter changes?
	else:
		stateTime -= 1;
		

func state_forceExit(stateNextOverride):
	if(stateNextOverride == state): return
	onLeave.call();
	_statePrevID = _stateID;
	state = stateNextOverride;
	stateChanged = true;
	state.call(); #update enter, main, leave and exit funcs
	state_run_onEnter_once(stateTime) # force onEnter changes
	
func state_check_ExitConditions():
	if(!stateChanged): 
		exitConditions.call()

# Runs the state Sandwich
func stateDriver(stateTime_):
	#onEnter
	state_run_onEnter_once(stateTime_) # runs onEnter once
	#main
	main.call() 
	#exiting
	state_check_ExitConditions() #doesnt run if stateTime == 0
	
	state_run_onLeave_whenStateDone()
	stateChanged = false # this must set it to false for both exitConditions and onEnter

#endregion


func _ready():
	stateInit();
	state = state_Idle;
	state.call()
	detection_circle.scale *= detection_range_scale;
	pass

func _physics_process(delta):
	stateDriver(stateTime);
	
	handle_gravity(delta);
	handle_death();

	move_and_slide()

func handle_death():
	if(health <= 0): 
		#do explosion
		var explode: GPUParticles2D = EXPLOSION_PARTICLE.instantiate()
		explode.one_shot = true;
		explode.position.y -= 8
		add_sibling(explode)
		explode.position = position + Vector2(0,-8)
		
		#drop item maybe
		var item_chance = randi_range(1,100);
		#if(item_chance <= 25):
		if(true):
			var item_type = randi_range(0,2);
			var size = randi_range(0,1);
			var item = ITEM_PICKUP.instantiate()
			item.item_type = item_type;
			item.size = size;
			item.onTimer = true;
			add_sibling(item);
			item.position = position + Vector2(0,-8);
			
		queue_free();
		

func handle_gravity(delta):
	# Add the gravity.
	if(ignore_gravity): return
	if not is_on_floor():
		velocity.y += gravity * delta
		
func face_player():
	#need player
	facing = -1;		

func detect_player():
	if(detection_range.overlaps_body(Global.player)):
		return false
	return true;

func try_damage(dmg):
	health -= dmg;
	return true;

func _on_tree_exiting():
	pass
	
func stateInit():
	#STATE EXAMPLES
	state_Idle = func():
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
			
	state_Attack_1 = func():
		_stateID		= "Attack_1";
		stateTime   = -1; # how long should the state run for. set to -1 if the state does not have a timed end
		stateNext	= null; # normal exit
		
		onEnter = func(): # run once, on entering the state. may not be necessary
			velocity = Vector2(0,-90);
			velocity.x = facing;
			return
				
		main	= func(): # run continuously
			return
			
		onLeave = func(): # run only when the state is changed. may not be necessary
			return
			
		exitConditions = func():
			return
			
