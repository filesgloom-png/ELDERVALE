extends Node2D

const WORLD_SIZE := Vector2(1280.0, 720.0)
const JOYSTICK_CENTER := Vector2(112.0, 600.0)
const JOYSTICK_RADIUS := 68.0
const ANCIENT_RUNE_POSITION := Vector2(914.0, 296.0)
const RUNE_INTERACTION_RANGE := 108.0
const RUIN_OBJECT_POSITIONS := [Vector2(754.0, 328.0), Vector2(978.0, 388.0), Vector2(1090.0, 304.0)]
const RUIN_OBJECT_RANGE := 92.0
const HIDDEN_GATE_POSITION := Vector2(1118.0, 282.0)
const HIDDEN_GATE_RANGE := 96.0
const ANCIENT_CHEST_POSITION := Vector2(1110.0, 396.0)
const ANCIENT_CHEST_RANGE := 90.0
const MEMORY_EXIT_POSITION := Vector2(1182.0, 374.0)
const MEMORY_EXIT_RANGE := 88.0
const SHATTERED_REACH_ENTRY_POSITION := Vector2(470.0, 568.0)
const SHATTERED_BEACON_POSITION := Vector2(475.0, 564.0)
const SHATTERED_BEACON_RANGE := 92.0
const NORTHBOUND_SIGNAL_POSITION := Vector2(575.0, 625.0)
const NORTHBOUND_SIGNAL_RANGE := 72.0
const WATCHTOWER_PATH_POSITION := Vector2(674.0, 610.0)
const WATCHTOWER_PATH_RANGE := 78.0
const FROSTWATCH_RELIC_POSITION := Vector2(842.0, 572.0)
const FROSTWATCH_RELIC_RANGE := 76.0
const WATCHTOWER_SYMBOL_POSITIONS := [Vector2(760.0, 535.0), Vector2(828.0, 515.0), Vector2(882.0, 535.0)]
const WATCHTOWER_SYMBOL_RANGE := 48.0
const WATCHTOWER_CACHE_POSITION := Vector2(770.0, 614.0)
const WATCHTOWER_CACHE_RANGE := 58.0
const FROSTFALL_ROUTE_POSITION := Vector2(896.0, 610.0)
const FROSTFALL_ROUTE_RANGE := 58.0
const CODEX_BUTTON_RECT := Rect2(1114.0, 145.0, 146.0, 44.0)
const RUNE_BUTTON_RECT := Rect2(516.0, 620.0, 248.0, 58.0)
const CODEX_CLOSE_RECT := Rect2(914.0, 124.0, 82.0, 38.0)
const PLAYER_SPEED := 245.0
const MAX_PLAYER_LEVEL := 100
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

const ULTIMATE_DATA := {
	"Warden": {"name": "Aegis of Dawn", "power": 1.10, "radius": 210.0, "heal": 12},
	"Weaponmaster": {"name": "Blade Tempest", "power": 1.42, "radius": 205.0, "heal": 0},
	"Champion": {"name": "Heroic Breaker", "power": 1.58, "radius": 190.0, "heal": 0},
	"Reaver": {"name": "Rend the Weak", "power": 1.40, "radius": 200.0, "heal": 0},
	"Bloodfury": {"name": "Blood Eclipse", "power": 1.48, "radius": 215.0, "heal": 8},
	"Juggernaut": {"name": "Cataclysm Slam", "power": 1.30, "radius": 225.0, "heal": 10},
	"Shadow": {"name": "Umbral Execution", "power": 1.48, "radius": 190.0, "heal": 0},
	"Executioner": {"name": "Final Verdict", "power": 1.45, "radius": 200.0, "heal": 0},
	"Phantom": {"name": "Hundredfold Echo", "power": 1.25, "radius": 235.0, "heal": 0},
	"Pathfinder": {"name": "Storm of Arrows", "power": 1.25, "radius": 275.0, "heal": 0},
	"Beastmaster": {"name": "Primal Pack", "power": 1.30, "radius": 230.0, "heal": 12},
	"Deadeye": {"name": "Deadeye Barrage", "power": 1.62, "radius": 300.0, "heal": 0},
	"Elementalist": {"name": "Primal Convergence", "power": 1.58, "radius": 285.0, "heal": 0},
	"Spellblade": {"name": "Arcane Sever", "power": 1.42, "radius": 205.0, "heal": 0},
	"Archmage": {"name": "Astral Cataclysm", "power": 1.72, "radius": 300.0, "heal": 0},
	"Lich": {"name": "Harvest of Souls", "power": 1.38, "radius": 235.0, "heal": 8},
	"Soulweaver": {"name": "Soul Requiem", "power": 1.12, "radius": 245.0, "heal": 24},
	"Gravecaller": {"name": "Gravewake", "power": 1.48, "radius": 255.0, "heal": 6},
	"Inquisitor": {"name": "Judgment of Ash", "power": 1.50, "radius": 220.0, "heal": 8},
	"Justicar": {"name": "Sanctuary Ascendant", "power": 1.08, "radius": 215.0, "heal": 28},
	"Sunkeeper": {"name": "Solar Dominion", "power": 1.52, "radius": 250.0, "heal": 16},
	"Shapebinder": {"name": "Wildshape Colossus", "power": 1.38, "radius": 220.0, "heal": 8},
	"Stormcaller": {"name": "Tempest Crown", "power": 1.55, "radius": 285.0, "heal": 0},
	"Grovekeeper": {"name": "Heart of the Green", "power": 1.08, "radius": 240.0, "heal": 30},
	"Way of the Fist": {"name": "Sevenfold Impact", "power": 1.48, "radius": 185.0, "heal": 0},
	"Way of the Gale": {"name": "Cyclone Step", "power": 1.32, "radius": 240.0, "heal": 0},
	"Way of Balance": {"name": "Perfect Equilibrium", "power": 1.22, "radius": 220.0, "heal": 18},
	"Tinkerer": {"name": "Overclock Protocol", "power": 1.35, "radius": 220.0, "heal": 0},
	"Artillerist": {"name": "Siegebreaker Salvo", "power": 1.70, "radius": 300.0, "heal": 0},
	"Aegis Smith": {"name": "Adamant Bastion", "power": 1.18, "radius": 220.0, "heal": 20}
}

const PASSIVE_DATA := {
	"Warden": {"name": "Unbroken Guard", "attack": 1, "skill": 1, "crit": 0, "armor": 3, "heal": 0, "charge": 1, "combo": 0, "ultimate": 1, "evade": 0.04, "damage_reduce": 0.04},
	"Weaponmaster": {"name": "Perfect Form", "attack": 1.1, "skill": 1.02, "crit": 0.02, "armor": 0, "heal": 0, "charge": 2, "combo": 0.04, "ultimate": 1.05, "evade": 0, "damage_reduce": 0},
	"Champion": {"name": "Victory Rush", "attack": 1.04, "skill": 1.08, "crit": 0, "armor": 1, "heal": 2, "charge": 1, "combo": 0.05, "ultimate": 1.08, "evade": 0, "damage_reduce": 0},
	"Reaver": {"name": "Rending Strikes", "attack": 1.12, "skill": 1.02, "crit": 0.02, "armor": 0, "heal": 0, "charge": 1, "combo": 0.04, "ultimate": 1.06, "evade": 0, "damage_reduce": 0},
	"Bloodfury": {"name": "Blood Price", "attack": 1.16, "skill": 1.08, "crit": 0, "armor": 0, "heal": 2, "charge": 2, "combo": 0.06, "ultimate": 1.1, "evade": 0, "damage_reduce": 0.02},
	"Juggernaut": {"name": "Iron Momentum", "attack": 1.03, "skill": 1.1, "crit": 0, "armor": 4, "heal": 0, "charge": 1, "combo": 0, "ultimate": 1.05, "evade": 0, "damage_reduce": 0.06},
	"Shadow": {"name": "Killer's Instinct", "attack": 1.05, "skill": 1.06, "crit": 0.08, "armor": 0, "heal": 0, "charge": 2, "combo": 0.03, "ultimate": 1.1, "evade": 0.04, "damage_reduce": 0},
	"Executioner": {"name": "Merciless", "attack": 1.06, "skill": 1.1, "crit": 0.03, "armor": 0, "heal": 0, "charge": 2, "combo": 0.03, "ultimate": 1.12, "evade": 0, "damage_reduce": 0},
	"Phantom": {"name": "Afterimage", "attack": 1.04, "skill": 1.12, "crit": 0.02, "armor": 0, "heal": 0, "charge": 3, "combo": 0.04, "ultimate": 1.06, "evade": 0.08, "damage_reduce": 0},
	"Pathfinder": {"name": "Longshot", "attack": 1.05, "skill": 1.08, "crit": 0.02, "armor": 0, "heal": 0, "charge": 2, "combo": 0.02, "ultimate": 1.05, "evade": 0.02, "damage_reduce": 0},
	"Beastmaster": {"name": "Pack Bond", "attack": 1.04, "skill": 1.08, "crit": 0, "armor": 1, "heal": 3, "charge": 2, "combo": 0.02, "ultimate": 1.06, "evade": 0, "damage_reduce": 0},
	"Deadeye": {"name": "Marked Target", "attack": 1.1, "skill": 1.14, "crit": 0.1, "armor": 0, "heal": 0, "charge": 2, "combo": 0.02, "ultimate": 1.12, "evade": 0, "damage_reduce": 0},
	"Elementalist": {"name": "Elemental Surge", "attack": 1, "skill": 1.16, "crit": 0.03, "armor": 0, "heal": 0, "charge": 3, "combo": 0.02, "ultimate": 1.12, "evade": 0, "damage_reduce": 0},
	"Spellblade": {"name": "Arcane Edge", "attack": 1.1, "skill": 1.1, "crit": 0.03, "armor": 0, "heal": 1, "charge": 2, "combo": 0.03, "ultimate": 1.08, "evade": 0, "damage_reduce": 0},
	"Archmage": {"name": "Overwhelming Force", "attack": 1, "skill": 1.2, "crit": 0.04, "armor": 0, "heal": 0, "charge": 4, "combo": 0, "ultimate": 1.16, "evade": 0, "damage_reduce": 0},
	"Lich": {"name": "Soul Siphon", "attack": 1.02, "skill": 1.12, "crit": 0.02, "armor": 0, "heal": 4, "charge": 2, "combo": 0.02, "ultimate": 1.08, "evade": 0, "damage_reduce": 0},
	"Soulweaver": {"name": "Shared Essence", "attack": 1, "skill": 1.04, "crit": 0, "armor": 1, "heal": 8, "charge": 2, "combo": 0, "ultimate": 1.04, "evade": 0, "damage_reduce": 0.02},
	"Gravecaller": {"name": "Grave Harvest", "attack": 1.02, "skill": 1.14, "crit": 0.02, "armor": 0, "heal": 2, "charge": 3, "combo": 0.02, "ultimate": 1.1, "evade": 0, "damage_reduce": 0},
	"Inquisitor": {"name": "Ashen Judgment", "attack": 1.1, "skill": 1.1, "crit": 0.03, "armor": 1, "heal": 1, "charge": 2, "combo": 0.03, "ultimate": 1.08, "evade": 0, "damage_reduce": 0},
	"Justicar": {"name": "Sanctuary Oath", "attack": 1, "skill": 1.03, "crit": 0, "armor": 4, "heal": 6, "charge": 1, "combo": 0, "ultimate": 1.04, "evade": 0, "damage_reduce": 0.06},
	"Sunkeeper": {"name": "Solar Renewal", "attack": 1.04, "skill": 1.12, "crit": 0.03, "armor": 1, "heal": 4, "charge": 2, "combo": 0.02, "ultimate": 1.1, "evade": 0, "damage_reduce": 0.02},
	"Shapebinder": {"name": "Adaptive Hide", "attack": 1.06, "skill": 1.08, "crit": 0, "armor": 2, "heal": 2, "charge": 2, "combo": 0.02, "ultimate": 1.06, "evade": 0, "damage_reduce": 0.03},
	"Stormcaller": {"name": "Rolling Thunder", "attack": 1.02, "skill": 1.14, "crit": 0.06, "armor": 0, "heal": 0, "charge": 4, "combo": 0.03, "ultimate": 1.12, "evade": 0, "damage_reduce": 0},
	"Grovekeeper": {"name": "Verdant Heart", "attack": 1, "skill": 1.05, "crit": 0, "armor": 2, "heal": 7, "charge": 1, "combo": 0, "ultimate": 1.03, "evade": 0, "damage_reduce": 0.04},
	"Way of the Fist": {"name": "Flowing Strikes", "attack": 1.12, "skill": 1.06, "crit": 0.04, "armor": 0, "heal": 0, "charge": 3, "combo": 0.07, "ultimate": 1.08, "evade": 0.02, "damage_reduce": 0},
	"Way of the Gale": {"name": "Windstep", "attack": 1.04, "skill": 1.08, "crit": 0.05, "armor": 0, "heal": 0, "charge": 3, "combo": 0.03, "ultimate": 1.05, "evade": 0.1, "damage_reduce": 0},
	"Way of Balance": {"name": "Centered Spirit", "attack": 1.04, "skill": 1.05, "crit": 0.02, "armor": 2, "heal": 3, "charge": 2, "combo": 0.02, "ultimate": 1.06, "evade": 0.02, "damage_reduce": 0.03},
	"Tinkerer": {"name": "Combat Protocol", "attack": 1.05, "skill": 1.1, "crit": 0.02, "armor": 1, "heal": 0, "charge": 3, "combo": 0.03, "ultimate": 1.08, "evade": 0, "damage_reduce": 0},
	"Artillerist": {"name": "Siege Calibration", "attack": 1.04, "skill": 1.18, "crit": 0.04, "armor": 0, "heal": 0, "charge": 4, "combo": 0.02, "ultimate": 1.14, "evade": 0, "damage_reduce": 0},
	"Aegis Smith": {"name": "Living Bulwark", "attack": 1, "skill": 1.04, "crit": 0, "armor": 3, "heal": 5, "charge": 1, "combo": 0, "ultimate": 1.04, "evade": 0, "damage_reduce": 0.05}
}

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
var ultimate_charge := 0.0
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
var echo_shards := 0
var echo_surge_time := 0.0
var codex_open := false
var codex_entries := 0
var rune_studied := false
var rune_activated := false
var rune_nearby := false
var nearby_ruin_object := -1
var nearby_hidden_gate := false
var nearby_ancient_chest := false
var nearby_memory_exit := false
var nearby_shattered_beacon := false
var nearby_northbound_signal := false
var nearby_watchtower_path := false
var nearby_frostwatch_relic := false
var nearby_watchtower_symbol := -1
var nearby_watchtower_cache := false
var nearby_frostfall_route := false
var hidden_passage_open := false
var ancient_chest_claimed := false
var shattered_reach_unlocked := false
var shattered_reach_discovered := false
var shattered_beacon_activated := false
var northbound_signal_discovered := false
var watchtower_path_open := false
var watchtower_discovered := false
var frostwatch_relic_discovered := false
var watchtower_symbols := 0
var watchtower_cache_claimed := false
var frostfall_pass_open := false
var weapon_enchant := 0
var armor_enchant := 0
var quest_reward_claimed := false
var second_quest_reward_claimed := false
var guardian_defeated := false
var memory_guardian_defeated := false
var memory_relic_owned := false
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
	_ensure_memory_guardian_encounter()
	queue_redraw()

