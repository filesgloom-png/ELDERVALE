extends Node2D

const WORLD_SIZE := Vector2(1280.0, 720.0)
const JOYSTICK_CENTER := Vector2(112.0, 600.0)
const JOYSTICK_RADIUS := 68.0
const PLAYER_SPEED := 245.0
const CLASS_DATA := [
	{"name": "Warrior", "specs": ["Warden", "Weaponmaster", "Champion"], "damage": 1.08, "crit": 0.0, "armor": 2, "skill": 1.0, "range": 88.0, "kill_heal": 0, "dodge_cd": 2.8},
	{"name": "Berserker", "specs": ["Reaver", "Bloodfury", "Juggernaut"], "damage": 1.12, "crit": 0.0, "armor": 0, "skill": 1.0, "range": 88.0, "kill_heal": 0, "dodge_cd": 2.8},
	{"name": "Assassin", "specs": ["Shadow", "Executioner", "Phantom"], "damage": 1.0, "crit": 0.08, "armor": 0, "skill": 1.0, "range": 88.0, "kill_heal": 0, "dodge_cd": 2.5},
	{"name": "Ranger", "specs": ["Pathfinder", "Beastmaster", "Deadeye"], "damage": 1.0, "crit": 0.03, "armor": 0, "skill": 1.0, "range": 108.0, "kill_heal": 0, "dodge_cd": 2.8},
	{"name": "Mage", "specs": ["Elementalist", "Spellblade", "Archmage"], "damage": 1.0, "crit": 0.0, "armor": 0, "skill": 1.25, "range": 88.0, "kill_heal": 0, "dodge_cd": 2.8},
	{"name": "Necromancer", "specs": ["Lich", "Soulweaver", "Gravecaller"], "damage": 1.0, "crit": 0.0, "armor": 0, "skill": 1.1, "range": 88.0, "kill_heal": 6, "dodge_cd": 2.8},
	{"name": "Paladin", "specs": ["Inquisitor", "Justicar", "Sunkeeper"], "damage": 1.04, "crit": 0.0, "armor": 3, "skill": 1.0, "range": 88.0, "kill_heal": 3, "dodge_cd": 2.8},
	{"name": "Druid", "specs": ["Shapebinder", "Stormcaller", "Grovekeeper"], "damage": 1.0, "crit": 0.0, "armor": 1, "skill": 1.15, "range": 88.0, "kill_heal": 4, "dodge_cd": 2.8},
	{"name": "Monk", "specs": ["Way of the Fist", "Way of the Gale", "Way of Balance"], "damage": 1.06, "crit": 0.03, "armor": 1, "skill": 1.0, "range": 88.0, "kill_heal": 0, "dodge_cd": 2.0},
	{"name": "Engineer", "specs": ["Tinkerer", "Artillerist", "Aegis Smith"], "damage": 1.05, "crit": 0.0, "armor": 1, "skill": 1.08, "range": 88.0, "kill_heal": 0, "dodge_cd": 2.8}
]

var player_position: Vector2 = WORLD_SIZE * 0.5
var move_vector: Vector2 = Vector2.ZERO
var joystick_vector: Vector2 = Vector2.ZERO
var joystick_active := false
var joystick_touch_index := -1
var elapsed := 0.0
var player_max_hp := 100
var player_hp := 100
var player_level := 1
var player_class_index := 0
var specialization_index := 0
var talent_points := 0
var talent_ranks: Array[int] = [0, 0, 0]
var player_xp := 0
var player_coins := 0
var kills := 0
var attack_cooldown := 0.0
var skill_cooldown := 0.0
var mob_attack_cooldown := 0.0
var player_hit_flash := 0.0
var dodge_time := 0.0
var dodge_cooldown := 0.0
var dodge_direction: Vector2 = Vector2.RIGHT
var critical_flash := 0.0
var combo_count := 0
var combo_timer := 0.0
var weapon_tier := 0
var armor_tier := 0
var herbs := 0
var potions := 0
var relic_shards := 0
var guardian_cores := 0
var ancient_caches := 0
var weapon_enchant := 0
var armor_enchant := 0
var quest_reward_claimed := false
var second_quest_reward_claimed := false
var guardian_defeated := false
var mobs: Array[Dictionary] = []
var loot_drops: Array[Dictionary] = []
var floating_messages: Array[Dictionary] = []
var combat_effects: Array[Dictionary] = []
var hit_flash_timers: Dictionary = {}
var save_path := "user://eldervale_save.json"

func _ready() -> void:
	_spawn_initial_mobs()
	_load_progress()
	_ensure_guardian_encounter()
	queue_redraw()

func _process(delta: float) -> void:
	elapsed += delta
	player_hit_flash = maxf(player_hit_flash - delta, 0.0)
	dodge_time = maxf(dodge_time - delta, 0.0)
	dodge_cooldown = maxf(dodge_cooldown - delta, 0.0)
	critical_flash = maxf(critical_flash - delta, 0.0)
	combo_timer = maxf(combo_timer - delta, 0.0)
	if combo_timer <= 0.0:
		combo_count = 0
	attack_cooldown = maxf(attack_cooldown - delta, 0.0)
	skill_cooldown = maxf(skill_cooldown - delta, 0.0)
	mob_attack_cooldown = maxf(mob_attack_cooldown - delta, 0.0)
	if Input.is_action_just_pressed("ui_accept"):
		_try_attack()
	_update_mobs(delta)
	_update_loot_drops(delta)
	_update_floating_messages(delta)
	_update_combat_effects(delta)
	var keyboard_vector := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := joystick_vector if joystick_vector.length_squared() > 0.001 else keyboard_vector
	move_vector = direction.limit_length(1.0)
	if dodge_time > 0.0:
		player_position += dodge_direction * 560.0 * delta
	else:
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
		elif event.keycode == KEY_V:
			_try_dodge()
		elif event.keycode == KEY_TAB:
			_cycle_class()
		elif event.keycode == KEY_G:
			_cycle_specialization()
		elif event.keycode == KEY_1:
			_spend_talent(0)
		elif event.keycode == KEY_2:
			_spend_talent(1)
		elif event.keycode == KEY_3:
			_spend_talent(2)
	if event is InputEventScreenTouch:
		if event.pressed and event.position.distance_to(JOYSTICK_CENTER) <= JOYSTICK_RADIUS * 1.65:
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
	for branch in range(3):
		if screen_position.distance_to(_talent_button_center(branch)) <= 68.0:
			_spend_talent(branch)
			return
	if screen_position.distance_to(_class_button_center()) <= 76.0:
		_cycle_class()
	elif screen_position.distance_to(_specialization_button_center()) <= 76.0:
		_cycle_specialization()
	elif screen_position.distance_to(_attack_button_center()) <= 58.0:
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
	elif screen_position.distance_to(_dodge_button_center()) <= 50.0:
		_try_dodge()

