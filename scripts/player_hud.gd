extends CanvasLayer

@onready var health_bar = $HealthBar
@onready var ammo_bar:TextureProgressBar = $"Ammo Bar"

@onready var p:Player = $".."


func _ready():
	ammo_bar.hide();

func _process(delta):
	if(p.weapon_state != p.WEAPON.NORMAL):
		ammo_bar.show()
		ammo_bar.value = p.ammo;
		ammo_bar.tint_progress = p.weapon_stats[p.weapon_state][3];
	else:
		ammo_bar.hide();
	health_bar.value = p.health;
		
