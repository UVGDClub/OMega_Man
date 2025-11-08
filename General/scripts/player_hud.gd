extends CanvasLayer
class_name PlayerHUD

@onready var health_bar = $HealthBar
@onready var ammo_bar:TextureProgressBar = $"Ammo Bar"


func _ready():
	ammo_bar.hide();

func update_ammo_bar(bar : bool, col : Color, val : int):
	ammo_bar.visible = bar
	ammo_bar.value = val
	ammo_bar.tint_progress = col

func update_health_bar(v : int):
	health_bar.value = v;