func _class_button_center() -> Vector2:
	return Vector2(640.0, 242.0)

func _specialization_button_center() -> Vector2:
	return Vector2(640.0, 302.0)

func _current_class_data() -> Dictionary:
	return CLASS_DATA[clampi(player_class_index, 0, CLASS_DATA.size() - 1)]

func _current_specialization_data() -> Dictionary:
	var class_data := _current_class_data()
	var spec_name := String((class_data["specs"] as Array)[specialization_index])
	var data := {"damage": 1.0, "crit": 0.0, "armor": 0, "skill": 1.0, "range": 0.0, "heal": 0, "dodge_cd": 0.0, "cooldown": 0.0}
	match spec_name:
		"Warden":
			data["armor"] = 2
			data["heal"] = 2
		"Weaponmaster":
			data["damage"] = 1.12
			data["cooldown"] = -0.25
		"Champion":
			data["damage"] = 1.08
			data["skill"] = 1.15
		"Reaver":
			data["damage"] = 1.15
		"Bloodfury":
			data["damage"] = 1.22 if float(player_hp) / float(player_max_hp) <= 0.5 else 1.0
			data["heal"] = 2
		"Juggernaut":
			data["armor"] = 4
			data["skill"] = 0.9
		"Shadow":
			data["crit"] = 0.10
			data["dodge_cd"] = -0.55
		"Executioner":
			data["damage"] = 1.2
			data["crit"] = 0.04
		"Phantom":
			data["dodge_cd"] = -0.8
			data["skill"] = 1.15
		"Pathfinder":
			data["range"] = 28.0
			data["dodge_cd"] = -0.25
		"Beastmaster":
			data["heal"] = 3
			data["skill"] = 1.1
		"Deadeye":
			data["crit"] = 0.12
			data["range"] = 12.0
		"Elementalist":
			data["skill"] = 1.4
			data["cooldown"] = 0.8
		"Spellblade":
			data["damage"] = 1.12
			data["skill"] = 1.12
		"Archmage":
			data["skill"] = 1.55
			data["cooldown"] = 1.4
		"Lich":
			data["skill"] = 1.22
			data["heal"] = 5
		"Soulweaver":
			data["heal"] = 10
			data["armor"] = 1
		"Gravecaller":
			data["skill"] = 1.28
			data["cooldown"] = -0.4
		"Inquisitor":
			data["damage"] = 1.16
			data["skill"] = 1.12
		"Justicar":
			data["armor"] = 5
			data["heal"] = 4
		"Sunkeeper":
			data["skill"] = 1.3
			data["heal"] = 3
		"Shapebinder":
			data["armor"] = 2
			data["damage"] = 1.08
		"Stormcaller":
			data["skill"] = 1.35
			data["crit"] = 0.03
		"Grovekeeper":
			data["heal"] = 8
			data["armor"] = 1
		"Way of the Fist":
			data["damage"] = 1.15
			data["cooldown"] = -0.4
		"Way of the Gale":
			data["dodge_cd"] = -0.9
			data["crit"] = 0.06
		"Way of Balance":
			data["armor"] = 2
			data["heal"] = 4
		"Tinkerer":
			data["cooldown"] = -0.8
			data["skill"] = 1.12
		"Artillerist":
			data["skill"] = 1.42
			data["range"] = 10.0
		"Aegis Smith":
			data["armor"] = 3
			data["heal"] = 2
	return data

func _current_talent_bonus() -> Dictionary:
	return {
		"damage": 1.0 + float(talent_ranks[0]) * 0.05,
		"armor": talent_ranks[1] * 1,
		"skill": 1.0 + float(talent_ranks[2]) * 0.06,
		"crit": float(talent_ranks[0]) * 0.005,
		"heal": talent_ranks[2]
	}

func _spend_talent(branch: int) -> void:
	if talent_points <= 0 or branch < 0 or branch >= talent_ranks.size() or talent_ranks[branch] >= 5:
		_add_floating_message("NO TALENT POINTS / MAX RANK", player_position + Vector2(0, -56), Color("#e6b2a5"))
		return
	talent_points -= 1
	talent_ranks[branch] += 1
	_add_floating_message("TALENT RANK %d" % talent_ranks[branch], player_position + Vector2(0, -58), Color("#b8e8a0"))
	_save_progress()
	queue_redraw()

func _talent_button_center(branch: int) -> Vector2:
	return Vector2(430.0 + float(branch) * 145.0, 390.0)

func _cycle_class() -> void:
	player_class_index = (player_class_index + 1) % CLASS_DATA.size()
	specialization_index = 0
	var class_data := _current_class_data()
	_add_floating_message("CLASS: %s" % String(class_data["name"]), player_position + Vector2(0, -72), Color("#c6b4f2"))
	_save_progress()
	queue_redraw()

func _cycle_specialization() -> void:
	var class_data := _current_class_data()
	var specs: Array = class_data["specs"]
	specialization_index = (specialization_index + 1) % specs.size()
	_add_floating_message("SPEC: %s" % String(specs[specialization_index]), player_position + Vector2(0, -72), Color("#c6b4f2"))
	_save_progress()
	queue_redraw()

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

func _dodge_button_center() -> Vector2:
	return Vector2(WORLD_SIZE.x - 220.0, WORLD_SIZE.y - 250.0)

