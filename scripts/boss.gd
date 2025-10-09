##Class for every stage boss to inherit from.
class_name Boss extends StateEntity2D

##Every boss should have the folowing nodes
@onready var sprite = $Sprite2D
@onready var animation_player = $AnimationPlayer
@onready var health_bar = $HUD/HealthBar
@onready var fill_timer = $HUD/fill_timer

##shared resources
const DEATH = preload("res://sfx/temp/player/death.ogg")
const HIT = preload("res://sfx/temp/enemy/hit.ogg")
const BOSS_HEALTH_TICK = preload("res://sfx/temp/boss_health_tick.wav")
const VFX_BIG_DEATH = preload("res://objects/vfx/vfx_big_death.tscn")

var health = 1;
var facing = -1;
var default_state:Callable = func(): return;

##Always call this is _ready
##the default state is the state the boss starts at after the intro is done
func initialize_boss(_default_state:Callable):
	state = state_Intro_1;
	state.call()
	health_bar.hide();
	default_state = _default_state; 

## handles the death
func handle_health_and_death():
	health_bar.value = health;
	if(health <= 0): 
		SoundManager.playSound(DEATH);
		big_death_explosion(); 	#do explosion vfx
		var item = ITEM_PICKUP.instantiate()
		item.item_type = 3; #drop goal object
		add_sibling(item);
		item.position = position + Vector2(0,-8);
		SoundManager.stop_music();
		queue_free() #TEMP

##does the big cool VFX when the boss dies. similar to player
func big_death_explosion():
	for i in range(8):
		var explosion = VFX_BIG_DEATH.instantiate();
		explosion.global_position = global_position
		var velo = (Vector2.UP * 3.0).rotated((2*PI/8)*i)
		explosion.velocity = velo
		add_sibling(explosion);
	for i in range(4):
		var explosion = VFX_BIG_DEATH.instantiate();
		explosion.global_position = global_position
		var velo = (Vector2.UP * 1.5).rotated((2*PI/4)*i)
		explosion.velocity = velo
		add_sibling(explosion);

## adds gravity to velocity when airborne	
func handle_gravity(delta):
	# Add the gravity.
	if(ignore_gravity): return
	if not is_on_floor():
		velocity.y += gravity * delta

## When called, automatically updates facing to point in the direction of the player.
## If a valid Sprite2D is passed, this will automatically flip the sprite to face the player. 
func face_player():
	if(Global.player == null): return
	if(Global.player.position.x > position.x):
		facing = 1;		
	else: facing = -1;
	if(sprite != null):
		sprite.flip_h = facing < 0;

#TODO logic for weapon immunity and return false
func try_damage(dmg):
	health -= dmg;
	SoundManager.playSound(HIT)
	return true;

## done at the end of intro_2
func show_and_fill_healthbar():
	health_bar.show()
	fill_timer.start();

## does the health bar fill at the beginning of the fight.
func _on_fill_timer_timeout():
	if(health != 28):
		health += 1;
		fill_timer.start();
	else:
		Global.player.has_control = true;
		state_forceExit(default_state);
	SoundManager.playSound(BOSS_HEALTH_TICK,0.5);


## The folowing states are used by every boss, and are for the intro cutscene only.
#region SHARED STATES
##falling into the arena
var state_Intro_1 = func():
	_stateID		= "Intro_1";
	stateTime   = -1; # how long should the state run for. set to -1 if the state does not have a timed end
	stateNext	= null; # normal exit
	
	onEnter = func(): # run once, on entering the state. may not be necessary
		animation_player.play("Intro_1")
		face_player();
		return
			
	main	= func(): # run continuously
		return
		
	onLeave = func(): # run only when the state is changed. may not be necessary
		return
		
	exitConditions = func():
		if(is_on_floor()): state_forceExit(state_Intro_2);
		return

## intro animation
var state_Intro_2 = func():
	_stateID		= "Intro_2";
	stateTime   = -1; # how long should the state run for. set to -1 if the state does not have a timed end
	stateNext	= null; # normal exit
	
	onEnter = func(): # run once, on entering the state. may not be necessary
		animation_player.play("Intro_2")
		return
			
	main	= func(): # run continuously
		if(!animation_player.is_playing()):
			if(health_bar.visible == false):
				show_and_fill_healthbar(); 
		return
		
	onLeave = func(): # run only when the state is changed. may not be necessary
		return
		
	exitConditions = func():
		return

#endregion
