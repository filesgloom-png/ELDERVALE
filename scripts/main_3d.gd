extends Node3D

class_name Eldervale3DWorld

# ELDERVALE 3D conversion — first playable visual foundation.
# Existing 2D implementation remains in scripts/main.gd as a migration reference.
const MOVE_SPEED := 5.2
const WORLD_LIMIT := 42.0
var player: Node3D
var camera: Camera3D
var move_input := Vector2.ZERO
var touch_origin := Vector2.ZERO
var touch_index := -1
var attack_cooldown := 0.0
var skill_cooldown := 0.0
var player_hp := 148
var player_max_hp := 148
var xp := 178
var coins := 164
var kills := 0
var player_level := 5
var xp_to_next_level := 190
var stats_label: Label
var inventory_label: Label
var inventory_panel: PanelContainer
var inventory: Dictionary = {"Ashen Pelt": 0, "Ancient Shard": 0, "Echo Fragment": 0, "Ruin Core": 0, "Warden Emblem": 0, "Frost Sigil": 0, "Glacial Crown": 0}
var boss_first_kill_claimed := false
var codex_discoveries: Array[String] = []
var weapon_level := 0
var armor_level := 0
var quest_stage := 0
var quest_stage_progress := 0
var quest_completed := false
var wave_respawn_timer := -1.0
var wave_number := 0
var enemies: Array[Node3D] = []
var hp_bar: ProgressBar
var boss_hp_bar: ProgressBar
var boss_panel: PanelContainer
var boss_phase_label: Label
var boss_hud_hp := -1
var boss_hud_phase := -1
var status_label: Label
var target_label: Label
var world_time := 0.0
var attack_flash := 0.0
var animated_arms: Array[Node3D] = []
var animated_legs: Array[Node3D] = []
var enemy_legs: Array[Node3D] = []
var enemy_tails: Array[Node3D] = []
var enemy_health: Dictionary = {}
var enemy_hit_timers: Dictionary = {}
var enemy_base_colors: Dictionary = {}
var enemy_health_ui: Dictionary = {}
var enemy_knockback: Dictionary = {}
var enemy_recovery_animations: Dictionary = {}
var frost_warden_states: Dictionary = {}
var health_bar_fade_effects: Array[Dictionary] = []
var damage_number_effects: Array[Dictionary] = []
var animated_sword: Node3D
var animated_cape: Node3D
var animated_torso: Node3D
var attack_anim_time := 0.0
const ATTACK_ANIM_DURATION := 0.62
const ENEMY_HIT_REACTION_DURATION := 0.24
var animation_time := 0.0
var magical_materials: Array[StandardMaterial3D] = []
var combat_effects: Array[Dictionary] = []

func _ready() -> void:
	_load_progress()
	_build_environment()
	_build_world()
	_build_player()
	_build_enemies()
	_build_hud()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	set_process(true)

func _build_environment() -> void:
	var world_env := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_SKY
	var sky := Sky.new()
	var sky_mat := ProceduralSkyMaterial.new()
	sky_mat.sky_top_color = Color("#243b48")
	sky_mat.sky_horizon_color = Color("#a6a17e")
	sky_mat.ground_bottom_color = Color("#17251f")
	sky_mat.ground_horizon_color = Color("#5a654c")
	sky.sky_material = sky_mat
	env.sky = sky
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color("#8ba69a")
	env.ambient_light_energy = 0.62
	env.fog_enabled = true
	env.fog_light_color = Color("#74877c")
	env.fog_density = 0.006
	env.fog_sky_affect = 0.18
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	world_env.environment = env
	add_child(world_env)
	var sun := DirectionalLight3D.new()
	sun.name = "LateAfternoonSun"
	sun.rotation_degrees = Vector3(-48, -32, 0)
	sun.light_color = Color("#ffe0b0")
	sun.light_energy = 0.86
	sun.light_color = Color("#ffddb0")
	sun.shadow_enabled = true
	sun.directional_shadow_mode = DirectionalLight3D.SHADOW_PARALLEL_4_SPLITS
	sun.directional_shadow_max_distance = 42.0
	add_child(sun)

func _mat(color: Color, roughness: float = 0.9, metallic: float = 0.0) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = color
	m.roughness = roughness
	m.metallic = metallic
	return m

func _mesh_node(parent: Node, mesh: Mesh, material: Material, pos: Vector3, node_name: String = "") -> MeshInstance3D:
	var n := MeshInstance3D.new()
	n.mesh = mesh
	n.position = pos
	if material != null:
		n.material_override = material
	if node_name != "":
		n.name = node_name
	parent.add_child(n)
	return n

func _box(parent: Node, size: Vector3, material: Material, pos: Vector3, node_name: String = "") -> MeshInstance3D:
	var mesh := BoxMesh.new()
	mesh.size = size
	return _mesh_node(parent, mesh, material, pos, node_name)

func _build_world() -> void:
	var grass := _mat(Color("#40563d"))
	var ground_mesh := PlaneMesh.new()
	ground_mesh.size = Vector2(110, 110)
	var ground := _mesh_node(self, ground_mesh, grass, Vector3.ZERO, "ForestGround")
	ground.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var path_mat := _mat(Color("#76694f"))
	var path_mesh := BoxMesh.new()
	path_mesh.size = Vector3(8.0, 0.12, 100.0)
	var path := _mesh_node(self, path_mesh, path_mat, Vector3(0, 0.025, 0), "AncientRoad")
	path.rotation.y = -0.22
	var moss := _mat(Color("#52694a"))
	var bark := _mat(Color("#4a3528"))
	var leaf_a := _mat(Color("#304d3b"))
	var leaf_b := _mat(Color("#496648"))
	var leaf_hi := _mat(Color("#61794d"))
	var rng := RandomNumberGenerator.new()
	rng.seed = 80421
	for i in range(58):
		var x := rng.randf_range(-38.0, 38.0)
		var z := rng.randf_range(-38.0, 38.0)
		if absf(x) < 6.5:
			continue
		var scale := rng.randf_range(0.75, 1.35)
		var tree := Node3D.new()
		tree.position = Vector3(x, 0, z)
		tree.scale = Vector3.ONE * scale
		tree.name = "ForestTree"
		add_child(tree)
		var trunk_mesh := CylinderMesh.new()
		trunk_mesh.top_radius = 0.22
		trunk_mesh.bottom_radius = 0.34
		trunk_mesh.height = 2.5
		_mesh_node(tree, trunk_mesh, bark, Vector3(0, 1.25, 0))
		for crown in range(3):
			var crown_mesh := SphereMesh.new()
			crown_mesh.radius = 1.2 if crown == 0 else 0.9
			crown_mesh.height = 2.0 if crown == 0 else 1.55
			var crown_mat: Material = leaf_a if crown == 0 else (leaf_b if crown == 1 else leaf_hi)
			var crown_node := _mesh_node(tree, crown_mesh, crown_mat, Vector3(rng.randf_range(-0.25, 0.25), 2.55 + float(crown) * 0.48, rng.randf_range(-0.2, 0.2)), "CanopyLayer")
			crown_node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF if crown > 0 else GeometryInstance3D.SHADOW_CASTING_SETTING_ON
		# A few restrained side branches and bark scars add silhouette detail without extra foliage layers everywhere.
		if i % 4 == 0:
			var branch_mesh := CylinderMesh.new()
			branch_mesh.top_radius = 0.055
			branch_mesh.bottom_radius = 0.095
			branch_mesh.height = 1.05
			var branch := _mesh_node(tree, branch_mesh, bark, Vector3(0.36, 1.85, 0.02), "LowBranch")
			branch.rotation.z = -0.9
			branch.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		if i % 5 == 0:
			var scar := _box(tree, Vector3(0.09, 0.42, 0.025), _mat(Color("#302a22")), Vector3(0.12, 1.1, -0.31), "BarkScar")
			scar.rotation.z = 0.12
			scar.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		if i % 3 == 0:
			var stone := _mesh_node(tree, SphereMesh.new(), moss, Vector3(rng.randf_range(-1.2, 1.2), 0.25, rng.randf_range(-1.2, 1.2)), "MossStone")
			stone.scale = Vector3(0.8, 0.35, 0.6)
	# Scatter low ground cover and weathered stones to break up the empty terrain.
	var ground_cover_a := _mat(Color("#596f45"), 1.0)
	var ground_cover_b := _mat(Color("#71804b"), 1.0)
	var pebble_mat := _mat(Color("#8b8874"), 0.95)
	for i in range(72):
		var patch_x := rng.randf_range(-36.0, 36.0)
		var patch_z := rng.randf_range(-36.0, 36.0)
		if absf(patch_x) < 5.5:
			continue
		var patch := _mesh_node(self, SphereMesh.new(), ground_cover_a if i % 2 == 0 else ground_cover_b, Vector3(patch_x, 0.035, patch_z), "GroundCover")
		patch.scale = Vector3(rng.randf_range(0.35, 1.2), 0.025, rng.randf_range(0.35, 1.0))
		patch.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		if i % 4 == 0:
			var pebble := _mesh_node(self, SphereMesh.new(), pebble_mat, Vector3(patch_x + 0.7, 0.12, patch_z - 0.4), "RoadsidePebble")
			pebble.scale = Vector3(0.18, 0.11, 0.24)
			pebble.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	# Small clusters along the trail make the forest floor feel less uniform; detail meshes do not cast shadows.
	var trail_stone := _mat(Color("#77786b"), 0.98)
	var trail_moss := _mat(Color("#64764b"), 1.0)
	for i in range(14):
		var side := -1.0 if i % 2 == 0 else 1.0
		var stone_x := side * rng.randf_range(5.8, 8.2)
		var stone_z := -32.0 + float(i) * 4.6
		var stone_mesh := SphereMesh.new()
		stone_mesh.radial_segments = 8
		stone_mesh.rings = 4
		var stone := _mesh_node(self, stone_mesh, trail_stone, Vector3(stone_x, 0.22, stone_z), "TrailStone")
		stone.scale = Vector3(rng.randf_range(0.35, 0.72), rng.randf_range(0.2, 0.38), rng.randf_range(0.32, 0.65))
		stone.rotation.y = rng.randf_range(-PI, PI)
		stone.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		if i % 2 == 0:
			var moss_mesh := SphereMesh.new()
			moss_mesh.radial_segments = 8
			moss_mesh.rings = 4
			var moss_patch := _mesh_node(self, moss_mesh, trail_moss, Vector3(stone_x, 0.36, stone_z - 0.04), "StoneMoss")
			moss_patch.scale = Vector3(0.2, 0.045, 0.16)
			moss_patch.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_build_ruins()
	_build_magic_accents()