func _try_dodge() -> void:
	if dodge_cooldown > 0.0 or dodge_time > 0.0:
		return
	var desired_direction := joystick_vector if joystick_vector.length_squared() > 0.001 else move_vector
	if desired_direction.length_squared() <= 0.001:
		var nearest_direction := Vector2.ZERO
		var nearest_distance := INF
		for mob in mobs:
			if not bool(mob.get("alive", false)):
				continue
			var distance := player_position.distance_to(Vector2(mob["pos"]))
			if distance < nearest_distance:
				nearest_distance = distance
				nearest_direction = player_position - Vector2(mob["pos"])
		desired_direction = nearest_direction
	if desired_direction.length_squared() <= 0.001:
		desired_direction = Vector2.RIGHT
	dodge_direction = desired_direction.normalized()
	dodge_time = 0.42
	var spec_data := _current_specialization_data()
	dodge_cooldown = maxf(0.8, float(_current_class_data().get("dodge_cd", 2.8)) + float(spec_data.get("dodge_cd", 0.0)))
	combat_effects.append({"kind": "dodge", "pos": player_position, "dir": dodge_direction, "life": 0.30, "duration": 0.30})
	_add_floating_message("DODGE!", player_position + Vector2(0, -48), Color("#9fe6ef"))
	queue_redraw()

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
			if bool(mob.get("boss", false)):
				mobs[i] = mob
				continue
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
		var hit_flash := maxf(float(mob.get("hit_flash", 0.0)) - delta, 0.0)
		if hit_flash > 0.0:
			mob["hit_flash"] = hit_flash
		else:
			mob.erase("hit_flash")
		var to_player := player_position - mob_pos
		var distance_to_player := to_player.length()
		var mob_name := String(mob["name"])
		var attack_range := 34.0
		var windup_duration := 0.42
		if mob_name == "Ruins Stalker":
			attack_range = 66.0
			windup_duration = 0.72
		elif mob_name == "Ruin Guardian":
			attack_range = 58.0
			windup_duration = 0.92
		var local_attack_cooldown := maxf(float(mob.get("attack_cooldown", 0.0)) - delta, 0.0)
		mob["attack_cooldown"] = local_attack_cooldown
		if mob_name == "Ruin Guardian":
			var guardian_enraged := float(mob["hp"]) <= float(mob["max_hp"]) * 0.5
			var cooldown_rate := 1.35 if guardian_enraged else 1.0
			var slam_cooldown := maxf(float(mob.get("slam_cooldown", 0.0)) - delta * cooldown_rate, 0.0)
			var slam_windup := float(mob.get("slam_windup", 0.0))
			if slam_windup > 0.0:
				slam_windup = maxf(slam_windup - delta, 0.0)
				mob["slam_windup"] = slam_windup
				if slam_windup <= 0.0:
					if player_position.distance_to(mob_pos) <= 112.0:
						combat_effects.append({"kind": "pulse", "pos": mob_pos, "life": 0.42, "duration": 0.42})
						if dodge_time > 0.0:
							_add_floating_message("SLAM DODGED!", player_position + Vector2(0, -52), Color("#9fe6ef"))
						else:
							var class_armor_bonus := int(_current_class_data().get("armor", 0)) + int(_current_specialization_data().get("armor", 0)) + int(_current_talent_bonus()["armor"])
						var slam_damage := maxi(1, (34 if guardian_enraged else 28) - armor_tier * 2 - armor_enchant * 2 - class_armor_bonus)
							player_hp -= slam_damage
							player_hit_flash = 0.28
							_add_floating_message("SLAM -%d" % slam_damage, player_position + Vector2(0, -52), Color("#ff8d69"))
							if player_hp <= 0:
								player_hp = player_max_hp
								player_position = WORLD_SIZE * 0.5
				mob["slam_cooldown"] = 4.8
			elif distance_to_player <= 180.0 and slam_cooldown <= 0.0:
				mob["slam_windup"] = 0.82 if guardian_enraged else 1.15
				mob["slam_cooldown"] = 4.8
			else:
				mob["slam_cooldown"] = slam_cooldown
		var attack_windup := float(mob.get("attack_windup", 0.0))
		if distance_to_player < 310.0 and distance_to_player > attack_range:
			var movement_direction := to_player.normalized()
			if mob_name == "Dusk Scavenger" and distance_to_player < 135.0:
				movement_direction = movement_direction.rotated(sin(elapsed * 2.8 + float(i)) * 0.72)
			var move_speed := float(mob["speed"])
			if mob_name == "Ash Wolf":
				var pounce_cooldown := maxf(float(mob.get("pounce_cooldown", 0.0)) - delta, 0.0)
				if distance_to_player >= 62.0 and distance_to_player <= 150.0 and pounce_cooldown <= 0.0:
					move_speed *= 3.4
					mob["pounce_cooldown"] = 2.6
					mob["pounce_flash"] = 0.28
				else:
					mob["pounce_cooldown"] = pounce_cooldown
					mob["pounce_flash"] = maxf(float(mob.get("pounce_flash", 0.0)) - delta, 0.0)
			mob_pos += movement_direction * move_speed * delta
			mob["attack_windup"] = 0.0
		elif distance_to_player <= attack_range:
			if attack_windup > 0.0:
				attack_windup = maxf(attack_windup - delta, 0.0)
				mob["attack_windup"] = attack_windup
				if attack_windup <= 0.0:
					if dodge_time > 0.0:
						_add_floating_message("DODGED!", player_position + Vector2(0, -42), Color("#9fe6ef"))
					else:
						var class_armor_bonus := int(_current_class_data().get("armor", 0)) + int(_current_specialization_data().get("armor", 0)) + int(_current_talent_bonus()["armor"])
						var incoming_damage := maxi(1, int(mob["damage"]) - armor_tier * 2 - armor_enchant * 2 - class_armor_bonus)
						player_hp -= incoming_damage
						player_hit_flash = 0.22
						_add_floating_message("-%d" % incoming_damage, player_position + Vector2(0, -35), Color("#f28f82"))
						if player_hp <= 0:
							player_hp = player_max_hp
							player_position = WORLD_SIZE * 0.5
					mob["attack_cooldown"] = 0.85 if mob_name != "Ruin Guardian" else 1.25
			elif local_attack_cooldown <= 0.0:
				mob["attack_windup"] = windup_duration
		else:
			mob["attack_windup"] = 0.0
		mob["pos"] = mob_pos
		mobs[i] = mob

func _try_attack() -> void:
	if attack_cooldown > 0.0:
		return
	attack_cooldown = 0.42
	var target_index := -1
	var spec_data := _current_specialization_data()
	var closest_distance := float(_current_class_data().get("range", 88.0)) + float(spec_data.get("range", 0.0))
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
	combo_count += 1
	combo_timer = 1.65
	if combo_count == 3:
		_add_floating_message("COMBO x3! +15%", player_position + Vector2(0, -68), Color("#b8e8a0"))
	elif combo_count == 5:
		_add_floating_message("COMBO x5! +35%", player_position + Vector2(0, -68), Color("#ffd56f"))
	var slash_direction := (Vector2(target["pos"]) - player_position).normalized()
	combat_effects.append({"kind": "slash", "pos": player_position, "dir": slash_direction, "life": 0.20, "duration": 0.20})
	var class_data := _current_class_data()
	var spec_data := _current_specialization_data()
	var talent_bonus := _current_talent_bonus()
	var damage := int(round(float(20 + weapon_tier * 8 + weapon_enchant * 4) * float(class_data.get("damage", 1.0)) * float(spec_data.get("damage", 1.0)) * float(talent_bonus["damage"])))
	if String(class_data["name"]) == "Berserker" and float(player_hp) / float(player_max_hp) <= 0.4:
		damage = int(round(float(damage) * 1.25))
	var combo_bonus := 0.35 if combo_count >= 5 else (0.15 if combo_count >= 3 else 0.0)
	damage = int(round(float(damage) * (1.0 + combo_bonus)))
	var critical_chance := minf(0.08 + float(weapon_enchant) * 0.04 + float(class_data.get("crit", 0.0)) + float(spec_data.get("crit", 0.0)) + float(talent_bonus["crit"]), 0.38)
	var is_critical := randf() < critical_chance
	if is_critical:
		damage = int(round(float(damage) * 1.75))
		critical_flash = 0.24
		combat_effects.append({"kind": "critical", "pos": Vector2(target["pos"]), "life": 0.34, "duration": 0.34})
		_add_floating_message("CRITICAL! -%d" % damage, Vector2(target["pos"]) + Vector2(0, -52), Color("#ffd56f"))
	else:
		_add_floating_message("-%d" % damage, Vector2(target["pos"]) + Vector2(0, -36), Color("#f2b0a0"))
	target["hp"] = int(target["hp"]) - damage
	target["hit_flash"] = 0.18
	combat_effects.append({"kind": "hit", "pos": Vector2(target["pos"]), "life": 0.18, "duration": 0.18})
	if int(target["hp"]) <= 0:
		_defeat_mob(target)
	_save_progress()
	queue_redraw()

