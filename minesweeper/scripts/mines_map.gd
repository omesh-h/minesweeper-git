extends TileMapLayer

@onready var interactive_tile_map: TileMapLayer = $"../InteractiveTileMap"
@onready var game_state: Node2D = $"../GameState"

signal map_rendered
signal mine_revealed

var mine_coords: Array[Vector2i]
var grid = Rect2i(Vector2i.ZERO, Vector2i.ZERO)
var mines = 0

const NEIGHBORS: Array[Vector2i] = [
	Vector2i(1, 0),
	Vector2i(-1, 0),
	Vector2i(0, 1),
	Vector2i(0, -1),
	Vector2i(1, 1),
	Vector2i(1, -1),
	Vector2i(-1, 1),
	Vector2i(-1, -1),
]
var revealed_tiles: Array[Vector2i]



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	map_rendered.connect(interactive_tile_map.map_finished, CONNECT_ONE_SHOT)
	mine_revealed.connect(game_state._on_mine_revealed)
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func create_minesweeper() -> void:
	grid = LevelGenerator.LEVELS[LevelGenerator.current_level]["grid"]
	mines = LevelGenerator.LEVELS[LevelGenerator.current_level]["mines"]
	interactive_tile_map.max_flags = mines
	print("Creating level with " + str(mines) + " mines" )
	create_visual_grid(grid, mines)

func create_visual_grid(grid: Rect2i, mines: int) -> void:
	#clear grid 
	clear()
	interactive_tile_map.clear()
	#take x and y values of rectangle and then set cell (create minemap)
	for x in range(1, abs(grid.size.x) + 1):
		for y in range(1, abs(grid.size.y) + 1):
			interactive_tile_map.set_cell(Vector2i(x, y), 0, Vector2i(0, 1))
			
			#enable first click safety
			if get_cell_source_id(Vector2i(x,y)) == -1:
				set_cell(Vector2i(x, y), 0, Vector2i(0, 0))
				
	emit_signal("map_rendered") #after first click, begin bomb placement

func initialize_mines(cell: Vector2i) -> void:
	print("initializing mines")
	place_mines(cell)
	generate_numbers()

func place_mines(clicked_cell: Vector2i) -> void:
	
	var safe_zone: Array[Vector2i] = [clicked_cell]
	for offset in NEIGHBORS:
		safe_zone.append(clicked_cell + offset)
	
	#print(safe_zone)
	while len(mine_coords) < mines:
		var cell = Vector2i(
			randi_range(1, abs(grid.size.x)),
			randi_range(1, abs(grid.size.y))
		)
		#skip over the tiles that were already revealed by the first click 
		#makes sure theres no dupes as well
		if cell in safe_zone or cell in mine_coords:
			continue
		
		set_cell(cell, 0, Vector2i(1, 1))
		mine_coords.append(cell)
		#print("Bomb Coords: " + str(bomb_coords))
		
	print(len(mine_coords))

func generate_numbers() -> void:
	for x in range(1, abs(grid.size.x) + 1):
		for y in range(1, abs(grid.size.y) + 1):
			var bomb_count = check_neighbors(Vector2i(x, y))
			
			#skip over bomb coordinates and tiles that were revealed in the first click
			if Vector2i(x, y) in mine_coords or Vector2i(x, y) in revealed_tiles:
				continue
			
			set_cell(Vector2i(x, y), 0, Vector2i(bomb_count, 0))


func reset() -> void:
	grid = Rect2i(Vector2i.ZERO, Vector2i.ZERO)
	mines = 0
	mine_coords.clear()
	revealed_tiles.clear()
	interactive_tile_map.first_tile = false


func check_neighbors(cell: Vector2i) -> int:
	var count = 0
	for neighbor_cell in NEIGHBORS:
		if cell + neighbor_cell in mine_coords:
			count += 1
	return count

func reveal_tiles(cell: Vector2i) -> void:
	
	#after first click, reveal all non-bomb tiles connected to revealed tile
	
	#check if cell already exists
	if cell in revealed_tiles:
		return
	
	interactive_tile_map.erase_cell(cell)
	revealed_tiles.append(cell)
	
	if is_mine(cell):
		print("You blew up!")
		emit_signal("mine_revealed")
	
	for offset in NEIGHBORS:
		var neighbor_cell = cell + offset
		if is_empty_tile(cell):
			
			#if cells are the same (i.e non-bomb), then reveal and begin to then loop over the other neighbors
			reveal_tiles(neighbor_cell)
	pass

func is_empty_tile(cell: Vector2i) -> bool:
	return get_cell_atlas_coords(cell) == Vector2i(0,0)

func is_mine(cell: Vector2i) -> bool:
	return get_cell_atlas_coords(cell) == Vector2i(1,1)
	

func get_grid_center() -> Vector2:
	if not grid:
		grid = LevelGenerator.LEVELS[LevelGenerator.current_level]["grid"]
	var start_local_pos = map_to_local(grid.position)
	var end_local_pos = map_to_local(grid.position + grid.size)
	var local_center = (end_local_pos - start_local_pos)/2
	return to_global(local_center)
	
