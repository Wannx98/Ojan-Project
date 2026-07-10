extends Control
class_name MiniMap

var room_rects_world: Array = []
var map_bounds_world: Rect2 = Rect2()
var player: Node2D = null

func set_data(rects: Array, bounds: Rect2):
	room_rects_world = rects
	map_bounds_world = bounds
	queue_redraw()

func set_player(p: Node2D):
	player = p

func _process(_delta):
	if player:
		queue_redraw() # redraw tiap frame biar dot player ikut update

func _draw():
	if map_bounds_world.size == Vector2.ZERO:
		return

	var scale_factor = min(
		size.x / map_bounds_world.size.x,
		size.y / map_bounds_world.size.y
	)

	# Gambar tiap ruangan jadi kotak kecil
	for rect in room_rects_world:
		var pos = (rect.position - map_bounds_world.position) * scale_factor
		var sz = rect.size * scale_factor
		draw_rect(Rect2(pos, sz), Color(0.7, 0.7, 0.7, 0.9))

	# Gambar player jadi titik
	if player:
		var player_pos = (player.global_position - map_bounds_world.position) * scale_factor
		draw_circle(player_pos, 4.0, Color(1, 0.3, 0.3))
func _ready():
	set_anchors_preset(Control.PRESET_TOP_RIGHT)
	custom_minimum_size = Vector2(220, 160)
	size = Vector2(220, 160)
	position -= Vector2(20, 20) # kasih jarak dikit dari pojok
