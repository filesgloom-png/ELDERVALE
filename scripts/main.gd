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
var player_max_hp := 100
var player_hp := 100
var player_level := 1
var player_xp := 0
var player_coins := 0
var kills := 0
var attack_cooldown := 0.0
var skill_cooldown := 0.0
var mob_attack_cooldown := 0.0
var weapon_tier := 0
var armor_tier := 0
var herbs := 0
var potions := 0
var relic_shards := 0
var weapon_enchant := 0
var armor_enchant := 0
var quest_reward_claimed := false
var second_quest_reward_claimed := false
var mobs: Array[Dictionary] = []
var loot_drops: Array[Dictionary] = []
var save_path := "user://eldervale_save.json"

func _ready() -> void:
	_spawn_initial_mobs()
	_load_progress()
	queue_redraw()

func _process(delta: float) -> void:
	elapsed += delta
	attack_cooldown = maxf(attack_cooldown - delta, 0.0)
	skill_cooldown = maxf(skill_cooldown - delta, 0.0)
	mob_attack_cooldown = maxf(mob_attack_cooldown - delta, 0.0)
	if Input.is_action_just_pressed("ui_accept"):
		_try_attack()
	_update_mobs(delta)
	_update_loot_drops(delta)
	var keyboard_vector := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := joystick_vector if joystick_vector.length_squared() > 0.001 else keyboard_vector
	move_vector = direction.limit_length(1.0)
	player_position += move_vector * PLAYER_SPEED * delta
	player_position.x = clampf(player_position.x, 36.0, WORLD_SIZE.x - 36.0)
	player_position.y = clampf(player_position.y, 70.0, WORLD_SIZE.y - 35.0)
	queue_redraw()

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_Q:
			_buy_weapon()
		elif event.keycode == KEY_E:
			_buy_armor()
		elif event.keycode == KEY_F:
			_try_skill()
		elif event.keycode == KEY_C:
			_craft_potion()
		elif event.keycode == KEY_R:
			_use_potion()
		elif event.keycode == KEY_Z:
			_craft_weapon_enchant()
		elif event.keycode == KEY_X:
			_craft_armor_enchant()
	if event is InputEventScreenTouch:
		if event.pressed and event.position.x < WORLD_SIZE.x * 0.48 and event.position.y > WORLD_SIZE.y * 0.48:
			joystick_active = true
			joystick_touch_index = event.index
			_update_joystick(event.position)
		elif event.pressed:
			_handle_action_touch(event.position)
		elif not event.pressed and event.index == joystick_touch_index:
			joystick_active = false
			joystick_touch_index = -1
			joystick_vector = Vector2.ZERO
	elif event is InputEventScreenDrag and event.index == joystick_touch_index:
		_update_joystick(event.position)

func _handle_action_touch(screen_position: Vector2) -> void:
	if screen_position.distance_to(_attack_button_center()) <= 58.0:
		_try_attack()
	elif screen_position.distance_to(_skill_button_center()) <= 58.0:
		_try_skill()
	elif screen_position.distance_to(_weapon_button_center()) <= 62.0:
		_buy_weapon()
	elif screen_position.distance_to(_armor_button_center()) <= 62.0:
		_buy_armor()
	elif screen_position.distance_to(_potion_button_center()) <= 58.0:
		if potions > 0:
			_use_potion()
		else:
			_craft_potion()
	elif screen_position.distance_to(_forge_weapon_button_center()) <= 55.0:
		_craft_weapon_enchant()
	elif screen_position.distance_to(_forge_armor_button_center()) <= 55.0:
		_craft_armor_enchant()

func _attack_button_center() -> Vector2:
	return Vector2(WORLD_SIZE.x - 100.0, WORLD_SIZE.y - 110.0)

func _skill_button_center() -> Vector2:
	return Vector2(WORLD_SIZE.x - 230.0, WORLD_SIZE.y - 110.0)

func _weapon_button_center() -> Vector2:
	return Vector2(WORLD_SIZE.x - 490.0, WORLD_SIZE.y - 92.0)

func _armor_button_center() -> Vector2:
	return Vector2(WORLD_SIZE.x - 350.0, WORLD_SIZE.y - 92.0)