func _try_skill() -> void:
	if skill_cooldown > 0.0:
		return
	var class_data := _current_class_data()
	var spec_data := _current_specialization_data()
	skill_cooldown = maxf(1.8, 5.0 + float(spec_data.get("cooldown", 0.0)) - float(talent_ranks[2]) * 0.12)
	combat_effects.append({"kind": "pulse", "pos": player_position, "life": 0.34, "duration": 0.34})
	var hit_any := false
	for mob in mobs:
		if not mob["alive"]:
			continue
		if player_position.distance_to(mob["pos"]) <= 150.0:
			var talent_bonus := _current_talent_bonus()
			var damage := int(round(float(35 + weapon_tier * 5 + weapon_enchant * 3) * float(class_data.get("skill", 1.0)) * float(spec_data.get("skill", 1.0)) * float(talent_bonus["skill"])))
			var critical_chance := minf(0.05 + float(weapon_enchant) * 0.03 + float(class_data.get("crit", 0.0)) * 0.5, 0.24)
			var is_critical := randf() < critical_chance
			if is_critical:
				damage = int(round(float(damage) * 1.5))
				critical_flash = 0.24
				combat_effects.append({"kind": "critical", "pos": Vector2(mob["pos"]), "life": 0.34, "duration": 0.34})
				_add_floating_message("SKILL CRIT! -%d" % damage, Vector2(mob["pos"]) + Vector2(0, -52), Color("#ffd56f"))
			else:
				_add_floating_message("-%d" % damage, Vector2(mob["pos"]) + Vector2(0, -36), Color("#a8d8ef"))
			mob["hp"] = int(mob["hp"]) - damage
			mob["hit_flash"] = 0.18
			combat_effects.append({"kind": "hit", "pos": Vector2(mob["pos"]), "life": 0.18, "duration": 0.18})
			hit_any = true
			if int(mob["hp"]) <= 0:
				_defeat_mob(mob)
	if hit_any:
		_save_progress()
	queue_redraw()

func _defeat_mob(mob: Dictionary) -> void:
	if not mob["alive"]:
		return
	var is_boss := bool(mob.get("boss", false))
	mob["alive"] = false
	if not is_boss:
		mob["respawn_timer"] = 8.0
	else:
		guardian_defeated = true
	kills += 1
	_spawn_loot_drop(mob["pos"], "coins", (35 + player_level * 3) if is_boss else (3 + player_level))
	_spawn_loot_drop(mob["pos"] + Vector2(-15, 8), "herbs", 1 + int(kills % 2))
	if int(mob["xp"]) >= 28:
		_spawn_loot_drop(mob["pos"] + Vector2(15, -8), "relic", 4 if is_boss else 1)
	if is_boss:
		_spawn_loot_drop(mob["pos"] + Vector2(-26, -18), "guardian_core", 1)
		_spawn_loot_drop(mob["pos"] + Vector2(26, -18), "ancient_cache", 1)
		_add_floating_message("GUARDIAN DEFEATED!", mob["pos"] + Vector2(0, -74), Color("#ffd28b"))
	_gain_xp(int(mob["xp"]))
	if not is_boss:
		_ensure_guardian_encounter()
	var class_kill_heal := int(_current_class_data().get("kill_heal", 0)) + int(_current_specialization_data().get("heal", 0)) + int(_current_talent_bonus()["heal"])
	if class_kill_heal > 0:
		player_hp = mini(player_max_hp, player_hp + class_kill_heal)
		_add_floating_message("CLASS HEAL +%d" % class_kill_heal, player_position + Vector2(0, -46), Color("#a8e6a0"))
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

func _ensure_guardian_encounter() -> void:
	if kills < 5 or guardian_defeated:
		return
	for mob in mobs:
		if String(mob["name"]) == "Ruin Guardian":
			return
	mobs.append({
		"name": "Ruin Guardian",
		"pos": Vector2(1010, 235),
		"hp": 240,
		"max_hp": 240,
		"damage": 17,
		"speed": 29.0,
		"xp": 120,
		"alive": true,
		"boss": true
	})
	_add_floating_message("RUIN GUARDIAN AWAKENS", Vector2(WORLD_SIZE.x * 0.5, 190), Color("#c7a5ff"))

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
			var label := ""
			var message_color := Color("#e0bd68")
			match String(drop["type"]):
				"coins":
					player_coins += amount
					label = "+%d COINS" % amount
					message_color = Color("#e0bd68")
				"herbs":
					herbs += amount
					label = "+%d HERBS" % amount
					message_color = Color("#a8d48a")
				"relic":
					relic_shards += amount
					label = "+%d RELIC SHARD" % amount
					message_color = Color("#c6a0ef")
				"guardian_core":
					guardian_cores += amount
					label = "ANCIENT CORE ACQUIRED"
					message_color = Color("#ff9877")
				"ancient_cache":
					ancient_caches += amount
					label = "ANCIENT CACHE ACQUIRED"
					message_color = Color("#e7d49a")
			_add_floating_message(label, player_position + Vector2(0, -42), message_color)
			loot_drops.remove_at(i)
			_save_progress()
		elif float(drop["life"]) <= 0.0:
			loot_drops.remove_at(i)
		else:
			loot_drops[i] = drop

func _update_combat_effects(delta: float) -> void:
	for i in range(combat_effects.size() - 1, -1, -1):
		var effect: Dictionary = combat_effects[i]
		effect["life"] = float(effect["life"]) - delta
		if float(effect["life"]) <= 0.0:
			combat_effects.remove_at(i)
		else:
			combat_effects[i] = effect

func _add_floating_message(message: String, message_position: Vector2, message_color: Color) -> void:
	floating_messages.append({
		"text": message,
		"pos": message_position,
		"color": message_color,
		"life": 1.25
	})

func _update_floating_messages(delta: float) -> void:
	for i in range(floating_messages.size() - 1, -1, -1):
		var message: Dictionary = floating_messages[i]
		message["life"] = float(message["life"]) - delta
		message["pos"] = Vector2(message["pos"]) + Vector2(0, -24.0 * delta)
		if float(message["life"]) <= 0.0:
			floating_messages.remove_at(i)
		else:
			floating_messages[i] = message

