extends Node

const CHARACTER_CREATION_SCENE = preload("res://scenes/game/character_creation.tscn")
const GAUNTLET_SCENE = preload("res://scenes/game/gauntlet.tscn")

var player_stats: CharacterStats
var player_weapon_id: String


func _ready():
	start_new_game()


func start_new_game():
	var creation = CHARACTER_CREATION_SCENE.instantiate()
	add_child(creation)
	creation.creation_complete.connect(_on_creation_complete.bind(creation))


func _on_creation_complete(stats: CharacterStats, weapon_id: String, creation_scene: Node):
	player_stats = stats
	player_weapon_id = weapon_id

	creation_scene.queue_free()
	start_gauntlet()


func start_gauntlet():
	var gauntlet = GAUNTLET_SCENE.instantiate()
	gauntlet.player_stats = player_stats
	gauntlet.player_weapon_id = player_weapon_id
	add_child(gauntlet)