func _potion_button_center() -> Vector2:
	return Vector2(650.0, WORLD_SIZE.y - 92.0)

func _forge_weapon_button_center() -> Vector2:
	return Vector2(135.0, 220.0)

func _forge_armor_button_center() -> Vector2:
	return Vector2(295.0, 220.0)

func _spawn_initial_mobs() -> void:
	mobs = [
		{"name": "Ash Wolf", "pos": Vector2(690, 330), "hp": 36, "max_hp": 36, "damage": 7, "speed": 52.0, "xp": 18, "alive": true},
		{"name": "Ash Wolf", "pos": Vector2(770, 475), "hp": 36, "max_hp": 36, "damage": 7, "speed": 52.0, "xp": 18, "alive": true},
		{"name": "Ruins Stalker", "pos": Vector2(555, 270), "hp": 54, "max_hp": 54, "damage": 10, "speed": 40.0, "xp": 28, "alive": true},
		{"name": "Ruins Stalker", "pos": Vector2(950, 300), "hp": 54, "max_hp": 54, "damage": 10, "speed": 40.0, "xp": 28, "alive": true},
		{"name": "Dusk Scavenger", "pos": Vector2(370, 445), "hp": 28, "max_hp": 28, "damage": 5, "speed": 66.0, "xp": 14, "alive": true}
	]

func _update_mobs(delta: float) -> void:
	for i in range(mobs.size()):
		var mob: Dictionary = mobs[i]
		if not mob["alive"]:
			var respawn_timer := float(mob.get("respawn_timer", 0.0)) - delta
			mob["respawn_timer"] = respawn_timer
			if respawn_timer <= 0.0:
				mob["alive"] = true
				mob["hp"] = mob["max_hp"]
				mob["pos"] = _mob_spawn_position(i)
				mob.erase("respawn_timer")
			mobs[i] = mob
			continue
		var mob_pos: Vector2 = mob["pos"]
		var to_player := player_position - mob_pos
		if to_player.length() < 310.0 and to_player.length() > 30.0:
			mob_pos += to_player.normalized() * float(mob["speed"]) * delta
			mob["pos"] = mob_pos
		elif to_player.length() <= 34.0 and mob_attack_cooldown <= 0.0:
			player_hp -= maxi(1, int(mob["damage"]) - armor_tier * 2 - armor_enchant * 2)
			mob_attack_cooldown = 1.0
			if player_hp <= 0:
				player_hp = player_max_hp
				player_position = WORLD_SIZE * 0.5
		mob["pos"] = mob_pos

func _try_attack() -> void:
	if attack_cooldown > 0.0:
		return
	attack_cooldown = 0.42
	var target_index := -1
	var closest_distance := 88.0
	for i in range(mobs.size()):
		var mob: Dictionary = mobs[i]
		if not mob["alive"]:
			continue
		var distance := player_position.distance_to(mob["pos"])
		if distance < closest_distance:
			closest_distance = distance
			target_index = i
	if target_index == -1:
		return
	var target: Dictionary = mobs[target_index]
	target["hp"] = int(target["hp"]) - (20 + weapon_tier * 8 + weapon_enchant * 4)
	if int(target["hp"]) <= 0:
		_defeat_mob(target)
	_save_progress()
	queue_redraw()

func _try_skill() -> void:
	if skill_cooldown > 0.0:
		return
	skill_cooldown = 5.0
	var hit_any := false
	for mob in mobs:
		if not mob["alive"]:
			continue
		if player_position.distance_to(mob["pos"]) <= 150.0:
			mob["hp"] = int(mob["hp"]) - (35 + weapon_tier * 5 + weapon_enchant * 3)
			hit_any = true
			if int(mob["hp"]) <= 0:
				_defeat_mob(mob)
	if hit_any:
		_save_progress()
	queue_redraw()