func _craft_weapon_enchant() -> void:
	if weapon_enchant >= 4:
		_add_floating_message("WEAPON ENCHANT MAXED", player_position + Vector2(0, -54), Color("#e7bd9a"))
		return
	if weapon_enchant == 3:
		if guardian_cores < 1 or ancient_caches < 1:
			_add_floating_message("NEED GUARDIAN CORE + ANCIENT CACHE", player_position + Vector2(0, -54), Color("#ff9877"))
			queue_redraw()
			return
		if relic_shards < 5 or herbs < 8:
			_add_floating_message("LEGENDARY FORGE: 5 SHARDS + 8 HERBS", player_position + Vector2(0, -54), Color("#e7d49a"))
			queue_redraw()
			return
		guardian_cores -= 1
		ancient_caches -= 1
		relic_shards -= 5
		herbs -= 8
		weapon_enchant += 1
		_add_floating_message("LEGENDARY WEAPON FORGED!", player_position + Vector2(0, -70), Color("#ffd28b"))
	else:
		if relic_shards < 3 or herbs < 5:
			_add_floating_message("FORGE NEEDS 3 SHARDS + 5 HERBS", player_position + Vector2(0, -54), Color("#c6a0ef"))
			queue_redraw()
			return
		relic_shards -= 3
		herbs -= 5
		weapon_enchant += 1
		_add_floating_message("WEAPON ENCHANT +%d" % weapon_enchant, player_position + Vector2(0, -54), Color("#d7c59f"))
	_save_progress()
	queue_redraw()

func _craft_armor_enchant() -> void:
	if armor_enchant >= 4:
		_add_floating_message("ARMOR ENCHANT MAXED", player_position + Vector2(0, -54), Color("#e7bd9a"))
		return
	if armor_enchant == 3:
		if guardian_cores < 1 or ancient_caches < 1:
			_add_floating_message("NEED GUARDIAN CORE + ANCIENT CACHE", player_position + Vector2(0, -54), Color("#ff9877"))
			queue_redraw()
			return
		if relic_shards < 4 or herbs < 8:
			_add_floating_message("LEGENDARY FORGE: 4 SHARDS + 8 HERBS", player_position + Vector2(0, -54), Color("#e7d49a"))
			queue_redraw()
			return
		guardian_cores -= 1
		ancient_caches -= 1
		relic_shards -= 4
		herbs -= 8
		armor_enchant += 1
		_add_floating_message("LEGENDARY ARMOR FORGED!", player_position + Vector2(0, -70), Color("#bfe4f0"))
	else:
		if relic_shards < 2 or herbs < 5:
			_add_floating_message("FORGE NEEDS 2 SHARDS + 5 HERBS", player_position + Vector2(0, -54), Color("#c6a0ef"))
			queue_redraw()
			return
		relic_shards -= 2
		herbs -= 5
		armor_enchant += 1
		_add_floating_message("ARMOR ENCHANT +%d" % armor_enchant, player_position + Vector2(0, -54), Color("#c5d8df"))
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
		if player_level % 2 == 0:
			talent_points += 1
			_add_floating_message("TALENT POINT +1", player_position + Vector2(0, -88), Color("#b8e8a0"))
		player_hp = player_max_hp
		_add_floating_message("LEVEL UP!  %d" % player_level, player_position + Vector2(0, -68), Color("#f2d58b"))

func _xp_for_next_level() -> int:
	return 50 + (player_level - 1) * 35

