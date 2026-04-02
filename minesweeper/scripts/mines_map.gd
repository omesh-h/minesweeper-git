extends TileMapLayer
@onready var interactive_tile_map: TileMapLayer = $"../InteractiveTileMap"

signal map_rendered

var map_size: Rect2i
var bombs: int
var bomb_coords: Array[Vector2i]


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
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func create_difficulty_map(difficulty) -> void:
	print("Creating difficulty: " + str(difficulty))
	match difficulty:
		0: #Easy - 10 x 10
			map_size = Rect2i(1, 1, 10, 10)#create a rect of the map size
			bombs = 10
			#use for loop to set the cell for each cell in the rect
			create_grid(map_size, bombs)
			pass
		1: #Medium
			map_size = Rect2i(1, 1, 16, 16)
			bombs = 30
			create_grid(map_size, bombs)
			pass
		2: #Hard
			bombs = 60
			map_size = Rect2i(1, 1, 20, 20)
			create_grid(map_size, bombs)
			pass
		3: #Extreme
			bombs = 180
			map_size = Rect2i(1, 1, 32, 32)
			create_grid(map_size, bombs)
			pass

func create_grid(grid: Rect2i, bombs: int) -> void:
	#clear grid 
	clear()
	interactive_tile_map.clear()
	#take x and y values of rectangle and then set cell (create minemap)
	for x in range(1, abs(grid.size.x)):
		for y in range(1, abs(grid.size.y)):
			interactive_tile_map.set_cell(Vector2i(x, y), 0, Vector2i(0, 1))
			
			#enable first click safety
			if get_cell_source_id(Vector2i(x,y)) == -1:
				set_cell(Vector2i(x, y), 0, Vector2i(0, 0))
				
	emit_signal("map_rendered") #after first click, begin bomb placement

func initialize_mines(cell: Vector2i) -> void:
	print("placing bombs")
	place_bombs(cell)
	generate_numbers()

func place_bombs(clicked_cell: Vector2i) -> void:
	
	var safe_zone: Array[Vector2i] = [clicked_cell]
	for offset in NEIGHBORS:
		safe_zone.append(clicked_cell + offset)
	
	while bomb_coords.size() < bombs:
		for i in range(0, bombs):
			var cell = Vector2i(
				randi_range(1, abs(map_size.size.x - 1)),
				randi_range(1, abs(map_size.size.y - 1))
			)
			
			#skip over the tiles that were already revealed by the first click 
			#makes sure theres no dupes as well
			if cell in safe_zone or cell in bomb_coords:
				continue
			
			set_cell(cell, 0, Vector2i(1, 1))
			bomb_coords.append(cell)
			#print("Bomb Coords: " + str(bomb_coords))

func generate_numbers() -> void:
	for x in range(1, abs(map_size.size.x)):
		for y in range(1, abs(map_size.size.y)):
			var bomb_count = check_neighbors(Vector2i(x, y))
			
			#skip over bomb coordinates and tiles that were revealed in the first click
			if Vector2i(x, y) in bomb_coords or Vector2i(x, y) in revealed_tiles:
				continue
			
			set_cell(Vector2i(x, y), 0, Vector2i(bomb_count, 0))


func reset() -> void:
	map_size = Rect2i(1, 1, 0, 0)
	bombs = 0
	bomb_coords.clear()
	revealed_tiles.clear()
	interactive_tile_map.first_tile = false


func check_neighbors(cell: Vector2i) -> int:
	var count = 0
	for neighbor_cell in NEIGHBORS:
		if cell + neighbor_cell in bomb_coords:
			count += 1
	return count

func reveal_tiles(cell: Vector2i) -> void:
	
	#after first click, reveal all non-bomb tiles connected to revealed tile
	
	#check if cell already exists
	if cell in revealed_tiles:
		return
	
	interactive_tile_map.erase_cell(cell)
	revealed_tiles.append(cell)
	
	for offset in NEIGHBORS:
		var neighbor_cell = cell + offset
		if is_empty_tile(cell):
			
			#if cells are the same (i.e non-bomb), then reveal and begin to then loop over the other neighbors
			reveal_tiles(neighbor_cell)
	pass


func is_empty_tile(cell: Vector2i) -> bool:
	return get_cell_atlas_coords(cell) == Vector2i(0,0)
