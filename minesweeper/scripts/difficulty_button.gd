extends OptionButton
@onready var game_state: Node2D = $"../../../GameState"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_item_selected(index: int) -> void:
	game_state.emit_signal("set_difficulty", index)
	pass # Replace with function body.