func _process(delta: float) -> void:
	elapsed += delta
	echo_surge_time = maxf(echo_surge_time - delta, 0.0)
	if echo_surge_time <= 0.0 and echo_shards >= 3:
		_activate_echo_surge()
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
	rune_nearby = player_position.distance_to(ANCIENT_RUNE_POSITION) <= RUNE_INTERACTION_RANGE
	nearby_ruin_object = -1
	var closest_ruin_distance := RUIN_OBJECT_RANGE
	for ruin_index in range(RUIN_OBJECT_POSITIONS.size()):
		if (codex_entries & (1 << (6 + ruin_index))) != 0:
			continue
		var ruin_distance := player_position.distance_to(RUIN_OBJECT_POSITIONS[ruin_index])
		if ruin_distance <= closest_ruin_distance:
			closest_ruin_distance = ruin_distance
			nearby_ruin_object = ruin_index
	nearby_hidden_gate = (codex_entries & 448) == 448 and player_position.distance_to(HIDDEN_GATE_POSITION) <= HIDDEN_GATE_RANGE
	nearby_ancient_chest = hidden_passage_open and not ancient_chest_claimed and player_position.distance_to(ANCIENT_CHEST_POSITION) <= ANCIENT_CHEST_RANGE
	nearby_memory_exit = memory_guardian_defeated and player_position.distance_to(MEMORY_EXIT_POSITION) <= MEMORY_EXIT_RANGE
	nearby_shattered_beacon = shattered_reach_discovered and player_position.distance_to(SHATTERED_BEACON_POSITION) <= SHATTERED_BEACON_RANGE
	nearby_northbound_signal = shattered_beacon_activated and player_position.distance_to(NORTHBOUND_SIGNAL_POSITION) <= NORTHBOUND_SIGNAL_RANGE
	nearby_watchtower_path = northbound_signal_discovered and player_position.distance_to(WATCHTOWER_PATH_POSITION) <= WATCHTOWER_PATH_RANGE
	nearby_frostwatch_relic = watchtower_discovered and not frostwatch_relic_discovered and player_position.distance_to(FROSTWATCH_RELIC_POSITION) <= FROSTWATCH_RELIC_RANGE
	nearby_watchtower_symbol = -1
	var closest_watchtower_symbol_distance := WATCHTOWER_SYMBOL_RANGE
	if watchtower_discovered:
		for symbol_index in range(WATCHTOWER_SYMBOL_POSITIONS.size()):
			if (watchtower_symbols & (1 << symbol_index)) != 0:
				continue
			var symbol_distance: float = player_position.distance_to(WATCHTOWER_SYMBOL_POSITIONS[symbol_index])
			if symbol_distance <= closest_watchtower_symbol_distance:
				closest_watchtower_symbol_distance = symbol_distance
				nearby_watchtower_symbol = symbol_index
	nearby_watchtower_cache = watchtower_discovered and watchtower_symbols == 7 and not watchtower_cache_claimed and player_position.distance_to(WATCHTOWER_CACHE_POSITION) <= WATCHTOWER_CACHE_RANGE
	nearby_frostfall_route = watchtower_discovered and player_position.distance_to(FROSTFALL_ROUTE_POSITION) <= FROSTFALL_ROUTE_RANGE
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
		elif event.keycode == KEY_B:
			_try_ultimate()
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
		elif event.keycode == KEY_J:
			_toggle_codex()
	if event is InputEventScreenTouch:
		if event.pressed and codex_open:
			_handle_action_touch(event.position)
		elif event.pressed and event.position.distance_to(JOYSTICK_CENTER) <= JOYSTICK_RADIUS * 1.65:
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
	if codex_open:
		if CODEX_CLOSE_RECT.has_point(screen_position) or not Rect2(260.0, 112.0, 760.0, 500.0).has_point(screen_position):
			codex_open = false
			queue_redraw()
		return
	if CODEX_BUTTON_RECT.has_point(screen_position):
		_toggle_codex()
		return
	if RUNE_BUTTON_RECT.has_point(screen_position):
		if rune_nearby:
			_interact_with_ancient_rune()
		elif nearby_ancient_chest:
			_claim_ancient_chest()
		elif nearby_northbound_signal:
			_inspect_northbound_signal()
		elif nearby_watchtower_symbol >= 0:
			_inspect_watchtower_symbol(nearby_watchtower_symbol)
		elif nearby_watchtower_cache:
			_claim_watchtower_cache()
		elif nearby_frostfall_route:
			_open_frostfall_pass()
		elif nearby_frostwatch_relic:
			_inspect_frostwatch_relic()
		elif nearby_watchtower_path:
			_enter_forgotten_watchtower()
		elif nearby_shattered_beacon:
			_activate_shattered_beacon()
		elif nearby_memory_exit:
			_enter_shattered_reach()
		elif nearby_hidden_gate:
			_interact_with_hidden_gate()
		elif nearby_ruin_object >= 0:
			_inspect_ruin_object(nearby_ruin_object)
		return
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
	elif screen_position.distance_to(_ultimate_button_center()) <= 60.0:
		_try_ultimate()
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

func _current_passive_data() -> Dictionary:
	var specs: Array = _current_class_data()["specs"]
	return PASSIVE_DATA.get(String(specs[clampi(specialization_index, 0, specs.size() - 1)]), {})

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

func _current_equipment_set_bonus() -> Dictionary:
	var bonus := {"name": "UNBOUND", "damage": 1.0, "armor": 0, "crit": 0.0, "heal": 0}
	if weapon_enchant >= 2 and armor_enchant >= 2:
		bonus = {"name": "RUINFORGED 2/2", "damage": 1.05, "armor": 2, "crit": 0.02, "heal": 1}
	if weapon_enchant >= 4 and armor_enchant >= 4:
		bonus = {"name": "ANCIENT GUARDIAN 2/2", "damage": 1.08, "armor": 4, "crit": 0.04, "heal": 2}
	return bonus

func _current_legendary_affix() -> Dictionary:
	var spec_name := String((_current_class_data()["specs"] as Array)[specialization_index])
	var affix := {"name": "DORMANT RELIC", "damage": 1.0, "skill": 1.0, "armor": 0, "crit": 0.0, "heal": 0}
	if weapon_enchant >= 4:
		affix["name"] = spec_name.to_upper() + " EDGE"
		match spec_name:
			"Weaponmaster", "Reaver", "Executioner", "Way of the Fist":
				affix["damage"] = 1.08
			"Shadow", "Deadeye", "Stormcaller", "Way of the Gale":
				affix["crit"] = 0.04
			"Elementalist", "Archmage", "Artillerist", "Gravecaller":
				affix["skill"] = 1.10
	if armor_enchant >= 4:
		affix["name"] = spec_name.to_upper() + " WARD" if weapon_enchant < 4 else spec_name.to_upper() + " RELIC"
		match spec_name:
			"Warden", "Juggernaut", "Justicar", "Aegis Smith":
				affix["armor"] = 3
			"Soulweaver", "Grovekeeper", "Sunkeeper", "Beastmaster":
				affix["heal"] = 3
			"Phantom", "Pathfinder", "Shapebinder", "Tinkerer":
				affix["armor"] = 1
	if memory_relic_owned:
		affix["name"] = "RELIC OF MEMORY"
		affix["damage"] = float(affix["damage"]) * 1.08
		affix["skill"] = float(affix["skill"]) * 1.10
		affix["crit"] = float(affix["crit"]) + 0.03
		affix["armor"] = int(affix["armor"]) + 2
	return affix

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

func _ultimate_button_center() -> Vector2:
	return Vector2(WORLD_SIZE.x - 405.0, WORLD_SIZE.y - 230.0)

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
		elif mob_name == "Memory Guardian":
			attack_range = 54.0
			windup_duration = 0.78
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
						_apply_incoming_damage(34 if guardian_enraged else 28, "SLAM")
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
						_apply_incoming_damage(int(mob["damage"]), "")
					mob["attack_cooldown"] = 0.85 if mob_name != "Ruin Guardian" else 1.25
			elif local_attack_cooldown <= 0.0:
				mob["attack_windup"] = windup_duration
		else:
			mob["attack_windup"] = 0.0
		mob["pos"] = mob_pos
		mobs[i] = mob

