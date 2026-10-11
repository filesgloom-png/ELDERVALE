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
var enemies: Array[Node3D] = []
var hp_bar: ProgressBar
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

func _build_enemies() -> void:
	var positions := [Vector3(4, 0, -4), Vector3(-5, 0, -10), Vector3(8, 0, -17), Vector3(-9, 0, -20)]
	for i in range(positions.size()):
		var enemy := Node3D.new()
		enemy.name = "AshWolf" if i < 3 else "RuinStalker"
		enemy.position = positions[i]
		add_child(enemy)
		var hide_mat := _mat(Color("#8b6553") if i < 3 else Color("#565c67"), 0.8)
		var fur := _mesh_node(enemy, CapsuleMesh.new(), hide_mat, Vector3(0, 0.72, 0), "EnemyBody")
		fur.scale = Vector3(0.72, 0.58, 0.55)
		var head := _mesh_node(enemy, SphereMesh.new(), hide_mat, Vector3(0, 1.25, -0.3), "EnemyHead")
		head.scale = Vector3(0.48, 0.42, 0.52)
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
		var eye_mat := _mat(Color("#ffbd76"), 0.3, 0.0)
		for side in [-1.0, 1.0]:
			var eye := _mesh_node(enemy, SphereMesh.new(), eye_mat, Vector3(side * 0.17, 1.31, -0.73), "Eye")
			eye.scale = Vector3(0.075, 0.07, 0.05)
		enemies.append(enemy)
		enemy_health[enemy] = 75 if i < 3 else 110
		enemy_hit_timers[enemy] = 0.0
		enemy_base_colors[enemy] = hide_mat.albedo_color

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
	var stats := Label.new()
	stats.text = "HP 148/148    XP 178/190    COINS 164"
	stats.add_theme_font_size_override("font_size", 12)
	stats.add_theme_color_override("font_color", Color("#e0d0ad"))
	stack.add_child(stats)
	status_label = Label.new()
	status_label.position = Vector2(410, 20)
	status_label.size = Vector2(460, 36)
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status_label.add_theme_font_size_override("font_size", 18)
	status_label.add_theme_color_override("font_color", Color("#e7d5ac"))
	layer.add_child(status_label)
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
	for i in range(magical_materials.size()):
		var pulse := 0.88 + 0.22 * sin(animation_time * 1.35 + float(i) * 0.7)
		magical_materials[i].emission_energy_multiplier = pulse * (1.25 if i < 3 else 0.8)
	_update_combat_effects(delta)
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
		enemy.rotation.z = lerpf(enemy.rotation.z, 0.0, minf(1.0, delta * 12.0))
		if hit_left <= 0.0 and enemy.has_node("EnemyBody"):
			var enemy_body := enemy.get_node("EnemyBody") as MeshInstance3D
			var enemy_material := enemy_body.material_override as StandardMaterial3D
			if enemy_material != null and enemy_base_colors.has(enemy):
				enemy_material.albedo_color = enemy_base_colors[enemy]
		if hit_left > 0.0: continue
		var d := enemy.position.distance_to(player.position)
		if d < 11.0 and d > 2.6:
			var toward := (player.position - enemy.position).normalized()
			enemy.position += Vector3(toward.x, 0, toward.z) * (0.55 if i < 3 else 0.35) * delta
			enemy.rotation.y = atan2(-toward.x, -toward.z)
	if hp_bar != null:
		hp_bar.value = player_hp
	if status_label != null:
		status_label.text = ("ATTACK READY" if attack_cooldown <= 0 else "ATTACK  %.1fs" % attack_cooldown) + "     •     " + ("SKILL READY" if skill_cooldown <= 0 else "SKILL  %.1fs" % skill_cooldown)

func _spawn_combat_effect(kind: String) -> void:
	if player == null:
		return
	# Short-lived emissive meshes only: no particles and no extra dynamic lights.
	var effect_root := Node3D.new()
	effect_root.name = "CombatFX_" + kind
	effect_root.position = player.position + Vector3(0.0, 0.04, 0.0)
	effect_root.rotation.y = player.rotation.y
	add_child(effect_root)
	var tint := Color("#c8f5ff") if kind == "slash" else (Color("#70e7ff") if kind == "cleave" else Color("#ffd58a"))
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
	else:
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
	combat_effects.append({"root": effect_root, "age": 0.0, "duration": 0.34 if kind == "slash" else (0.48 if kind == "cleave" else 0.72), "kind": kind})

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
		_damage_enemy(target, 34)
		status_label.text = "SWORD STRIKE  •  34 DAMAGE"
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
		_damage_enemy(target, 58)
		status_label.text = "WARDEN CLEAVE  •  58 DAMAGE"
	else:
		status_label.text = "WARDEN CLEAVE  •  NO TARGET"
	attack_flash = 0.32
	attack_anim_time = ATTACK_ANIM_DURATION

func _damage_enemy(enemy: Node3D, damage: int) -> void:
	if not is_instance_valid(enemy): return
	var remaining_hp: int = int(enemy_health.get(enemy, 75)) - damage
	enemy_health[enemy] = remaining_hp
	# Brief hit-stop-like feedback: a red flash, recoil, and a short interruption of pursuit.
	var body := enemy.get_node_or_null("EnemyBody") as MeshInstance3D
	if body != null:
		var flash_material := body.material_override as StandardMaterial3D
		if flash_material != null:
			flash_material.albedo_color = Color("#e5a08c")
	enemy_hit_timers[enemy] = ENEMY_HIT_REACTION_DURATION
	var recoil := enemy.global_position - player.global_position
	recoil.y = 0.0
	if recoil.length_squared() > 0.001:
		enemy.position += recoil.normalized() * 0.48
	enemy.rotation.z = -0.2 if enemy.position.x < player.position.x else 0.2
	if remaining_hp > 0:
		status_label.text = "HIT  •  %d DAMAGE  •  %d HP LEFT" % [damage, remaining_hp]
		return
	kills += 1
	xp += 12
	coins += 5
	enemies.erase(enemy)
	enemy_health.erase(enemy)
	enemy_hit_timers.erase(enemy)
	enemy_base_colors.erase(enemy)
	var burst := OmniLight3D.new()
	burst.light_color = Color("#ffbf72")
	burst.light_energy = 2.5
	burst.omni_range = 4.5
	burst.position = enemy.position + Vector3(0, 1.0, 0)
	add_child(burst)
	var timer := get_tree().create_timer(0.16)
	timer.timeout.connect(func():
		if is_instance_valid(burst): burst.queue_free()
	)
	enemy.queue_free()
	if target_label != null:
		target_label.text = "KILLS %d  •  XP %d  •  COINS %d" % [kills, xp, coins]

func _dodge() -> void:
	var direction := Vector3(move_input.x, 0, move_input.y)
	if direction.length_squared() < 0.01:
		direction = -player.global_transform.basis.z
	player.position += direction.normalized() * 3.0
	player.position.x = clampf(player.position.x, -WORLD_LIMIT, WORLD_LIMIT)
	player.position.z = clampf(player.position.z, -WORLD_LIMIT, WORLD_LIMIT)
	status_label.text = "EVASIVE STEP"

func _ultimate() -> void:
	_spawn_combat_effect("oath")
	var target := _nearest_enemy()
	if target != null:
		_damage_enemy(target, 90)
		status_label.text = "ANCIENT OATH  •  90 DAMAGE"
	else:
		status_label.text = "ANCIENT OATH  •  NO TARGET"
	attack_flash = 0.4
	attack_anim_time = ATTACK_ANIM_DURATION