func _defeat_mob(mob: Dictionary) -> void:
	if not mob["alive"]:
		return
	mob["alive"] = false
	mob["respawn_timer"] = 8.0
	kills += 1
	_spawn_loot_drop(mob["pos"], "coins", 3 + player_level)
	_spawn_loot_drop(mob["pos"] + Vector2(-15, 8), "herbs", 1 + int(kills % 2))
	if int(mob["xp"]) >= 28:
		_spawn_loot_drop(mob["pos"] + Vector2(15, -8), "relic", 1)
	_gain_xp(int(mob["xp"]))
	if kills >= 3 and not quest_reward_claimed:
		quest_reward_claimed = true
		player_xp += 60
		player_coins += 25
		_process_level_ups()
	if kills >= 5 and not second_quest_reward_claimed:
		second_quest_reward_claimed = true
		player_xp += 100
		player_coins += 50
		_process_level_ups()
	_save_progress()

func _buy_weapon() -> void:
	var cost := 25 + weapon_tier * 35
	if weapon_tier >= 5 or player_coins < cost:
		return
	player_coins -= cost
	weapon_tier += 1
	_save_progress()
	queue_redraw()

func _buy_armor() -> void:
	var cost := 25 + armor_tier * 35
	if armor_tier >= 5 or player_coins < cost:
		return
	player_coins -= cost
	armor_tier += 1
	_save_progress()
	queue_redraw()

func _mob_spawn_position(index: int) -> Vector2:
	var spawn_positions: Array[Vector2] = [
		Vector2(690, 330), Vector2(770, 475), Vector2(555, 270),
		Vector2(950, 300), Vector2(370, 445)
	]
	return spawn_positions[index % spawn_positions.size()]

func _spawn_loot_drop(drop_position: Vector2, drop_type: String, amount: int) -> void:
	loot_drops.append({
		"type": drop_type,
		"amount": amount,
		"pos": drop_position,
		"life": 22.0
	})

func _update_loot_drops(delta: float) -> void:
	for i in range(loot_drops.size() - 1, -1, -1):
		var drop: Dictionary = loot_drops[i]
		drop["life"] = float(drop["life"]) - delta
		if player_position.distance_to(drop["pos"]) <= 42.0:
			var amount := int(drop["amount"])
			match String(drop["type"]):
				"coins":
					player_coins += amount
				"herbs":
					herbs += amount
				"relic":
					relic_shards += amount
			loot_drops.remove_at(i)
			_save_progress()
		elif float(drop["life"]) <= 0.0:
			loot_drops.remove_at(i)
		else:
			loot_drops[i] = drop

func _craft_weapon_enchant() -> void:
	if weapon_enchant >= 3 or relic_shards < 3 or herbs < 5:
		return
	relic_shards -= 3
	herbs -= 5
	weapon_enchant += 1
	_save_progress()
	queue_redraw()

func _craft_armor_enchant() -> void:
	if armor_enchant >= 3 or relic_shards < 2 or herbs < 5:
		return
	relic_shards -= 2
	herbs -= 5
	armor_enchant += 1
	_save_progress()
	queue_redraw()

func _craft_potion() -> void:
	if herbs < 3:
		return
	herbs -= 3
	potions += 1
	_save_progress()
	queue_redraw()

func _use_potion() -> void:
	if potions <= 0 or player_hp >= player_max_hp:
		return
	potions -= 1
	player_hp = mini(player_max_hp, player_hp + 45)
	_save_progress()
	queue_redraw()

func _gain_xp(amount: int) -> void:
	player_xp += amount
	_process_level_ups()

func _process_level_ups() -> void:
	while player_xp >= _xp_for_next_level():
		player_xp -= _xp_for_next_level()
		player_level += 1
		player_max_hp += 12
		player_hp = player_max_hp

func _xp_for_next_level() -> int:
	return 50 + (player_level - 1) * 35

func _save_progress() -> void:
	var data := {
		"level": player_level,
		"xp": player_xp,
		"coins": player_coins,
		"kills": kills,
		"quest_reward_claimed": quest_reward_claimed,
		"second_quest_reward_claimed": second_quest_reward_claimed,
		"weapon_tier": weapon_tier,
		"armor_tier": armor_tier,
		"herbs": herbs,
		"potions": potions,
		"relic_shards": relic_shards,
		"weapon_enchant": weapon_enchant,
		"armor_enchant": armor_enchant,
		"player_hp": player_hp,
		"player_max_hp": player_max_hp
	}
	var file := FileAccess.open(save_path, FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify(data))

