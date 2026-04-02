extends Node2D

signal set_difficulty(difficulty)
signal create_map(difficulty)
@onready var mine_map = $"../MinesMap"
@onready var camera_2d: Camera2D = $"../Camera2D"

enum DIFFICULTY{
	EASY, #0
	MEDIUM, #1
	HARD, #2
	EXTREME #3
}


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_difficulty.connect(on_set_difficulty)
	create_map.connect(mine_map.create_difficulty_map)
	pass # Replace with function body.

func on_set_difficulty(difficulty: DIFFICULTY) -> void:	
	mine_map.reset()
	match difficulty:
		DIFFICULTY.EASY:
			camera_2d.zoom = Vector2(3.0, 3.0)
			emit_signal("create_map", DIFFICULTY.EASY)
			pass
		DIFFICULTY.MEDIUM:
			camera_2d.zoom = Vector2(3.0, 3.0)
			emit_signal("create_map", DIFFICULTY.MEDIUM)
			pass
		DIFFICULTY.HARD:
			camera_2d.zoom = Vector2(2.0, 2.0)
			emit_signal("create_map", DIFFICULTY.HARD)
			pass
		DIFFICULTY.EXTREME:
			camera_2d.zoom = Vector2(2.0, 2.0)
			emit_signal("create_map", DIFFICULTY.EXTREME)
			pass
