extends CanvasLayer

@onready var state = $state_label
@onready var position_x = $positionX
@onready var position_y = $positionY
@onready var state_time: Label = $stateTime

@onready var player = $".."

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position_x.text = "X: " + str(snapped(player.position.x,0.01))
	position_y.text = "Y: " + str(snapped(player.position.y,0.01))
	state.text = "STATE: " + player._stateID
	state_time.text = "STATE TIME: " + str(player.stateTime)
	pass