func _load_progress() -> void:
	if not FileAccess.file_exists(save_path):
		return
	var file := FileAccess.open(save_path, FileAccess.READ)
	if file == null:
		return
	var parsed = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		return
	player_level = maxi(1, int(parsed.get("level", 1)))
	player_xp = maxi(0, int(parsed.get("xp", 0)))
	player_coins = maxi(0, int(parsed.get("coins", 0)))
	kills = maxi(0, int(parsed.get("kills", 0)))
	quest_reward_claimed = bool(parsed.get("quest_reward_claimed", false))
	second_quest_reward_claimed = bool(parsed.get("second_quest_reward_claimed", false))
	weapon_tier = clampi(int(parsed.get("weapon_tier", 0)), 0, 5)
	armor_tier = clampi(int(parsed.get("armor_tier", 0)), 0, 5)
	herbs = maxi(0, int(parsed.get("herbs", 0)))
	potions = maxi(0, int(parsed.get("potions", 0)))
	relic_shards = maxi(0, int(parsed.get("relic_shards", 0)))
	weapon_enchant = clampi(int(parsed.get("weapon_enchant", 0)), 0, 3)
	armor_enchant = clampi(int(parsed.get("armor_enchant", 0)), 0, 3)
	player_max_hp = maxi(100, int(parsed.get("player_max_hp", 100)))
	player_hp = clampi(int(parsed.get("player_hp", player_max_hp)), 1, player_max_hp)

func _update_joystick(screen_position: Vector2) -> void:
	var offset := screen_position - JOYSTICK_CENTER
	joystick_vector = (offset / JOYSTICK_RADIUS).limit_length(1.0)

func _draw() -> void:
	_draw_ground()
	_draw_ruins()
	_draw_trees()
	_draw_mobs()
	_draw_loot_drops()
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

func _draw_mobs() -> void:
	for mob in mobs:
		if not mob["alive"]:
			continue
		var mob_pos: Vector2 = mob["pos"]
		var is_wolf := String(mob["name"]) == "Ash Wolf"
		var body_color := Color("#8e6553") if is_wolf else (Color("#887d9c") if String(mob["name"]) == "Ruins Stalker" else Color("#a58a53"))
		draw_circle(mob_pos + Vector2(1, 10), 15.0, Color(0.02, 0.025, 0.02, 0.35))
		draw_circle(mob_pos, 13.0, body_color)
		draw_circle(mob_pos + Vector2(-4, -5), 4.0, body_color.lightened(0.22))
		draw_circle(mob_pos + Vector2(-4, -2), 2.0, Color("#e3b36b"))
		draw_circle(mob_pos + Vector2(4, -2), 2.0, Color("#e3b36b"))
		var bar_width := 34.0
		draw_rect(Rect2(mob_pos + Vector2(-bar_width / 2.0, -24), Vector2(bar_width, 4)), Color("#241e1d"))
		draw_rect(Rect2(mob_pos + Vector2(-bar_width / 2.0, -24), Vector2(bar_width * clampf(float(mob["hp"]) / float(mob["max_hp"]), 0.0, 1.0), 4)), Color("#b94d45"))
		draw_string(ThemeDB.fallback_font, mob_pos + Vector2(-27, -30), String(mob["name"]), HORIZONTAL_ALIGNMENT_LEFT, 70, 9, Color("#ded2bd"))