func _build_magic_accents() -> void:
	# Emissive geometry gives the ruins a readable magical focal point without extra dynamic lights.
	var crystal_positions: Array[Vector3] = [Vector3(-5.2, 0.0, -13.0), Vector3(5.2, 0.0, -13.0), Vector3(0.0, 0.0, -19.0)]
	var crystal_colors: Array[Color] = [Color("#61d9d2"), Color("#8c9dff"), Color("#77f0cf")]
	for i in range(crystal_positions.size()):
		var glow_mat := _mat(crystal_colors[i], 0.28, 0.18)
		glow_mat.emission_enabled = true
		glow_mat.emission = crystal_colors[i]
		glow_mat.emission_energy_multiplier = 1.25
		magical_materials.append(glow_mat)
		var crystal_mesh := PrismMesh.new()
		var crystal := _mesh_node(self, crystal_mesh, glow_mat, crystal_positions[i] + Vector3(0.0, 0.62, 0.0), "ShatteredReachCrystal")
		crystal.scale = Vector3(0.34, 0.82, 0.34) if i != 1 else Vector3(0.28, 0.65, 0.28)
		crystal.rotation.y = float(i) * 1.1
		crystal.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		var base_mat := _mat(Color("#344e4c"), 0.85, 0.12)
		var base := _mesh_node(self, CylinderMesh.new(), base_mat, crystal_positions[i] + Vector3(0.0, 0.13, 0.0), "CrystalSocket")
		base.scale = Vector3(0.72, 0.18, 0.72)
		base.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	# Short, flat rune strokes around the old foundation; no particles or extra light sources.
	var rune_color := Color("#69d8ce")
	var rune_mat := _mat(rune_color, 0.5, 0.1)
	rune_mat.emission_enabled = true
	rune_mat.emission = rune_color
	rune_mat.emission_energy_multiplier = 0.8
	magical_materials.append(rune_mat)
	for i in range(8):
		var angle := TAU * float(i) / 8.0
		var rune := _box(self, Vector3(0.48, 0.035, 0.09), rune_mat, Vector3(cos(angle) * 7.2, 0.17, -14.0 + sin(angle) * 2.0), "AncientRune")
		rune.rotation.y = -angle * 0.5
		rune.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

func _build_ruins() -> void:
	var stone := _mat(Color("#6d7068"), 0.85)
	var worn := _mat(Color("#898878"))
	var dark := _mat(Color("#343d37"))
	for side in [-1.0, 1.0]:
		for col in range(3):
			var x: float = side * (13.0 + float(col) * 2.1)
			var z := -13.0 - float(col % 2) * 1.4
			_box(self, Vector3(1.35, 4.8, 1.35), stone, Vector3(x, 2.4, z), "RuinedPillar")
			_box(self, Vector3(1.75, 0.35, 1.75), worn, Vector3(x, 4.8, z), "PillarCapital")
	_box(self, Vector3(13.0, 0.8, 1.5), stone, Vector3(0, 5.0, -14.0), "BrokenLintel")
	_box(self, Vector3(11.0, 0.2, 1.8), dark, Vector3(0, 0.12, -14.0), "RuinedFoundation")
	for i in range(8):
		var rock_mesh := SphereMesh.new()
		rock_mesh.radial_segments = 8
		rock_mesh.rings = 4
		var rock := _mesh_node(self, rock_mesh, stone, Vector3(-10.0 + float(i) * 2.8, 0.35, -7.0 - float(i % 3) * 1.1), "RuinDebris")
		rock.scale = Vector3(0.75 + float(i % 3) * 0.18, 0.38, 0.55)
		rock.rotation.y = float(i) * 0.73
		rock.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		if i % 2 == 0:
			var lichen_mesh := SphereMesh.new()
			lichen_mesh.radial_segments = 8
			lichen_mesh.rings = 4
			var lichen := _mesh_node(self, lichen_mesh, _mat(Color("#7c8960"), 1.0), rock.position + Vector3(0.08, 0.24, -0.12), "RuinLichen")
			lichen.scale = Vector3(0.28, 0.06, 0.2)
			lichen.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	# A few broken slabs suggest an old route into the ruins.
	var slab_mat := _mat(Color("#77786e"), 0.92)
	for i in range(5):
		var slab := _box(self, Vector3(1.1 + float(i % 2) * 0.35, 0.16, 0.65), slab_mat, Vector3(-4.4 + float(i) * 2.0, 0.1, -8.4 - float(i % 2) * 0.65), "BrokenPathSlab")
		slab.rotation.y = float(i % 3 - 1) * 0.18
		slab.rotation.z = float(i % 2) * 0.07
		slab.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

func _build_player() -> void:
	player = Node3D.new()
	player.name = "Player_Warden"
	player.position = Vector3(0, 0, 5)
	add_child(player)
	var armor := _mat(Color("#667c80"), 0.42, 0.55)
	var dark_armor := _mat(Color("#283c42"), 0.48, 0.35)
	var skin := _mat(Color("#d5ae8b"))
	var gold := _mat(Color("#c9a15b"), 0.38, 0.72)
	var body := _mesh_node(player, CapsuleMesh.new(), armor, Vector3(0, 1.12, 0), "ArmoredBody")
	body.scale = Vector3(0.78, 0.8, 0.62)
	animated_torso = body
	var head := _mesh_node(player, SphereMesh.new(), skin, Vector3(0, 2.05, 0), "Head")
	head.scale = Vector3(0.38, 0.43, 0.36)
	var helmet := _mesh_node(player, SphereMesh.new(), dark_armor, Vector3(0, 2.25, 0), "Helmet")
	helmet.scale = Vector3(0.43, 0.28, 0.4)
	_box(player, Vector3(0.95, 0.18, 0.72), gold, Vector3(0, 1.55, -0.02), "ChestTrim")
	_box(player, Vector3(0.78, 0.42, 0.12), dark_armor, Vector3(0, 1.22, -0.37), "LayeredBreastplate")
	_box(player, Vector3(0.72, 0.12, 0.68), gold, Vector3(0, 0.83, 0), "WarriorBelt")
	var cape := _mesh_node(player, PrismMesh.new(), _mat(Color("#263b43"), 0.82, 0.1), Vector3(0, 1.12, 0.42), "WardenCape")
	cape.scale = Vector3(0.7, 0.92, 0.18)
	animated_cape = cape
	for side in [-1.0, 1.0]:
		var shoulder := _mesh_node(player, SphereMesh.new(), gold, Vector3(side * 0.58, 1.55, 0), "ShoulderGuard")
		shoulder.scale = Vector3(0.34, 0.25, 0.32)
		var arm := _mesh_node(player, CapsuleMesh.new(), dark_armor, Vector3(side * 0.58, 1.18, 0), "Arm")
		arm.scale = Vector3(0.22, 0.55, 0.24)
		animated_arms.append(arm)
		var bracer := _mesh_node(player, CapsuleMesh.new(), gold, Vector3(side * 0.61, 0.91, -0.015), "WardenBracer")
		bracer.scale = Vector3(0.235, 0.19, 0.25)
		var leg := _mesh_node(player, CapsuleMesh.new(), dark_armor, Vector3(side * 0.25, 0.43, 0), "Leg")
		leg.scale = Vector3(0.24, 0.52, 0.27)
		animated_legs.append(leg)
		var boot := _mesh_node(player, BoxMesh.new(), _mat(Color("#171f25"), 0.7, 0.25), Vector3(side * 0.25, 0.13, -0.08), "ArmoredBoot")
		boot.scale = Vector3(0.34, 0.23, 0.52)
		var greave := _mesh_node(player, BoxMesh.new(), armor, Vector3(side * 0.25, 0.43, -0.19), "WardenGreave")
		greave.scale = Vector3(0.29, 0.34, 0.12)
	var sword := _box(player, Vector3(0.13, 1.45, 0.18), _mat(Color("#d8e0d5"), 0.24, 0.85), Vector3(0.82, 1.25, -0.1), "Longsword")
	sword.rotation.z = -0.28
	animated_sword = sword
	_box(player, Vector3(0.42, 0.12, 0.22), gold, Vector3(0.79, 0.62, -0.1), "SwordGuard")
	camera = Camera3D.new()
	camera.name = "ThirdPersonCamera"
	camera.position = Vector3(0, 4.8, 7.4)
	camera.rotation_degrees = Vector3(-28, 0, 0)
	camera.current = true
	player.add_child(camera)
	camera.position = Vector3(0, 4.8, 7.4)
	camera.rotation = Vector3(deg_to_rad(-25), 0, 0)
	camera.fov = 62.0
	_refresh_equipment_visuals()

func _refresh_equipment_visuals() -> void:
	if player == null:
		return
	var blade := player.get_node_or_null("Longsword") as MeshInstance3D
	if blade != null:
		var blade_mat := _mat(Color("#d8e0d5") if weapon_level < 2 else (Color("#83e8e0") if weapon_level < 4 else Color("#ffd28b")), 0.22, 0.9)
		if weapon_level >= 3:
			blade_mat.emission_enabled = true
			blade_mat.emission = Color("#5bded0") if weapon_level < 5 else Color("#ffb84f")
			blade_mat.emission_energy_multiplier = 1.1 + float(weapon_level - 2) * 0.35
		blade.material_override = blade_mat
	var breastplate := player.get_node_or_null("LayeredBreastplate") as MeshInstance3D
	if breastplate != null:
		breastplate.material_override = _mat(Color("#283c42") if armor_level < 2 else (Color("#477b78") if armor_level < 4 else Color("#a17a43")), 0.38, 0.48)
	var cape := player.get_node_or_null("WardenCape") as MeshInstance3D
	if cape != null:
		cape.material_override = _mat(Color("#263b43") if armor_level < 3 else (Color("#275c57") if armor_level < 5 else Color("#6d4328")), 0.7, 0.18)
	var crest := player.get_node_or_null("EquipmentCrest") as MeshInstance3D
	if crest == null and armor_level >= 2:
		crest = _mesh_node(player, PrismMesh.new(), _mat(Color("#c9a15b"), 0.3, 0.75), Vector3(0, 1.78, -0.43), "EquipmentCrest")
		crest.scale = Vector3(0.24, 0.32, 0.12)
	if crest != null:
		crest.visible = armor_level >= 2
	var shoulder_runes := player.get_node_or_null("ShoulderRunes") as MeshInstance3D
	if shoulder_runes == null and armor_level >= 4:
		shoulder_runes = _mesh_node(player, SphereMesh.new(), _mat(Color("#83e8e0"), 0.25, 0.4), Vector3(0, 1.56, 0.02), "ShoulderRunes")
		shoulder_runes.scale = Vector3(0.72, 0.16, 0.42)
	if shoulder_runes != null:
		shoulder_runes.visible = armor_level >= 4