func _save_progress() -> void:
	var data := {
		"level": player_level,
		"talent_points": talent_points,
		"talent_ranks": talent_ranks,
		"class_index": player_class_index,
		"specialization_index": specialization_index,
		"xp": player_xp,
		"coins": player_coins,
		"kills": kills,
		"quest_reward_claimed": quest_reward_claimed,
		"second_quest_reward_claimed": second_quest_reward_claimed,
		"guardian_defeated": guardian_defeated,
		"weapon_tier": weapon_tier,
		"armor_tier": armor_tier,
		"herbs": herbs,
		"potions": potions,
		"relic_shards": relic_shards,
		"guardian_cores": guardian_cores,
		"ancient_caches": ancient_caches,
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
	talent_points = maxi(0, int(parsed.get("talent_points", 0)))
	var saved_talents = parsed.get("talent_ranks", [0, 0, 0])
	if saved_talents is Array and saved_talents.size() >= 3:
		for talent_index in range(3):
			talent_ranks[talent_index] = clampi(int(saved_talents[talent_index]), 0, 5)
	player_class_index = clampi(int(parsed.get("class_index", 0)), 0, CLASS_DATA.size() - 1)
	var saved_class_specs: Array = CLASS_DATA[player_class_index]["specs"]
	specialization_index = clampi(int(parsed.get("specialization_index", 0)), 0, saved_class_specs.size() - 1)
	player_xp = maxi(0, int(parsed.get("xp", 0)))
	player_coins = maxi(0, int(parsed.get("coins", 0)))
	kills = maxi(0, int(parsed.get("kills", 0)))
	quest_reward_claimed = bool(parsed.get("quest_reward_claimed", false))
	second_quest_reward_claimed = bool(parsed.get("second_quest_reward_claimed", false))
	guardian_defeated = bool(parsed.get("guardian_defeated", false))
	weapon_tier = clampi(int(parsed.get("weapon_tier", 0)), 0, 5)
	armor_tier = clampi(int(parsed.get("armor_tier", 0)), 0, 5)
	herbs = maxi(0, int(parsed.get("herbs", 0)))
	potions = maxi(0, int(parsed.get("potions", 0)))
	relic_shards = maxi(0, int(parsed.get("relic_shards", 0)))
	guardian_cores = maxi(0, int(parsed.get("guardian_cores", 0)))
	ancient_caches = maxi(0, int(parsed.get("ancient_caches", 0)))
	weapon_enchant = clampi(int(parsed.get("weapon_enchant", 0)), 0, 4)
	armor_enchant = clampi(int(parsed.get("armor_enchant", 0)), 0, 4)
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
	_draw_combat_effects()
	_draw_floating_messages()
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
	_draw_moss_patches()
	_draw_path()

func _draw_moss_patches() -> void:
	var patches: Array[Vector2] = [
		Vector2(215, 220), Vector2(330, 410), Vector2(505, 205),
		Vector2(650, 485), Vector2(895, 465), Vector2(1090, 355),
		Vector2(1140, 255), Vector2(420, 620), Vector2(800, 85)
	]
	for i in range(patches.size()):
		var p := patches[i]
		var pulse := 0.035 + 0.018 * sin(elapsed * 1.4 + float(i))
		var moss := Color("#8cb66a")
		moss.a = pulse
		draw_circle(p, 25.0 + sin(elapsed + float(i)) * 2.0, moss)
		draw_circle(p + Vector2(9, -4), 13.0, moss)

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
		var mob_name := String(mob["name"])
		var is_wolf := mob_name == "Ash Wolf"
		var is_guardian := mob_name == "Ruin Guardian"
		var body_color := Color("#8e6553") if is_wolf else (Color("#887d9c") if mob_name == "Ruins Stalker" else (Color("#b95f49") if is_guardian else Color("#a58a53")))
		if float(mob.get("hit_flash", 0.0)) > 0.0:
			body_color = Color("#fff0d4")
		draw_circle(mob_pos + Vector2(1, 10), 23.0 if is_guardian else 15.0, Color(0.02, 0.025, 0.02, 0.35))
		if is_guardian:
			var guardian_enraged := float(mob["hp"]) <= float(mob["max_hp"]) * 0.5
			var guardian_glow := 0.28 + 0.18 * sin(elapsed * (5.0 if guardian_enraged else 3.0))
			var guardian_color := Color("#ff4d35") if guardian_enraged else Color("#d36b55")
			guardian_color.a = guardian_glow
			draw_arc(mob_pos, 29.0 + sin(elapsed * 2.4) * 2.0, 0.0, TAU, 36, guardian_color, 4.0, true)
			var slam_windup := float(mob.get("slam_windup", 0.0))
			if slam_windup > 0.0:
				var warning_alpha := 0.18 + 0.08 * sin(elapsed * 18.0)
				var danger_fill := Color("#f05b48")
				danger_fill.a = warning_alpha
				draw_circle(mob_pos, 112.0, danger_fill)
				var danger_outline := Color("#ff7658")
				danger_outline.a = 0.88
				draw_arc(mob_pos, 112.0, 0.0, TAU, 56, danger_outline, 4.0, true)
				for marker_index in range(8):
					var marker_angle := TAU * float(marker_index) / 8.0 + elapsed * 0.8
					var marker_direction := Vector2(cos(marker_angle), sin(marker_angle))
					draw_line(mob_pos + marker_direction * 94.0, mob_pos + marker_direction * 108.0, Color("#ffd0a1"), 3.0)
				draw_string(ThemeDB.fallback_font, mob_pos + Vector2(-42, -66), "DODGE!", HORIZONTAL_ALIGNMENT_CENTER, 84, 16, Color("#ffd0a1"))
		var threat_distance := player_position.distance_to(mob_pos)
		if threat_distance <= 76.0:
			var warning_color := Color("#e36b5d")
			warning_color.a = 0.48 + 0.28 * sin(elapsed * 10.0)
			draw_arc(mob_pos + Vector2(0, 3), 20.0 + 2.0 * sin(elapsed * 8.0), 0.0, TAU, 28, warning_color, 2.5, true)
		var attack_windup := float(mob.get("attack_windup", 0.0))
		if attack_windup > 0.0:
			var windup_duration := 0.42
			if mob_name == "Ruins Stalker":
				windup_duration = 0.72
			elif is_guardian:
				windup_duration = 0.92
			var windup_progress := 1.0 - clampf(attack_windup / windup_duration, 0.0, 1.0)
			var telegraph_color := Color("#ffb45c")
			telegraph_color.a = 0.75 + 0.25 * sin(elapsed * 18.0)
			draw_arc(mob_pos + Vector2(0, 3), 26.0, -PI * 0.5, -PI * 0.5 + TAU * windup_progress, 32, telegraph_color, 4.0, true)
		if mob_name == "Ruins Stalker":
			var rune_glow := 0.35 + 0.22 * sin(elapsed * 3.2 + mob_pos.x * 0.02)
			var rune_color := Color("#ad8bf0")
			rune_color.a = rune_glow
			draw_arc(mob_pos + Vector2(0, 2), 16.0 + sin(elapsed * 4.0) * 1.5, 0.0, TAU, 24, rune_color, 2.0, true)
		draw_circle(mob_pos, 21.0 if is_guardian else 13.0, body_color)
		draw_circle(mob_pos + Vector2(-4, -5), 7.0 if is_guardian else 4.0, body_color.lightened(0.22))
		draw_circle(mob_pos + Vector2(-5, -2), 3.0, Color("#ffd27b") if is_guardian else Color("#e3b36b"))
		draw_circle(mob_pos + Vector2(5, -2), 3.0, Color("#ffd27b") if is_guardian else Color("#e3b36b"))
		var bar_width := 58.0 if is_guardian else 34.0
		draw_rect(Rect2(mob_pos + Vector2(-bar_width / 2.0, -24), Vector2(bar_width, 4)), Color("#241e1d"))
		draw_rect(Rect2(mob_pos + Vector2(-bar_width / 2.0, -24), Vector2(bar_width * clampf(float(mob["hp"]) / float(mob["max_hp"]), 0.0, 1.0), 4)), Color("#b94d45"))
		draw_string(ThemeDB.fallback_font, mob_pos + Vector2(-40 if is_guardian else -27, -34 if is_guardian else -30), mob_name, HORIZONTAL_ALIGNMENT_LEFT, 100 if is_guardian else 70, 11 if is_guardian else 9, Color("#f0c6b4") if is_guardian else Color("#ded2bd"))

func _draw_loot_drops() -> void:
	for drop in loot_drops:
		var p: Vector2 = drop["pos"]
		var drop_type := String(drop["type"])
		var color := Color("#e0bd68") if drop_type == "coins" else (Color("#8fbd75") if drop_type == "herbs" else (Color("#ff9877") if drop_type == "guardian_core" else (Color("#e7d49a") if drop_type == "ancient_cache" else Color("#b58be0"))))
		var pulse := 1.0 + 0.14 * sin(elapsed * 5.0 + float(p[0] + p[1]) * 0.03)
		draw_circle(p + Vector2(0, 5), 9.0, Color(0.02, 0.025, 0.02, 0.32))
		draw_circle(p, 7.0 * pulse, color)
		draw_arc(p, 8.0 * pulse, 0.0, TAU, 20, color.lightened(0.45), 2.0)
		if drop_type == "guardian_core":
			draw_arc(p, 12.0 * pulse, 0.0, TAU, 24, Color("#ffd0a1"), 2.0, true)
		elif drop_type == "ancient_cache":
			draw_rect(Rect2(p - Vector2(8, 7), Vector2(16, 14)), Color("#9c7441"))
			draw_rect(Rect2(p - Vector2(8, 7), Vector2(16, 14)), Color("#f0d58b"), false, 2.0)
		var glyph := "G" if drop_type == "coins" else ("H" if drop_type == "herbs" else ("C" if drop_type == "guardian_core" else ("A" if drop_type == "ancient_cache" else "R")))
		draw_string(ThemeDB.fallback_font, p + Vector2(-3, 3), glyph, HORIZONTAL_ALIGNMENT_LEFT, 8, 8, Color("#22231d"))

func _draw_combat_effects() -> void:
	for effect in combat_effects:
		var life := float(effect["life"])
		var duration := maxf(float(effect["duration"]), 0.001)
		var progress := clampf(1.0 - life / duration, 0.0, 1.0)
		if String(effect["kind"]) == "slash":
			var direction: Vector2 = effect["dir"]
			var center: Vector2 = effect["pos"] + direction * 18.0
			var slash_color := Color("#f5dfad")
			slash_color.a = (1.0 - progress) * 0.92
			draw_arc(center, 30.0 + progress * 8.0, direction.angle() - 0.95, direction.angle() + 0.95, 20, slash_color, 4.0, true)
		elif String(effect["kind"]) == "critical":
			var critical_color := Color("#ffd56f")
			critical_color.a = (1.0 - progress) * 0.95
			var critical_center: Vector2 = effect["pos"]
			for ray_index in range(10):
				var ray_angle := TAU * float(ray_index) / 10.0 + progress * 0.25
				var ray_direction := Vector2(cos(ray_angle), sin(ray_angle))
				draw_line(critical_center + ray_direction * (8.0 + progress * 5.0), critical_center + ray_direction * (24.0 + progress * 16.0), critical_color, 3.0)
			draw_arc(critical_center, 18.0 + progress * 22.0, 0.0, TAU, 28, critical_color, 2.5, true)
		elif String(effect["kind"]) == "dodge":
			var direction: Vector2 = effect["dir"]
			var dodge_color := Color("#9fe6ef")
			dodge_color.a = (1.0 - progress) * 0.8
			for trail_index in range(3):
				var trail_offset := -direction * float(trail_index + 1) * 12.0
				draw_line(Vector2(effect["pos"]) + trail_offset, Vector2(effect["pos"]) + trail_offset - direction * 10.0, dodge_color, 5.0 - float(trail_index))
		elif String(effect["kind"]) == "hit":
			var hit_color := Color("#ffd58b")
			hit_color.a = (1.0 - progress) * 0.95
			for ray_index in range(6):
				var ray_angle := TAU * float(ray_index) / 6.0
				var ray_direction := Vector2(cos(ray_angle), sin(ray_angle))
				draw_line(Vector2(effect["pos"]) + ray_direction * 4.0, Vector2(effect["pos"]) + ray_direction * (10.0 + progress * 13.0), hit_color, 2.0)
		else:
			var pulse_color := Color("#9fd9e8")
			pulse_color.a = (1.0 - progress) * 0.72
			draw_arc(effect["pos"], 24.0 + progress * 126.0, 0.0, TAU, 48, pulse_color, 4.0 - progress * 2.0, true)

func _draw_floating_messages() -> void:
	for message in floating_messages:
		var life := float(message["life"])
		var message_position: Vector2 = message["pos"]
		var alpha := clampf(life / 0.45, 0.0, 1.0)
		var message_color: Color = message["color"]
		message_color.a = alpha
		draw_string(ThemeDB.fallback_font, message_position, String(message["text"]), HORIZONTAL_ALIGNMENT_CENTER, 220, 14, message_color)

func _draw_player() -> void:
	draw_circle(player_position + Vector2(2, 15), 18.0, Color(0.02, 0.03, 0.025, 0.28))
	var body_color := Color("#fff0d4") if player_hit_flash > 0.0 else Color("#283b36")
	var head_color := Color("#fff5e6") if player_hit_flash > 0.0 else Color("#c6ad8b")
	draw_circle(player_position + Vector2(0, 2), 14.0, body_color)
	draw_circle(player_position + Vector2(0, -7), 9.0, head_color)
	draw_arc(player_position + Vector2(0, -7), 10.0, PI, TAU, 16, Color("#5b4335"), 4.0)
	var weapon_direction := move_vector.normalized() if move_vector.length_squared() > 0.01 else Vector2(1, 0)
	var weapon_start := player_position + weapon_direction * 9.0
	var weapon_end := player_position + weapon_direction * 27.0
	draw_line(weapon_start, weapon_end, Color("#b8c7c3"), 4.0)
	draw_line(weapon_start - Vector2(3, 3), weapon_start + Vector2(3, 3), Color("#8b6848"), 3.0
	)
	draw_circle(player_position + Vector2(-3, -10), 2.0, Color("#26332d"))

func _draw_hud() -> void:
	for mob in mobs:
		if bool(mob.get("boss", false)) and bool(mob["alive"]):
			var boss_hp_ratio := clampf(float(mob["hp"]) / float(mob["max_hp"]), 0.0, 1.0)
			draw_rect(Rect2(440, 20, 400, 48), Color(0.035, 0.025, 0.03, 0.92))
			var boss_title := "RUIN GUARDIAN  •  ENRAGED" if float(mob["hp"]) <= float(mob["max_hp"]) * 0.5 else "RUIN GUARDIAN"
			draw_string(ThemeDB.fallback_font, Vector2(440, 16), boss_title, HORIZONTAL_ALIGNMENT_CENTER, 400, 16, Color("#ff896d") if float(mob["hp"]) <= float(mob["max_hp"]) * 0.5 else Color("#f0c6b4"))
			draw_rect(Rect2(456, 35, 368, 14), Color("#382629"))
			draw_rect(Rect2(456, 35, 368.0 * boss_hp_ratio, 14), Color("#c74f46"))
			draw_rect(Rect2(456, 35, 368, 14), Color("#f0a08a"), false, 1.5)
			break
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
	var dodge_center := _dodge_button_center()
	draw_circle(dodge_center, 40.0, Color(0.08, 0.22, 0.25, 0.88))
	draw_arc(dodge_center, 40.0, 0.0, TAU, 40, Color("#9fe6ef"), 3.0)
	draw_string(ThemeDB.fallback_font, dodge_center + Vector2(-25, -2), "DODGE", HORIZONTAL_ALIGNMENT_LEFT, 70, 12, Color("#d7f4f5"))
	draw_string(ThemeDB.fallback_font, dodge_center + Vector2(-24, 15), "%.1fs" % dodge_cooldown if dodge_cooldown > 0.0 else "READY  V", HORIZONTAL_ALIGNMENT_LEFT, 70, 10, Color("#9fe6ef"))
	draw_string(ThemeDB.fallback_font, Vector2(42, 144), "ARMOR reduces damage • SKILL cooldown %.1fs" % skill_cooldown, HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color("#c5cfba"))
	draw_string(ThemeDB.fallback_font, Vector2(42, 164), "HERBS %d   POTIONS %d   RELIC SHARDS %d" % [herbs, potions, relic_shards], HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("#c5cfba"))
	draw_string(ThemeDB.fallback_font, Vector2(42, 202), "GUARDIAN CORES %d   ANCIENT CACHES %d" % [guardian_cores, ancient_caches], HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color("#e7bd9a"))
	draw_string(ThemeDB.fallback_font, Vector2(42, 184), "DMG %d  •  CRIT %d%%  •  ARMOR %d" % [20 + weapon_tier * 8 + weapon_enchant * 4, int(round(minf(0.08 + float(weapon_enchant) * 0.04, 0.24) * 100.0)), armor_tier * 2 + armor_enchant * 2], HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color("#d7c59f"))
	var combo_bonus_percent := 35 if combo_count >= 5 else (15 if combo_count >= 3 else 0)
	var combo_label := "COMBO x%d  •  +%d%% DAMAGE" % [combo_count, combo_bonus_percent] if combo_count > 0 else "COMBO: READY"
	var combo_color := Color("#ffd56f") if combo_count >= 5 else (Color("#b8e8a0") if combo_count >= 3 else Color("#c5cfba"))
	draw_string(ThemeDB.fallback_font, Vector2(465, 102), combo_label, HORIZONTAL_ALIGNMENT_CENTER, 350, 15, combo_color)
	var class_center := _class_button_center()
	draw_rect(Rect2(class_center - Vector2(100, 24), Vector2(200, 48)), Color(0.12, 0.10, 0.18, 0.92))
	draw_rect(Rect2(class_center - Vector2(100, 24), Vector2(200, 48)), Color("#b9a4e6"), false, 2.0)
	var current_class := _current_class_data()
	draw_string(ThemeDB.fallback_font, class_center + Vector2(-88, 5), "CLASS: %s  [TAB]" % String(current_class["name"]), HORIZONTAL_ALIGNMENT_LEFT, 180, 13, Color("#e8dcff"))
	var spec_center := _specialization_button_center()
	draw_rect(Rect2(spec_center - Vector2(130, 22), Vector2(260, 44)), Color(0.10, 0.14, 0.18, 0.92))
	draw_rect(Rect2(spec_center - Vector2(130, 22), Vector2(260, 44)), Color("#8eb6c5"), false, 2.0)
	var current_specs: Array = current_class["specs"]
	draw_string(ThemeDB.fallback_font, spec_center + Vector2(-118, 4), "SPEC: %s  [G]" % String(current_specs[specialization_index]), HORIZONTAL_ALIGNMENT_LEFT, 240, 12, Color("#d7e8ed"))
	var talent_titles: Array[String] = ["OFFENSE", "DEFENSE", "UTILITY"]
	for branch in range(3):
		var talent_center := _talent_button_center(branch)
		var talent_color := Color("#c96c59") if branch == 0 else (Color("#7aabc0") if branch == 1 else Color("#9bc58a"))
		draw_rect(Rect2(talent_center - Vector2(66, 22), Vector2(132, 44)), Color(0.07, 0.09, 0.10, 0.94))
		draw_rect(Rect2(talent_center - Vector2(66, 22), Vector2(132, 44)), talent_color, false, 2.0)
		draw_string(ThemeDB.fallback_font, talent_center + Vector2(-58, -2), "%s %d/5" % [talent_titles[branch], talent_ranks[branch]], HORIZONTAL_ALIGNMENT_LEFT, 120, 11, Color("#e7dfc8"))
		draw_string(ThemeDB.fallback_font, talent_center + Vector2(-58, 14), "KEY %d" % (branch + 1), HORIZONTAL_ALIGNMENT_LEFT, 120, 9, Color("#d7c59f"))
	draw_string(ThemeDB.fallback_font, Vector2(640, 432), "TALENT POINTS: %d" % talent_points, HORIZONTAL_ALIGNMENT_CENTER, 280, 13, Color("#b8e8a0") if talent_points > 0 else Color("#c5cfba"))
	var forge_weapon_center := _forge_weapon_button_center()
	draw_rect(Rect2(forge_weapon_center - Vector2(67, 23), Vector2(134, 46)), Color(0.16, 0.13, 0.09, 0.92))
	draw_rect(Rect2(forge_weapon_center - Vector2(67, 23), Vector2(134, 46)), Color("#c49a62"), false, 2.0)
	draw_string(ThemeDB.fallback_font, forge_weapon_center + Vector2(-59, -2), "FORGE WPN Z", HORIZONTAL_ALIGNMENT_LEFT, 120, 11, Color("#f0dfc4"))
	var weapon_forge_cost := "MAX LEVEL" if weapon_enchant >= 4 else ("CORE+CACHE 5S/8H" if weapon_enchant == 3 else "3 shards / 5 herbs")
	draw_string(ThemeDB.fallback_font, forge_weapon_center + Vector2(-59, 14), "+%d  %s" % [weapon_enchant, weapon_forge_cost], HORIZONTAL_ALIGNMENT_LEFT, 125, 9, Color("#ffd28b") if weapon_enchant == 3 else Color("#d7c59f"))
	var forge_armor_center := _forge_armor_button_center()
	draw_rect(Rect2(forge_armor_center - Vector2(67, 23), Vector2(134, 46)), Color(0.12, 0.15, 0.19, 0.92))
	draw_rect(Rect2(forge_armor_center - Vector2(67, 23), Vector2(134, 46)), Color("#8eb6c5"), false, 2.0)
	draw_string(ThemeDB.fallback_font, forge_armor_center + Vector2(-59, -2), "FORGE ARM X", HORIZONTAL_ALIGNMENT_LEFT, 120, 11, Color("#d7e8ed"))
	var armor_forge_cost := "MAX LEVEL" if armor_enchant >= 4 else ("CORE+CACHE 4S/8H" if armor_enchant == 3 else "2 shards / 5 herbs")
	draw_string(ThemeDB.fallback_font, forge_armor_center + Vector2(-59, 14), "+%d  %s" % [armor_enchant, armor_forge_cost], HORIZONTAL_ALIGNMENT_LEFT, 125, 9, Color("#bfe4f0") if armor_enchant == 3 else Color("#c5d8df"))
	var potion_center := _potion_button_center()
	draw_rect(Rect2(potion_center - Vector2(60, 30), Vector2(120, 60)), Color(0.13, 0.18, 0.12, 0.9))
	draw_rect(Rect2(potion_center - Vector2(60, 30), Vector2(120, 60)), Color("#9fc18b"), false, 2.0)
	draw_string(ThemeDB.fallback_font, potion_center + Vector2(-48, -2), "POTION C/R", HORIZONTAL_ALIGNMENT_LEFT, 105, 12, Color("#e7dfc8"))
	draw_string(ThemeDB.fallback_font, potion_center + Vector2(-48, 15), "x%d / 3 herbs" % potions, HORIZONTAL_ALIGNMENT_LEFT, 105, 11, Color("#d7c59f"))