func _draw_loot_drops() -> void:
	for drop in loot_drops:
		var p: Vector2 = drop["pos"]
		var drop_type := String(drop["type"])
		var color := Color("#e0bd68") if drop_type == "coins" else (Color("#8fbd75") if drop_type == "herbs" else Color("#b58be0"))
		draw_circle(p + Vector2(0, 5), 9.0, Color(0.02, 0.025, 0.02, 0.32))
		draw_circle(p, 7.0, color)
		draw_arc(p, 7.0, 0.0, TAU, 20, color.lightened(0.45), 2.0)
		var glyph := "G" if drop_type == "coins" else ("H" if drop_type == "herbs" else "R")
		draw_string(ThemeDB.fallback_font, p + Vector2(-3, 3), glyph, HORIZONTAL_ALIGNMENT_LEFT, 8, 8, Color("#22231d"))

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
	draw_rect(Rect2(22, 20, 350, 106), Color(0.035, 0.055, 0.05, 0.9))
	draw_rect(Rect2(22, 20, 4, 106), Color("#b98a51"))
	draw_string(ThemeDB.fallback_font, Vector2(42, 49), "ELDERVALE  •  LV. %d" % player_level, HORIZONTAL_ALIGNMENT_LEFT, -1, 22, Color("#e7dfc8"))
	draw_string(ThemeDB.fallback_font, Vector2(43, 72), "HP  %d / %d" % [player_hp, player_max_hp], HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color("#e6a39a"))
	draw_rect(Rect2(43, 80, 300, 8), Color("#392b2b"))
	draw_rect(Rect2(43, 80, 300.0 * float(player_hp) / float(player_max_hp), 8), Color("#b84d46"))
	draw_string(ThemeDB.fallback_font, Vector2(43, 108), "XP %d / %d     COINS %d" % [player_xp, _xp_for_next_level(), player_coins], HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("#d7c59f"))
	draw_rect(Rect2(WORLD_SIZE.x - 310, 22, 288, 116), Color(0.035, 0.055, 0.05, 0.9))
	draw_string(ThemeDB.fallback_font, Vector2(WORLD_SIZE.x - 291, 45), "QUEST I: ASHEN FRONTIER", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color("#d7c59f"))
	draw_string(ThemeDB.fallback_font, Vector2(WORLD_SIZE.x - 291, 65), "Defeat 3: %d / 3" % mini(kills, 3), HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("#c5cfba"))
	draw_string(ThemeDB.fallback_font, Vector2(WORLD_SIZE.x - 291, 82), "60 XP + 25 coins" if not quest_reward_claimed else "Reward claimed", HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color("#aab5a1"))
	draw_string(ThemeDB.fallback_font, Vector2(WORLD_SIZE.x - 291, 103), "QUEST II: HUNT 5  %d / 5" % mini(kills, 5), HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color("#d7c59f"))
	draw_string(ThemeDB.fallback_font, Vector2(WORLD_SIZE.x - 291, 123), "100 XP + 50 coins" if not second_quest_reward_claimed else "Reward claimed", HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color("#aab5a1"))
	draw_circle(JOYSTICK_CENTER, JOYSTICK_RADIUS, Color(0.02, 0.035, 0.03, 0.45))
	draw_arc(JOYSTICK_CENTER, JOYSTICK_RADIUS, 0.0, TAU, 48, Color(0.75, 0.78, 0.68, 0.65), 2.0)
	var knob_position := JOYSTICK_CENTER + joystick_vector * (JOYSTICK_RADIUS * 0.58)
	draw_circle(knob_position, 25.0, Color(0.65, 0.68, 0.58, 0.76))
	draw_arc(knob_position, 25.0, 0.0, TAU, 32, Color("#d6d4bd"), 2.0)
	var weapon_center := _weapon_button_center()
	draw_rect(Rect2(weapon_center - Vector2(58, 30), Vector2(116, 60)), Color(0.12, 0.16, 0.13, 0.88))
	draw_rect(Rect2(weapon_center - Vector2(58, 30), Vector2(116, 60)), Color("#a6b68e"), false, 2.0)
	draw_string(ThemeDB.fallback_font, weapon_center + Vector2(-49, -2), "WEAPON Q", HORIZONTAL_ALIGNMENT_LEFT, 100, 12, Color("#e7dfc8"))
	draw_string(ThemeDB.fallback_font, weapon_center + Vector2(-49, 15), "T%d  %dG" % [weapon_tier, 25 + weapon_tier * 35], HORIZONTAL_ALIGNMENT_LEFT, 100, 11, Color("#d7c59f"))
	var armor_center := _armor_button_center()
	draw_rect(Rect2(armor_center - Vector2(58, 30), Vector2(116, 60)), Color(0.12, 0.16, 0.13, 0.88))
	draw_rect(Rect2(armor_center - Vector2(58, 30), Vector2(116, 60)), Color("#a6b68e"), false, 2.0)
	draw_string(ThemeDB.fallback_font, armor_center + Vector2(-49, -2), "ARMOR E", HORIZONTAL_ALIGNMENT_LEFT, 100, 12, Color("#e7dfc8"))
	draw_string(ThemeDB.fallback_font, armor_center + Vector2(-49, 15), "T%d  %dG" % [armor_tier, 25 + armor_tier * 35], HORIZONTAL_ALIGNMENT_LEFT, 100, 11, Color("#d7c59f"))
	var skill_center := _skill_button_center()
	draw_circle(skill_center, 45.0, Color(0.17, 0.23, 0.28, 0.82))
	draw_arc(skill_center, 45.0, 0.0, TAU, 48, Color("#8eb6c5"), 3.0)
	draw_string(ThemeDB.fallback_font, skill_center + Vector2(-25, 4), "SKILL", HORIZONTAL_ALIGNMENT_LEFT, 70, 14, Color("#d7e8ed"))
	var attack_center := _attack_button_center()
	draw_circle(attack_center, 52.0, Color(0.28, 0.12, 0.10, 0.72))
	draw_arc(attack_center, 52.0, 0.0, TAU, 48, Color("#d8a66d"), 3.0)
	draw_string(ThemeDB.fallback_font, attack_center + Vector2(-28, 5), "ATTACK", HORIZONTAL_ALIGNMENT_LEFT, 80, 15, Color("#f0dfc4"))
	draw_string(ThemeDB.fallback_font, Vector2(42, 144), "ARMOR reduces damage • SKILL cooldown %.1fs" % skill_cooldown, HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color("#c5cfba"))
	draw_string(ThemeDB.fallback_font, Vector2(42, 164), "HERBS %d   POTIONS %d   RELIC SHARDS %d" % [herbs, potions, relic_shards], HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("#c5cfba"))
	var forge_weapon_center := _forge_weapon_button_center()
	draw_rect(Rect2(forge_weapon_center - Vector2(67, 23), Vector2(134, 46)), Color(0.16, 0.13, 0.09, 0.92))
	draw_rect(Rect2(forge_weapon_center - Vector2(67, 23), Vector2(134, 46)), Color("#c49a62"), false, 2.0)
	draw_string(ThemeDB.fallback_font, forge_weapon_center + Vector2(-59, -2), "FORGE WPN Z", HORIZONTAL_ALIGNMENT_LEFT, 120, 11, Color("#f0dfc4"))
	draw_string(ThemeDB.fallback_font, forge_weapon_center + Vector2(-59, 14), "+%d  3 shards/5 herbs" % weapon_enchant, HORIZONTAL_ALIGNMENT_LEFT, 125, 9, Color("#d7c59f"))
	var forge_armor_center := _forge_armor_button_center()
	draw_rect(Rect2(forge_armor_center - Vector2(67, 23), Vector2(134, 46)), Color(0.12, 0.15, 0.19, 0.92))
	draw_rect(Rect2(forge_armor_center - Vector2(67, 23), Vector2(134, 46)), Color("#8eb6c5"), false, 2.0)
	draw_string(ThemeDB.fallback_font, forge_armor_center + Vector2(-59, -2), "FORGE ARM X", HORIZONTAL_ALIGNMENT_LEFT, 120, 11, Color("#d7e8ed"))
	draw_string(ThemeDB.fallback_font, forge_armor_center + Vector2(-59, 14), "+%d  2 shards/5 herbs" % armor_enchant, HORIZONTAL_ALIGNMENT_LEFT, 125, 9, Color("#c5d8df"))
	var potion_center := _potion_button_center()
	draw_rect(Rect2(potion_center - Vector2(60, 30), Vector2(120, 60)), Color(0.13, 0.18, 0.12, 0.9))
	draw_rect(Rect2(potion_center - Vector2(60, 30), Vector2(120, 60)), Color("#9fc18b"), false, 2.0)
	draw_string(ThemeDB.fallback_font, potion_center + Vector2(-48, -2), "POTION C/R", HORIZONTAL_ALIGNMENT_LEFT, 105, 12, Color("#e7dfc8"))
	draw_string(ThemeDB.fallback_font, potion_center + Vector2(-48, 15), "x%d / 3 herbs" % potions, HORIZONTAL_ALIGNMENT_LEFT, 105, 11, Color("#d7c59f"))
