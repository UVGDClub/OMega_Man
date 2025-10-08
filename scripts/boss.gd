class_name Boss extends StateEntity2D

@onready var sprite = $Sprite2D
@onready var animation_player = $AnimationPlayer
@onready var health_bar = $HUD/HealthBar
@onready var fill_timer = $HUD/fill_timer

const DEATH = preload("res://sfx/temp/player/death.ogg")
const HIT = preload("res://sfx/temp/enemy/hit.ogg")

var health = 1;
var facing = -1;
var default_state:Callable = func(): return;

## handles the death particle and drop item logic.
func handle_death():
	if(health <= 0): 
		SoundManager.playSound(DEATH);
		#do explosion
		var item = ITEM_PICKUP.instantiate()
		item.item_type = 3; #goal object
		add_sibling(item);
		item.position = position + Vector2(0,-8);
		
		queue_free() #TEMP 

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

func _on_fill_timer_timeout():
	if(health != 28):
		health += 1;
		fill_timer.start();
	else:
		Global.player.has_control = true;
		state_forceExit(default_state);
	#play sound
