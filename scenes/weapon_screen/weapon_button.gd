extends Button

@onready var label = $Label
@onready var ammo = $ammo
@onready var blinker = $blinker

const MENU_MOVE = preload("res://sfx/temp/menu/menu_move.ogg")

@export var weaponIndex:Player.WEAPON;
var tint:Color = Color.WHITE;

func _ready():
	pass
	
func set_ammo(amt, tint_ = Color.WHITE):
	ammo.value = amt;
	ammo.tint_progress = tint_;

func _on_pressed():
	#select weapon
	Global.player.handle_weapon_swtich(weaponIndex);
	#exit menu
	Global.toggle_weapon_menu();

func _on_focus_entered():
	label.visible = false;
	SoundManager.playSound(MENU_MOVE)
	blinker.start();
	pass # Replace with function body.

func _on_focus_exited():
	blinker.stop()
	label.visible = true;
	pass # Replace with function body.

func _on_blinker_timeout():
	label.visible = !label.visible