func _apply_incoming_damage(raw_damage: int, label: String) -> void:
	var passive := _current_passive_data()
	if randf() < clampf(float(passive.get("evade", 0.0)), 0.0, 0.08):
		combat_effects.append({"kind": "dodge", "pos": player_position, "dir": dodge_direction, "life": 0.28, "duration": 0.28})
		_show_passive_proc("PASSIVE: %s • EVADE" % String(passive.get("name", "DODGE")), player_position, Color("#9fe6ef"))
		return
	var set_bonus := _current_equipment_set_bonus()
	var legendary_affix := _current_legendary_affix()
	var armor_bonus := int(_current_class_data().get("armor", 0)) + int(_current_specialization_data().get("armor", 0)) + int(_current_talent_bonus()["armor"]) + int(passive.get("armor", 0)) + int(set_bonus["armor"]) + int(legendary_affix["armor"])
	var reduction := clampf(float(passive.get("damage_reduce", 0.0)), 0.0, 0.08)
	var damage := maxi(1, int(round(float(maxi(1, raw_damage - armor_tier * 2 - armor_enchant * 2 - armor_bonus)) * (1.0 - reduction))))
	player_hp -= damage
	player_hit_flash = 0.24
	var prefix := label + " -" if not label.is_empty() else "-"
	_add_floating_message("%s%d" % [prefix, damage], player_position + Vector2(0, -45), Color("#ff8d69") if not label.is_empty() else Color("#f28f82"))
	if player_hp <= 0:
		player_hp = player_max_hp
		player_position = WORLD_SIZE * 0.5

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
		if float(_current_passive_data().get("combo", 0.0)) > 0.0:
			_show_passive_proc("PASSIVE COMBO +%d%%" % int(round(float(_current_passive_data()["combo"]) * 100.0)), player_position, Color("#b8e8a0"))
	elif combo_count == 5:
		_add_floating_message("COMBO x5! +35%", player_position + Vector2(0, -68), Color("#ffd56f"))
		if float(_current_passive_data().get("combo", 0.0)) > 0.0:
			_show_passive_proc("PASSIVE COMBO +%d%%" % int(round(float(_current_passive_data()["combo"]) * 100.0)), player_position, Color("#b8e8a0"))
	ultimate_charge = minf(100.0, ultimate_charge + 12.0 + float(_current_passive_data().get("charge", 0.0)))
	var slash_direction := (Vector2(target["pos"]) - player_position).normalized()
	combat_effects.append({"kind": "slash", "pos": player_position, "dir": slash_direction, "life": 0.20, "duration": 0.20})
	var class_data := _current_class_data()
	var spec_data := _current_specialization_data()
	var talent_bonus := _current_talent_bonus()
	var passive := _current_passive_data()
	var passive_attack_multiplier := clampf(float(passive.get("attack", 1.0)), 0.90, 1.16)
	var set_bonus := _current_equipment_set_bonus()
	var legendary_affix := _current_legendary_affix()
	var damage := int(round(float(20 + weapon_tier * 8 + weapon_enchant * 4) * float(class_data.get("damage", 1.0)) * float(spec_data.get("damage", 1.0)) * passive_attack_multiplier * float(talent_bonus["damage"]) * float(set_bonus["damage"]) * float(legendary_affix["damage"])))
	if echo_surge_time > 0.0:
		damage = int(round(float(damage) * 1.12))
	if String(class_data["name"]) == "Berserker" and float(player_hp) / float(player_max_hp) <= 0.4:
		damage = int(round(float(damage) * 1.25))
	var combo_bonus := 0.35 if combo_count >= 5 else (0.15 if combo_count >= 3 else 0.0)
	combo_bonus += float(passive.get("combo", 0.0)) if combo_count >= 3 else 0.0
	damage = int(round(float(damage) * (1.0 + combo_bonus)))
	var critical_chance := minf(0.45, 0.08 + float(weapon_enchant) * 0.04 + float(class_data.get("crit", 0.0)) + float(spec_data.get("crit", 0.0)) + float(talent_bonus["crit"]) + float(passive.get("crit", 0.0)) + float(set_bonus["crit"]) + float(legendary_affix["crit"]))
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
	var spec_name := String((class_data["specs"] as Array)[specialization_index])
	var skill_radius := 150.0
	if spec_name == "Elementalist" or spec_name == "Artillerist" or spec_name == "Stormcaller":
		skill_radius = 190.0
	elif spec_name == "Deadeye" or spec_name == "Pathfinder":
		skill_radius = 165.0
	for mob in mobs:
		if not mob["alive"]:
			continue
		if player_position.distance_to(mob["pos"]) <= skill_radius:
			var talent_bonus := _current_talent_bonus()
			var passive := _current_passive_data()
			var passive_skill_multiplier := clampf(float(passive.get("skill", 1.0)), 0.90, 1.18)
			var set_bonus := _current_equipment_set_bonus()
			var legendary_affix := _current_legendary_affix()
			var damage := int(round(float(35 + weapon_tier * 5 + weapon_enchant * 3) * float(class_data.get("skill", 1.0)) * float(spec_data.get("skill", 1.0)) * passive_skill_multiplier * float(talent_bonus["skill"]) * float(set_bonus["damage"]) * float(legendary_affix["damage"]) * float(legendary_affix["skill"])))
			if echo_surge_time > 0.0:
				damage = int(round(float(damage) * 1.12))
			var critical_chance := minf(0.30, 0.05 + float(weapon_enchant) * 0.03 + float(class_data.get("crit", 0.0)) * 0.5 + float(spec_data.get("crit", 0.0)) + float(talent_bonus["crit"]) + float(passive.get("crit", 0.0)) + float(set_bonus["crit"]) + float(legendary_affix["crit"]))
			if spec_name == "Executioner" and float(mob["hp"]) / maxf(1.0, float(mob["max_hp"])) <= 0.35:
				damage = int(round(float(damage) * 1.35))
				_add_floating_message("EXECUTE!", Vector2(mob["pos"]) + Vector2(0, -66), Color("#ff8b78"))
			if spec_name == "Bloodfury" and float(player_hp) / float(player_max_hp) <= 0.5:
				damage = int(round(float(damage) * 1.2))
			var is_critical := randf() < critical_chance
			if is_critical:
				damage = int(round(float(damage) * 1.5))
				critical_flash = 0.24
				combat_effects.append({"kind": "critical", "pos": Vector2(mob["pos"]), "life": 0.34, "duration": 0.34})
				_add_floating_message("SKILL CRIT! -%d" % damage, Vector2(mob["pos"]) + Vector2(0, -52), Color("#ffd56f"))
			else:
				_add_floating_message("-%d" % damage, Vector2(mob["pos"]) + Vector2(0, -36), Color("#a8d8ef"))
			mob["hp"] = int(mob["hp"]) - damage
			if spec_name == "Soulweaver" or spec_name == "Grovekeeper" or spec_name == "Justicar":
				var base_heal := 7 if spec_name == "Soulweaver" else (6 if spec_name == "Grovekeeper" else 4)
				var heal_amount := base_heal + int(passive.get("heal", 0)) + int(talent_bonus["heal"])
				var old_hp := player_hp
				player_hp = mini(player_max_hp, player_hp + heal_amount)
				if player_hp > old_hp:
					_add_floating_message("HEAL +%d" % (player_hp - old_hp), player_position + Vector2(0, -52), Color("#a8e6a0"))
			if spec_name == "Warden" or spec_name == "Juggernaut" or spec_name == "Aegis Smith":
				player_hp = mini(player_max_hp, player_hp + 2)
			mob["hit_flash"] = 0.18
			combat_effects.append({"kind": "hit", "pos": Vector2(mob["pos"]), "life": 0.18, "duration": 0.18})
			hit_any = true
			ultimate_charge = minf(100.0, ultimate_charge + 15.0 + float(passive.get("charge", 0.0)))
			if int(mob["hp"]) <= 0:
				_defeat_mob(mob)
	if hit_any:
		var passive_name := String(_current_passive_data().get("name", ""))
		_show_passive_proc("PASSIVE SKILL: %s" % passive_name, player_position, Color("#b8e8a0"))
		_save_progress()
	queue_redraw()

func _try_ultimate() -> void:
	if ultimate_charge < 100.0:
		_add_floating_message("ULTIMATE %d%%" % int(ultimate_charge), player_position + Vector2(0, -60), Color("#d7c59f"))
		return
	var class_data := _current_class_data()
	var spec_data := _current_specialization_data()
	var spec_name := String((class_data["specs"] as Array)[specialization_index])
	var ultimate: Dictionary = ULTIMATE_DATA.get(spec_name, {"name": "Ascendant Strike", "power": 1.25, "radius": 220.0, "heal": 0})
	ultimate_charge = 0.0
	var radius := float(ultimate["radius"])
	var passive := _current_passive_data()
	var talent_bonus := _current_talent_bonus()
	var power := float(ultimate["power"]) * clampf(float(passive.get("ultimate", 1.0)), 0.90, 1.12)
	var passive_skill_multiplier := clampf(float(passive.get("skill", 1.0)), 0.90, 1.18)
	var set_bonus := _current_equipment_set_bonus()
	var legendary_affix := _current_legendary_affix()
	var base_damage := float(70 + weapon_tier * 10 + weapon_enchant * 5) * float(set_bonus["damage"]) * float(legendary_affix["damage"]) * float(legendary_affix["skill"])
	if echo_surge_time > 0.0:
		base_damage *= 1.12
	combat_effects.append({"kind": "ultimate", "pos": player_position, "life": 0.72, "duration": 0.72})
	_add_floating_message(String(ultimate["name"]) + "!", player_position + Vector2(0, -76), Color("#ffd28b"))
	_show_passive_proc("PASSIVE ULTIMATE: %s" % String(passive.get("name", "ASCENDANT")), player_position, Color("#b8e8a0"))
	var hit_count := 0
	for mob in mobs:
		if not bool(mob.get("alive", false)):
			continue
		if player_position.distance_to(Vector2(mob["pos"])) > radius:
			continue
		var damage := int(round(base_damage * power * float(class_data.get("skill", 1.0)) * float(spec_data.get("skill", 1.0)) * passive_skill_multiplier * float(talent_bonus["skill"])))
		if spec_name == "Executioner" and float(mob["hp"]) / maxf(1.0, float(mob["max_hp"])) <= 0.35:
			damage = int(round(float(damage) * 1.5))
		elif spec_name == "Bloodfury" and float(player_hp) / float(player_max_hp) <= 0.5:
			damage = int(round(float(damage) * 1.25))
		mob["hp"] = int(mob["hp"]) - damage
		mob["hit_flash"] = 0.32
		combat_effects.append({"kind": "hit", "pos": Vector2(mob["pos"]), "life": 0.26, "duration": 0.26})
		_add_floating_message("ULT -%d" % damage, Vector2(mob["pos"]) + Vector2(0, -58), Color("#ffd28b"))
		hit_count += 1
		if int(mob["hp"]) <= 0:
			_defeat_mob(mob)
	var heal_amount := int(ultimate["heal"]) + int(passive.get("heal", 0)) + int(talent_bonus["heal"]) + int(legendary_affix["heal"])
	if hit_count > 0 and heal_amount > 0:
		var old_hp := player_hp
		player_hp = mini(player_max_hp, player_hp + heal_amount)
		if player_hp > old_hp:
			_add_floating_message("ULTIMATE HEAL +%d" % (player_hp - old_hp), player_position + Vector2(0, -48), Color("#a8e6a0"))
	if hit_count == 0:
		_add_floating_message("NO TARGETS IN RANGE", player_position + Vector2(0, -52), Color("#e6b2a5"))
	_save_progress()
	queue_redraw()

func _defeat_mob(mob: Dictionary) -> void:
	if not mob["alive"]:
		return
	var is_boss := bool(mob.get("boss", false))
	var is_memory_boss := String(mob["name"]) == "Memory Guardian"
	mob["alive"] = false
	if not is_boss:
		mob["respawn_timer"] = 8.0
	elif is_memory_boss:
		memory_guardian_defeated = true
		memory_relic_owned = true
		shattered_reach_unlocked = true
		player_coins += 300
		relic_shards += 5
		guardian_cores += 1
		_discover_codex_entry(10)
		_add_floating_message("RELIC OF MEMORY CLAIMED  •  +8% DAMAGE / +10% SKILL", player_position + Vector2(0, -94), Color("#83e8e0"))
	else:
		guardian_defeated = true
		_discover_codex_entry(2)
	kills += 1
	_spawn_loot_drop(mob["pos"], "coins", (35 + player_level * 3) if is_boss else (3 + player_level))
	_spawn_loot_drop(mob["pos"] + Vector2(-15, 8), "herbs", 1 + int(kills % 2))
	if is_boss:
		_spawn_loot_drop(mob["pos"] + Vector2(0, -28), "echo", 3)
	elif randf() < 0.24:
		_spawn_loot_drop(mob["pos"] + Vector2(0, -20), "echo", 1)
	if int(mob["xp"]) >= 28:
		_spawn_loot_drop(mob["pos"] + Vector2(15, -8), "relic", 4 if is_boss else 1)
	if is_boss:
		_spawn_loot_drop(mob["pos"] + Vector2(-26, -18), "guardian_core", 1)
		_spawn_loot_drop(mob["pos"] + Vector2(26, -18), "ancient_cache", 1)
		_add_floating_message("MEMORY GUARDIAN DEFEATED!" if is_memory_boss else "GUARDIAN DEFEATED!", mob["pos"] + Vector2(0, -74), Color("#83e8e0") if is_memory_boss else Color("#ffd28b"))
	_gain_xp(int(mob["xp"]))
	if not is_boss:
		_ensure_guardian_encounter()
	var passive := _current_passive_data()
	var set_bonus := _current_equipment_set_bonus()
	var class_kill_heal := int(_current_class_data().get("kill_heal", 0)) + int(_current_specialization_data().get("heal", 0)) + int(_current_talent_bonus()["heal"]) + int(passive.get("heal", 0)) + int(set_bonus["heal"])
	if class_kill_heal > 0:
		player_hp = mini(player_max_hp, player_hp + class_kill_heal)
		_add_floating_message("CLASS HEAL +%d" % class_kill_heal, player_position + Vector2(0, -46), Color("#a8e6a0"))
	if kills >= 3 and not quest_reward_claimed:
		quest_reward_claimed = true
		_gain_xp(60)
		player_coins += 25
	if kills >= 5 and not second_quest_reward_claimed:
		second_quest_reward_claimed = true
		_gain_xp(100)
		player_coins += 50
	_save_progress()

func _toggle_codex() -> void:
	codex_open = not codex_open
	queue_redraw()

