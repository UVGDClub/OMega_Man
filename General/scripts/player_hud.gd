extends CanvasLayer
class_name PlayerHUD

@onready var health_bar = $HealthBar
@onready var ammo_bar:TextureProgressBar = $"Ammo Bar"


func _ready():
	ammo_bar.hide();

#func _process(delta):
	#if(p.weapon_state != p.WEAPON.NORMAL):
		#ammo_bar.show()
		#ammo_bar.value = p.ammo;
		#ammo_bar.tint_progress = p.weapon_stats[p.weapon_state][3];
	#else:
		#ammo_bar.hide();
	#health_bar.value = p.health;

func update_ammo_bar(bar : bool, col : Color, val : int):
	ammo_bar.visible = bar
	ammo_bar.value = val
	ammo_bar.tint_progress = col

func update_health_bar(v : int):
	health_bar.value = v;
