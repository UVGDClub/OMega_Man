extends CanvasLayer

@onready var state = $state_label
@onready var position_x = $positionX
@onready var position_y = $positionY
@onready var state_time: Label = $stateTime
@onready var weapon = $weapon
@onready var hp = $hp
@onready var lives = $lives
@onready var ammo = $ammo

@onready var player = Global.player;

# Called when the node enters the scene tree for the first time.
func _ready():
	follow_viewport_enabled = false;
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if(player == null): return
	
	position_x.text = "X: " + str(snapped(player.position.x,0.01))
	position_y.text = "Y: " + str(snapped(player.position.y,0.01))
	state.text = "STATE: " + player._stateID
	state_time.text = "STATE TIME: " + str(player.stateTime)
	weapon.text = "WEAPON: " + str(player.weapon_state)
	hp.text = "HP: " + str(player.health)
	ammo.text = "AMMO: " + str(player.ammo)
	lives.text = "LIVES: " + str(Global.playerLives)
	
	
	pass
