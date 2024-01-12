extends CharacterBody2D

#REFERENCES
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var sprite_2d = $Sprite2D
@onready var animation_player = $AnimationPlayer

@onready var bulletSource = preload("res://bullet_small.tscn")
@onready var World = $"../.."

#ANIMATION STATE
enum ANIM {
	IDLE, 
	RUN, 
	AIR, 
	LADDER, 
	SLIDE, 
	TELEPORT, 
	DAMAGE, 
	STUN
}

var anim_state = ANIM.IDLE;

#CONSTANTS
const SPEED = 100.0
const JUMP_VELOCITY = -350.0
const FRICTION = 45.0
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")

# State Related Variables
var facing = 1;
var ignore_friction = false;
var can_shoot = true;
var shoot_anim_timer: int = 0;
var shoot_anim_timer_max: int = 15;

#INPUT RELATED
var has_control = true;
var input_move : Vector2;
var input_shoot : bool;
var input_jump : bool;
var input_jump_press : bool;

#COOLDOWNS
var INVINCIBILITY: int = 0;
var dash_cooldown_MAX: int = 30;
var dash_cooldown: int = 0;
var jump_cooldown : int = 0;
var shoot_cooldown_MAX: int = 5
var shoot_cooldown: int = 0

#OFFSETS
var bullet_offset: Vector2 = Vector2.ZERO;

#STATE INITIALIZE (godot needs this?)
var state_Idle;
var state_Run;
var state_Air;
var state_Ladder;
var state_Slide;
var state_Teleport;
var state_Damage;
var state_Stun;

#STATE DRIVERS
var state = func(): return
var onEnterFunc = func(): return
var mainFunc = func(): return
var onLeaveFunc = func(): return
var exitFunctions = func(): return

var stateNext = func(): return
var stateChanged: bool = false
var stateTime: int = 0
var stateID: String = "NULL";
var statePrevID: String = "NULL";

func state_onEnter(stateTimeNew):
	if (stateID != statePrevID):
		stateChanged = true
		statePrevID = stateID;
		
	if(stateChanged):
		stateTime = stateTimeNew
		onEnterFunc.call()
		print("----PLAYER_STATE----: "+stateID);
		
func state_runToExit():
	if(stateTime == -1): return
	if(stateChanged): return
	if(stateTime == 0):
		onLeaveFunc.call()
		statePrevID = stateID;
		state = stateNext;
		stateChanged = true;
		state.call() # update enter, main, leave and exit funcs
		#state_onEnter(stateTime) # force onEnter changes?
	else:
		stateTime -= 1;
		

func state_forceExit(stateNextOverride):
	onLeaveFunc.call();
	statePrevID = stateID;
	state = stateNextOverride;
	stateChanged = true;
	state.call(); #update enter, main, leave and exit funcs
	state_onEnter(stateTime) # force onEnter changes
	
func stateDriver(stateTime_):
	#onEnter
	state_onEnter(stateTime_)
	#main
	mainFunc.call()
	#exiting
	state_runToExit()
	if(!stateChanged): 
		exitFunctions.call()
	stateChanged = false


func _ready():
	stateInit();
	state = state_Idle;
	state.call()
	pass


func _physics_process(delta: float) -> void:
	handle_cooldowns();
	
	get_input()
	stateDriver(stateTime);
	
	handle_gravity(delta)
	handle_movement()
	handle_friction()
	handle_jump()
	handle_shoot()
	

	update_animation()
	
	move_and_slide()
	queue_redraw(); # necessary for updating draws calls in-script

func _draw():
	pass
	
func handle_movement():
	if input_move.x:
		facing = input_move.x
		if(stateID == "Slide"): return
		velocity.x = facing * SPEED
		
func handle_friction():
	if(ignore_friction): return
	if(input_move.x): return	
	velocity.x = move_toward(velocity.x, 0, FRICTION)

