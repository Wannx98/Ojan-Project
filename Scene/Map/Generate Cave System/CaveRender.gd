extends Node2D

@onready var tilemap = $TileMap

func render_cave(grid):
	for y in range(grid.size()):
		for x in range(grid[y].size()):
			if grid[y][x] == 1:
				tilemap.set_cell(0, Vector2i(x, y), 0)