func _build_enemies() -> void:
	wave_number += 1
	var positions := [Vector3(4, 0, -4), Vector3(-5, 0, -10), Vector3(8, 0, -17), Vector3(-9, 0, -20)]
	var has_boss := wave_number % 3 == 0
	if has_boss:
		positions.append(Vector3(0, 0, -25))
	for i in range(positions.size()):
		var enemy := Node3D.new()
		enemy.name = "FrostWarden" if i == 4 else ("AshWolf" if i < 3 else "RuinStalker")
		enemy.position = positions[i]
		add_child(enemy)
		var hide_color := Color("#8b6553") if i < 3 else (Color("#7edbd9") if i == 4 else Color("#565c67"))
		var hide_mat := _mat(hide_color, 0.8, 0.18 if i == 4 else 0.0)
		if i == 4:
			hide_mat.emission_enabled = true
			hide_mat.emission = Color("#3da9b9")
			hide_mat.emission_energy_multiplier = 0.65
		var fur := _mesh_node(enemy, CapsuleMesh.new(), hide_mat, Vector3(0, 0.72, 0), "EnemyBody")
		fur.scale = Vector3(1.18, 1.05, 0.92) if i == 4 else Vector3(0.72, 0.58, 0.55)
		var head := _mesh_node(enemy, SphereMesh.new(), hide_mat, Vector3(0, 1.25 if i != 4 else 1.75, -0.3), "EnemyHead")
		head.scale = Vector3(0.48, 0.42, 0.52) if i != 4 else Vector3(0.78, 0.7, 0.72)
		for side in [-1.0, 1.0]:
			var ear := _mesh_node(enemy, PrismMesh.new(), hide_mat, Vector3(side * 0.28, 1.65, -0.3), "Ear")
			ear.scale = Vector3(0.32, 0.5, 0.25)
		for side in [-1.0, 1.0]:
			for fore_aft in [-1.0, 1.0]:
				var paw := _mesh_node(enemy, CapsuleMesh.new(), hide_mat, Vector3(side * 0.38, 0.28, fore_aft * 0.32), "WolfPaw")
				paw.scale = Vector3(0.18, 0.42, 0.18)
				enemy_legs.append(paw)
		var tail := _mesh_node(enemy, CapsuleMesh.new(), hide_mat, Vector3(0, 0.88, 0.5), "WolfTail")
		tail.rotation.x = -0.8
		tail.scale = Vector3(0.13, 0.42, 0.13)
		enemy_tails.append(tail)
		var muzzle := _mesh_node(enemy, SphereMesh.new(), _mat(Color("#302b2b"), 0.92), Vector3(0, 1.12, -0.72), "DarkMuzzle")
		muzzle.scale = Vector3(0.25, 0.18, 0.25)
		for side in [-1.0, 1.0]:
			var claw := _mesh_node(enemy, PrismMesh.new(), _mat(Color("#c6bca7"), 0.65), Vector3(side * 0.38, 0.12, -0.42), "PawClaw")
			claw.scale = Vector3(0.07, 0.08, 0.16)
		var eye_color := Color("#8dfaff") if i == 4 else Color("#ffbd76")
		var eye_mat := _mat(eye_color, 0.3, 0.0)
		if i == 4:
			eye_mat.emission_enabled = true
			eye_mat.emission = eye_color
			eye_mat.emission_energy_multiplier = 1.8
		for side in [-1.0, 1.0]:
			var eye := _mesh_node(enemy, SphereMesh.new(), eye_mat, Vector3(side * (0.29 if i == 4 else 0.17), 1.81 if i == 4 else 1.31, -0.86 if i == 4 else -0.73), "Eye")
			eye.scale = Vector3(0.13, 0.1, 0.07) if i == 4 else Vector3(0.075, 0.07, 0.05)
		if i == 4:
			for side in [-1.0, 1.0]:
				var horn := _mesh_node(enemy, PrismMesh.new(), _mat(Color("#e2f6ee"), 0.3, 0.2), Vector3(side * 0.48, 2.42, -0.16), "FrostHorn")
				horn.scale = Vector3(0.32, 0.82, 0.28)
				horn.rotation.z = -side * 0.32
			var core_mat := _mat(Color("#b3ffff"), 0.22, 0.3)
			core_mat.emission_enabled = true
			core_mat.emission = Color("#67e7f2")
			core_mat.emission_energy_multiplier = 2.2
			var core := _mesh_node(enemy, PrismMesh.new(), core_mat, Vector3(0, 1.12, -0.68), "FrostCore")
			core.scale = Vector3(0.32, 0.42, 0.22)
		enemies.append(enemy)
		enemy_health[enemy] = 650 if i == 4 else (75 if i < 3 else 110)
		enemy_hit_timers[enemy] = 0.0
		if enemy.name == "FrostWarden":
			frost_warden_states[enemy] = {"cooldown": 2.8, "windup": 0.0, "marker": null, "target": Vector3.ZERO, "origin": enemy.position, "phase": 0, "attack": "nova", "next_attack": 0, "last_attack": "", "phase_shift": 0.0, "combo_step": 0}
		enemy_base_colors[enemy] = hide_mat.albedo_color
		_create_enemy_health_ui(enemy)

func _create_enemy_health_ui(enemy: Node3D) -> void:
	var root := Node3D.new()
	root.name = "EnemyHealthDisplay"
	root.position = Vector3(0.0, 2.05, 0.0)
	enemy.add_child(root)
	var back_material := _mat(Color("#1c2422"), 0.95)
	var fill_material := _mat(Color("#72bd70"), 0.8)
	var background := _box(root, Vector3(1.0, 0.075, 0.035), back_material, Vector3.ZERO, "HealthBarBackground")
	background.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var fill := _box(root, Vector3(0.94, 0.045, 0.045), fill_material, Vector3(-0.03, 0.0, 0.026), "HealthBarFill")
	fill.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var name_tag := Label3D.new()
	name_tag.name = "EnemyName"
	name_tag.text = "FROST WARDEN  •  ELITE" if enemy.name == "FrostWarden" else ("ASH WOLF" if enemy.name == "AshWolf" else "RUIN STALKER")
	if enemy.name == "FrostWarden":
		name_tag.modulate = Color("#9af5ff")
		name_tag.font_size = 34
		root.scale = Vector3(1.35, 1.35, 1.35)
	name_tag.position = Vector3(0.0, 0.17, 0.0)
	name_tag.font_size = 28
	name_tag.pixel_size = 0.006
	name_tag.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	name_tag.modulate = Color("#f0dfc3")
	name_tag.outline_size = 4
	root.add_child(name_tag)
	enemy_health_ui[enemy] = {"root": root, "fill": fill, "material": fill_material}
	_update_enemy_health_ui(enemy)
	if enemy.name == "FrostWarden":
		_update_boss_hud(enemy)

func _update_enemy_health_ui(enemy: Node3D) -> void:
	if not enemy_health_ui.has(enemy):
		return
	var display: Dictionary = enemy_health_ui[enemy]
	var fill := display.get("fill") as MeshInstance3D
	var material := display.get("material") as StandardMaterial3D
	if fill == null or material == null:
		return
	var max_hp := 650.0 if enemy.name == "FrostWarden" else (110.0 if enemy.name == "RuinStalker" else 75.0)
	var ratio := clampf(float(enemy_health.get(enemy, max_hp)) / max_hp, 0.0, 1.0)
	fill.scale.x = ratio
	fill.position.x = -0.03 - 0.47 * (1.0 - ratio)
	material.albedo_color = Color("#72bd70") if ratio > 0.55 else (Color("#e0b45f") if ratio > 0.25 else Color("#d9685c"))

func _update_boss_hud(enemy: Node3D) -> void:
	if boss_panel == null or boss_hp_bar == null or boss_phase_label == null:
		return
	var hp := clampi(int(enemy_health.get(enemy, 0)), 0, 650)
	var phase_index := 2 if hp <= 195 else (1 if hp <= 422 else 0)
	var phase := "PHASE III  •  ENRAGED" if phase_index == 2 else ("PHASE II  •  AWAKENED" if phase_index == 1 else "PHASE I  •  DORMANT")
	boss_panel.visible = hp > 0
	if hp != boss_hud_hp:
		boss_hud_hp = hp
		boss_hp_bar.value = hp
		boss_phase_label.text = "FROST WARDEN   %d / 650 HP   •   %s" % [hp, phase]
	if phase_index != boss_hud_phase:
		boss_hud_phase = phase_index
		boss_hp_bar.add_theme_stylebox_override("fill", _hud_bar_style(Color("#74e9f2") if phase_index == 0 else (Color("#4db8d3") if phase_index == 1 else Color("#b77be8"))))

func _refresh_boss_hud() -> void:
	var boss: Node3D = null
	for candidate in enemies:
		if is_instance_valid(candidate) and candidate.name == "FrostWarden":
			boss = candidate
			break
	if boss != null:
		_update_boss_hud(boss)
	elif boss_panel != null:
		boss_panel.visible = false

func _spawn_damage_number(enemy: Node3D, damage: int) -> void:
	var number := Label3D.new()
	number.name = "FloatingDamageNumber"
	number.text = "-%d" % damage
	number.font_size = 48
	number.pixel_size = 0.008
	number.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	number.modulate = Color("#fff0bd")
	number.outline_size = 7
	number.outline_modulate = Color("#3b2420")
	number.position = enemy.global_position + Vector3(0.0, 2.0, 0.0)
	add_child(number)
	damage_number_effects.append({"node": number, "age": 0.0, "duration": 0.72, "drift": Vector3(0.0, 1.15, 0.0)})

func _update_health_bar_fades(delta: float) -> void:
	for i in range(health_bar_fade_effects.size() - 1, -1, -1):
		var item: Dictionary = health_bar_fade_effects[i]
		var root := item.get("root") as Node3D
		if not is_instance_valid(root):
			health_bar_fade_effects.remove_at(i)
			continue
		var age := float(item.get("age", 0.0)) + delta
		var duration := float(item.get("duration", 0.24))
		item["age"] = age
		health_bar_fade_effects[i] = item
		if age >= duration:
			root.queue_free()
			health_bar_fade_effects.remove_at(i)
			continue
		var progress := clampf(age / duration, 0.0, 1.0)
		root.scale = Vector3.ONE * (1.0 - progress) * (1.0 - progress)
		root.position.y += delta * 0.45

func _update_damage_numbers(delta: float) -> void:
	for i in range(damage_number_effects.size() - 1, -1, -1):
		var item: Dictionary = damage_number_effects[i]
		var label := item.get("node") as Label3D
		if not is_instance_valid(label):
			damage_number_effects.remove_at(i)
			continue
		var age := float(item.get("age", 0.0)) + delta
		var duration := float(item.get("duration", 0.72))
		item["age"] = age
		damage_number_effects[i] = item
		if age >= duration:
			label.queue_free()
			damage_number_effects.remove_at(i)
			continue
		label.position += (item.get("drift", Vector3.UP) as Vector3) * delta
		label.modulate.a = 1.0 - clampf(age / duration, 0.0, 1.0)
		label.scale = Vector3.ONE * (1.0 + sin(clampf(age / 0.12, 0.0, 1.0) * PI) * 0.12)

