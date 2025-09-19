class_name SpawnPoint extends Node2D

@export var location:int = 0;
@export var camera_y_screen:int = 0; #what height in screens should the camera start at from this spawn

func _ready():
	$Sprite2D.visible = false;
