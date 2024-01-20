extends CharacterBody2D

#REFERENCES
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var sprite_2d = $Sprite2D
@onready var animation_player = $AnimationPlayer

const bulletSource = preload("res://scenes/bullet_small.tscn")
const LADDER_ZONE = preload("res://scenes/ladder_zone.tscn")
@onready var World = $"../.."

#debug
var debug_slowMo = 1

#ANIMATION STATE
enum ANIM {
	IDLE, 
	RUN, 
	AIR, 
	LADDER, 
	SLIDE, 
	TELEPORT,
	TELEPORT_FINISH,
	DAMAGE, 
	STUN
}
var anim_state = ANIM.IDLE;

#CONSTANTS
const SPEED = 100.0
const SPEED_LADDER = 1.0
const JUMP_VELOCITY = -300.0
const FRICTION = 45.0
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")

#stats
var health = 24;

# State Related Variables
var facing = 1;
var ignore_friction = false;
var ignore_gravity = false;
var ignore_movement = false;
var can_shoot = true;
var shoot_anim_timer: int = 0;
var shoot_anim_timer_max: int = 15;
var detect_ladder = false;
var ladder_inst = null;

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
var state_Idle = func(): return;
var state_Run;
var state_Air;
var state_Ladder;
var state_Slide;
var state_Teleport_Enter;
var state_Teleport_Exit;
var state_Damage;
var state_Stun;
var state_Special;
var state_Special2;

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
	if (_stateID != _statePrevID):
		stateChanged = true
		_statePrevID = _stateID;
		
	if(stateChanged):
		stateTime = stateTimeNew
		onEnter.call()
		print("----PLAYER_STATE----: "+_stateID);
		
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


func _ready():
	stateInit();
	state = state_Teleport_Enter;
	state.call()
	pass


func _physics_process(delta: float) -> void:
	debug_handle_slowmo();
	handle_cooldowns();
	
	get_input()
	stateDriver(stateTime);
	
	#print(state.hash())
	
	handle_gravity(delta)
	handle_movement()
	handle_friction()
	handle_jump()
	handle_shoot()
	

	update_animation()
	
	move_and_slide() # necessary to update the character body
	queue_redraw(); # necessary for updating draws calls in-script

func _draw():
	pass
	
func handle_movement():
	if(ignore_movement): return
	if input_move.x:
		facing = input_move.x
		if(_stateID == "Slide"): return
		velocity.x = facing * SPEED

func debug_handle_slowmo():
	if(Input.is_action_just_pressed("debug_slowmo")):
		debug_slowMo *= -1
		print("AH")
	if(debug_slowMo == 1):
		Engine.set_time_scale(1)
		Engine.max_fps = 60
	else:
		var guh: float = 1.0/60.0
		Engine.max_fps = 1
		Engine.set_time_scale(guh)
		
		
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
	if(ignore_gravity): return
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

func can_climb_ladder():
	if(detect_ladder):
		if(abs(input_move.y)): return true
	return false
	
func handle_weapon_switch():
	#switch weapons with shouler buttons
	
	pass
	
	
			
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
		ANIM.TELEPORT_FINISH:
			animation_player.play("teleport_finish")
		ANIM.DAMAGE:
			animation_player.play("damage")
		ANIM.STUN:
			animation_player.play("stun")
		_:
			animation_player.play("idle")

