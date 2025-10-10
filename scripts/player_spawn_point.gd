class_name SpawnPoint extends Node2D

@export var location:int = 0;

func _ready():
	$Sprite2D.visible = false;
