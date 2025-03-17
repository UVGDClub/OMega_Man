class_name Enemy extends StateEntity2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const EXPLOSION_PARTICLE = preload("res://scenes/explosion_particle.tscn")
const ITEM_PICKUP = preload("res://scenes/item_pickup.tscn")
const detection_range_scale = 32
@onready var detection_range = $detection_range
@onready var detection_circle = $detection_range/detection_circle
@onready var sprite = $TempGuy


var health = 3;
var facing = -1;
var SPAWNER_INSTANCE:int = -1;

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var ignore_gravity = false;

func _ready():
	state = state_Idle;
	state.call()
	detection_circle.scale *= detection_range_scale;
	pass

func _physics_process(delta):
	stateDriver();
	
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
		if(item_chance <= 25):
			var item_type = randi_range(0,2);
			var size = randi_range(0,1);
			var item = ITEM_PICKUP.instantiate()
			item.item_type = item_type;
			item.size = size;
			item.onTimer = true;
			add_sibling(item);
			item.position = position + Vector2(0,-8);
			
		handle_despawn();
		

func handle_gravity(delta):
	# Add the gravity.
	if(ignore_gravity): return
	if not is_on_floor():
		velocity.y += gravity * delta
		
func face_player():
	if(Global.player.position.x > position.x):
		facing = -1;		
	else: facing = 1;
	sprite.flip_h = facing < 0
	

func detect_player():
	var detect = detection_range.get_overlapping_bodies()
	for body:Node2D in detect:
		if body.is_in_group("player"): 
			print("i see u")
			return true
	return false;

func try_damage(dmg):
	health -= dmg;
	return true;
	
func connect_with_spawner(spawner_ID):
	#called by enemy_spawner
	#at the moment this connection is superfluous
	SPAWNER_INSTANCE = spawner_ID;
	var test = instance_from_id(SPAWNER_INSTANCE);
	assert(test.ENEMY_INST_ID == self.get_instance_id())
	pass
	
func handle_despawn():
	#when off screen
	#handle any spawner communication if needed
	if(is_instance_id_valid(SPAWNER_INSTANCE)):
		var spawner = instance_from_id(SPAWNER_INSTANCE);
		assert(is_instance_valid(spawner))
		#spawner.ENEMY_INST_ID = -1; #not needed
	queue_free();

func _on_tree_exiting():
	pass
	
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
		velocity.x = facing;
		return
			
	main	= func(): # run continuously
		return
		
	onLeave = func(): # run only when the state is changed. may not be necessary
		return
		
	exitConditions = func():
		if(is_on_floor()): state_forceExit(state_Idle)
		return
			
