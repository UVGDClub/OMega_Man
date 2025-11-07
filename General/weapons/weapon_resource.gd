extends Resource
class_name WeaponResource

@export var weapon_scene : PackedScene
@export var acquired : bool = false
@export var weapon_index : int = 0
@export var bar_colour : Color = Color.WHITE
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
	
