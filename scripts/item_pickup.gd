extends RigidBody2D
@export_enum("Health", "Ammo", "1up", "Goal") var item_type: int
@export_enum("small", "big") var size: int
@export var onTimer: bool = false;
@onready var sprite = $ItemPickup/Sprite

const SFX_GOAL = preload("res://sfx/temp/level/tada1.wav")
const SFX_1UP = preload("res://sfx/temp/player/1up.wav")

var death_timer: int = 300;
var anim_timer: int = 0;
#HACK automatically choose weapon of the current levels' boss
var unlock_weapon: int = Global.curr_level; 

# Called when the node enters the scene tree for the first time.
func _ready():
	#set sprite
	sprite.hframes = 2
	match(item_type):
		0:
			#health
			if(size == 0):
				sprite.texture = load("res://sprites/Items/health_small.png")
			else:
				sprite.texture = load("res://sprites/Items/health_big.png")
		1:
			#ammo
			if(size == 0):
				sprite.texture = load("res://sprites/Items/ammo_small.png")
			else:
				sprite.texture = load("res://sprites/Items/ammo_big.png")
			pass
		2:
			#extra life
			sprite.texture = load("res://sprites/Items/1up.png")
			sprite.hframes = 1
			pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	sprite.visible = true;
	handle_animation();
	handle_timer();

func handle_timer():
	if(!onTimer): return
	if(death_timer == 0): queue_free()
	if( (death_timer < 120)
		and (death_timer % 4 > 1)): sprite.visible = false;
	death_timer -= 1;
	
func handle_animation():
	#the frame in mm2 actually blinks 2, 3, 2, 3, ...
	#but im keeping it simple
	if(sprite.hframes * sprite.vframes == 1): return;
	if(anim_timer == 0):
		sprite.frame = (sprite.frame + 1) % 2
	anim_timer = (anim_timer + 1) % 4

func _on_item_pickup_body_entered(player):
	if(!player.is_in_group("player")): return;
	#pick up item
	match(item_type):
		0:
			#gain health
			if(size == 0):
				player.try_gain_health(2)
			else:
				player.try_gain_health(10)
		1:
			#get ammo
			if(size == 0):
				player.try_gain_ammo(2)
			else:
				player.try_gain_ammo(10)
			
		2:
			#get extra life
			player.gain_extra_life()
			SoundManager.playSound(SFX_1UP,0.25);
		3:
			Global.player_unlock_weapon(unlock_weapon)
			SoundManager.playSound(SFX_GOAL);
			player.leave_stage();
	queue_free()