func _build_hud() -> void:
	var layer := CanvasLayer.new()
	layer.name = "MobileHUD"
	add_child(layer)
	var panel := PanelContainer.new()
	panel.position = Vector2(22, 18)
	panel.custom_minimum_size = Vector2(300, 100)
	layer.add_child(panel)
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.035, 0.055, 0.05, 0.88)
	style.border_color = Color("#b99a65")
	style.set_border_width_all(2)
	style.set_corner_radius_all(8)
	panel.add_theme_stylebox_override("panel", style)
	var stack := VBoxContainer.new()
	stack.add_theme_constant_override("separation", 3)
	panel.add_child(stack)
	var title := Label.new()
	title.text = "ELDERVALE  •  WARDEN LV. 5"
	title.add_theme_font_size_override("font_size", 19)
	title.add_theme_color_override("font_color", Color("#f0dfbf"))
	stack.add_child(title)
	hp_bar = ProgressBar.new()
	hp_bar.custom_minimum_size = Vector2(270, 15)
	hp_bar.max_value = player_max_hp
	hp_bar.value = player_hp
	hp_bar.show_percentage = false
	hp_bar.add_theme_stylebox_override("background", _hud_bar_style(Color("#352c2a")))
	hp_bar.add_theme_stylebox_override("fill", _hud_bar_style(Color("#b84d46")))
	stack.add_child(hp_bar)
	stats_label = Label.new()
	stats_label.name = "ProgressionStats"
	stats_label.add_theme_font_size_override("font_size", 12)
	stats_label.add_theme_color_override("font_color", Color("#e0d0ad"))
	stack.add_child(stats_label)
	status_label = Label.new()
	status_label.position = Vector2(410, 20)
	status_label.size = Vector2(460, 36)
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status_label.add_theme_font_size_override("font_size", 18)
	status_label.add_theme_color_override("font_color", Color("#e7d5ac"))
	layer.add_child(status_label)
	boss_panel = PanelContainer.new()
	boss_panel.name = "FrostWardenBossHUD"
	boss_panel.position = Vector2(300, 64)
	boss_panel.custom_minimum_size = Vector2(480, 56)
	boss_panel.visible = false
	var boss_style := StyleBoxFlat.new()
	boss_style.bg_color = Color(0.025, 0.075, 0.09, 0.92)
	boss_style.border_color = Color("#5fdde8")
	boss_style.set_border_width_all(2)
	boss_style.set_corner_radius_all(7)
	boss_panel.add_theme_stylebox_override("panel", boss_style)
	layer.add_child(boss_panel)
	var boss_stack := VBoxContainer.new()
	boss_stack.add_theme_constant_override("separation", 2)
	boss_panel.add_child(boss_stack)
	boss_phase_label = Label.new()
	boss_phase_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	boss_phase_label.add_theme_font_size_override("font_size", 14)
	boss_phase_label.add_theme_color_override("font_color", Color("#b7f8ff"))
	boss_stack.add_child(boss_phase_label)
	boss_hp_bar = ProgressBar.new()
	boss_hp_bar.custom_minimum_size = Vector2(450, 14)
	boss_hp_bar.min_value = 0
	boss_hp_bar.max_value = 650
	boss_hp_bar.value = 650
	boss_hp_bar.show_percentage = false
	boss_hp_bar.add_theme_stylebox_override("background", _hud_bar_style(Color("#172b33")))
	boss_hp_bar.add_theme_stylebox_override("fill", _hud_bar_style(Color("#74e9f2")))
	boss_stack.add_child(boss_hp_bar)
	target_label = Label.new()
	target_label.position = Vector2(18, 130)
	target_label.size = Vector2(300, 24)
	target_label.text = "SHATTERED REACH  •  ANCIENT RUINS"
	target_label.add_theme_font_size_override("font_size", 13)
	target_label.add_theme_color_override("font_color", Color("#d2d9bd"))
	layer.add_child(target_label)
	_add_action_button(layer, "ATTACK", Vector2(-118, -112), Vector2(104, 104), Color("#8c4937"), _attack)
	_add_action_button(layer, "SKILL", Vector2(-238, -92), Vector2(88, 88), Color("#3d6c83"), _skill)
	_add_action_button(layer, "DODGE", Vector2(-205, -205), Vector2(76, 76), Color("#367780"), _dodge)
	_add_action_button(layer, "ULT", Vector2(-326, -142), Vector2(80, 80), Color("#9b783d"), _ultimate)
	_add_action_button(layer, "BAG", Vector2(-86, -340), Vector2(76, 46), Color("#746347"), _toggle_inventory)
	inventory_panel = PanelContainer.new()
	inventory_panel.name = "InventoryPanel"
	inventory_panel.position = Vector2(340, 120)
	inventory_panel.custom_minimum_size = Vector2(370, 430)
	inventory_panel.visible = false
	var inventory_style := StyleBoxFlat.new()
	inventory_style.bg_color = Color(0.035, 0.055, 0.05, 0.96)
	inventory_style.border_color = Color("#b99a65")
	inventory_style.set_border_width_all(2)
	inventory_style.set_corner_radius_all(8)
	inventory_panel.add_theme_stylebox_override("panel", inventory_style)
	layer.add_child(inventory_panel)
	var inventory_stack := VBoxContainer.new()
	inventory_stack.add_theme_constant_override("separation", 8)
	inventory_panel.add_child(inventory_stack)
	var inventory_title := Label.new()
	inventory_title.text = "FIELD INVENTORY  •  SHATTERED REACH"
	inventory_title.add_theme_font_size_override("font_size", 17)
	inventory_title.add_theme_color_override("font_color", Color("#f0dfbf"))
	inventory_stack.add_child(inventory_title)
	inventory_label = Label.new()
	inventory_label.name = "InventoryContents"
	inventory_label.custom_minimum_size = Vector2(340, 225)
	inventory_label.add_theme_font_size_override("font_size", 15)
	inventory_label.add_theme_color_override("font_color", Color("#e0d0ad"))
	inventory_stack.add_child(inventory_label)
	var craft_weapon_button := Button.new()
	craft_weapon_button.text = "CRAFT / EQUIP  •  ASHEN BLADE"
	craft_weapon_button.pressed.connect(_craft_weapon)
	inventory_stack.add_child(craft_weapon_button)
	var craft_armor_button := Button.new()
	craft_armor_button.text = "CRAFT / EQUIP  •  RUIN ARMOR"
	craft_armor_button.pressed.connect(_craft_armor)
	inventory_stack.add_child(craft_armor_button)
	var close_inventory := Button.new()
	close_inventory.text = "CLOSE"
	close_inventory.pressed.connect(_toggle_inventory)
	inventory_stack.add_child(close_inventory)
	_refresh_progression_ui()
	var help := Label.new()
	help.position = Vector2(24, 650)
	help.text = "MOVE  •  LEFT SIDE      ATTACK  •  SKILL  •  DODGE"
	help.add_theme_font_size_override("font_size", 12)
	help.add_theme_color_override("font_color", Color("#d7d6c0"))
	layer.add_child(help)

func _hud_bar_style(color: Color) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = color
	s.set_corner_radius_all(4)
	return s

func _add_action_button(layer: CanvasLayer, caption: String, offset: Vector2, size: Vector2, tint: Color, action: Callable) -> void:
	var button := Button.new()
	button.text = caption
	button.custom_minimum_size = size
	button.size = size
	button.anchor_left = 1.0
	button.anchor_top = 1.0
	button.anchor_right = 1.0
	button.anchor_bottom = 1.0
	button.offset_left = offset.x - size.x * 0.5
	button.offset_top = offset.y - size.y * 0.5
	button.offset_right = offset.x + size.x * 0.5
	button.offset_bottom = offset.y + size.y * 0.5
	button.add_theme_font_size_override("font_size", 15)
	var normal := StyleBoxFlat.new()
	normal.bg_color = tint.darkened(0.45)
	normal.border_color = tint.lightened(0.25)
	normal.set_border_width_all(3)
	normal.set_corner_radius_all(48)
	button.add_theme_stylebox_override("normal", normal)
	var pressed := normal.duplicate() as StyleBoxFlat
	pressed.bg_color = tint
	button.add_theme_stylebox_override("pressed", pressed)
	button.add_theme_color_override("font_color", Color("#fff0d6"))
	button.pressed.connect(action)
	layer.add_child(button)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_W, KEY_UP: move_input.y = -1
			KEY_S, KEY_DOWN: move_input.y = 1
			KEY_A, KEY_LEFT: move_input.x = -1
			KEY_D, KEY_RIGHT: move_input.x = 1
			KEY_SPACE: _attack()
			KEY_F: _skill()
			KEY_V: _dodge()
			KEY_B: _ultimate()
	elif event is InputEventKey and not event.pressed:
		match event.keycode:
			KEY_W, KEY_S, KEY_UP, KEY_DOWN: move_input.y = 0
			KEY_A, KEY_D, KEY_LEFT, KEY_RIGHT: move_input.x = 0
	elif event is InputEventScreenTouch:
		if event.pressed and event.position.x < get_viewport().get_visible_rect().size.x * 0.38 and event.position.y > get_viewport().get_visible_rect().size.y * 0.48:
			touch_index = event.index
			touch_origin = event.position
			move_input = Vector2.ZERO
		elif not event.pressed and event.index == touch_index:
			touch_index = -1
			move_input = Vector2.ZERO
	elif event is InputEventScreenDrag and event.index == touch_index:
		var drag_delta: Vector2 = event.position - touch_origin
		move_input = Vector2(clampf(drag_delta.x / 70.0, -1.0, 1.0), clampf(drag_delta.y / 70.0, -1.0, 1.0))

