extends Button
@onready var game_state: Node2D = $"../../../GameState"

func _on_pressed() -> void:
	game_state.emit_signal("load_level")
	
	pass # Replace with function body.