func stateInit():
	#STATE EXAMPLES
	state_Idle = func():
		_stateID		= "Idle";
		stateTime   = -1; # how long should the state run for. set to -1 if the state does not have a timed end
		stateNext	= null; # normal exit
		
		onEnter = func(): # run once, on entering the state. may not be necessary
			anim_state = ANIM.IDLE;
			bullet_offset = Vector2(21,-13)
			return
				
		main	= func(): # run continuously
			return
			
		onLeave = func(): # run only when the state is changed. may not be necessary
			return
			
		exitConditions = func():
			if(!is_on_floor()): state_forceExit(state_Air)
			if(input_move.x != 0): state_forceExit(state_Run)
			var slide = (input_move.y == -1) && input_jump_press
			if(slide): state_forceExit(state_Slide)
			if(can_climb_ladder()): state_forceExit(state_Ladder)
			if(Input.is_action_just_pressed("ui_down")): state_forceExit(state_Special)
			return
		

	state_Run = func():
		_stateID		= "Run";
		stateTime   = -1; # how long should the state run for. set to -1 if the state does not have a timed end
		stateNext	= null; # normal exit
		
		onEnter = func(): # run once, on entering the state. may not be necessary
			anim_state = ANIM.RUN;
			bullet_offset = Vector2(21,-13)
			return
				
		main	= func(): # run continuously
			return
			
		onLeave = func(): # run only when the state is changed. may not be necessary
			return
			
		exitConditions = func():
			if(!is_on_floor()): state_forceExit(state_Air)
			if(input_move.x == 0): state_forceExit(state_Idle)
			var slide = (input_move.y == -1) && input_jump_press
			if(slide): state_forceExit(state_Slide)
			if(can_climb_ladder()): state_forceExit(state_Ladder)
			return


	state_Air = func():
		_stateID		= "Air";
		stateTime   = -1; # how long should the state run for. set to -1 if the state does not have a timed end
		stateNext	= null; # normal exit
		onEnter = func(): # run once, on entering the state. may not be necessary
			anim_state = ANIM.AIR;
			bullet_offset = Vector2(18,-16)
			return
				
		main	= func(): # run continuously
			return
			
		onLeave = func(): # run only when the state is changed. may not be necessary
			return
			
		exitConditions = func():
			if(is_on_floor()): state_forceExit(state_Idle)
			if(can_climb_ladder()): state_forceExit(state_Ladder)
			return
			

	state_Ladder = func():
		_stateID		= "Ladder";
		stateTime   = -1; # how long should the state run for. set to -1 if the state does not have a timed end
		stateNext	= null; # normal exit

		onEnter = func(): # run once, on entering the state. may not be necessary
			anim_state = ANIM.LADDER;
			bullet_offset = Vector2(18,-16)
			ignore_gravity = true;
			ignore_movement = true;
			position.x = ladder_inst.position.x + 8
			return
				
		main	= func(): # run continuously
			velocity = Vector2.ZERO
			animation_player.speed_scale = 0
			if(input_move != Vector2.ZERO):
				#position.x += input_move.x * SPEED_LADDER # subtract cause up in grid is negative
				position.y -= input_move.y * SPEED_LADDER # subtract cause up in grid is negative
				animation_player.speed_scale = 1
			return
			
		onLeave = func(): # run only when the state is changed. may not be necessary
			animation_player.speed_scale = 1
			ignore_gravity = false;
			ignore_movement = false;
			return
			
		exitConditions = func():
			if(input_jump_press): state_forceExit(state_Air)
			if(!detect_ladder): state_forceExit(state_Air)
			return
			

	state_Slide = func():
		_stateID		= "Slide";
		stateTime   = 20; # how long should the state run for. set to -1 if the state does not have a timed end
		stateNext	= state_Idle; # normal exit
		
		onEnter = func(): # run once, on entering the state. may not be necessary
			anim_state = ANIM.SLIDE;
			input_jump_press = false; #reset input
			ignore_friction = true;
			jump_cooldown = 5;
			return
				
		main	= func(): # run continuously
			velocity.x = facing * SPEED * 2
			if(stateTime == 1):
				#if there is a ceiling above us
					#increase state time by 1
				pass
			
		onLeave = func(): # run only when the state is changed. may not be necessary
			ignore_friction = false;
			return
			
		exitConditions = func():
			var jump = Input.is_action_just_pressed("act_jump") && (jump_cooldown == 0)
			if(jump || !is_on_floor()): state_forceExit(state_Air)
			if(Input.is_action_just_pressed("act_shoot")): state_forceExit(state_Damage)
			return;
	
	state_Teleport_Enter = func():
		_stateID		= "Teleport_Enter";
		stateTime   = 4; # how long should the state run for. set to -1 if the state does not have a timed end
		stateNext	= state_Idle; # normal exit
		
		onEnter = func(): # run once, on entering the state. may not be necessary
			anim_state = ANIM.TELEPORT;
			ignore_friction = true;
			ignore_gravity = true;
			ignore_movement = true;
			return
				
		main	= func(): # run continuously
			if(!is_on_floor()):
				stateTime = 5;
				velocity.y = 980;
				velocity.x = 0;
			else:
				anim_state = ANIM.TELEPORT_FINISH
				velocity.y = 0;
				velocity.x = 0;
			return
			
		onLeave = func(): # run only when the state is changed. may not be necessary
			ignore_friction = false;
			ignore_gravity = false;
			ignore_movement = false;
			return
			
		exitConditions = func():
			return
		

	state_Damage = func():
		_stateID		= "Damage";
		stateTime   = 20; # how long should the state run for. set to -1 if the state does not have a timed end
		stateNext	= state_Idle; # normal exit
		
		onEnter = func(): # run once, on entering the state. may not be necessary
			anim_state = ANIM.DAMAGE;
			INVINCIBILITY = 90;
			has_control = false;
			return
				
		main	= func(): # run continuously
			return
			
		onLeave = func(): # run only when the state is changed. may not be necessary
			has_control = true;
			return
			
		exitConditions = func():
			return
		
		
	state_Stun = func():
		_stateID		= "Stun";
		stateTime   = 30; # how long should the state run for. set to -1 if the state does not have a timed end
		stateNext	= state_Idle; # normal exit
		
		onEnter = func(): # run once, on entering the state. may not be necessary
			anim_state = ANIM.STUN;
			has_control = false;
			return
				
		main	= func(): # run continuously
			return
			
		onLeave = func(): # run only when the state is changed. may not be necessary
			has_control = true;
			return
			
		exitConditions = func():
			return
			
	state_Special = func():
		_stateID	= "Special";
		stateTime   = 61; # how long should the state run for. set to -1 if the state does not have a timed end
		stateNext	= state_Idle; # normal exit
		
		onEnter = func(): # run once, on entering the state. may not be necessary
			anim_state = ANIM.STUN;
			has_control = false;
			return
				
		main	= func(): # run continuously
			rotation += 15;
			return
			
		onLeave = func(): # run only when the state is changed. may not be necessary
			has_control = true;
			rotation = 0;
			return
			
		exitConditions = func():
			if(stateTime == 1):
				if(position.y > 150):
					state_forceExit(state_Stun)
				else:
					state_forceExit(state_Special2)
			return

	state_Special2 = func():
		_stateID	= "Special";
		stateTime   = 20; # how long should the state run for. set to -1 if the state does not have a timed end
		stateNext	= state_Idle; # normal exit
		
		onEnter = func(): # run once, on entering the state. may not be necessary
			anim_state = ANIM.STUN;
			has_control = false;
			return
				
		main	= func(): # run continuously
			position.y -= 15;
			return
			
		onLeave = func(): # run only when the state is changed. may not be necessary
			has_control = true;
			return
			
		exitConditions = func():
			return
