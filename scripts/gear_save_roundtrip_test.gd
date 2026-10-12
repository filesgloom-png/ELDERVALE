extends SceneTree

var failed := false

func _initialize() -> void:
	call_deferred("_run_tests")

func _check(condition: bool, message: String) -> void:
	if condition:
		print("PASS: ", message)
	else:
		push_error("FAIL: " + message)
		failed = true

func _run_tests() -> void:
	var save_path := "user://eldervale_progress.cfg"
	var save := ConfigFile.new()
	var weapon := {"id": 41, "name": "Roundtrip Fang", "slot": "weapon", "rarity": "Epic", "source": "CI test", "attack": 7, "hp": 0, "mitigation": 0}
	var armor := {"id": 42, "name": "Roundtrip Aegis", "slot": "armor", "rarity": "Rare", "source": "CI test", "attack": 0, "hp": 20, "mitigation": 2}
	save.set_value("character", "name", "CI Gear Tester")
	save.set_value("character", "class", "Warden")
	save.set_value("player", "level", 5)
	save.set_value("player", "xp", 0)
	save.set_value("player", "xp_to_next_level", 100)
	save.set_value("player", "coins", 77)
	save.set_value("player", "hp", 120)
	save.set_value("attributes", "strength_rank", 2)
	save.set_value("attributes", "vitality_rank", 2)
	save.set_value("equipment", "weapon_level", 1)
	save.set_value("equipment", "armor_level", 1)
	save.set_value("equipment", "loot_gear", [weapon, armor])
	save.set_value("equipment", "equipped_loot_weapon_id", 41)
	save.set_value("equipment", "equipped_loot_armor_id", 42)
	save.set_value("equipment", "next_loot_gear_id", 43)
	var write_error := save.save(save_path)
	_check(write_error == OK, "write fixture save")
	if write_error != OK:
		quit(1)
		return
	var game_script: Script = load("res://scripts/main_3d.gd")
	var first = game_script.new()
	first.call("_load_progress")
	_check((first.get("loot_gear") as Array).size() == 2, "load both loot items")
	_check(int(first.get("equipped_loot_weapon_id")) == 41, "restore equipped weapon ID")
	_check(int(first.get("equipped_loot_armor_id")) == 42, "restore equipped armor ID")
	_check(int(first.call("_basic_attack_damage")) == 56, "apply weapon attack bonus to basic damage")
	_check(int(first.get("player_max_hp")) == 214, "apply armor HP bonus to max health")
	_check(int(first.call("_armor_mitigation")) == 5, "apply armor mitigation bonus")
	first.call("_save_progress")
	var second = game_script.new()
	second.call("_load_progress")
	var reloaded_items: Array = second.get("loot_gear")
	_check(reloaded_items.size() == 2, "round-trip preserves item collection")
	_check(int(second.get("equipped_loot_weapon_id")) == 41, "round-trip preserves weapon equip")
	_check(int(second.get("equipped_loot_armor_id")) == 42, "round-trip preserves armor equip")
	_check(int(second.call("_basic_attack_damage")) == 56, "round-trip preserves weapon bonus")
	_check(int(second.get("player_max_hp")) == 214, "round-trip preserves armor health bonus")
	_check(int(second.call("_armor_mitigation")) == 5, "round-trip preserves armor mitigation")
	_check(int(second.get("next_loot_gear_id")) == 43, "round-trip preserves next item ID")
	var legacy := ConfigFile.new()
	legacy.set_value("character", "name", "Legacy Save")
	legacy.set_value("character", "class", "Warden")
	legacy.set_value("equipment", "weapon_level", 1)
	legacy.set_value("equipment", "armor_level", 1)
	var legacy_error := legacy.save(save_path)
	_check(legacy_error == OK, "write legacy save fixture without loot fields")
	var old_game = game_script.new()
	old_game.call("_load_progress")
	_check((old_game.get("loot_gear") as Array).is_empty(), "legacy save without loot remains compatible")
	_check(int(old_game.get("equipped_loot_weapon_id")) == 0, "legacy save clears missing equipped weapon ID")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(save_path))
	if failed:
		push_error("Equipment save/load regression suite FAILED.")
		quit(1)
	else:
		print("Equipment save/load regression suite PASSED.")
		quit(0)