func _process(delta: float) -> void:
	world_time += delta
	animation_time += delta
	if wave_respawn_timer >= 0.0:
		wave_respawn_timer -= delta
		if wave_respawn_timer <= 0.0 and enemies.is_empty():
			wave_respawn_timer = -1.0
			_build_enemies()
			if status_label != null:
				status_label.text = "NEW WAVE  •  ASH WOLVES AND RUIN STALKERS RETURN"
	for i in range(magical_materials.size()):
		var pulse := 0.88 + 0.22 * sin(animation_time * 1.35 + float(i) * 0.7)
		magical_materials[i].emission_energy_multiplier = pulse * (1.25 if i < 3 else 0.8)
	_update_combat_effects(delta)
	_update_damage_numbers(delta)
	_update_health_bar_fades(delta)
	attack_cooldown = maxf(0.0, attack_cooldown - delta)
	skill_cooldown = maxf(0.0, skill_cooldown - delta)
	attack_flash = maxf(0.0, attack_flash - delta)
	var input_dir := move_input
	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP): input_dir.y -= 1.0
	if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN): input_dir.y += 1.0
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT): input_dir.x -= 1.0
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT): input_dir.x += 1.0
	if input_dir.length_squared() > 1.0: input_dir = input_dir.normalized()
	var walking := input_dir.length_squared() > 0.01
	var gait := sin(animation_time * 9.0) * (0.62 if walking else 0.035)
	attack_anim_time = maxf(0.0, attack_anim_time - delta)
	var attack_phase := 1.0 - attack_anim_time / ATTACK_ANIM_DURATION
	var attack_active := attack_anim_time > 0.0
	var anticipation := sin(clampf(attack_phase / 0.28, 0.0, 1.0) * PI * 0.5) if attack_active else 0.0
	var strike_progress := clampf((attack_phase - 0.28) / 0.34, 0.0, 1.0)
	var swing := sin(strike_progress * PI) if attack_active and attack_phase >= 0.28 and attack_phase <= 0.62 else 0.0
	var follow_through := (1.0 - clampf((attack_phase - 0.62) / 0.38, 0.0, 1.0)) if attack_active and attack_phase > 0.62 else 0.0
	for i in range(animated_arms.size()):
		var arm_side := 1.0 if i == 0 else -1.0
		animated_arms[i].rotation.x = -gait * arm_side - anticipation * 0.42 - swing * 1.5 + follow_through * 0.2
		animated_arms[i].rotation.z = -anticipation * 0.16 - swing * 0.22
	for i in range(animated_legs.size()):
		animated_legs[i].rotation.x = gait * (1.0 if i == 0 else -1.0) + anticipation * 0.08 - swing * 0.12
	if animated_sword != null:
		animated_sword.rotation.z = -0.28 + anticipation * 0.82 - swing * 1.55 + follow_through * 0.18
		animated_sword.rotation.x = -anticipation * 0.18 + swing * 0.42
	if animated_torso != null:
		animated_torso.position.y = 1.12 + (absf(gait) * 0.035 if walking else 0.0) - anticipation * 0.025 - swing * 0.065 + follow_through * 0.02
		animated_torso.rotation.y = anticipation * -0.12 + swing * 0.18
	if animated_cape != null:
		animated_cape.rotation.x = sin(animation_time * 3.0) * 0.045 + (0.1 if walking else 0.0) + anticipation * 0.12 - swing * 0.16 + follow_through * 0.08
	for i in range(enemy_legs.size()):
		enemy_legs[i].rotation.x = sin(animation_time * 7.0 + float(i % 4) * PI * 0.5) * 0.16
	for i in range(enemy_tails.size()):
		enemy_tails[i].rotation.x = -0.8 + sin(animation_time * 3.2 + float(i)) * 0.12
	if input_dir.length_squared() > 0.01:
		var direction := Vector3(input_dir.x, 0, input_dir.y)
		player.position += direction * MOVE_SPEED * delta
		player.position.x = clampf(player.position.x, -WORLD_LIMIT, WORLD_LIMIT)
		player.position.z = clampf(player.position.z, -WORLD_LIMIT, WORLD_LIMIT)
		player.rotation.y = lerp_angle(player.rotation.y, atan2(direction.x, direction.z), minf(1.0, delta * 10.0))
		camera.position = camera.position.lerp(Vector3(0, 4.8, 7.4), minf(1.0, delta * 4.0))
		camera.rotation.x = lerp(camera.rotation.x, deg_to_rad(-25), minf(1.0, delta * 4.0))
	camera.look_at(player.position + Vector3(0, 1.0, -2.0), Vector3.UP)
	for i in range(enemies.size()):
		var enemy := enemies[i]
		if not is_instance_valid(enemy): continue
		var hit_left: float = maxf(0.0, float(enemy_hit_timers.get(enemy, 0.0)) - delta)
		enemy_hit_timers[enemy] = hit_left
		var knockback: Vector3 = enemy_knockback.get(enemy, Vector3.ZERO)
		if knockback.length_squared() > 0.0004:
			enemy.position += knockback * delta
			enemy_knockback[enemy] = knockback.move_toward(Vector3.ZERO, 17.0 * delta)
		else:
			enemy_knockback.erase(enemy)
		if enemy_recovery_animations.has(enemy):
			var recovery: Dictionary = enemy_recovery_animations[enemy]
			var recovery_age := float(recovery.get("age", 0.0)) + delta
			var recovery_duration := float(recovery.get("duration", 0.32))
			var recovery_progress := clampf(recovery_age / recovery_duration, 0.0, 1.0)
			var recovery_pulse := sin(recovery_progress * PI)
			var impact_strength := float(recovery.get("strength", 1.0))
			var impact_direction := float(recovery.get("direction", 1.0))
			var recovery_body := enemy.get_node_or_null("EnemyBody") as MeshInstance3D
			var recovery_head := enemy.get_node_or_null("EnemyHead") as MeshInstance3D
			if recovery_body != null:
				var base_body_scale: Vector3 = recovery.get("body_scale", Vector3(0.72, 0.58, 0.55))
				var base_body_rotation: Vector3 = recovery.get("body_rotation", Vector3.ZERO)
				recovery_body.scale = base_body_scale + Vector3(0.06, -0.10, 0.08) * recovery_pulse * impact_strength
				recovery_body.rotation = base_body_rotation + Vector3(0.0, 0.0, 0.12 * impact_direction * recovery_pulse * impact_strength)
			if recovery_head != null:
				var base_head_position: Vector3 = recovery.get("head_position", Vector3(0.0, 1.25, -0.3))
				var base_head_rotation: Vector3 = recovery.get("head_rotation", Vector3.ZERO)
				recovery_head.position = base_head_position + Vector3(0.045 * impact_direction, -0.07, 0.04) * recovery_pulse * impact_strength
				recovery_head.rotation = base_head_rotation + Vector3(0.15 * recovery_pulse * impact_strength, 0.0, -0.08 * impact_direction * recovery_pulse * impact_strength)
			if recovery_age >= recovery_duration:
				if recovery_body != null:
					recovery_body.scale = recovery.get("body_scale", Vector3(0.72, 0.58, 0.55))
					recovery_body.rotation = recovery.get("body_rotation", Vector3.ZERO)
				if recovery_head != null:
					recovery_head.position = recovery.get("head_position", Vector3(0.0, 1.25, -0.3))
					recovery_head.rotation = recovery.get("head_rotation", Vector3.ZERO)
				enemy_recovery_animations.erase(enemy)
			else:
				recovery["age"] = recovery_age
				enemy_recovery_animations[enemy] = recovery
		enemy.rotation.z = lerpf(enemy.rotation.z, 0.0, minf(1.0, delta * 12.0))
		if enemy_health_ui.has(enemy):
			var display: Dictionary = enemy_health_ui[enemy]
			var display_root := display.get("root") as Node3D
			if is_instance_valid(display_root) and camera != null:
				display_root.look_at(camera.global_position, Vector3.UP)
		if hit_left <= 0.0 and enemy.has_node("EnemyBody"):
			var enemy_body := enemy.get_node("EnemyBody") as MeshInstance3D
			var enemy_material := enemy_body.material_override as StandardMaterial3D
			if enemy_material != null and enemy_base_colors.has(enemy):
				enemy_material.albedo_color = enemy_base_colors[enemy]
		if hit_left > 0.0: continue
		if enemy.name == "FrostWarden":
			_update_frost_warden_combat(enemy, delta)
		var d := enemy.position.distance_to(player.position)
		if d < 11.0 and d > 2.6:
			var toward := (player.position - enemy.position).normalized()
			enemy.position += Vector3(toward.x, 0, toward.z) * (0.55 if i < 3 else 0.35) * delta
			enemy.rotation.y = atan2(-toward.x, -toward.z)
	if hp_bar != null:
		hp_bar.value = player_hp
	_refresh_boss_hud()
	if status_label != null:
		var combat_status := ("ATTACK READY" if attack_cooldown <= 0 else "ATTACK  %.1fs" % attack_cooldown) + "     •     " + ("SKILL READY" if skill_cooldown <= 0 else "SKILL  %.1fs" % skill_cooldown)
		for boss in enemies:
			if is_instance_valid(boss) and boss.name == "FrostWarden" and frost_warden_states.has(boss):
				var boss_state: Dictionary = frost_warden_states[boss]
				var windup_left := float(boss_state.get("windup", 0.0))
				if windup_left > 0.0:
					var attack_name := str(boss_state.get("attack", "nova")).to_upper().replace("NOVA", "NOVA").replace("LANCE", "LANCE").replace("SHATTER", "SHATTER RING")
					combat_status = "%s INCOMING  •  DODGE NOW  •  %.1fs" % [attack_name, windup_left]
				elif float(boss_state.get("cooldown", 0.0)) > 0.0:
					combat_status += "     •     FROST WARDEN ACTIVE"
				break
		status_label.text = combat_status

