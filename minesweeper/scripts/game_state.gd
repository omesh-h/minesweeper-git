extends Node2D

#Keeps track of the game state, score, camera and UI

signal load_level
signal update_level
@onready var mine_map = $"../MinesMap"
@onready var camera_2d: Camera2D = $"../Camera2D"
@onready var lose_screen: CanvasLayer = $"../LoseScreen"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_camera()
	
	load_level.connect(_on_load_level)
	update_level.connect(_on_update_level)
	
	LevelGenerator.register_layers(
		$"../MinesMap",
		$"../InteractiveTileMap"
	)
	
	pass # Replace with function body.

func update_camera():
	var grid_width = LevelGenerator.get_grid_width(LevelGenerator.current_level)
	var grid_height = LevelGenerator.get_grid_height(LevelGenerator.current_level)
	
	camera_2d.position = mine_map.get_grid_center()
	camera_2d.zoom = camera_2d.get_viewport().size / Vector2i(grid_width * 24, grid_height * 14)

func _on_update_level() -> void:
	LevelGenerator.create_level(LevelGenerator.current_level)
	LevelGenerator.current_level += 1
	emit_signal("load_level")

func _on_load_level() -> void:
	mine_map.reset()
	mine_map.create_minesweeper()
	pass

func _on_mine_revealed() -> void:
	lose_screen.visible = true
	pass
