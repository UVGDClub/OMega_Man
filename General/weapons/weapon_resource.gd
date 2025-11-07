extends Resource
##READ: https://docs.google.com/document/d/1Nx2bDud6jFGAK-fJVuQmFSQD_PMJEAqOdFbjn8nDh3g/edit?usp=sharing
class_name WeaponResource

@export var weapon_name : String
##The scene of the weapon
@export var weapon_scene : PackedScene
##This should only be checked if the weapon should be available from the start (or for testing)
@export var acquired : bool = false
##This must be equal to index of this resource in the array, and the level index where this weapon is acquired
@export var weapon_index : int = 0
##The colour of the ammo bar
@export var bar_colour : Color = Color.WHITE
##The string used to identify the weapon in the weapon select screen
@export var select_character : String = "P"

var saved_ammo := 28

func spawn_weapon(p : Player):
	if !weapon_scene:
		push_error("No weapon scene")
		return
	
	var w_temp : Weapon = weapon_scene.instantiate()
	p.add_child(w_temp)
	p.weapon = w_temp
	w_temp.ammo = saved_ammo
	w_temp.idx = weapon_index
	
