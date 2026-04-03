extends TileMapLayer

signal tile_clicked(cell)
@onready var mines_map: TileMapLayer = $"../MinesMap"

var map_rendered: bool = false
var first_tile: bool = false
var flag_coords: Array[Vector2i]
var max_flags = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	tile_clicked.connect(on_tile_clicked)
		
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		visible = !visible

	if map_rendered:
		var cell = local_to_map(get_local_mouse_position())
		if get_cell_source_id(cell) != -1:
			if Input.is_action_just_pressed("click_tile"):
				emit_signal("tile_clicked", cell)
			
			if first_tile:
				if Input.is_action_just_pressed("place_flag"):
					if can_place_flags():
						if !is_flagged(cell):
							set_cell(cell, 0, Vector2i(0, 2))
							flag_coords.append(cell)
					else:
						set_cell(cell, 0, Vector2i(0, 1))
						flag_coords.erase(cell)
			
		pass

func on_tile_clicked(cell: Vector2i):
	if not first_tile:
		first_tile = true
		print("first tile clicked")
		
		mines_map.initialize_mines(cell)
	mines_map.reveal_tiles(cell)

func map_finished():
	print("pre-bomb map finished rendering")
	map_rendered = true
	pass

func is_flagged(cell: Vector2i) -> bool:
	return get_cell_atlas_coords(cell) == Vector2i(0, 2)
func can_place_flags() -> bool:
	return len(flag_coords) < max_flags