func _discover_codex_entry(entry_id: int) -> void:
	var titles: Array[String] = [
		"A Voice in the Ash", "Resonance Awakened", "Memory of the Guardian", "The Cache Inscription",
		"The First Convergence", "The Rune of Convergence", "The Watchstone Road", "The Pilgrim's Oath",
		"The Sealed Memory", "The Hall Beneath", "The Memory Guardian", "The Shattered Reach",
		"The First Beacon", "The Northbound Signal", "The Forgotten Watchtower", "Frostwatch Relic",
		"First Watchtower Symbol", "Second Watchtower Symbol", "Third Watchtower Symbol",
		"The Watchtower Memory Cache", "The Road to Frostfall Pass"
	]
	if entry_id < 0 or entry_id >= titles.size():
		return
	var entry_bit := 1 << entry_id
	if (codex_entries & entry_bit) != 0:
		return
	codex_entries |= entry_bit
	var reward_xp := 300 if entry_id == 13 else (250 if entry_id == 12 else (200 if entry_id == 11 else (400 if entry_id == 10 else (150 if entry_id == 5 else (100 if entry_id == 4 else (35 + (entry_id - 14) * 10 if entry_id >= 14 else 20))))))
	var reward_coins := 150 if entry_id == 13 else (125 if entry_id == 12 else (100 if entry_id == 11 else (250 if entry_id == 10 else (75 if entry_id == 5 else (50 if entry_id == 4 else (15 + (entry_id - 14) * 5 if entry_id >= 14 else 10))))))
	_gain_xp(reward_xp)
	player_coins += reward_coins
	_add_floating_message("CODEX FOUND: %s" % titles[entry_id], player_position + Vector2(0, -68), Color("#83e8e0"))
	if entry_id == 5:
		_add_floating_message("ANCIENT RUNE AWAKENED  •  +%d XP / +%d COINS" % [reward_xp, reward_coins], player_position + Vector2(0, -92), Color("#ffd28b"))
	elif entry_id == 4:
		_add_floating_message("MYSTERY THREAD COMPLETE  •  +%d XP / +%d COINS" % [reward_xp, reward_coins], player_position + Vector2(0, -92), Color("#ffd28b"))
	elif (codex_entries & 15) == 15:
		_discover_codex_entry(4)
	_save_progress()
	queue_redraw()

func _interact_with_ancient_rune() -> void:
	if rune_activated:
		_add_floating_message("THE RUNE IS ALREADY AWAKE", player_position + Vector2(0, -58), Color("#83e8e0"))
		return
	if not rune_studied:
		rune_studied = true
		_add_floating_message("RUNE STUDIED: FOUR ECHOES FORM ONE PATH", player_position + Vector2(0, -68), Color("#83e8e0"))
	if (codex_entries & 15) != 15:
		_add_floating_message("THE RUNE IS DORMANT • FIND ALL FOUR TRACES", player_position + Vector2(0, -92), Color("#d7c59f"))
		_save_progress()
		queue_redraw()
		return
	rune_activated = true
	_discover_codex_entry(5)
	_add_floating_message("ANCIENT RUNE ACTIVATED", ANCIENT_RUNE_POSITION + Vector2(0, -54), Color("#83e8e0"))
	_update_hidden_passage_unlock()
	_save_progress()
	queue_redraw()

func _update_hidden_passage_unlock() -> void:
	if hidden_passage_open or not rune_activated or (codex_entries & 448) != 448:
		return
	hidden_passage_open = true
	_discover_codex_entry(9)
	_add_floating_message("THE HIDDEN PASSAGE OPENS", HIDDEN_GATE_POSITION + Vector2(0, -42), Color("#83e8e0"))
	_add_floating_message("A forgotten hall stirs beyond the stone", HIDDEN_GATE_POSITION + Vector2(0, -64), Color("#d7c59f"))
	_save_progress()
	queue_redraw()

func _interact_with_hidden_gate() -> void:
	if hidden_passage_open:
		player_position = Vector2(1110.0, 320.0)
		_add_floating_message("ENTERED THE ANCIENT HALL", player_position + Vector2(0, -58), Color("#83e8e0"))
		queue_redraw()
		return
	_add_floating_message("THE GATE NEEDS THE AWAKENED RUNE AND THREE RELIC TRACES", player_position + Vector2(0, -68), Color("#d7c59f"))

func _enter_shattered_reach() -> void:
	if not memory_guardian_defeated or not shattered_reach_unlocked:
		_add_floating_message("THE EXIT IS SEALED BY THE MEMORY GUARDIAN", player_position + Vector2(0, -62), Color("#d7c59f"))
		return
	player_position = SHATTERED_REACH_ENTRY_POSITION
	shattered_reach_discovered = true
	_discover_codex_entry(11)
	_add_floating_message("THE SHATTERED REACH", player_position + Vector2(0, -70), Color("#83e8e0"))
	_add_floating_message("THE FIRST BEACON HAS GONE DARK", player_position + Vector2(0, -94), Color("#d7c59f"))
	_save_progress()
	queue_redraw()


func _activate_shattered_beacon() -> void:
	if not shattered_reach_unlocked or not shattered_reach_discovered:
		_add_floating_message("THE BEACON IS BEYOND YOUR REACH", player_position + Vector2(0, -62), Color("#d7c59f"))
		return
	if shattered_beacon_activated:
		_add_floating_message("THE FIRST BEACON IS ALREADY AWAKE", player_position + Vector2(0, -62), Color("#83e8e0"))
		return
	shattered_beacon_activated = true
	_discover_codex_entry(12)
	_add_floating_message("FIRST BEACON RESTORED", player_position + Vector2(0, -70), Color("#9dffe2"))
	_add_floating_message("A LIGHT ANSWERS FROM THE FAR NORTH", player_position + Vector2(0, -94), Color("#ffd28b"))
	_save_progress()
	queue_redraw()


func _inspect_northbound_signal() -> void:
	if not shattered_beacon_activated:
		return
	if northbound_signal_discovered:
		_add_floating_message("THE NORTHBOUND TRACE IS ALREADY RECORDED", player_position + Vector2(0, -62), Color("#83e8e0"))
		return
	northbound_signal_discovered = true
	_discover_codex_entry(13)
	_add_floating_message("A SECOND LIGHT ANSWERS FROM THE NORTH", player_position + Vector2(0, -70), Color("#9dffe2"))
	_add_floating_message("THE BROKEN ROAD LEADS TO A FORGOTTEN WATCHTOWER", player_position + Vector2(0, -94), Color("#ffd28b"))
	_save_progress()
	queue_redraw()


func _enter_forgotten_watchtower() -> void:
	if not northbound_signal_discovered:
		_add_floating_message("THE NORTHERN ROAD IS STILL LOST", player_position + Vector2(0, -62), Color("#d7c59f"))
		return
	watchtower_path_open = true
	watchtower_discovered = true
	player_position = Vector2(730.0, 590.0)
	_discover_codex_entry(14)
	_add_floating_message("THE FORGOTTEN WATCHTOWER", player_position + Vector2(0, -70), Color("#b9dff2"))
	_add_floating_message("A COLD WIND CARRIES OLD WHISPERS", player_position + Vector2(0, -94), Color("#d7c59f"))
	_save_progress()
	queue_redraw()


func _inspect_frostwatch_relic() -> void:
	if not watchtower_discovered or frostwatch_relic_discovered:
		return
	frostwatch_relic_discovered = true
	_discover_codex_entry(15)
	echo_shards += 1
	player_xp += 20
	_process_level_ups()
	_add_floating_message("FROSTWATCH RELIC RECOVERED", player_position + Vector2(0, -70), Color("#b9dff2"))
	_add_floating_message("ECHO SHARD +1  •  XP +20", player_position + Vector2(0, -94), Color("#9dffe2"))
	_save_progress()
	queue_redraw()


func _inspect_watchtower_symbol(symbol_index: int) -> void:
	if not watchtower_discovered or symbol_index < 0 or symbol_index >= WATCHTOWER_SYMBOL_POSITIONS.size():
		return
	var symbol_bit := 1 << symbol_index
	if (watchtower_symbols & symbol_bit) != 0:
		return
	watchtower_symbols |= symbol_bit
	_discover_codex_entry(16 + symbol_index)
	var symbol_names: Array[String] = ["FIRST", "SECOND", "THIRD"]
	_add_floating_message("%s ANCIENT SYMBOL READ" % symbol_names[symbol_index], player_position + Vector2(0, -70), Color("#b9dff2"))
	if watchtower_symbols == 7:
		_add_floating_message("THE THREE SYMBOLS ALIGN — THE CACHE STIRS", player_position + Vector2(0, -94), Color("#83e8e0"))
	_save_progress()
	queue_redraw()


func _claim_watchtower_cache() -> void:
	if not watchtower_discovered or watchtower_symbols != 7 or watchtower_cache_claimed:
		return
	watchtower_cache_claimed = true
	relic_shards += 2
	player_coins += 75
	_gain_xp(60)
	_discover_codex_entry(19)
	_add_floating_message("WATCHTOWER MEMORY CACHE OPENED", player_position + Vector2(0, -70), Color("#ffd28b"))
	_add_floating_message("+2 RELIC SHARDS  •  +75 COINS  •  +60 XP", player_position + Vector2(0, -94), Color("#83e8e0"))
	_save_progress()
	queue_redraw()


func _open_frostfall_pass() -> void:
	if not watchtower_discovered:
		return
	if not (watchtower_symbols == 7 and watchtower_cache_claimed and frostwatch_relic_discovered):
		_add_floating_message("THE PASS NEEDS THREE SYMBOLS, THE CACHE, AND THE FROSTWATCH RELIC", player_position + Vector2(0, -70), Color("#d7c59f"))
		return
	if frostfall_pass_open:
		_add_floating_message("FROSTFALL PASS IS ALREADY OPEN", player_position + Vector2(0, -62), Color("#83e8e0"))
		return
	frostfall_pass_open = true
	_discover_codex_entry(20)
	echo_shards += 1
	_gain_xp(40)
	_add_floating_message("FROSTFALL PASS UNSEALED", player_position + Vector2(0, -70), Color("#b9dff2"))
	_add_floating_message("A NEW ROUTE OPENS BEYOND THE WATCHTOWER", player_position + Vector2(0, -94), Color("#83e8e0"))
	_save_progress()
	queue_redraw()


func _claim_ancient_chest() -> void:
	if not hidden_passage_open or ancient_chest_claimed:
		return
	ancient_chest_claimed = true
	player_coins += 150
	relic_shards += 3
	herbs += 5
	ancient_caches += 1
	_gain_xp(250)
	_add_floating_message("ANCIENT CACHE CLAIMED  •  +250 XP / +150 COINS", player_position + Vector2(0, -70), Color("#ffd28b"))
	_add_floating_message("+3 RELIC SHARDS  •  +5 HERBS", player_position + Vector2(0, -92), Color("#83e8e0"))
	_ensure_memory_guardian_encounter()
	_save_progress()
	queue_redraw()

func _inspect_ruin_object(object_index: int) -> void:
	if object_index < 0 or object_index >= RUIN_OBJECT_POSITIONS.size():
		return
	var entry_id := 6 + object_index
	if (codex_entries & (1 << entry_id)) != 0:
		return
	var object_names: Array[String] = ["Cracked Watchstone", "Pilgrim's Inscription", "Sealed Memory Cache"]
	var discoveries: Array[String] = [
		"The watchstone points toward a forgotten road.",
		"The inscription speaks of three keepers and one oath.",
		"The sealed cache reacts to the rune's distant pulse."
	]
	_add_floating_message(discoveries[object_index], player_position + Vector2(0, -68), Color("#d7c59f"))
	_discover_codex_entry(entry_id)
	_add_floating_message("RELIC INSPECTED: %s" % object_names[object_index], player_position + Vector2(0, -92), Color("#83e8e0"))
	_update_hidden_passage_unlock()
	_save_progress()
	queue_redraw()

func _activate_echo_surge() -> void:
	if echo_shards < 3 or echo_surge_time > 0.0:
		return
	echo_shards -= 3
	echo_surge_time = 12.0
	_discover_codex_entry(1)
	_show_passive_proc("WORLD ECHO RESONANCE  •  DAMAGE +12%", player_position, Color("#83e8e0"))
	_save_progress()
	queue_redraw()

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


func _ensure_memory_guardian_encounter() -> void:
	if not hidden_passage_open or not ancient_chest_claimed or memory_guardian_defeated:
		return
	for mob in mobs:
		if String(mob["name"]) == "Memory Guardian":
			return
	mobs.append({
		"name": "Memory Guardian",
		"pos": Vector2(1120.0, 350.0),
		"hp": 520,
		"max_hp": 520,
		"damage": 23,
		"speed": 34.0,
		"xp": 420,
		"alive": true,
		"boss": true,
		"memory_boss": true
	})
	_add_floating_message("THE MEMORY GUARDIAN AWAKENS", Vector2(1110.0, 290.0), Color("#83e8e0"))
	_add_floating_message("A LAST KEEPER STANDS BETWEEN YOU AND THE RELIC", Vector2(1110.0, 270.0), Color("#d7c59f"))

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
					_discover_codex_entry(3)
					label = "ANCIENT CACHE ACQUIRED"
					message_color = Color("#e7d49a")
				"echo":
					echo_shards += amount
					_discover_codex_entry(0)
					label = "+%d WORLD ECHO" % amount
					message_color = Color("#83e8e0")
					if echo_surge_time <= 0.0:
						_activate_echo_surge()
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