func get_input():
	input_move.x = Input.get_axis("move_left", "move_right")
	input_move.y = Input.get_axis("move_down", "move_up")
	input_shoot = Input.is_action_just_pressed("act_shoot");
	input_jump = Input.is_action_pressed("act_jump");
	input_jump_press = Input.is_action_just_pressed("act_jump");
	
func handle_gravity(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

func handle_shoot():
	if(shoot_cooldown != 0): return
	if(input_shoot):
		# shoot projectile
		var bullet_ = bulletSource.instantiate()
		bullet_.set_velocity(facing)
		bullet_.position = position + Vector2(facing * bullet_offset.x, bullet_offset.y)
		World.add_child(bullet_)
		shoot_cooldown = shoot_cooldown_MAX;
		shoot_anim_timer = shoot_anim_timer_max;
		
		# shoot projectile
		
func handle_jump():
	# Handle jump.
	if(jump_cooldown): return;
	if is_on_floor():
		if input_jump_press: 
			velocity.y = JUMP_VELOCITY
	else: #this sucks, work on better conditional
		if Input.is_action_just_released("act_jump") and velocity.y < JUMP_VELOCITY / 2: 
			velocity.y = JUMP_VELOCITY / 2
			
func handle_cooldowns():
	if(INVINCIBILITY): INVINCIBILITY -= 1;
	if(shoot_cooldown > 0): shoot_cooldown -= 1;
	if(shoot_anim_timer): shoot_anim_timer -= 1;
	if(jump_cooldown): jump_cooldown -= 1;
	pass

			
func update_animation():
	sprite_2d.scale.x = facing
	match(anim_state):
		ANIM.IDLE:
			if(shoot_anim_timer): animation_player.play("idle_shoot")
			else: animation_player.play("idle")
		ANIM.RUN:
			if(shoot_anim_timer): animation_player.play("run_shoot")
			else: animation_player.play("run")
		ANIM.AIR:
			if(shoot_anim_timer): animation_player.play("air_shoot")
			else: animation_player.play("air_neutral")
		ANIM.LADDER:
			if(shoot_anim_timer): animation_player.play("ladder_shoot")
			else: animation_player.play("ladder")
		ANIM.SLIDE:
			animation_player.play("slide")
		ANIM.TELEPORT:
			animation_player.play("teleport")
		ANIM.DAMAGE:
			animation_player.play("damage")
		ANIM.STUN:
			animation_player.play("stun")
		_:
			animation_player.play("idle")

func stateInit():
	#STATE EXAMPLES
	state_Idle = func():
		stateID		= "Idle";
		stateTime   = -1; # how long should the state run for. set to -1 if the state does not have a timed end
		stateNext	= null; # normal exit
		
		onEnterFunc = func(): # run once, on entering the state. may not be necessary
			anim_state = ANIM.IDLE;
			bullet_offset = Vector2(21,-13)
			return
				
		mainFunc	= func(): # run continuously
			return
			
		onLeaveFunc = func(): # run only when the state is changed. may not be necessary
			return
			
		exitFunctions = func():
			if(!is_on_floor()): state_forceExit(state_Air)
			if(input_move.x != 0): state_forceExit(state_Run)
			var slide = (input_move.y == -1) && input_jump_press
			if(slide): state_forceExit(state_Slide)
			return
		

	state_Run = func():
		stateID		= "Run";
		stateTime   = -1; # how long should the state run for. set to -1 if the state does not have a timed end
		stateNext	= null; # normal exit
		
		onEnterFunc = func(): # run once, on entering the state. may not be necessary
			anim_state = ANIM.RUN;
			bullet_offset = Vector2(21,-13)
			return
				
		mainFunc	= func(): # run continuously
			return
			
		onLeaveFunc = func(): # run only when the state is changed. may not be necessary
			return
			
		exitFunctions = func():
			if(!is_on_floor()): state_forceExit(state_Air)
			if(input_move.x == 0): state_forceExit(state_Idle)
			var slide = (input_move.y == -1) && input_jump_press
			if(slide): state_forceExit(state_Slide)
			return


	state_Air = func():
		stateID		= "Air";
		stateTime   = -1; # how long should the state run for. set to -1 if the state does not have a timed end
		stateNext	= null; # normal exit
		onEnterFunc = func(): # run once, on entering the state. may not be necessary
			anim_state = ANIM.AIR;
			bullet_offset = Vector2(18,-16)
			return
				
		mainFunc	= func(): # run continuously
			return
			
		onLeaveFunc = func(): # run only when the state is changed. may not be necessary
			return
			
		exitFunctions = func():
			if(is_on_floor()): state_forceExit(state_Idle)
			return
			

	state_Ladder = func():
		stateID		= "Ladder";
		stateTime   = -1; # how long should the state run for. set to -1 if the state does not have a timed end
		stateNext	= null; # normal exit

		onEnterFunc = func(): # run once, on entering the state. may not be necessary
			anim_state = ANIM.LADDER;
			bullet_offset = Vector2(18,-16)
			return
				
		mainFunc	= func(): # run continuously
			return
			
		onLeaveFunc = func(): # run only when the state is changed. may not be necessary
			return
			
		exitFunctions = func():
			return
			

	state_Slide = func():
		stateID		= "Slide";
		stateTime   = 20; # how long should the state run for. set to -1 if the state does not have a timed end
		stateNext	= state_Idle; # normal exit
		
		onEnterFunc = func(): # run once, on entering the state. may not be necessary
			anim_state = ANIM.SLIDE;
			input_jump_press = false; #reset input
			ignore_friction = true;
			jump_cooldown = 5;
			return
				
		mainFunc	= func(): # run continuously
			velocity.x = facing * SPEED * 2
			if(stateTime == 1):
				#if there is a ceiling above us
					#increase state time by 1
				pass
			
		onLeaveFunc = func(): # run only when the state is changed. may not be necessary
			ignore_friction = false;
			return
			
		exitFunctions = func():
			var jump = Input.is_action_just_pressed("act_jump") && (jump_cooldown == 0)
			if(jump): state_forceExit(state_Air)
			return;
	
	state_Teleport = func():
		stateID		= "Teleport";
		stateTime   = -1; # how long should the state run for. set to -1 if the state does not have a timed end
		stateNext	= null; # normal exit
		
		onEnterFunc = func(): # run once, on entering the state. may not be necessary
			anim_state = ANIM.TELEPORT;
			return
				
		mainFunc	= func(): # run continuously
			return
			
		onLeaveFunc = func(): # run only when the state is changed. may not be necessary
			return
			
		exitFunctions = func():
			return
		

	state_Damage = func():
		stateID		= "Damage";
		stateTime   = 20; # how long should the state run for. set to -1 if the state does not have a timed end
		stateNext	= state_Idle; # normal exit
		
		onEnterFunc = func(): # run once, on entering the state. may not be necessary
			anim_state = ANIM.DAMAGE;
			INVINCIBILITY = 90;
			has_control = false;
			return
				
		mainFunc	= func(): # run continuously
			return
			
		onLeaveFunc = func(): # run only when the state is changed. may not be necessary
			has_control = true;
			return
			
		exitFunctions = func():
			return
		
		
	state_Stun = func():
		stateID		= "Stun";
		stateTime   = 30; # how long should the state run for. set to -1 if the state does not have a timed end
		stateNext	= state_Idle; # normal exit
		
		onEnterFunc = func(): # run once, on entering the state. may not be necessary
			anim_state = ANIM.STUN;
			has_control = false;
			return
				
		mainFunc	= func(): # run continuously
			return
			
		onLeaveFunc = func(): # run only when the state is changed. may not be necessary
			has_control = true;
			return
			
		exitFunctions = func():
			return
		
