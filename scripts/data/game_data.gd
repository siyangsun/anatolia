class_name GameData
extends RefCounted

var alloys: Dictionary      # String -> Dictionary (raw JSON)
var weapon_classes: Dictionary  # String -> Dictionary (raw JSON)
var weapons: Dictionary
var enemies: Dictionary

# Cached instances
var _alloy_cache: Dictionary = {}  # String -> Alloy
var _weapon_class_cache: Dictionary = {}  # String -> WeaponClass


func _init():
	load_all()


func load_all():
	alloys = load_json("res://assets/data/alloys.json")
	weapon_classes = load_json("res://assets/data/weapon_classes.json")
	weapons = load_json("res://assets/data/weapons.json")
	enemies = load_json("res://assets/data/enemies.json")


func load_json(path: String) -> Dictionary:
	var file = FileAccess.open(path, FileAccess.READ)
	var content = file.get_as_text()
	file.close()
	return JSON.parse_string(content)


func get_alloy(alloy_id: String) -> Alloy:
	assert(alloys.has(alloy_id), "Unknown alloy: %s" % alloy_id)
	if not _alloy_cache.has(alloy_id):
		_alloy_cache[alloy_id] = Alloy.new(alloy_id, alloys[alloy_id])
	return _alloy_cache[alloy_id]


func get_weapon_class(class_id: String) -> WeaponClass:
	assert(weapon_classes.has(class_id), "Unknown weapon class: %s" % class_id)
	if not _weapon_class_cache.has(class_id):
		_weapon_class_cache[class_id] = WeaponClass.new(class_id, weapon_classes[class_id])
	return _weapon_class_cache[class_id]


func create_enemy(enemy_id: String) -> Combatant:
	assert(enemies.has(enemy_id), "Unknown enemy: %s" % enemy_id)
	var data = enemies[enemy_id]
	var stats = CharacterStats.from_dict(data["stats"])
	var weapon = Weapon.new(data["weapon"], self)
	return Combatant.new(data["name"], stats, weapon)