func _show_passive_proc(message: String, effect_position: Vector2, effect_color: Color) -> void:
	combat_effects.append({
		"kind": "passive_proc",
		"pos": effect_position,
		"color": effect_color,
		"life": 0.46,
		"duration": 0.46
	})
	_add_floating_message(message, effect_position + Vector2(0, -72), effect_color)

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
	if amount <= 0 or player_level >= MAX_PLAYER_LEVEL:
		return
	player_xp += amount
	_process_level_ups()

func _process_level_ups() -> void:
	while player_level < MAX_PLAYER_LEVEL and player_xp >= _xp_for_next_level():
		player_xp -= _xp_for_next_level()
		player_level += 1
		player_max_hp += 12
		if player_level % 2 == 0:
			talent_points += 1
			_add_floating_message("TALENT POINT +1", player_position + Vector2(0, -88), Color("#b8e8a0"))
		player_hp = player_max_hp
		_add_floating_message("LEVEL UP!  %d" % player_level, player_position + Vector2(0, -68), Color("#f2d58b"))
	if player_level >= MAX_PLAYER_LEVEL:
		player_xp = 0
		_add_floating_message("MAX LEVEL REACHED", player_position + Vector2(0, -92), Color("#ffd28b"))

func _xp_for_next_level() -> int:
	if player_level >= MAX_PLAYER_LEVEL:
		return 0
	return 50 + (player_level - 1) * 35

func _save_progress() -> void:
	var data := {
		"save_version": 6,
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
		"echo_shards": echo_shards,
		"codex_entries": codex_entries,
		"rune_studied": rune_studied,
		"rune_activated": rune_activated,
		"hidden_passage_open": hidden_passage_open,
		"ancient_chest_claimed": ancient_chest_claimed,
		"memory_guardian_defeated": memory_guardian_defeated,
		"memory_relic_owned": memory_relic_owned,
		"shattered_reach_unlocked": shattered_reach_unlocked,
		"shattered_reach_discovered": shattered_reach_discovered,
		"shattered_beacon_activated": shattered_beacon_activated,
		"northbound_signal_discovered": northbound_signal_discovered,
		"watchtower_path_open": watchtower_path_open,
		"watchtower_discovered": watchtower_discovered,
		"frostwatch_relic_discovered": frostwatch_relic_discovered,
		"watchtower_symbols": watchtower_symbols,
		"watchtower_cache_claimed": watchtower_cache_claimed,
		"frostfall_pass_open": frostfall_pass_open,
		"weapon_enchant": weapon_enchant,
		"armor_enchant": armor_enchant,
		"player_hp": player_hp,
		"player_max_hp": player_max_hp,
		"player_position_x": player_position.x,
		"player_position_y": player_position.y
	}
	var temp_path := save_path + ".tmp"
	var backup_path := save_path + ".bak"
	var file := FileAccess.open(temp_path, FileAccess.WRITE)
	if file == null:
		_add_floating_message("SAVE FAILED: CANNOT WRITE", player_position + Vector2(0, -58), Color("#ff9877"))
		return
	file.store_string(JSON.stringify(data))
	file.close()
	var verify_file := FileAccess.open(temp_path, FileAccess.READ)
	if verify_file == null or typeof(JSON.parse_string(verify_file.get_as_text())) != TYPE_DICTIONARY:
		DirAccess.remove_absolute(ProjectSettings.globalize_path(temp_path))
		_add_floating_message("SAVE FAILED: VERIFY ERROR", player_position + Vector2(0, -58), Color("#ff9877"))
		return
	verify_file.close()
	var save_absolute := ProjectSettings.globalize_path(save_path)
	var temp_absolute := ProjectSettings.globalize_path(temp_path)
	var backup_absolute := ProjectSettings.globalize_path(backup_path)
	if FileAccess.file_exists(save_path):
		if FileAccess.file_exists(backup_path):
			DirAccess.remove_absolute(backup_absolute)
		var backup_error := DirAccess.copy_absolute(save_absolute, backup_absolute)
		if backup_error != OK:
			DirAccess.remove_absolute(temp_absolute)
			_add_floating_message("SAVE FAILED: BACKUP ERROR", player_position + Vector2(0, -58), Color("#ff9877"))
			return
		DirAccess.remove_absolute(save_absolute)
	var rename_error := DirAccess.rename_absolute(temp_absolute, save_absolute)
	if rename_error != OK:
		if FileAccess.file_exists(backup_path):
			DirAccess.copy_absolute(backup_absolute, save_absolute)
		_add_floating_message("SAVE FAILED: RESTORE BACKUP", player_position + Vector2(0, -58), Color("#ff9877"))

