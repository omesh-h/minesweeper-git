extends Button
@export var game_state: Node2D

func _on_pressed() -> void:
	game_state.emit_signal("load_level")
	
	pass # Replace with function body.
