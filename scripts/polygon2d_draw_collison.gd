extends Polygon2D

@onready var collision_polygon_2d: CollisionPolygon2D = $".."

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	polygon = collision_polygon_2d.polygon


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
