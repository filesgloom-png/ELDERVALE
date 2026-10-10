extends Node2D

const WORLD_SIZE := Vector2(1280.0, 720.0)
const JOYSTICK_CENTER := Vector2(112.0, 600.0)
const JOYSTICK_RADIUS := 68.0
const PLAYER_SPEED := 245.0

var player_position: Vector2 = WORLD_SIZE * 0.5
var move_vector: Vector2 = Vector2.ZERO
var joystick_vector: Vector2 = Vector2.ZERO
var joystick_active := false
var joystick_touch_index := -1
var elapsed := 0.0

func _ready() -> void:
	queue_redraw()

func _process(delta: float) -> void:
	elapsed += delta
	var keyboard_vector := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := joystick_vector if joystick_vector.length_squared() > 0.001 else keyboard_vector
	move_vector = direction.limit_length(1.0)
	player_position += move_vector * PLAYER_SPEED * delta
	player_position.x = clampf(player_position.x, 36.0, WORLD_SIZE.x - 36.0)
	player_position.y = clampf(player_position.y, 70.0, WORLD_SIZE.y - 35.0)
	queue_redraw()

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed and event.position.x < WORLD_SIZE.x * 0.48 and event.position.y > WORLD_SIZE.y * 0.48:
			joystick_active = true
			joystick_touch_index = event.index
			_update_joystick(event.position)
		elif not event.pressed and event.index == joystick_touch_index:
			joystick_active = false
			joystick_touch_index = -1
			joystick_vector = Vector2.ZERO
	elif event is InputEventScreenDrag and event.index == joystick_touch_index:
		_update_joystick(event.position)

func _update_joystick(screen_position: Vector2) -> void:
	var offset := screen_position - JOYSTICK_CENTER
	joystick_vector = (offset / JOYSTICK_RADIUS).limit_length(1.0)

func _draw() -> void:
	_draw_ground()
	_draw_ruins()
	_draw_trees()
	_draw_player()
	_draw_hud()

func _draw_ground() -> void:
	draw_rect(Rect2(Vector2.ZERO, WORLD_SIZE), Color("#273b32"))
	for y in range(12):
		for x in range(21):
			var tile_x := float(x * 64)
			var tile_y := float(y * 64)
			var variation := posmod(x * 17 + y * 31 + x * y * 3, 5)
			var grass_color := Color("#2d4337")
			if variation == 1:
				grass_color = Color("#304638")
			elif variation == 2:
				grass_color = Color("#293d32")
			draw_rect(Rect2(tile_x, tile_y, 64, 64), grass_color)
			if variation != 3:
				var tuft_x := tile_x + float(posmod(x * 19 + y * 7, 47)) + 7.0
				var tuft_y := tile_y + float(posmod(y * 23 + x * 11, 43)) + 8.0
				draw_line(Vector2(tuft_x, tuft_y), Vector2(tuft_x - 3.0, tuft_y - 7.0), Color("#567052"), 2.0)
				draw_line(Vector2(tuft_x, tuft_y), Vector2(tuft_x + 4.0, tuft_y - 5.0), Color("#6b8057"), 2.0)
	_draw_path()

func _draw_path() -> void:
	var path_points := PackedVector2Array([
		Vector2(0, 270), Vector2(180, 292), Vector2(370, 335),
		Vector2(565, 390), Vector2(760, 410), Vector2(970, 380),
		Vector2(1280, 430)
	])
	draw_polyline(path_points, Color("#514d40"), 78.0, true)
	draw_polyline(path_points, Color("#69614c"), 64.0, true)
	for i in range(36):
		var px := float(posmod(i * 113 + 29, 1240))
		var py := 300.0 + sin(px * 0.006) * 75.0
		draw_circle(Vector2(px, py), 2.0 + float(i % 3), Color("#80755b"))

func _draw_ruins() -> void:
	_draw_stone_building(Vector2(825, 145), Vector2(170, 112))
	_draw_stone_building(Vector2(1035, 188), Vector2(112, 78))
	for i in range(7):
		var stone_pos := Vector2(725.0 + float(i * 27), 260.0 + sin(float(i)) * 18.0)
		draw_rect(Rect2(stone_pos, Vector2(22, 15)), Color("#65685a"))
		draw_rect(Rect2(stone_pos + Vector2(2, 2), Vector2(18, 3)), Color("#858473"))

func _draw_stone_building(pos: Vector2, size: Vector2) -> void:
	draw_rect(Rect2(pos + Vector2(5, 8), size), Color("#1b2924"))
	draw_rect(Rect2(pos, size), Color("#5c6055"))
	draw_rect(Rect2(pos + Vector2(7, 7), size - Vector2(14, 14)), Color("#444b43"))
	draw_rect(Rect2(pos + Vector2(15, 14), Vector2(size.x - 30, 5)), Color("#77786a"))
	for x in range(3, int(size.x / 24.0)):
		var block_pos := pos + Vector2(float(x * 24), 28.0)
		draw_line(block_pos, block_pos + Vector2(0, size.y - 36.0), Color("#303b34"), 2.0)
	draw_rect(Rect2(pos + Vector2(size.x * 0.42, size.y - 28.0), Vector2(25, 28)), Color("#252e28"))

