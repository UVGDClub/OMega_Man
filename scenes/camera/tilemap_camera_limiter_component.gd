class_name TilemapCameraLimiterComponent
extends Node

@export var tilemap: TileMap
@export var camera: OmegaCamera2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	limit_camera_to_tilemap()

func limit_camera_to_tilemap():
	var tilemap_rect = tilemap.get_used_rect()
	var tilemap_tile_size = tilemap.tile_set.tile_size
	
	camera.limit_left = tilemap_rect.position.x * tilemap_tile_size.x
	camera.limit_right = tilemap_rect.end.x * tilemap_tile_size.x
	camera.limit_top = tilemap_rect.position.y * tilemap_tile_size.y
	camera.limit_bottom = tilemap_rect.end.y * tilemap_tile_size.y
	
