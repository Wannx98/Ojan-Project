extends TileMap

# --- PENGATURAN MAP ---
@export var map_width: int = 120
@export var map_height: int = 80
@export var min_room_size: int = 10
@export var max_room_size: int = 22
@export var max_rooms: int = 15
@export var max_attempts: int = 300       # batas percobaan random placement
@export var jarak_antar_ruang: int = 4
@export var lebar_lorong: int = 3         # lebar lorong dalam tile

var grid = []
var room_rects = []

# --- PENGATURAN TERRAIN ---
var layer_id = 0
var terrain_set_id = 0
var terrain_lantai_id = 0
var terrain_dinding_id = 2

func _ready():
	randomize()

func generate_map():
	if Global.current_cave_seed == -1:
		randomize()
		Global.current_cave_seed = randi()
	seed(Global.current_cave_seed)

	generate_rooms_and_corridors()
	render_to_tilemap()

# ==========================================
# ALGORITMA RUANGAN & LORONG
# ==========================================
func generate_rooms_and_corridors():
	grid.clear()
	room_rects.clear()

	for x in range(map_width):
		var column = []
		for y in range(map_height):
			column.append(1)
		grid.append(column)

	var attempts = 0
	while room_rects.size() < max_rooms and attempts < max_attempts:
		attempts += 1

		var w = randi_range(min_room_size, max_room_size)
		var h = randi_range(min_room_size, max_room_size)

		var x = randi_range(jarak_antar_ruang, map_width - w - jarak_antar_ruang)
		var y = randi_range(jarak_antar_ruang, map_height - h - jarak_antar_ruang)

		var new_room = Rect2i(x, y, w, h)
		var padded_room = new_room.grow(jarak_antar_ruang)

		var overlaps = false
		for other_room in room_rects:
			var other_padded = other_room.grow(jarak_antar_ruang)
			if padded_room.intersects(other_padded):
				overlaps = true
				break

		if not overlaps:
			for rx in range(new_room.position.x, new_room.end.x):
				for ry in range(new_room.position.y, new_room.end.y):
					grid[rx][ry] = 0

			if room_rects.size() > 0:
				var nearest_room = cari_ruangan_terdekat(new_room)
				buat_lorong(nearest_room, new_room)

			room_rects.append(new_room)

	# PEMBERSIHAN: hilangkan dinding tipis (1 tile) yang nyempil di antara dua lantai
	bersihkan_dinding_tipis()

	print("Berhasil bikin ", room_rects.size(), " ruangan dari ", attempts, " percobaan")

func bersihkan_dinding_tipis(max_gap: int = 3):
	for pass_i in range(3):
		for x in range(map_width):
			for y in range(map_height):
				if grid[x][y] != 1:
					continue

				# Arah horizontal: ada lantai di kiri, cari lantai dalam jarak max_gap ke kanan
				if x > 0 and grid[x - 1][y] == 0:
					for gap in range(1, max_gap + 1):
						var target_x = x + gap - 1
						if target_x >= map_width or grid[target_x][y] != 0 and grid[target_x][y] != 1:
							break
						if grid[target_x][y] == 0:
							for fx in range(x, target_x):
								grid[fx][y] = 0
							break

				# Arah vertikal: ada lantai di atas, cari lantai dalam jarak max_gap ke bawah
				if y > 0 and grid[x][y - 1] == 0:
					for gap in range(1, max_gap + 1):
						var target_y = y + gap - 1
						if target_y >= map_height or grid[x][target_y] != 0 and grid[x][target_y] != 1:
							break
						if grid[x][target_y] == 0:
							for fy in range(y, target_y):
								grid[x][fy] = 0
							break

func cari_ruangan_terdekat(room: Rect2i) -> Rect2i:
	var center = room.get_center()
	var nearest = room_rects[0]
	var nearest_dist = center.distance_squared_to(nearest.get_center())

	for other_room in room_rects:
		var dist = center.distance_squared_to(other_room.get_center())
		if dist < nearest_dist:
			nearest_dist = dist
			nearest = other_room

	return nearest

func buat_lorong(room_a: Rect2i, room_b: Rect2i):
	var center_a = room_a.get_center()
	var center_b = room_b.get_center()

	if randf() > 0.5:
		gali_garis_horizontal(center_a.x, center_b.x, center_a.y)
		gali_garis_vertikal(center_a.y, center_b.y, center_b.x)
	else:
		gali_garis_vertikal(center_a.y, center_b.y, center_a.x)
		gali_garis_horizontal(center_a.x, center_b.x, center_b.y)

func gali_garis_horizontal(x1: int, x2: int, y: int):
	var start_x = min(x1, x2)
	var end_x = max(x1, x2)
	for x in range(start_x, end_x + 1):
		for dy in range(lebar_lorong):
			var yy = clamp(y + dy, 0, map_height - 1)
			grid[x][yy] = 0

func gali_garis_vertikal(y1: int, y2: int, x: int):
	var start_y = min(y1, y2)
	var end_y = max(y1, y2)
	for y in range(start_y, end_y + 1):
		for dx in range(lebar_lorong):
			var xx = clamp(x + dx, 0, map_width - 1)
			grid[xx][y] = 0

# ==========================================
# TUKANG GAMBAR (AUTO-TERRAIN LU)
# ==========================================
func render_to_tilemap():
	clear()

	var posisi_dinding_array = []
	var posisi_lantai_array = []

	for x in range(map_width):
		for y in range(map_height):
			if grid[x][y] == 1:
				posisi_dinding_array.append(Vector2i(x, y))
			elif grid[x][y] == 0:
				posisi_lantai_array.append(Vector2i(x, y))

	set_cells_terrain_connect(layer_id, posisi_lantai_array, terrain_set_id, terrain_lantai_id)
	set_cells_terrain_connect(layer_id, posisi_dinding_array, terrain_set_id, terrain_dinding_id)

func get_spawn_position() -> Vector2:
	if room_rects.size() == 0:
		return Vector2.ZERO
	var center_cell = room_rects[0].get_center()
	return to_global(map_to_local(center_cell))

func get_room_rects_world() -> Array:
	var world_rects = []
	for r in room_rects:
		var top_left = to_global(map_to_local(r.position))
		var bottom_right = to_global(map_to_local(r.end))
		world_rects.append(Rect2(top_left, bottom_right - top_left))
	return world_rects

func get_map_bounds_world() -> Rect2:
	var top_left = to_global(map_to_local(Vector2i(0, 0)))
	var bottom_right = to_global(map_to_local(Vector2i(map_width, map_height)))
	return Rect2(top_left, bottom_right - top_left)