func _draw_trees() -> void:
	var tree_positions: Array[Vector2] = [
		Vector2(75, 105), Vector2(155, 80), Vector2(260, 120), Vector2(365, 70),
		Vector2(485, 125), Vector2(600, 85), Vector2(710, 95), Vector2(1170, 95),
		Vector2(1210, 210), Vector2(80, 430), Vector2(175, 500), Vector2(300, 570),
		Vector2(440, 515), Vector2(570, 610), Vector2(690, 530), Vector2(930, 555),
		Vector2(1100, 505), Vector2(1210, 620), Vector2(45, 650), Vector2(1000, 80)
	]
	for tree_pos in tree_positions:
		_draw_tree(tree_pos)

func _draw_tree(pos: Vector2) -> void:
	draw_ellipse_shadow(pos + Vector2(4, 12), Vector2(30, 17))
	draw_rect(Rect2(pos - Vector2(7, 2), Vector2(14, 33)), Color("#493b2b"))
	draw_circle(pos + Vector2(0, -16), 29.0, Color("#1b3028"))
	draw_circle(pos + Vector2(-12, -23), 20.0, Color("#294334"))
	draw_circle(pos + Vector2(12, -29), 19.0, Color("#344d37"))
	draw_circle(pos + Vector2(-4, -36), 14.0, Color("#3d593c"))
	draw_circle(pos + Vector2(-11, -29), 5.0, Color("#526747"))

func draw_ellipse_shadow(center: Vector2, radius: Vector2) -> void:
	for i in range(5):
		var shrink := float(i) * 2.0
		draw_circle(center, maxf(radius.x - shrink, 1.0), Color(0.03, 0.05, 0.04, 0.09))

func _draw_player() -> void:
	draw_circle(player_position + Vector2(2, 15), 18.0, Color(0.02, 0.03, 0.025, 0.28))
	draw_circle(player_position + Vector2(0, 2), 14.0, Color("#283b36"))
	draw_circle(player_position + Vector2(0, -7), 9.0, Color("#c6ad8b"))
	draw_arc(player_position + Vector2(0, -7), 10.0, PI, TAU, 16, Color("#5b4335"), 4.0)
	var weapon_direction := move_vector.normalized() if move_vector.length_squared() > 0.01 else Vector2(1, 0)
	var weapon_start := player_position + weapon_direction * 9.0
	var weapon_end := player_position + weapon_direction * 27.0
	draw_line(weapon_start, weapon_end, Color("#b8c7c3"), 4.0)
	draw_line(weapon_start - Vector2(3, 3), weapon_start + Vector2(3, 3), Color("#8b6848"), 3.0
	)
	draw_circle(player_position + Vector2(-3, -10), 2.0, Color("#26332d"))

func _draw_hud() -> void:
	draw_rect(Rect2(22, 20, 340, 76), Color(0.035, 0.055, 0.05, 0.88))
	draw_rect(Rect2(22, 20, 4, 76), Color("#b98a51"))
	draw_string(ThemeDB.fallback_font, Vector2(42, 49), "ELDERVALE", HORIZONTAL_ALIGNMENT_LEFT, -1, 24, Color("#e7dfc8"))
	draw_string(ThemeDB.fallback_font, Vector2(43, 76), "THE ASHEN FRONTIER  •  PROTOTYPE", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("#aab5a1"))
	draw_rect(Rect2(WORLD_SIZE.x - 230, 22, 208, 54), Color(0.035, 0.055, 0.05, 0.82))
	draw_string(ThemeDB.fallback_font, Vector2(WORLD_SIZE.x - 211, 44), "FOUNDATION BUILD", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color("#d7c59f"))
	draw_string(ThemeDB.fallback_font, Vector2(WORLD_SIZE.x - 211, 62), "Move to explore", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("#aab5a1"))
	draw_circle(JOYSTICK_CENTER, JOYSTICK_RADIUS, Color(0.02, 0.035, 0.03, 0.45))
	draw_arc(JOYSTICK_CENTER, JOYSTICK_RADIUS, 0.0, TAU, 48, Color(0.75, 0.78, 0.68, 0.65), 2.0)
	var knob_position := JOYSTICK_CENTER + joystick_vector * (JOYSTICK_RADIUS * 0.58)
	draw_circle(knob_position, 25.0, Color(0.65, 0.68, 0.58, 0.76))
	draw_arc(knob_position, 25.0, 0.0, TAU, 32, Color("#d6d4bd"), 2.0)
