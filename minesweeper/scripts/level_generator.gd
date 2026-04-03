extends Node

var mine_map_layer: TileMapLayer
var interactive_map: TileMapLayer

var current_level: int = 0


var LEVELS: Array[Dictionary] = [
	#keeps track of grids and bombs
	{"grid": Rect2i(1, 1, 10, 10), "mines": 16}, #LEVEL 0
]

func register_layers(mine_path, interactive_path):
	#register any paths to nodes needed
	mine_map_layer = mine_path
	interactive_map = interactive_path

func create_level(level: int):
	#current level will be an index of LEVELS (under the assumption that the previous lvl is already made
	
	var grid = LEVELS[level]["grid"] 
	grid.width += 6
	grid.height += 6
	
	var bombs = roundi((grid.width * grid.height) * randf_range(0.15, 0.21))
	#create a more difficult level based off the last level
	LEVELS.append(
		{"grid": grid, "mines": bombs}
	)
