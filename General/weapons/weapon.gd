extends Node2D
class_name Weapon

@export var weapon_name : String
@export_range(0,28) var shot_cost : int = 2
@export var max_onscreen_bullets : int = 3
##Weapon cooldown in seconds
@export var weapon_cooldown : float = 5.0/60
@export_enum("shoot", "shoot_palm") var anim_type : String = "shoot"
@export var has_ammo_bar : bool = true

var idx : int = -1
var cooldown : float = 0
var onscreen_bullets : int = 0
var ammo : int = 28:
	set(value):
		ammo = clamp(value, 0, 28)

##Example function that should be overwritten in your own weapons
##Or you can start your overwrite with if !super.shoot(player): return
func shoot(player : Player):
	if ammo <= 0 || cooldown > 0 || onscreen_bullets >= max_onscreen_bullets: 
		return false
	ammo -= shot_cost
	cooldown = weapon_cooldown
	onscreen_bullets += 1
	player.update_weapon_hud()
	return true

func _process(delta: float) -> void:
	if cooldown > 0: cooldown -= delta

#Connect this to the bullets "bullet_despawn" signal
func bullet_has_despawned():
	onscreen_bullets = max(onscreen_bullets - 1, 0)
	print(onscreen_bullets)