func _read_save_data(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {}
	var parsed = JSON.parse_string(file.get_as_text())
	file.close()
	if typeof(parsed) != TYPE_DICTIONARY:
		return {}
	return parsed

func _load_progress() -> void:
	var parsed := _read_save_data(save_path)
	if parsed.is_empty():
		parsed = _read_save_data(save_path + ".bak")
		if not parsed.is_empty():
			_add_floating_message("SAVE RESTORED FROM BACKUP", player_position + Vector2(0, -58), Color("#b8e8a0"))
	if parsed.is_empty():
		return
	player_level = clampi(int(parsed.get("level", 1)), 1, MAX_PLAYER_LEVEL)
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
	echo_shards = clampi(int(parsed.get("echo_shards", 0)), 0, 999999)
	codex_entries = clampi(int(parsed.get("codex_entries", 0)), 0, 2097151)
	rune_studied = bool(parsed.get("rune_studied", false))
	rune_activated = bool(parsed.get("rune_activated", false))
	hidden_passage_open = bool(parsed.get("hidden_passage_open", rune_activated and (codex_entries & 448) == 448))
	ancient_chest_claimed = bool(parsed.get("ancient_chest_claimed", false))
	memory_guardian_defeated = bool(parsed.get("memory_guardian_defeated", false))
	memory_relic_owned = bool(parsed.get("memory_relic_owned", memory_guardian_defeated))
	shattered_reach_unlocked = bool(parsed.get("shattered_reach_unlocked", memory_guardian_defeated))
	shattered_reach_discovered = bool(parsed.get("shattered_reach_discovered", false))
	shattered_beacon_activated = bool(parsed.get("shattered_beacon_activated", false))
	northbound_signal_discovered = bool(parsed.get("northbound_signal_discovered", false))
	watchtower_path_open = bool(parsed.get("watchtower_path_open", false))
	watchtower_discovered = bool(parsed.get("watchtower_discovered", false))
	frostwatch_relic_discovered = bool(parsed.get("frostwatch_relic_discovered", false))
	watchtower_symbols = clampi(int(parsed.get("watchtower_symbols", 0)), 0, 7)
	watchtower_cache_claimed = bool(parsed.get("watchtower_cache_claimed", false))
	frostfall_pass_open = bool(parsed.get("frostfall_pass_open", false))
	weapon_enchant = clampi(int(parsed.get("weapon_enchant", 0)), 0, 4)
	armor_enchant = clampi(int(parsed.get("armor_enchant", 0)), 0, 4)
	player_max_hp = clampi(int(parsed.get("player_max_hp", 100)), 100, 100000)
	player_hp = clampi(int(parsed.get("player_hp", player_max_hp)), 1, player_max_hp)
	player_position = Vector2(
		clampf(float(parsed.get("player_position_x", WORLD_SIZE.x * 0.5)), 36.0, WORLD_SIZE.x - 36.0),
		clampf(float(parsed.get("player_position_y", WORLD_SIZE.y * 0.5)), 70.0, WORLD_SIZE.y - 35.0)
	)

func _update_joystick(screen_position: Vector2) -> void:
	var offset := screen_position - JOYSTICK_CENTER
	joystick_vector = (offset / JOYSTICK_RADIUS).limit_length(1.0)

func _draw() -> void:
	_draw_ground()
	_draw_ruins()
	_draw_shattered_reach()
	_draw_forgotten_watchtower()
	_draw_hidden_hall()
	_draw_ruin_objects()
	_draw_hidden_gate()
	_draw_ancient_chest()
	_draw_memory_exit()
	_draw_ancient_rune()
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

func _draw_hidden_hall() -> void:
	if not hidden_passage_open:
		return
	var hall_rect := Rect2(1018.0, 292.0, 190.0, 166.0)
	draw_rect(Rect2(hall_rect.position + Vector2(5, 8), hall_rect.size), Color("#111c19"))
	draw_rect(hall_rect, Color("#393f37"))
	draw_rect(Rect2(hall_rect.position + Vector2(8, 8), hall_rect.size - Vector2(16, 16)), Color("#242f2a"))
	draw_rect(Rect2(hall_rect.position + Vector2(20, 20), hall_rect.size - Vector2(40, 40)), Color("#303b32"))
	for pillar_y in [hall_rect.position.y + 25.0, hall_rect.position.y + hall_rect.size.y - 35.0]:
		for pillar_x in [hall_rect.position.x + 20.0, hall_rect.position.x + hall_rect.size.x - 30.0]:
			draw_rect(Rect2(Vector2(pillar_x, pillar_y), Vector2(14, 24)), Color("#62685a"))
			draw_rect(Rect2(Vector2(pillar_x + 2, pillar_y + 2), Vector2(10, 4)), Color("#8c8a74"))
	for tile_index in range(5):
		var tile_x := hall_rect.position.x + 48.0 + float(tile_index) * 25.0
		draw_line(Vector2(tile_x, hall_rect.position.y + 28.0), Vector2(tile_x, hall_rect.position.y + hall_rect.size.y - 28.0), Color("#465249"), 1.5)
	var hall_glow := Color("#83e8e0")
	hall_glow.a = 0.06 + 0.03 * sin(elapsed * 1.6)
	draw_circle(Vector2(1112.0, 372.0), 62.0, hall_glow)
	draw_string(ThemeDB.fallback_font, Vector2(1042, 318), "THE HALL BELOW", HORIZONTAL_ALIGNMENT_LEFT, 145, 11, Color("#c7d8c5"))

func _draw_hidden_gate() -> void:
	var gate_color := Color("#83e8e0") if hidden_passage_open else Color("#777c6d")
	var gate_position := HIDDEN_GATE_POSITION
	draw_rect(Rect2(gate_position + Vector2(-31, -17), Vector2(62, 38)), Color("#242d28"))
	draw_rect(Rect2(gate_position + Vector2(-31, -17), Vector2(62, 38)), gate_color, false, 3.0)
	for bar_index in range(4):
		var bar_x := gate_position.x - 22.0 + float(bar_index) * 14.0
		if not hidden_passage_open:
			draw_line(Vector2(bar_x, gate_position.y - 14.0), Vector2(bar_x, gate_position.y + 18.0), gate_color, 3.0)
		else:
			draw_line(Vector2(bar_x, gate_position.y - 14.0), Vector2(bar_x - 11.0, gate_position.y + 16.0), gate_color, 2.0)
	if hidden_passage_open:
		var portal_glow := Color("#83e8e0")
		portal_glow.a = 0.12 + 0.07 * sin(elapsed * 2.2)
		draw_circle(gate_position, 44.0, portal_glow)
		draw_string(ThemeDB.fallback_font, gate_position + Vector2(-47, -27), "PASSAGE OPEN", HORIZONTAL_ALIGNMENT_LEFT, 100, 10, Color("#bff5e9"))

func _draw_memory_exit() -> void:
	if not hidden_passage_open or not shattered_reach_unlocked:
		return
	var portal_color := Color("#83e8e0")
	portal_color.a = 0.10 + 0.06 * sin(elapsed * 2.1)
	draw_circle(MEMORY_EXIT_POSITION, 38.0, portal_color)
	draw_arc(MEMORY_EXIT_POSITION, 26.0 + sin(elapsed * 2.4) * 2.0, 0.0, TAU, 40, Color("#b6fff2"), 3.0, true)
	draw_line(MEMORY_EXIT_POSITION + Vector2(0, -17), MEMORY_EXIT_POSITION + Vector2(0, 17), Color("#b6fff2"), 2.0)
	draw_line(MEMORY_EXIT_POSITION + Vector2(-12, 0), MEMORY_EXIT_POSITION + Vector2(12, 0), Color("#b6fff2"), 2.0)
	draw_string(ThemeDB.fallback_font, MEMORY_EXIT_POSITION + Vector2(-53, -36), "SHATTERED REACH", HORIZONTAL_ALIGNMENT_LEFT, 110, 9, Color("#bff5e9"))


func _draw_shattered_reach() -> void:
	if not shattered_reach_unlocked:
		return
	var zone_rect := Rect2(350.0, 500.0, 250.0, 150.0)
	draw_rect(Rect2(zone_rect.position + Vector2(4, 6), zone_rect.size), Color("#151c21"))
	draw_rect(zone_rect, Color("#303c42"))
	draw_rect(Rect2(zone_rect.position + Vector2(8, 8), zone_rect.size - Vector2(16, 16)), Color("#222e34"))
	for shard_index in range(7):
		var shard_x := zone_rect.position.x + 26.0 + float(shard_index) * 30.0
		var shard_y := zone_rect.position.y + 35.0 + float((shard_index * 19) % 62)
		draw_line(Vector2(shard_x, shard_y), Vector2(shard_x + 10.0, shard_y - 18.0), Color("#687f85"), 3.0)
		draw_line(Vector2(shard_x + 10.0, shard_y - 18.0), Vector2(shard_x + 21.0, shard_y + 3.0), Color("#52676f"), 2.0)
	var beacon_position := SHATTERED_BEACON_POSITION
	var beacon_glow := Color("#9dffe2") if shattered_beacon_activated else Color("#83e8e0")
	beacon_glow.a = (0.18 + 0.08 * sin(elapsed * 2.0)) if shattered_beacon_activated else (0.05 + 0.04 * sin(elapsed * 1.4))
	draw_circle(beacon_position, 42.0 if not shattered_beacon_activated else 58.0, beacon_glow)
	if shattered_beacon_activated:
		for ray_index in range(8):
			var ray_angle := TAU * float(ray_index) / 8.0 + elapsed * 0.08
			var ray_start := beacon_position + Vector2(cos(ray_angle), sin(ray_angle)) * 24.0
			var ray_end := beacon_position + Vector2(cos(ray_angle), sin(ray_angle)) * 49.0
			draw_line(ray_start, ray_end, Color("#b9ffe9"), 2.0)
		draw_line(beacon_position + Vector2(0, -23), beacon_position + Vector2(0, -68), Color("#b9ffe9"), 3.0)
		draw_circle(beacon_position + Vector2(0, -27), 5.0, Color("#e0fff5"))
	draw_rect(Rect2(beacon_position + Vector2(-9, -24), Vector2(18, 48)), Color("#719b91") if shattered_beacon_activated else Color("#4a5c60"))
	draw_arc(beacon_position, 27.0, 0.0, TAU, 32, Color("#b9ffe9") if shattered_beacon_activated else Color("#718c8e"), 2.0, true)
	draw_string(ThemeDB.fallback_font, zone_rect.position + Vector2(22, 22), "THE SHATTERED REACH", HORIZONTAL_ALIGNMENT_LEFT, 208, 12, Color("#c3e0df"))
	draw_string(ThemeDB.fallback_font, beacon_position + Vector2(-48, 47), "BEACON: AWAKENED" if shattered_beacon_activated else "BEACON: DORMANT", HORIZONTAL_ALIGNMENT_LEFT, 140, 10, Color("#b9ffe9") if shattered_beacon_activated else Color("#9bb5b7"))
	if shattered_beacon_activated:
		var signal_color := Color("#ffd28b") if northbound_signal_discovered else Color("#9dffe2")
		var signal_pulse := 0.65 + 0.35 * sin(elapsed * 2.2)
		draw_circle(NORTHBOUND_SIGNAL_POSITION, 19.0 + signal_pulse * 3.0, Color(signal_color.r, signal_color.g, signal_color.b, 0.08 + signal_pulse * 0.08))
		var signal_points := PackedVector2Array([NORTHBOUND_SIGNAL_POSITION + Vector2(0, -13), NORTHBOUND_SIGNAL_POSITION + Vector2(11, 0), NORTHBOUND_SIGNAL_POSITION + Vector2(0, 13), NORTHBOUND_SIGNAL_POSITION + Vector2(-11, 0)])
		draw_colored_polygon(signal_points, signal_color)
		draw_string(ThemeDB.fallback_font, NORTHBOUND_SIGNAL_POSITION + Vector2(-54, 30), "TRACE RECORDED" if northbound_signal_discovered else "NORTHBOUND TRACE", HORIZONTAL_ALIGNMENT_LEFT, 150, 9, signal_color)


func _draw_forgotten_watchtower() -> void:
	if not watchtower_path_open:
		if northbound_signal_discovered:
			var path_glow := Color("#b9dff2", 0.10 + 0.05 * sin(elapsed * 1.7))
			draw_line(NORTHBOUND_SIGNAL_POSITION + Vector2(12, 2), WATCHTOWER_PATH_POSITION + Vector2(-12, 0), Color("#8caab5", 0.55), 5.0)
			draw_circle(WATCHTOWER_PATH_POSITION, 20.0, path_glow)
			draw_string(ThemeDB.fallback_font, WATCHTOWER_PATH_POSITION + Vector2(-46, 36), "BROKEN NORTH ROAD", HORIZONTAL_ALIGNMENT_LEFT, 132, 9, Color("#b9dff2"))
		return
	var zone_rect := Rect2(620.0, 492.0, 300.0, 158.0)
	draw_rect(Rect2(zone_rect.position + Vector2(4, 6), zone_rect.size), Color("#111a20"))
	draw_rect(zone_rect, Color("#293a43"))
	draw_rect(Rect2(zone_rect.position + Vector2(8, 8), zone_rect.size - Vector2(16, 16)), Color("#202d35"))
	for shard_index in range(9):
		var shard_x := zone_rect.position.x + 20.0 + float(shard_index) * 30.0
		var shard_y := zone_rect.position.y + 36.0 + float((shard_index * 23) % 80)
		draw_line(Vector2(shard_x, shard_y), Vector2(shard_x + 9.0, shard_y - 16.0), Color("#647f8d"), 2.5)
	draw_rect(Rect2(710.0, 520.0, 42.0, 65.0), Color("#17242a"))
	draw_rect(Rect2(704.0, 514.0, 54.0, 10.0), Color("#536b77"))
	draw_rect(Rect2(718.0, 530.0, 9.0, 22.0), Color("#b9dff2"))
	draw_rect(Rect2(737.0, 530.0, 9.0, 22.0), Color("#b9dff2"))
	draw_line(Vector2(730.0, 514.0), Vector2(730.0, 490.0), Color("#839ca7"), 3.0)
	draw_line(Vector2(730.0, 490.0), Vector2(715.0, 501.0), Color("#839ca7"), 3.0)
	draw_line(Vector2(730.0, 490.0), Vector2(745.0, 501.0), Color("#839ca7"), 3.0)
	draw_string(ThemeDB.fallback_font, zone_rect.position + Vector2(18, 22), "THE FORGOTTEN WATCHTOWER", HORIZONTAL_ALIGNMENT_LEFT, 260, 12, Color("#c6e3f2"))
	var relic_glow := Color("#b9dff2", 0.15 + 0.08 * sin(elapsed * 2.0)) if not frostwatch_relic_discovered else Color("#83e8e0", 0.08)
	draw_circle(FROSTWATCH_RELIC_POSITION, 28.0, relic_glow)
	draw_polygon(PackedVector2Array([FROSTWATCH_RELIC_POSITION + Vector2(0, -15), FROSTWATCH_RELIC_POSITION + Vector2(12, 0), FROSTWATCH_RELIC_POSITION + Vector2(0, 15), FROSTWATCH_RELIC_POSITION + Vector2(-12, 0)]), PackedColorArray([Color("#b9dff2"), Color("#7199b2"), Color("#d6f0ff"), Color("#7199b2")]))
	draw_string(ThemeDB.fallback_font, FROSTWATCH_RELIC_POSITION + Vector2(-50, 32), "FROSTWATCH RELIC" if not frostwatch_relic_discovered else "RELIC RECOVERED", HORIZONTAL_ALIGNMENT_LEFT, 130, 9, Color("#b9dff2"))
	for symbol_index in range(WATCHTOWER_SYMBOL_POSITIONS.size()):
		var symbol_pos: Vector2 = WATCHTOWER_SYMBOL_POSITIONS[symbol_index]
		var symbol_found := (watchtower_symbols & (1 << symbol_index)) != 0
		var symbol_color := Color("#83e8e0") if symbol_found else Color("#b9dff2")
		var pulse := 0.6 + 0.4 * sin(elapsed * 2.0 + float(symbol_index))
		draw_circle(symbol_pos, 15.0 + pulse * 3.0, Color(symbol_color.r, symbol_color.g, symbol_color.b, 0.08 + pulse * 0.08))
		draw_line(symbol_pos + Vector2(-8, 0), symbol_pos + Vector2(8, 0), symbol_color, 2.0)
		draw_line(symbol_pos + Vector2(0, -9), symbol_pos + Vector2(0, 9), symbol_color, 2.0)
		draw_line(symbol_pos + Vector2(-6, -6), symbol_pos + Vector2(6, 6), symbol_color, 1.5)
		draw_string(ThemeDB.fallback_font, symbol_pos + Vector2(-22, 25), "MARK %d" % (symbol_index + 1) if not symbol_found else "READ", HORIZONTAL_ALIGNMENT_LEFT, 60, 9, symbol_color)
	var cache_color := Color("#ffd28b") if not watchtower_cache_claimed else Color("#71817c")
	draw_rect(Rect2(WATCHTOWER_CACHE_POSITION - Vector2(14, 10), Vector2(28, 20)), cache_color)
	draw_rect(Rect2(WATCHTOWER_CACHE_POSITION - Vector2(14, 10), Vector2(28, 20)), Color("#24343a"), false, 2.0)
	draw_line(WATCHTOWER_CACHE_POSITION + Vector2(0, -10), WATCHTOWER_CACHE_POSITION + Vector2(0, 10), Color("#24343a"), 2.0)
	draw_string(ThemeDB.fallback_font, WATCHTOWER_CACHE_POSITION + Vector2(-36, 23), "MEMORY CACHE" if not watchtower_cache_claimed else "CACHE EMPTY", HORIZONTAL_ALIGNMENT_LEFT, 90, 8, cache_color)
	if frostfall_pass_open:
		draw_line(Vector2(880, 605), Vector2(950, 625), Color("#b9dff2", 0.75), 7.0)
		draw_line(Vector2(900, 610), Vector2(972, 585), Color("#83e8e0", 0.55), 3.0)
		draw_string(ThemeDB.fallback_font, Vector2(902, 578), "FROSTFALL PASS", HORIZONTAL_ALIGNMENT_LEFT, 150, 10, Color("#b9dff2"))
	else:
		var route_glow := Color("#b9dff2", 0.10 + 0.06 * sin(elapsed * 1.5))
		draw_circle(FROSTFALL_ROUTE_POSITION, 17.0, route_glow)
		draw_line(FROSTFALL_ROUTE_POSITION + Vector2(-8, 0), FROSTFALL_ROUTE_POSITION + Vector2(8, 0), Color("#839ca7"), 3.0)
		draw_string(ThemeDB.fallback_font, FROSTFALL_ROUTE_POSITION + Vector2(-42, -22), "SEALED PASS", HORIZONTAL_ALIGNMENT_LEFT, 100, 9, Color("#b9dff2"))


func _draw_ancient_chest() -> void:
	if not hidden_passage_open:
		return
	var chest_color := Color("#e0bd68") if not ancient_chest_claimed else Color("#778679")
	var chest_glow := chest_color
	chest_glow.a = 0.10 + 0.06 * sin(elapsed * 2.0)
	draw_circle(ANCIENT_CHEST_POSITION, 31.0, chest_glow)
	draw_rect(Rect2(ANCIENT_CHEST_POSITION + Vector2(-20, -12), Vector2(40, 27)), Color("#55442f"))
	draw_rect(Rect2(ANCIENT_CHEST_POSITION + Vector2(-20, -12), Vector2(40, 27)), chest_color, false, 3.0)
	draw_rect(Rect2(ANCIENT_CHEST_POSITION + Vector2(-4, -8), Vector2(8, 18)), Color("#f5d990") if not ancient_chest_claimed else Color("#303c34"))
	draw_line(ANCIENT_CHEST_POSITION + Vector2(-17, -3), ANCIENT_CHEST_POSITION + Vector2(17, -3), Color("#ad8b4e"), 2.0)
	if ancient_chest_claimed:
		draw_string(ThemeDB.fallback_font, ANCIENT_CHEST_POSITION + Vector2(-28, -21), "EMPTY", HORIZONTAL_ALIGNMENT_LEFT, 60, 9, Color("#b1c0b1"))

func _draw_ruin_objects() -> void:
	for object_index in range(RUIN_OBJECT_POSITIONS.size()):
		var object_pos: Vector2 = RUIN_OBJECT_POSITIONS[object_index]
		var discovered := (codex_entries & (1 << (6 + object_index))) != 0
		var relic_color := Color("#83e8e0") if discovered else Color("#b8a477")
		var pulse := 0.65 + 0.35 * sin(elapsed * 1.8 + float(object_index))
		var relic_glow := relic_color
		relic_glow.a = 0.07 + pulse * 0.08
		draw_circle(object_pos, 28.0 + pulse * 3.0, relic_glow)
		if object_index == 0:
			draw_rect(Rect2(object_pos + Vector2(-15, -22), Vector2(30, 44)), Color("#4b5148"))
			draw_rect(Rect2(object_pos + Vector2(-15, -22), Vector2(30, 44)), relic_color, false, 2.0)
			draw_line(object_pos + Vector2(-4, -16), object_pos + Vector2(5, -4), Color("#262f2a"), 3.0)
			draw_line(object_pos + Vector2(5, -4), object_pos + Vector2(-2, 7), Color("#262f2a"), 3.0)
		elif object_index == 1:
			draw_rect(Rect2(object_pos + Vector2(-23, -14), Vector2(46, 28)), Color("#625a48"))
			draw_rect(Rect2(object_pos + Vector2(-23, -14), Vector2(46, 28)), relic_color, false, 2.0)
			for line_index in range(3):
				draw_line(object_pos + Vector2(-15, -7 + line_index * 7), object_pos + Vector2(14, -7 + line_index * 7), Color("#c9bd99") if discovered else Color("#383a30"), 2.0)
		else:
			draw_rect(Rect2(object_pos + Vector2(-19, -15), Vector2(38, 30)), Color("#514332"))
			draw_rect(Rect2(object_pos + Vector2(-19, -15), Vector2(38, 30)), relic_color, false, 2.0)
			draw_rect(Rect2(object_pos + Vector2(-5, -4), Vector2(10, 8)), Color("#d7bd78") if discovered else Color("#8e754a"))
		if not discovered:
			draw_circle(object_pos + Vector2(0, -29), 3.0 + pulse * 1.5, relic_color)

func _draw_ancient_rune() -> void:
	var pulse := 0.65 + 0.35 * sin(elapsed * 2.4)
	var glow := Color("#83e8e0")
	glow.a = 0.10 + pulse * 0.12
	draw_circle(ANCIENT_RUNE_POSITION, 42.0 + pulse * 4.0, glow)
	draw_circle(ANCIENT_RUNE_POSITION, 26.0, Color("#283d3c"))
	draw_circle(ANCIENT_RUNE_POSITION, 22.0, Color("#65776a"))
	draw_circle(ANCIENT_RUNE_POSITION, 16.0, Color("#263b39"))
	draw_line(ANCIENT_RUNE_POSITION + Vector2(0, -15), ANCIENT_RUNE_POSITION + Vector2(0, 15), Color("#9bf5e8") if rune_activated else Color("#8eb9a9"), 3.0)
	draw_line(ANCIENT_RUNE_POSITION + Vector2(-12, -7), ANCIENT_RUNE_POSITION + Vector2(12, 7), Color("#9bf5e8") if rune_activated else Color("#8eb9a9"), 3.0)
	draw_line(ANCIENT_RUNE_POSITION + Vector2(-12, 7), ANCIENT_RUNE_POSITION + Vector2(12, -7), Color("#9bf5e8") if rune_activated else Color("#8eb9a9"), 2.0)
	if rune_activated:
		draw_arc(ANCIENT_RUNE_POSITION, 34.0 + pulse * 5.0, 0.0, TAU, 48, Color(0.52, 0.95, 0.88, 0.28), 2.0)

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
		var is_memory_guardian := mob_name == "Memory Guardian"
		var is_guardian := mob_name == "Ruin Guardian" or is_memory_guardian
		var body_color := Color("#8e6553") if is_wolf else (Color("#887d9c") if mob_name == "Ruins Stalker" else (Color("#57bdb0") if is_memory_guardian else (Color("#b95f49") if is_guardian else Color("#a58a53"))))
		if float(mob.get("hit_flash", 0.0)) > 0.0:
			body_color = Color("#fff0d4")
		draw_circle(mob_pos + Vector2(1, 10), 23.0 if is_guardian else 15.0, Color(0.02, 0.025, 0.02, 0.35))
		if is_guardian:
			var guardian_enraged := float(mob["hp"]) <= float(mob["max_hp"]) * 0.5
			var guardian_glow := 0.28 + 0.18 * sin(elapsed * (5.0 if guardian_enraged else 3.0))
			var guardian_color := (Color("#a5fff0") if guardian_enraged else Color("#4fd5c4")) if is_memory_guardian else (Color("#ff4d35") if guardian_enraged else Color("#d36b55"))
			guardian_color.a = guardian_glow
			draw_arc(mob_pos, 29.0 + sin(elapsed * 2.4) * 2.0, 0.0, TAU, 36, guardian_color, 4.0, true)
			var slam_windup := float(mob.get("slam_windup", 0.0))
			if slam_windup > 0.0:
				var warning_alpha := 0.18 + 0.08 * sin(elapsed * 18.0)
				var danger_fill := Color("#48d9c4") if is_memory_guardian else Color("#f05b48")
				danger_fill.a = warning_alpha
				draw_circle(mob_pos, 112.0, danger_fill)
				var danger_outline := Color("#a5fff0") if is_memory_guardian else Color("#ff7658")
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
		var eye_color := Color("#bffff2") if is_memory_guardian else (Color("#ffd27b") if is_guardian else Color("#e3b36b"))
		draw_circle(mob_pos + Vector2(-5, -2), 3.0, eye_color)
		draw_circle(mob_pos + Vector2(5, -2), 3.0, eye_color)
		var bar_width := 58.0 if is_guardian else 34.0
		draw_rect(Rect2(mob_pos + Vector2(-bar_width / 2.0, -24), Vector2(bar_width, 4)), Color("#241e1d"))
		draw_rect(Rect2(mob_pos + Vector2(-bar_width / 2.0, -24), Vector2(bar_width * clampf(float(mob["hp"]) / float(mob["max_hp"]), 0.0, 1.0), 4)), Color("#b94d45"))
		draw_string(ThemeDB.fallback_font, mob_pos + Vector2(-40 if is_guardian else -27, -34 if is_guardian else -30), mob_name, HORIZONTAL_ALIGNMENT_LEFT, 100 if is_guardian else 70, 11 if is_guardian else 9, Color("#f0c6b4") if is_guardian else Color("#ded2bd"))

func _draw_loot_drops() -> void:
	for drop in loot_drops:
		var p: Vector2 = drop["pos"]
		var drop_type := String(drop["type"])
		var color := Color("#83e8e0") if drop_type == "echo" else (Color("#e0bd68") if drop_type == "coins" else (Color("#8fbd75") if drop_type == "herbs" else (Color("#ff9877") if drop_type == "guardian_core" else (Color("#e7d49a") if drop_type == "ancient_cache" else Color("#b58be0")))))
		var pulse := 1.0 + 0.14 * sin(elapsed * 5.0 + float(p[0] + p[1]) * 0.03)
		draw_circle(p + Vector2(0, 5), 9.0, Color(0.02, 0.025, 0.02, 0.32))
		draw_circle(p, 7.0 * pulse, color)
		draw_arc(p, 8.0 * pulse, 0.0, TAU, 20, color.lightened(0.45), 2.0)
		if drop_type == "guardian_core":
			draw_arc(p, 12.0 * pulse, 0.0, TAU, 24, Color("#ffd0a1"), 2.0, true)
		elif drop_type == "ancient_cache":
			draw_rect(Rect2(p - Vector2(8, 7), Vector2(16, 14)), Color("#9c7441"))
			draw_rect(Rect2(p - Vector2(8, 7), Vector2(16, 14)), Color("#f0d58b"), false, 2.0)
		var glyph := "E" if drop_type == "echo" else ("G" if drop_type == "coins" else ("H" if drop_type == "herbs" else ("C" if drop_type == "guardian_core" else ("A" if drop_type == "ancient_cache" else "R"))))
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
		elif String(effect["kind"]) == "ultimate":
			var ultimate_color := Color("#ffd28b")
			ultimate_color.a = (1.0 - progress) * 0.88
			var ultimate_center: Vector2 = effect["pos"]
			for ray_index in range(16):
				var ray_angle := TAU * float(ray_index) / 16.0 + progress * 0.18
				var ray_direction := Vector2(cos(ray_angle), sin(ray_angle))
				draw_line(ultimate_center + ray_direction * (18.0 + progress * 20.0), ultimate_center + ray_direction * (72.0 + progress * 170.0), ultimate_color, 3.0)
			draw_arc(ultimate_center, 34.0 + progress * 205.0, 0.0, TAU, 64, ultimate_color, 5.0 - progress * 2.0, true)
		elif String(effect["kind"]) == "passive_proc":
			var proc_color: Color = effect.get("color", Color("#b8e8a0"))
			proc_color.a = (1.0 - progress) * 0.9
			var proc_center: Vector2 = effect["pos"]
			var proc_radius := 16.0 + progress * 48.0
			draw_arc(proc_center, proc_radius, progress * 1.2, TAU - progress * 0.4, 40, proc_color, 3.0, true)
			for ray_index in range(8):
				var ray_angle := TAU * float(ray_index) / 8.0 + progress * 0.45
				var ray_direction := Vector2(cos(ray_angle), sin(ray_angle))
				draw_line(proc_center + ray_direction * (proc_radius + 3.0), proc_center + ray_direction * (proc_radius + 10.0), proc_color, 2.0)
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
			var is_memory_boss := String(mob["name"]) == "Memory Guardian"
			var boss_title := String(mob["name"]).to_upper() + ("  •  ENRAGED" if float(mob["hp"]) <= float(mob["max_hp"]) * 0.5 else "")
			var boss_color := Color("#83e8e0") if is_memory_boss else Color("#ff896d")
			draw_string(ThemeDB.fallback_font, Vector2(440, 16), boss_title, HORIZONTAL_ALIGNMENT_CENTER, 400, 16, boss_color)
			draw_rect(Rect2(456, 35, 368, 14), Color("#243b39") if is_memory_boss else Color("#382629"))
			draw_rect(Rect2(456, 35, 368.0 * boss_hp_ratio, 14), Color("#4fc9b9") if is_memory_boss else Color("#c74f46"))
			draw_rect(Rect2(456, 35, 368, 14), boss_color.lightened(0.2), false, 1.5)
			break
	draw_rect(Rect2(22, 20, 350, 106), Color(0.035, 0.055, 0.05, 0.9))
	draw_rect(Rect2(22, 20, 4, 106), Color("#b98a51"))
	draw_string(ThemeDB.fallback_font, Vector2(42, 49), "ELDERVALE  •  LV. %d" % player_level, HORIZONTAL_ALIGNMENT_LEFT, -1, 22, Color("#e7dfc8"))
	draw_string(ThemeDB.fallback_font, Vector2(43, 72), "HP  %d / %d" % [player_hp, player_max_hp], HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color("#e6a39a"))
	draw_rect(Rect2(43, 80, 300, 8), Color("#392b2b"))
	draw_rect(Rect2(43, 80, 300.0 * float(player_hp) / float(player_max_hp), 8), Color("#b84d46"))
	draw_string(ThemeDB.fallback_font, Vector2(43, 108), "XP %d / %d     COINS %d" % [player_xp, _xp_for_next_level(), player_coins], HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("#d7c59f"))
	draw_rect(Rect2(WORLD_SIZE.x - 310, 22, 288, 116), Color(0.035, 0.055, 0.05, 0.9))
	draw_string(ThemeDB.fallback_font, Vector2(WORLD_SIZE.x - 291, 45), "QUESTS  •  WORLD JOURNAL", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color("#d7c59f"))
	draw_string(ThemeDB.fallback_font, Vector2(WORLD_SIZE.x - 291, 65), "Defeat 3: %d / 3" % mini(kills, 3), HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("#c5cfba"))
	draw_string(ThemeDB.fallback_font, Vector2(WORLD_SIZE.x - 291, 82), "60 XP + 25 coins" if not quest_reward_claimed else "Reward claimed", HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color("#aab5a1"))
	draw_string(ThemeDB.fallback_font, Vector2(WORLD_SIZE.x - 291, 103), "QUEST II: HUNT 5  %d / 5" % mini(kills, 5), HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color("#d7c59f"))
	draw_string(ThemeDB.fallback_font, Vector2(WORLD_SIZE.x - 291, 123), "100 XP + 50 coins" if not second_quest_reward_claimed else "Reward claimed", HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color("#aab5a1"))
	draw_rect(CODEX_BUTTON_RECT, Color(0.06, 0.18, 0.19, 0.96))
	draw_rect(CODEX_BUTTON_RECT, Color("#83e8e0"), false, 2.0)
	var book_center := CODEX_BUTTON_RECT.position + Vector2(22, 22)
	draw_rect(Rect2(book_center - Vector2(9, 12), Vector2(8, 24)), Color("#d9f6ee"))
	draw_rect(Rect2(book_center + Vector2(1, -12), Vector2(8, 24)), Color("#b4d9ce"))
	draw_line(book_center + Vector2(0, -11), book_center + Vector2(0, 12), Color("#2a4541"), 2.0)
	draw_string(ThemeDB.fallback_font, CODEX_BUTTON_RECT.position + Vector2(43, 27), "CODEX", HORIZONTAL_ALIGNMENT_LEFT, 90, 15, Color("#e0f7ee"))
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
	var ultimate_center := _ultimate_button_center()
	draw_circle(ultimate_center, 49.0, Color(0.25, 0.17, 0.07, 0.9))
	draw_arc(ultimate_center, 49.0, 0.0, TAU * ultimate_charge / 100.0, 48, Color("#ffd28b"), 5.0, true)
	draw_arc(ultimate_center, 49.0, 0.0, TAU, 48, Color("#9c7b48"), 2.0)
	draw_string(ThemeDB.fallback_font, ultimate_center + Vector2(-37, -3), "ULTIMATE", HORIZONTAL_ALIGNMENT_LEFT, 78, 11, Color("#ffe8b0"))
	draw_string(ThemeDB.fallback_font, ultimate_center + Vector2(-22, 14), "%d%% [B]" % int(ultimate_charge), HORIZONTAL_ALIGNMENT_LEFT, 60, 11, Color("#ffd28b") if ultimate_charge >= 100.0 else Color("#d7c59f"))
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
	var echo_label := "ECHO SURGE %.1fs  •  +12%% DAMAGE" % echo_surge_time if echo_surge_time > 0.0 else "WORLD ECHOES %d / 3" % echo_shards
	draw_string(ThemeDB.fallback_font, Vector2(42, 220), echo_label, HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color("#83e8e0") if echo_surge_time > 0.0 else Color("#b0c9c1"))
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
	var passive_data := _current_passive_data()
	draw_string(ThemeDB.fallback_font, Vector2(640, 338), "PASSIVE: %s" % String(passive_data.get("name", "None")), HORIZONTAL_ALIGNMENT_CENTER, 400, 12, Color("#b8e8a0"))
	var talent_titles: Array[String] = ["OFFENSE", "DEFENSE", "UTILITY"]
	for branch in range(3):
		var talent_center := _talent_button_center(branch)
		var talent_color := Color("#c96c59") if branch == 0 else (Color("#7aabc0") if branch == 1 else Color("#9bc58a"))
		draw_rect(Rect2(talent_center - Vector2(66, 22), Vector2(132, 44)), Color(0.07, 0.09, 0.10, 0.94))
		draw_rect(Rect2(talent_center - Vector2(66, 22), Vector2(132, 44)), talent_color, false, 2.0)
		draw_string(ThemeDB.fallback_font, talent_center + Vector2(-58, -2), "%s %d/5" % [talent_titles[branch], talent_ranks[branch]], HORIZONTAL_ALIGNMENT_LEFT, 120, 11, Color("#e7dfc8"))
		draw_string(ThemeDB.fallback_font, talent_center + Vector2(-58, 14), "KEY %d" % (branch + 1), HORIZONTAL_ALIGNMENT_LEFT, 120, 9, Color("#d7c59f"))
	draw_string(ThemeDB.fallback_font, Vector2(640, 432), "TALENT POINTS: %d" % talent_points, HORIZONTAL_ALIGNMENT_CENTER, 280, 13, Color("#b8e8a0") if talent_points > 0 else Color("#c5cfba"))
	var set_bonus := _current_equipment_set_bonus()
	var legendary_affix := _current_legendary_affix()
	var set_color := Color("#ffd28b") if weapon_enchant >= 4 and armor_enchant >= 4 else (Color("#b8e8a0") if weapon_enchant >= 2 and armor_enchant >= 2 else Color("#c5cfba"))
	draw_string(ThemeDB.fallback_font, Vector2(640, 454), "SET: %s  •  DMG +%d%%  •  ARMOR +%d  •  CRIT +%d%%" % [String(set_bonus["name"]), int(round((float(set_bonus["damage"]) - 1.0) * 100.0)), int(set_bonus["armor"]), int(round(float(set_bonus["crit"]) * 100.0))], HORIZONTAL_ALIGNMENT_CENTER, 560, 11, set_color)
	draw_string(ThemeDB.fallback_font, Vector2(640, 474), "LEGENDARY: %s  •  DMG +%d%%  •  SKILL +%d%%  •  ARMOR +%d" % [String(legendary_affix["name"]), int(round((float(legendary_affix["damage"]) - 1.0) * 100.0)), int(round((float(legendary_affix["skill"]) - 1.0) * 100.0)), int(legendary_affix["armor"])], HORIZONTAL_ALIGNMENT_CENTER, 560, 10, Color("#ffd28b") if weapon_enchant >= 4 or armor_enchant >= 4 else Color("#c5cfba"))
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
	if (rune_nearby or nearby_ruin_object >= 0 or nearby_hidden_gate or nearby_ancient_chest or nearby_memory_exit or nearby_shattered_beacon or nearby_northbound_signal or nearby_watchtower_path or nearby_frostwatch_relic or nearby_watchtower_symbol >= 0 or nearby_watchtower_cache or nearby_frostfall_route) and not codex_open:
		draw_rect(RUNE_BUTTON_RECT, Color(0.035, 0.12, 0.13, 0.96))
		var interaction_color := Color("#83e8e0") if rune_nearby or nearby_ancient_chest or nearby_memory_exit or nearby_shattered_beacon or nearby_northbound_signal else Color("#d7c59f")
		draw_rect(RUNE_BUTTON_RECT, interaction_color, false, 2.5)
		var interaction_label := "RUNE AWAKENED" if rune_activated else ("ACTIVATE RUNE" if rune_studied and (codex_entries & 15) == 15 else "STUDY ANCIENT RUNE")
		if nearby_northbound_signal and not rune_nearby:
			interaction_label = "TRACE RECORDED" if northbound_signal_discovered else "FOLLOW NORTHBOUND SIGNAL"
		elif nearby_watchtower_symbol >= 0 and not rune_nearby:
			interaction_label = ["READ FIRST SYMBOL", "READ SECOND SYMBOL", "READ THIRD SYMBOL"][nearby_watchtower_symbol]
		elif nearby_watchtower_cache and not rune_nearby:
			interaction_label = "OPEN MEMORY CACHE"
		elif nearby_frostfall_route and not rune_nearby:
			interaction_label = "ENTER FROSTFALL PASS" if frostfall_pass_open else "UNSEAL FROSTFALL PASS"
		elif nearby_frostwatch_relic and not rune_nearby:
			interaction_label = "RELIC RECOVERED" if frostwatch_relic_discovered else "RECOVER FROSTWATCH RELIC"
		elif nearby_watchtower_path and not rune_nearby:
			interaction_label = "ENTER FORGOTTEN WATCHTOWER"
		elif nearby_shattered_beacon and not rune_nearby:
			interaction_label = "BEACON AWAKENED" if shattered_beacon_activated else "ACTIVATE BEACON"
		elif nearby_ancient_chest and not rune_nearby:
			interaction_label = "CLAIM ANCIENT CACHE"
		elif nearby_memory_exit and not rune_nearby:
			interaction_label = "ENTER SHATTERED REACH"
		elif nearby_hidden_gate and not rune_nearby:
			interaction_label = "ENTER HIDDEN PASSAGE" if hidden_passage_open else "STUDY SEALED GATE"
		elif not rune_nearby and nearby_ruin_object >= 0:
			var object_labels: Array[String] = ["INSPECT WATCHSTONE", "READ INSCRIPTION", "OPEN MEMORY CACHE"]
			interaction_label = object_labels[nearby_ruin_object]
		draw_string(ThemeDB.fallback_font, RUNE_BUTTON_RECT.position + Vector2(18, 24), interaction_label, HORIZONTAL_ALIGNMENT_CENTER, 212, 14, Color("#e0f7ee"))
		draw_string(ThemeDB.fallback_font, RUNE_BUTTON_RECT.position + Vector2(18, 43), "TAP TO INTERACT", HORIZONTAL_ALIGNMENT_CENTER, 212, 10, Color("#a9c9c2"))
	if codex_open:
		var panel_rect := Rect2(260.0, 112.0, 760.0, 500.0)
		draw_rect(panel_rect, Color(0.018, 0.028, 0.032, 0.98))
		draw_rect(panel_rect, Color("#83e8e0"), false, 3.0)
		draw_string(ThemeDB.fallback_font, Vector2(300, 158), "MEMORY OF ELDERVALE  •  DISCOVERY CODEX", HORIZONTAL_ALIGNMENT_LEFT, 580, 23, Color("#d9f6ee"))
		draw_rect(CODEX_CLOSE_RECT, Color(0.12, 0.20, 0.20, 0.98))
		draw_rect(CODEX_CLOSE_RECT, Color("#83e8e0"), false, 1.5)
		draw_string(ThemeDB.fallback_font, CODEX_CLOSE_RECT.position + Vector2(14, 24), "CLOSE", HORIZONTAL_ALIGNMENT_LEFT, 64, 12, Color("#e0f7ee"))
		draw_string(ThemeDB.fallback_font, Vector2(300, 187), "Collect traces from combat and ancient relics. Four clues reveal a hidden convergence.", HORIZONTAL_ALIGNMENT_LEFT, 680, 12, Color("#a9c9c2"))
		var codex_titles: Array[String] = ["A Voice in the Ash", "Resonance Awakened", "Memory of the Guardian", "The Cache Inscription", "The First Convergence", "The Rune of Convergence", "The Watchstone Road", "The Pilgrim's Oath", "The Sealed Memory", "The Hall Beneath", "The Memory Guardian", "The Shattered Reach", "The First Beacon", "The Northbound Signal", "The Forgotten Watchtower", "Frostwatch Relic", "First Watchtower Symbol", "Second Watchtower Symbol", "Third Watchtower Symbol", "The Watchtower Memory Cache", "The Road to Frostfall Pass"]
		var codex_hints: Array[String] = [
			"A fragment remembers something its owner forgot.",
			"Three echoes briefly become one living force.",
			"The Ruin Guardian carried a memory, not just a key.",
			"An ancient cache bears the same mark as the echoes.",
			"The four traces point toward a mystery beyond battle.",
			"The ancient rune awakens only when all four traces align.",
			"This watchstone marks a road erased from ordinary maps.",
			"Three keepers guarded one memory through the ages.",
			"A sealed cache still responds to the rune's pulse.",
		"Three relic traces and the awakened rune reveal the hall below.",
			"An ancient will protects the hall. Its relic remembers every battle.",
			"Beyond the hall, a broken road leads to the Shattered Reach. The first beacon is silent.",
			"The beacon has awakened. Its light points toward a distant signal beyond the shattered road.",
			"A faint answering light marks a route to a forgotten watchtower farther north.",
			"The broken northern path opens into a wind-scoured watchtower, abandoned but not silent.",
			"A frostbound relic holds an echo from the watchtower's final keeper.",
			"The first mark names the watchtower's last oath: keep the northern light alive.",
			"The second mark records a path through the snowbound ridges.",
			"The third mark warns that the pass opens only when memory and relic are reunited.",
			"The three symbols align. A hidden cache preserves the keeper's final testimony.",
			"The seal breaks, revealing a road into Frostfall Pass and the lands beyond."
		]
		var codex_found := 0
		for entry_index in range(codex_titles.size()):
			var discovered := (codex_entries & (1 << entry_index)) != 0
			if discovered:
				codex_found += 1
			var compact_codex := codex_titles.size() > 6
			var row_spacing := 20.0 if codex_titles.size() > 16 else (25.0 if codex_titles.size() > 13 else (27.0 if codex_titles.size() > 12 else (35.0 if codex_titles.size() > 9 else (39.0 if compact_codex else 52.0))))
			var entry_y := 206.0 + float(entry_index) * row_spacing
			draw_circle(Vector2(310, entry_y - 4.0), 6.0 if compact_codex else 9.0, Color("#83e8e0") if discovered else Color("#53615d"))
			draw_string(ThemeDB.fallback_font, Vector2(332, entry_y), "%02d  %s" % [entry_index + 1, codex_titles[entry_index] if discovered else "UNKNOWN TRACE"], HORIZONTAL_ALIGNMENT_LEFT, 620, 11 if codex_titles.size() > 9 else (12 if compact_codex else 14), Color("#e0f7ee") if discovered else Color("#9ba7a2"))
			draw_string(ThemeDB.fallback_font, Vector2(332, entry_y + (13.0 if codex_titles.size() > 9 else (15.0 if compact_codex else 20.0)), codex_hints[entry_index] if discovered else "The details remain hidden until the trace is found.", HORIZONTAL_ALIGNMENT_LEFT, 640, 8 if codex_titles.size() > 9 else (9 if compact_codex else 11), Color("#a9c9c2") if discovered else Color("#687571"))
		draw_string(ThemeDB.fallback_font, Vector2(300, 574), "DISCOVERED %d / %d" % [codex_found, codex_titles.size()], HORIZONTAL_ALIGNMENT_LEFT, 220, 13, Color("#ffd28b"))
		draw_string(ThemeDB.fallback_font, Vector2(570, 574), "TAP CLOSE OR OUTSIDE THE JOURNAL", HORIZONTAL_ALIGNMENT_LEFT, 400, 12, Color("#c5cfba"))
