extends TileMap

const SOURCE_ID = 0
const WALL_TILE = Vector2i(1, 2)
const AIR_TILE  = Vector2i(14, 7)

func render_cave(grid):
	print("RENDER KE PANGGIL")
	clear()
	
	# 🔥 TEST TILE
	set_cell(0, Vector2i(0,0), SOURCE_ID, WALL_TILE)

	for y in range(grid.size()):
		for x in range(grid[y].size()):
			if grid[y][x]:
				set_cell(0, Vector2i(x, y), SOURCE_ID, WALL_TILE)
			else:
				set_cell(0, Vector2i(x, y), SOURCE_ID, AIR_TILE)