func _update_frost_warden_combat(enemy: Node3D, delta: float) -> void:
	if not frost_warden_states.has(enemy):
		frost_warden_states[enemy] = {"cooldown": 2.8, "windup": 0.0, "marker": null, "target": Vector3.ZERO, "origin": enemy.position, "phase": 0, "attack": "nova", "next_attack": 0}
	var state: Dictionary = frost_warden_states[enemy]
	var hp_ratio := float(enemy_health.get(enemy, 650)) / 650.0
	var phase := 2 if hp_ratio <= 0.30 else (1 if hp_ratio <= 0.65 else 0)
	if phase != int(state.get("phase", 0)):
		state["phase"] = phase
		var body := enemy.get_node_or_null("EnemyBody") as MeshInstance3D
		if body != null:
			var material := body.material_override as StandardMaterial3D
			if material != null:
				material.albedo_color = Color("#a4faff") if phase == 2 else (Color("#61cbd8") if phase == 1 else Color("#7edbd9"))
				material.emission_energy_multiplier = 1.1 if phase == 2 else (0.8 if phase == 1 else 0.65)
		var core := enemy.get_node_or_null("FrostCore") as MeshInstance3D
		if core != null:
			core.scale = Vector3(0.48, 0.58, 0.32) if phase == 2 else (Vector3(0.38, 0.48, 0.26) if phase == 1 else Vector3(0.32, 0.42, 0.22))
		if body != null:
			var phase_material := body.material_override as StandardMaterial3D
			if phase_material != null:
				enemy_base_colors[enemy] = phase_material.albedo_color
		var phase_marker := state.get("marker") as Node3D
		if is_instance_valid(phase_marker):
			phase_marker.queue_free()
		state["marker"] = null
		state["windup"] = 0.0
		state["recovery"] = 0.0
		state["phase_shift"] = 1.05
		state["cooldown"] = 1.45
		_spawn_combat_effect("frost_phase", enemy.position + Vector3(0.0, 0.06, 0.0))
		if status_label != null:
			status_label.text = "FROST WARDEN ENRAGED  •  PHASE III" if phase == 2 else "FROST WARDEN AWAKENS  •  PHASE II"
	_update_boss_hud(enemy)
	var phase_shift_left := maxf(0.0, float(state.get("phase_shift", 0.0)) - delta)
	state["phase_shift"] = phase_shift_left
	if phase_shift_left > 0.0:
		if boss_body != null:
			var shift_pulse := 1.0 + 0.075 * sin(animation_time * 18.0)
			boss_body.scale = Vector3.ONE * shift_pulse
		if boss_core != null:
			boss_core.rotation.y += delta * 5.0
			boss_core.scale = Vector3(0.48, 0.58, 0.32) * (1.0 + 0.16 * sin(animation_time * 20.0))
		frost_warden_states[enemy] = state
		return
	var windup := float(state.get("windup", 0.0))
	var boss_body := enemy.get_node_or_null("EnemyBody") as MeshInstance3D
	var boss_core := enemy.get_node_or_null("FrostCore") as MeshInstance3D
	if windup > 0.0:
		var attack_pose := str(state.get("attack", "nova"))
		var pose_wave := sin(animation_time * (17.0 if phase == 2 else 13.0))
		enemy.rotation.z = (0.12 if attack_pose == "lance" else (-0.13 if attack_pose == "shatter" else 0.0)) + pose_wave * 0.025
		if boss_body != null:
			var pose_scale := Vector3(1.18, 1.05, 0.92)
			if attack_pose == "nova":
				pose_scale = Vector3(1.10, 0.92, 1.08)
			elif attack_pose == "lance":
				pose_scale = Vector3(1.24, 0.98, 0.88)
			else:
				pose_scale = Vector3(1.08, 1.18, 0.98)
			boss_body.scale = pose_scale * (1.0 + 0.025 * pose_wave)
		if boss_core != null:
			boss_core.rotation.y += delta * (3.2 if phase == 2 else 2.1)
			boss_core.rotation.x = (0.32 if attack_pose == "lance" else (-0.24 if attack_pose == "shatter" else 0.0)) + sin(animation_time * 8.0) * 0.04
			boss_core.scale = (Vector3(0.48, 0.58, 0.32) if phase == 2 else (Vector3(0.38, 0.48, 0.26) if phase == 1 else Vector3(0.32, 0.42, 0.22))) * (1.0 + 0.10 * sin(animation_time * 16.0))
		var live_marker := state.get("marker") as Node3D
		if is_instance_valid(live_marker):
			var pulse := 0.94 + 0.08 * sin(animation_time * 15.0)
			live_marker.scale = Vector3(pulse, 1.0, pulse)
		windup -= delta
		state["windup"] = windup
		if windup <= 0.0:
			var marker := state.get("marker") as Node3D
			if is_instance_valid(marker):
				marker.queue_free()
			state["marker"] = null
			state["recovery"] = 0.42
			enemy.rotation.z = 0.24 if phase == 2 else 0.16
			var attack := str(state.get("attack", "nova"))
			var target: Vector3 = state.get("target", Vector3.ZERO)
			var origin: Vector3 = state.get("origin", enemy.position)
			var impact_kind := "frost_nova_burst" if attack == "nova" else ("frost_lance_burst" if attack == "lance" else "frost_shatter_burst")
			_spawn_combat_effect(impact_kind, (target if attack == "nova" else origin) + Vector3(0.0, 0.04, 0.0))
			var hit := false
			var damage := 0
			if attack == "nova":
				var radius := 3.45 if phase == 2 else (3.0 if phase == 1 else 2.55)
				hit = player.position.distance_to(target) <= radius
				damage = 42 if phase == 2 else (34 if phase == 1 else 26)
			elif attack == "lance":
				hit = _player_in_ice_lance(origin, target)
				damage = 35 if phase == 2 else (28 if phase == 1 else 22)
			else:
				var ring_inner := 4.0 if phase == 2 else (3.4 if phase == 1 else 2.8)
				var ring_outer := ring_inner + 0.55
				var player_radius := Vector2(player.position.x - enemy.position.x, player.position.z - enemy.position.z).length()
				hit = player_radius >= ring_inner and player_radius <= ring_outer
				damage = 36 if phase == 2 else (29 if phase == 1 else 23)
			if hit:
				_take_frost_damage(damage, "FROST NOVA" if attack == "nova" else ("ICE LANCE" if attack == "lance" else "SHATTER RING"))
				_spawn_combat_effect("hit", player.position + Vector3(0.0, 0.08, 0.0))
			elif status_label != null:
				status_label.text = "FROST ATTACK EVADED  •  GOOD DODGE"
		frost_warden_states[enemy] = state
		return
	var recovery_left := maxf(0.0, float(state.get("recovery", 0.0)) - delta)
	state["recovery"] = recovery_left
	if recovery_left > 0.0:
		var recovery_progress := recovery_left / 0.42
		enemy.rotation.z = 0.24 * recovery_progress
		if boss_body != null:
			boss_body.scale = Vector3(1.18, 1.05, 0.92) * (1.0 - 0.055 * sin((1.0 - recovery_progress) * PI))
	elif boss_body != null:
		boss_body.scale = Vector3(1.18, 1.05, 0.92)
	var cooldown := float(state.get("cooldown", 2.8)) - delta
	if cooldown <= 0.0:
		var next_attack := int(state.get("next_attack", 0))
		var distance_to_player := Vector2(player.position.x - enemy.position.x, player.position.z - enemy.position.z).length()
		var last_attack := str(state.get("last_attack", ""))
		var attack := _choose_frost_warden_attack(distance_to_player, phase, next_attack, last_attack)
		state["next_attack"] = next_attack + 1
		state["last_attack"] = attack
		state["combo_step"] = int(state.get("combo_step", 0)) + 1
		var target := player.position
		var origin := enemy.position
		state["target"] = target
		state["origin"] = origin
		state["attack"] = attack
		var distance_windup_bonus := 0.12 if distance_to_player < 3.2 else (0.08 if distance_to_player > 8.0 else 0.0)
		state["windup"] = ((1.28 if phase == 0 else (1.08 if phase == 1 else 0.92)) if attack == "nova" else (((1.42 if phase == 0 else (1.22 if phase == 1 else 1.02))) if attack == "lance" else ((1.2 if phase == 0 else (1.02 if phase == 1 else 0.9)))) + distance_windup_bonus
		state["cooldown"] = (4.8 if phase == 0 else (3.55 if phase == 1 else 2.65))
		state["recovery"] = 0.0
		var warning := MeshInstance3D.new()
		warning.name = "FrostTelegraph_" + attack
		var warning_tint := Color("#51e8ff") if attack == "nova" else (Color("#ffb65c") if attack == "lance" else Color("#b78cff"))
		var warning_material := _mat(Color(warning_tint.r, warning_tint.g, warning_tint.b, 0.42), 0.35, 0.2)
		warning_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		warning_material.emission_enabled = true
		warning_material.emission = warning_tint
		warning_material.emission_energy_multiplier = 1.15
		warning.material_override = warning_material
		warning.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		if attack == "lance":
			var line := BoxMesh.new()
			var distance := maxf(2.0, Vector2(target.x - origin.x, target.z - origin.z).length())
			line.size = Vector3(1.65, 0.055, distance)
			warning.mesh = line
			warning.position = Vector3((origin.x + target.x) * 0.5, 0.075, (origin.z + target.z) * 0.5)
			warning.rotation.y = atan2(target.x - origin.x, target.z - origin.z)
		elif attack == "shatter":
			var ring := TorusMesh.new()
			ring.inner_radius = 2.8 if phase == 0 else (3.4 if phase == 1 else 4.0)
			ring.outer_radius = ring.inner_radius + 0.55
			ring.rings = 5
			ring.ring_segments = 20
			warning.mesh = ring
			warning.position = Vector3(origin.x, 0.09, origin.z)
		else:
			var disk := CylinderMesh.new()
			disk.top_radius = 2.55 if phase == 0 else (3.0 if phase == 1 else 3.45)
			disk.bottom_radius = disk.top_radius
			disk.height = 0.055
			warning.mesh = disk
			warning.position = Vector3(target.x, 0.07, target.z)
		add_child(warning)
		state["marker"] = warning
		if status_label != null:
			status_label.text = "FROST NOVA  •  DODGE THE CYAN ZONE" if attack == "nova" else ("ICE LANCE  •  LEAVE THE LINE" if attack == "lance" else "SHATTER RING  •  ESCAPE THE BOSS")
	else:
		state["cooldown"] = cooldown
	frost_warden_states[enemy] = state

func _choose_frost_warden_attack(distance_to_player: float, phase: int, sequence_index: int, last_attack: String) -> String:
	var preferred := "lance"
	if distance_to_player < 3.2:
		preferred = "nova"
	elif distance_to_player <= 8.0:
		var patterns := [
			["nova", "lance", "shatter"],
			["lance", "shatter", "nova"],
			["shatter", "nova", "lance"]
		]
		var pattern: Array = patterns[clampi(phase, 0, 2)]
		preferred = str(pattern[sequence_index % pattern.size()])
	if preferred == last_attack:
		if preferred == "nova":
			preferred = "shatter" if distance_to_player > 4.0 else "lance"
		elif preferred == "lance":
			preferred = "nova" if distance_to_player < 5.5 else "shatter"
		else:
			preferred = "lance" if distance_to_player > 5.5 else "nova"
	return preferred

func _player_in_ice_lance(origin: Vector3, target: Vector3) -> bool:
	var start := Vector2(origin.x, origin.z)
	var finish := Vector2(target.x, target.z)
	var point := Vector2(player.position.x, player.position.z)
	var segment := finish - start
	if segment.length_squared() < 0.01:
		return point.distance_to(start) <= 1.15
	var t := clampf((point - start).dot(segment) / segment.length_squared(), 0.0, 1.0)
	return point.distance_to(start + segment * t) <= 1.15

func _take_frost_damage(amount: int, attack_name: String = "FROST ATTACK") -> void:
	var mitigation := mini(12, armor_level * 3)
	var damage := maxi(8, amount - mitigation)
	player_hp = maxi(0, player_hp - damage)
	if player_hp <= 0:
		coins = maxi(0, coins - 25)
		player_hp = player_max_hp
		player.position = Vector3(0.0, 0.0, 3.0)
		if status_label != null:
			status_label.text = "WARDEN DOWN  •  -25 COINS  •  RETURNED TO THE CAMP"
	else:
		if status_label != null:
			status_label.text = "%s HIT  •  -%d HP  •  ARMOR BLOCKED %d" % [attack_name, damage, mitigation]
	if hp_bar != null:
		hp_bar.value = player_hp
	_refresh_progression_ui()
	_save_progress()

func _spawn_combat_effect(kind: String, origin: Variant = null) -> void:
	if player == null:
		return
	# Short-lived emissive meshes only: no particles and no extra dynamic lights.
	var effect_root := Node3D.new()
	effect_root.name = "CombatFX_" + kind
	effect_root.position = (player.position + Vector3(0.0, 0.04, 0.0)) if origin == null else origin
	effect_root.rotation.y = player.rotation.y
	add_child(effect_root)
	var tint := Color("#8df7ff") if kind.begins_with("frost_") else (Color("#c8f5ff") if kind == "slash" else (Color("#70e7ff") if kind == "cleave" or kind == "dodge" else (Color("#ffbf72") if kind == "hit" or kind == "death" else Color("#ffd58a"))))
	var glow := _mat(tint, 0.3, 0.25)
	glow.emission_enabled = true
	glow.emission = tint
	glow.emission_energy_multiplier = 1.65 if kind != "oath" else 2.0
	if kind == "slash":
		for i in range(3):
			var streak := _box(effect_root, Vector3(0.12, 0.07, 1.35), glow, Vector3(-0.55 + float(i) * 0.55, 1.18, -1.1 - absf(float(i) - 1.0) * 0.18), "SwordArcStreak")
			streak.rotation.y = (float(i) - 1.0) * 0.24
			streak.rotation.x = -0.12
			streak.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	elif kind == "cleave":
		for i in range(5):
			var streak := _box(effect_root, Vector3(0.16, 0.09, 2.05), glow, Vector3(-1.15 + float(i) * 0.575, 1.0, -1.55 - absf(float(i) - 2.0) * 0.12), "CleaveArcStreak")
			streak.rotation.y = (float(i) - 2.0) * 0.19
			streak.rotation.x = -0.18
			streak.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	elif kind == "oath":
		var ring_mesh := TorusMesh.new()
		ring_mesh.inner_radius = 1.35
		ring_mesh.outer_radius = 1.52
		ring_mesh.rings = 6
		ring_mesh.ring_segments = 16
		var ring := _mesh_node(effect_root, ring_mesh, glow, Vector3(0.0, 0.12, 0.0), "OathGroundRing")
		ring.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		for i in range(4):
			var beam := _box(effect_root, Vector3(0.12, 2.2, 0.12), glow, Vector3(cos(float(i) * TAU / 4.0) * 1.35, 1.1, sin(float(i) * TAU / 4.0) * 1.35), "OathRuneBeam")
			beam.rotation.y = float(i) * TAU / 4.0
			beam.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	elif kind == "hit":
		# Five tiny angular sparks radiate from the impact point.
		for i in range(5):
			var angle := TAU * float(i) / 5.0
			var spark := _box(effect_root, Vector3(0.07, 0.07, 0.42), glow, Vector3(cos(angle) * 0.22, sin(angle) * 0.22, 0.0), "ImpactSpark")
			spark.rotation.z = angle
			spark.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	elif kind.begins_with("frost_"):
		var ring_count := 1
		var shard_count := 8
		var inner_radius := 0.45
		var outer_radius := 0.68
		if kind == "frost_nova_burst":
			ring_count = 2
			inner_radius = 0.55
			outer_radius = 0.76
		elif kind == "frost_lance_burst":
			shard_count = 6
			inner_radius = 0.18
			outer_radius = 0.42
		elif kind == "frost_shatter_burst":
			ring_count = 3
			shard_count = 10
			inner_radius = 0.7
			outer_radius = 0.9
		for ring_index in range(ring_count):
			var frost_ring_mesh := TorusMesh.new()
			frost_ring_mesh.inner_radius = inner_radius + float(ring_index) * 0.38
			frost_ring_mesh.outer_radius = outer_radius + float(ring_index) * 0.38
			frost_ring_mesh.rings = 5
			frost_ring_mesh.ring_segments = 18
			var frost_ring := _mesh_node(effect_root, frost_ring_mesh, glow, Vector3(0.0, 0.12 + float(ring_index) * 0.025, 0.0), "FrostImpactRing")
			frost_ring.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		for i in range(shard_count):
			var angle := TAU * float(i) / float(shard_count)
			var shard_size := Vector3(0.1, 0.28 + float(i % 3) * 0.07, 0.1) if kind != "frost_lance_burst" else Vector3(0.09, 0.18 + float(i % 2) * 0.05, 0.46)
			var shard_position := Vector3(cos(angle) * 0.42, 0.32, sin(angle) * 0.42)
			if kind == "frost_lance_burst":
				shard_position = Vector3((float(i) - 2.5) * 0.24, 0.4, -0.35 - float(i % 2) * 0.18)
			var shard := _box(effect_root, shard_size, glow, shard_position, "FrostImpactShard")
			shard.rotation = Vector3(0.0, angle, angle * 0.35)
			shard.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	elif kind == "death":
		# Low-poly ember shards replace the former short-lived point light.
		for i in range(7):
			var angle := TAU * float(i) / 7.0
			var shard := _box(effect_root, Vector3(0.11, 0.18 + float(i % 3) * 0.04, 0.1), glow, Vector3(cos(angle) * 0.32, 0.48 + float(i % 2) * 0.18, sin(angle) * 0.32), "DeathEmberShard")
			shard.rotation = Vector3(angle * 0.4, angle, angle * 0.7)
			shard.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	elif kind == "dodge":
		# Three short afterimage bars stay at the dodge starting point.
		for i in range(3):
			var trail := _box(effect_root, Vector3(0.09, 0.08, 1.0), glow, Vector3(0.0, 0.42 + float(i) * 0.24, 0.45 + float(i) * 0.32), "DodgeAfterimage")
			trail.rotation.y = (float(i) - 1.0) * 0.18
			trail.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var duration := 0.72
	if kind.begins_with("frost_"):
		duration = 0.54 if kind == "frost_phase" else 0.46
	elif kind == "hit":
		duration = 0.22
	elif kind == "death":
		duration = 0.52
	elif kind == "dodge":
		duration = 0.26
	elif kind == "slash":
		duration = 0.34
	elif kind == "cleave":
		duration = 0.48
	combat_effects.append({"root": effect_root, "age": 0.0, "duration": duration, "kind": kind})

func _update_combat_effects(delta: float) -> void:
	for i in range(combat_effects.size() - 1, -1, -1):
		var fx: Dictionary = combat_effects[i]
		var root := fx.get("root") as Node3D
		if not is_instance_valid(root):
			combat_effects.remove_at(i)
			continue
		var age := float(fx.get("age", 0.0)) + delta
		var duration := float(fx.get("duration", 0.4))
		var progress := clampf(age / duration, 0.0, 1.0)
		fx["age"] = age
		combat_effects[i] = fx
		if age >= duration:
			root.queue_free()
			combat_effects.remove_at(i)
			continue
		var kind := str(fx.get("kind", "slash"))
		if kind == "slash":
			root.scale = Vector3.ONE * (0.82 + progress * 0.42)
			root.rotation.y += delta * 0.75
		elif kind == "cleave":
			root.scale = Vector3(0.75 + progress * 0.7, 0.9, 0.8 + progress * 0.65)
			root.rotation.y += delta * 0.42
		elif kind == "hit":
			root.scale = Vector3.ONE * (0.65 + progress * 0.9)
		elif kind.begins_with("frost_"):
			root.scale = Vector3.ONE * (0.45 + progress * (2.0 if kind == "frost_shatter_burst" else 1.65))
			root.rotation.y += delta * (2.3 if kind == "frost_shatter_burst" else 1.8)
		elif kind == "death":
			root.scale = Vector3.ONE * (0.7 + progress * 1.4)
			root.rotation.y += delta * 1.6
		elif kind == "dodge":
			root.scale = Vector3(1.0 + progress * 0.35, 1.0 - progress * 0.25, 1.0 + progress * 0.55)
			root.position.y += delta * 0.35
		else:
			root.scale = Vector3.ONE * (0.55 + progress * 1.25)
			root.rotation.y += delta * 0.55

func _nearest_enemy() -> Node3D:
	var best: Node3D = null
	var best_distance := 4.8
	for enemy in enemies:
		if is_instance_valid(enemy):
			var d := player.position.distance_to(enemy.position)
			if d < best_distance:
				best_distance = d
				best = enemy
	return best

func _attack() -> void:
	if attack_cooldown > 0.0: return
	_spawn_combat_effect("slash")
	attack_cooldown = 0.48
	var target := _nearest_enemy()
	if target != null:
		var damage := 34 + weapon_level * 9
		_damage_enemy(target, damage)
		status_label.text = "SWORD STRIKE  •  %d DAMAGE" % damage
	else:
		status_label.text = "SWORD SWING  •  MOVE CLOSER"
	attack_flash = 0.18
	attack_anim_time = ATTACK_ANIM_DURATION

func _skill() -> void:
	if skill_cooldown > 0.0: return
	_spawn_combat_effect("cleave")
	skill_cooldown = 4.0
	var target := _nearest_enemy()
	if target != null:
		var damage := 58 + weapon_level * 14
		_damage_enemy(target, damage)
		status_label.text = "WARDEN CLEAVE  •  %d DAMAGE" % damage
	else:
		status_label.text = "WARDEN CLEAVE  •  NO TARGET"
	attack_flash = 0.32
	attack_anim_time = ATTACK_ANIM_DURATION

func _damage_enemy(enemy: Node3D, damage: int) -> void:
	if not is_instance_valid(enemy): return
	if enemy.name == "FrostWarden" and frost_warden_states.has(enemy):
		var boss_state: Dictionary = frost_warden_states[enemy]
		if float(boss_state.get("phase_shift", 0.0)) > 0.0:
			if status_label != null:
				status_label.text = "FROST WARDEN PHASE SHIFT  •  TEMPORARILY IMMUNE"
			return
	var remaining_hp: int = int(enemy_health.get(enemy, 75)) - damage
	enemy_health[enemy] = remaining_hp
	_spawn_damage_number(enemy, damage)
	_update_enemy_health_ui(enemy)
	# The impact flash and squash pulse share one short recovery window.
	var body := enemy.get_node_or_null("EnemyBody") as MeshInstance3D
	var head := enemy.get_node_or_null("EnemyHead") as MeshInstance3D
	if body != null:
		var flash_material := body.material_override as StandardMaterial3D
		if flash_material != null:
			flash_material.albedo_color = Color("#ffd0ad")
		var impact_strength := clampf(float(damage) / 90.0, 0.4, 1.0)
		var impact_direction := -1.0 if enemy.position.x < player.position.x else 1.0
		var recovery: Dictionary = enemy_recovery_animations.get(enemy, {})
		if not recovery.is_empty():
			impact_strength = maxf(impact_strength, float(recovery.get("strength", 0.4)))
		enemy_recovery_animations[enemy] = {
			"age": 0.0,
			"duration": 0.32,
			"strength": impact_strength,
			"direction": impact_direction,
			"body_scale": recovery.get("body_scale", body.scale),
			"body_rotation": recovery.get("body_rotation", body.rotation),
			"head_position": recovery.get("head_position", head.position if head != null else Vector3(0.0, 1.25, -0.3)),
			"head_rotation": recovery.get("head_rotation", head.rotation if head != null else Vector3.ZERO)
		}
	enemy_hit_timers[enemy] = ENEMY_HIT_REACTION_DURATION
	_spawn_combat_effect("hit", enemy.position + Vector3(0.0, 0.9, 0.0))
	var recoil := enemy.global_position - player.global_position
	recoil.y = 0.0
	if recoil.length_squared() > 0.001:
		var hit_push := recoil.normalized() * 4.2
		var existing_push: Vector3 = enemy_knockback.get(enemy, Vector3.ZERO)
		var combined_push := hit_push + existing_push * 0.45
		enemy_knockback[enemy] = combined_push.limit_length(5.2)
	enemy.rotation.z = -0.28 if enemy.position.x < player.position.x else 0.28
	if remaining_hp > 0:
		status_label.text = "HIT  •  %d DAMAGE  •  %d HP LEFT" % [damage, remaining_hp]
		return
	kills += 1
	xp += 12
	coins += 5
	enemies.erase(enemy)
	enemy_health.erase(enemy)
	enemy_hit_timers.erase(enemy)
	enemy_knockback.erase(enemy)
	enemy_recovery_animations.erase(enemy)
	enemy_base_colors.erase(enemy)
	if frost_warden_states.has(enemy):
		var boss_state: Dictionary = frost_warden_states[enemy]
		var warning_marker := boss_state.get("marker") as Node3D
		if is_instance_valid(warning_marker):
			warning_marker.queue_free()
		frost_warden_states.erase(enemy)
	if enemy_health_ui.has(enemy):
		var display: Dictionary = enemy_health_ui[enemy]
		var display_root := display.get("root") as Node3D
		if is_instance_valid(display_root):
			display_root.reparent(self, true)
			health_bar_fade_effects.append({"root": display_root, "age": 0.0, "duration": 0.24})
		enemy_health_ui.erase(enemy)
	_spawn_combat_effect("death", enemy.position + Vector3(0.0, 0.04, 0.0))
	enemy.queue_free()
	_roll_enemy_loot(enemy)
	if enemies.is_empty():
		wave_respawn_timer = 7.0
	_gain_xp(12)
	_save_progress()
	if target_label != null:
		target_label.text = "KILLS %d  •  LV. %d  •  XP %d/%d  •  COINS %d" % [kills, player_level, xp, xp_to_next_level, coins]
	_refresh_progression_ui()

func _dodge() -> void:
	var dodge_origin := player.position
	var direction := Vector3(move_input.x, 0, move_input.y)
	if direction.length_squared() < 0.01:
		direction = -player.global_transform.basis.z
	player.position += direction.normalized() * 3.0
	player.position.x = clampf(player.position.x, -WORLD_LIMIT, WORLD_LIMIT)
	player.position.z = clampf(player.position.z, -WORLD_LIMIT, WORLD_LIMIT)
	_spawn_combat_effect("dodge", dodge_origin)
	status_label.text = "EVASIVE STEP"

func _ultimate() -> void:
	_spawn_combat_effect("oath")
	var target := _nearest_enemy()
	if target != null:
		var damage := 90 + weapon_level * 22
		_damage_enemy(target, damage)
		status_label.text = "ANCIENT OATH  •  %d DAMAGE" % damage
	else:
		status_label.text = "ANCIENT OATH  •  NO TARGET"
	attack_flash = 0.4
	attack_anim_time = ATTACK_ANIM_DURATION

func _roll_enemy_loot(enemy: Node3D) -> void:
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	var gained: Array[String] = []
	if enemy.name == "FrostWarden":
		inventory["Warden Emblem"] = int(inventory.get("Warden Emblem", 0)) + 2
		inventory["Frost Sigil"] = int(inventory.get("Frost Sigil", 0)) + 1
		inventory["Echo Fragment"] = int(inventory.get("Echo Fragment", 0)) + 4
		inventory["Ruin Core"] = int(inventory.get("Ruin Core", 0)) + 3
		gained.append_array(["Warden Emblem", "Frost Sigil", "Echo Fragment ×4", "Ruin Core ×3"])
		coins += 300
		_gain_xp(350)
		if not boss_first_kill_claimed:
			boss_first_kill_claimed = true
			inventory["Glacial Crown"] = int(inventory.get("Glacial Crown", 0)) + 1
			coins += 500
			_gain_xp(600)
			if not codex_discoveries.has("Frost Warden Slain"):
				codex_discoveries.append("Frost Warden Slain")
			gained.append("GLACIAL CROWN  •  FIRST KILL RELIC")
			status_label.text = "FIRST WARDEN SLAIN  •  GLACIAL CROWN +500 COINS +600 XP"
	elif enemy.name == "AshWolf":
		if rng.randf() <= 0.48:
			inventory["Ashen Pelt"] = int(inventory.get("Ashen Pelt", 0)) + 1
			gained.append("Ashen Pelt")
		if rng.randf() <= 0.10:
			inventory["Echo Fragment"] = int(inventory.get("Echo Fragment", 0)) + 1
			gained.append("Echo Fragment")
	else:
		inventory["Ancient Shard"] = int(inventory.get("Ancient Shard", 0)) + 1
		gained.append("Ancient Shard")
		if rng.randf() <= 0.28:
			inventory["Ruin Core"] = int(inventory.get("Ruin Core", 0)) + 1
			gained.append("Ruin Core")
		if enemy.name == "RuinStalker" and rng.randf() <= 0.25:
			inventory["Warden Emblem"] = int(inventory.get("Warden Emblem", 0)) + 1
			gained.append("Warden Emblem")
	if not gained.is_empty():
		status_label.text = "LOOT FOUND  •  " + ", ".join(gained)
		if "Echo Fragment" in gained and not codex_discoveries.has("Echoes of Shattered Reach"):
			codex_discoveries.append("Echoes of Shattered Reach")
			status_label.text = "CODEX DISCOVERY  •  ECHOES OF SHATTERED REACH"
	_advance_quest(gained)
	_save_progress()

func _gain_xp(amount: int) -> void:
	xp += amount
	var leveled_up := false
	while xp >= xp_to_next_level:
		xp -= xp_to_next_level
		player_level += 1
		xp_to_next_level += 130 + player_level * 18
		leveled_up = true
	if leveled_up:
		status_label.text = "LEVEL UP  •  WARDEN LV. %d" % player_level
		_spawn_combat_effect("oath", player.position + Vector3(0.0, 0.04, 0.0))
	_refresh_progression_ui()

func _toggle_inventory() -> void:
	if inventory_panel == null:
		return
	inventory_panel.visible = not inventory_panel.visible
	_refresh_progression_ui()

func _refresh_progression_ui() -> void:
	if stats_label != null:
		stats_label.text = "HP %d/%d    LV. %d    XP %d/%d    COINS %d" % [player_hp, player_max_hp, player_level, xp, xp_to_next_level, coins]
	if inventory_label != null:
		var lines: Array[String] = []
		for item_name in ["Ashen Pelt", "Ancient Shard", "Echo Fragment", "Ruin Core", "Warden Emblem", "Frost Sigil", "Glacial Crown"]:
			lines.append("%s  × %d" % [item_name, int(inventory.get(item_name, 0))])
		lines.append("")
		lines.append("EQUIPMENT")
		lines.append("Ashen Blade  Lv.%d  •  +%d attack" % [weapon_level, weapon_level * 9])
		lines.append("Ruin Armor  Lv.%d  •  +%d max HP" % [armor_level, armor_level * 18])
		lines.append("WEAPON: 3 Shards + 2 Pelts + 35 coins")
		lines.append("ARMOR: 3 Pelts + 2 Cores + 35 coins")
		lines.append("ELITE DROP: Warden Emblem  •  25%")
		lines.append("FROST WARDEN: every 3rd wave  •  650 HP")
		lines.append("BOSS PHASES: 65% / 30% HP  •  FROST NOVA TELEGRAPH")
		lines.append("DODGE: leave the cyan danger zone before impact")
		lines.append("ARMOR reduces Frost Warden damage by up to 12")
		lines.append("BOSS AI: range-aware combos  •  phase shift grants 1.05s guard")
		lines.append("SHATTER RING: dodge through the inner safe zone or beyond the outer edge")
		lines.append("BOSS REWARD: Frost Sigil + 300 coins + 350 XP")
		lines.append("FIRST KILL: Glacial Crown + 500 coins + 600 XP")
		lines.append("BOSS ATTACKS: Frost Nova / Ice Lance / Shatter Ring")
		lines.append("TELEGRAPH COLORS: NOVA CYAN / LANCE AMBER / SHATTER VIOLET")
		lines.append("ATTACK TELEGRAPH: colored danger zone pulses before impact")
		lines.append("")
		lines.append("STORY QUEST")
		lines.append(_quest_description())
		lines.append("CODEX DISCOVERIES")
		if codex_discoveries.is_empty():
			lines.append("No echoes recorded yet.")
		else:
			for discovery in codex_discoveries:
				lines.append("• " + discovery)
		inventory_label.text = "\n".join(lines)


func _craft_weapon() -> void:
	if weapon_level >= 5:
		status_label.text = "ASHEN BLADE IS ALREADY MAXED"
		return
	if int(inventory.get("Ancient Shard", 0)) < 3 or int(inventory.get("Ashen Pelt", 0)) < 2 or coins < 35:
		status_label.text = "BLADE RECIPE: 3 SHARDS + 2 PELTS + 35 COINS"
		return
	inventory["Ancient Shard"] = int(inventory["Ancient Shard"]) - 3
	inventory["Ashen Pelt"] = int(inventory["Ashen Pelt"]) - 2
	coins -= 35
	weapon_level += 1
	_refresh_equipment_visuals()
	status_label.text = "ASHEN BLADE FORGED  •  LEVEL %d  •  +%d ATTACK" % [weapon_level, weapon_level * 9]
	_refresh_progression_ui()
	_save_progress()

func _craft_armor() -> void:
	if armor_level >= 5:
		status_label.text = "RUIN ARMOR IS ALREADY MAXED"
		return
	if int(inventory.get("Ashen Pelt", 0)) < 3 or int(inventory.get("Ruin Core", 0)) < 2 or coins < 35:
		status_label.text = "ARMOR RECIPE: 3 PELTS + 2 CORES + 35 COINS"
		return
	inventory["Ashen Pelt"] = int(inventory["Ashen Pelt"]) - 3
	inventory["Ruin Core"] = int(inventory["Ruin Core"]) - 2
	coins -= 35
	armor_level += 1
	player_max_hp = 148 + armor_level * 18
	player_hp = mini(player_max_hp, player_hp + 18)
	_refresh_equipment_visuals()
	status_label.text = "RUIN ARMOR EQUIPPED  •  LEVEL %d  •  +%d MAX HP" % [armor_level, armor_level * 18]
	_refresh_progression_ui()
	_save_progress()

func _quest_description() -> String:
	match quest_stage:
		0:
			return "I. ASHEN THREAT  •  DEFEAT 3 FOES  (%d/3)" % mini(quest_stage_progress, 3)
		1:
			return "II. WOLF PELTS  •  COLLECT 3 PELTS  (%d/3)" % mini(quest_stage_progress, 3)
		2:
			return "III. RUIN HEARTS  •  COLLECT 2 CORES  (%d/2)" % mini(quest_stage_progress, 2)
		3:
			return "IV. WARDEN'S MARK  •  FIND 1 EMBLEM  (%d/1)" % mini(quest_stage_progress, 1)
		_:
			return "STORY QUEST COMPLETE  •  FROST SIGIL CLAIMED"

func _advance_quest(gained: Array[String]) -> void:
	if quest_completed:
		return
	if quest_stage == 0:
		quest_stage_progress += 1
		if quest_stage_progress >= 3:
			quest_stage = 1
			quest_stage_progress = 0
			status_label.text = "QUEST UPDATED  •  GATHER ASHEN PELTS"
	elif quest_stage == 1:
		if gained.has("Ashen Pelt"):
			quest_stage_progress += 1
			if quest_stage_progress >= 3:
				quest_stage = 2
				quest_stage_progress = 0
				status_label.text = "QUEST UPDATED  •  FIND RUIN CORES"
	elif quest_stage == 2:
		if gained.has("Ruin Core"):
			quest_stage_progress += 1
			if quest_stage_progress >= 2:
				quest_stage = 3
				quest_stage_progress = 0
				status_label.text = "QUEST UPDATED  •  HUNT RUIN STALKERS FOR A WARDEN EMBLEM"
	elif quest_stage == 3 and gained.has("Warden Emblem"):
		quest_stage = 4
		quest_stage_progress = 0
		quest_completed = true
		coins += 250
		inventory["Frost Sigil"] = int(inventory.get("Frost Sigil", 0)) + 1
		inventory["Echo Fragment"] = int(inventory.get("Echo Fragment", 0)) + 3
		_gain_xp(220)
		status_label.text = "QUEST COMPLETE  •  FROST SIGIL +220 XP +250 COINS +3 ECHOES"
	_refresh_progression_ui()

func _save_progress() -> void:
	var save := ConfigFile.new()
	save.set_value("player", "level", player_level)
	save.set_value("player", "xp", xp)
	save.set_value("player", "xp_to_next_level", xp_to_next_level)
	save.set_value("player", "coins", coins)
	save.set_value("inventory", "items", inventory)
	save.set_value("equipment", "weapon_level", weapon_level)
	save.set_value("equipment", "armor_level", armor_level)
	save.set_value("quest", "stage", quest_stage)
	save.set_value("quest", "progress", quest_stage_progress)
	save.set_value("quest", "completed", quest_completed)
	save.set_value("codex", "discoveries", codex_discoveries)
	save.set_value("boss", "first_kill_claimed", boss_first_kill_claimed)
	save.set_value("world", "wave_number", wave_number)
	save.save("user://eldervale_progress.cfg")

func _load_progress() -> void:
	var save := ConfigFile.new()
	if save.load("user://eldervale_progress.cfg") != OK:
		return
	player_level = int(save.get_value("player", "level", player_level))
	xp = int(save.get_value("player", "xp", xp))
	xp_to_next_level = int(save.get_value("player", "xp_to_next_level", xp_to_next_level))
	coins = int(save.get_value("player", "coins", coins))
	var saved_inventory: Variant = save.get_value("inventory", "items", inventory)
	if saved_inventory is Dictionary:
		for item_name in inventory.keys():
			inventory[item_name] = int(saved_inventory.get(item_name, inventory[item_name]))
	weapon_level = clampi(int(save.get_value("equipment", "weapon_level", weapon_level)), 0, 5)
	armor_level = clampi(int(save.get_value("equipment", "armor_level", armor_level)), 0, 5)
	quest_stage = clampi(int(save.get_value("quest", "stage", quest_stage)), 0, 4)
	quest_stage_progress = maxi(0, int(save.get_value("quest", "progress", quest_stage_progress)))
	quest_completed = bool(save.get_value("quest", "completed", quest_completed))
	wave_number = maxi(0, int(save.get_value("world", "wave_number", wave_number)))
	boss_first_kill_claimed = bool(save.get_value("boss", "first_kill_claimed", boss_first_kill_claimed))
	if quest_completed and quest_stage == 3:
		quest_stage = 4
	player_max_hp = 148 + armor_level * 18
	player_hp = mini(player_hp, player_max_hp)
	var saved_discoveries: Variant = save.get_value("codex", "discoveries", [])
	if saved_discoveries is Array:
		for discovery in saved_discoveries:
			if not codex_discoveries.has(str(discovery)):
				codex_discoveries.append(str(discovery))
