extends Enemy

const SPEED = 150.0
const ENEMY_BULLET = preload("res://General/objects/enemy_bullet.tscn")
const SHOOT = preload("res://General/sfx/temp/player/shoot.ogg")

func _ready():
	state = state_Fly;
	state.call()
	handle_node_connections();
	pass

func _physics_process(delta):
	stateDriver();
	handle_death();
	move_and_slide()
	
#region STATES
var state_Fly = func():
	_stateID		= "Fly";
	stateTime   = -1; # how long should the state run for. set to -1 if the state does not have a timed end
	stateNext	= null; # normal exit
	
	onEnter = func(): # run once, on entering the state. may not be necessary
		return
			
	main	= func(): # run continuously
		velocity = Vector2.LEFT * SPEED;
		return
		
	onLeave = func(): # run only when the state is changed. may not be necessary
		return
		
	exitConditions = func():
		if(detect_player()): state_forceExit(state_Attack_1);
		return
		
var state_Attack_1 = func():
	_stateID		= "Attack_1";
	stateTime   = 30; # how long should the state run for. set to -1 if the state does not have a timed end
	stateNext	= state_FlyAway; # normal exit
	
	onEnter = func(): # run once, on entering the state. may not be necessary
		velocity = Vector2.ZERO
		return
			
	main	= func(): # run continuously
		if(stateTime == 15):
			#shoot player
			if(Global.player != null):
				var target = Global.player.global_position;
				var dir = global_position.direction_to(target);
				var bullet = ENEMY_BULLET.instantiate()
				bullet.velocity = 200.0 * dir;
				bullet.global_position = global_position
				SoundManager.playSound(SHOOT)
				add_sibling(bullet);
		return
		
	onLeave = func(): # run only when the state is changed. may not be necessary
		return
		
	exitConditions = func():
		return
			

var state_FlyAway = func():
	_stateID		= "FlyAway";
	stateTime   = -1; # how long should the state run for. set to -1 if the state does not have a timed end
	stateNext	= null; # normal exit
	
	onEnter = func(): # run once, on entering the state. may not be necessary
		return
			
	main	= func(): # run continuously
		velocity = Vector2.RIGHT * SPEED*2;
		return
		
	onLeave = func(): # run only when the state is changed. may not be necessary
		return
		
	exitConditions = func():
		return
