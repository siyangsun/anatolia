extends Control

const STATS_HUD_SCENE = preload("res://scenes/ui/stats_hud.tscn")
const TICK_DELAY = 0.1

@onready var output_label: RichTextLabel = $VBoxContainer/RichTextLabel
@onready var next_button: Button = $VBoxContainer/NextButton

signal _moveset_chosen(moveset)

var player_stats: CharacterStats
var player_weapon_id: String

var data: GameData
var text_data: TextData
var gauntlet_text: Dictionary
var log: TextLog
var player: Combatant
var enemy_ids: Array = []
var current_enemy_index: int = 0
var stats_hud: StatsHUD
var combat_in_progress: bool = false


func _ready():
	data = GameData.new()
	text_data = TextData.new()
	gauntlet_text = text_data.load_text("gauntlet")
	log = TextLog.new(output_label)

	enemy_ids = data.enemies.keys()

	if player_stats == null:
		player_stats = CharacterStats.new(12, 11, 10, 10)
	if player_weapon_id == null or player_weapon_id.is_empty():
		player_weapon_id = "wootz_steel_blade"

	var player_weapon = Weapon.new(player_weapon_id, data)
	player = Combatant.new("Player", player_stats, player_weapon)

	stats_hud = STATS_HUD_SCENE.instantiate()
	add_child(stats_hud)
	stats_hud.set_combatant(player)

	next_button.pressed.connect(_on_next_pressed)

	show_player_info()
	start_fight()


func show_player_info():
	log.log_header(gauntlet_text["header"])
	log.log_line("")
	log.log_paragraph(gauntlet_text["intro"])

	log.log_subheader(gauntlet_text["player_header"])
	log.log_line("Weapon: %s" % player.weapon.name)
	log.log_line("Sanguis: %d" % player.max_sanguis)
	log.log_line("")


func start_fight():
	if current_enemy_index >= enemy_ids.size():
		show_victory()
		return

	player.sanguis = player.max_sanguis
	stats_hud.refresh()

	var enemy_id = enemy_ids[current_enemy_index]
	var enemy = data.create_enemy(enemy_id)

	var encounter_header = TextData.format(gauntlet_text["encounter_header_template"], {
		"current": current_enemy_index + 1,
		"total": enemy_ids.size(),
		"enemy_name": enemy.name.to_upper()
	})
	log.log_header(encounter_header)
	log.log_line("Weapon: %s" % enemy.weapon.name)
	log.log_line("Sanguis: %d" % enemy.max_sanguis)
	log.log_line("")

	log.log_line("=== COMBAT JOINED ===")
	log.log_line("%s (%d sanguis) vs %s (%d sanguis)" % [
		player.name, player.sanguis, enemy.name, enemy.sanguis
	])
	log.log_line("")

	next_button.disabled = true
	combat_in_progress = true

	await run_combat(player, enemy)

	combat_in_progress = false
	stats_hud.refresh()


func run_combat(attacker: Combatant, defender: Combatant):
	var combat = CombatCalc.create_combat(attacker, defender)

	while not combat["finished"]:
		var chosen = await _choose_moveset(attacker.weapon.get_movesets())
		combat["attacker_moveset"] = chosen
		combat["attacker_combo_tick"] = 0

		for _i in range(chosen.pattern.size()):
			if combat["finished"]:
				break
			var events = CombatCalc.process_tick(combat)
			var had_event = false
			for event in events:
				if event["type"] == "attack":
					var hit_desc = DamageText.describe_hit(
						event["attacker"],
						event["attack"].name,
						event["attack"].damage_type,
						event["damage"],
						event["defender"],
						event["target_max_sanguis"],
						event["target_sanguis"]
					)
					log.log_line(hit_desc["ui"], TextLog.Channel.UI)
					log.log_line(hit_desc["debug"], TextLog.Channel.DEBUG)
					stats_hud.refresh()
					had_event = true
				elif event["type"] == "death":
					log.log_line(DamageText.describe_death(event["name"], event["damage_type"]))
			if had_event:
				await get_tree().create_timer(TICK_DELAY).timeout

	log.log_line("")

	var combat_text = gauntlet_text["combat"]
	var buttons = gauntlet_text["buttons"]

	if combat["winner"] == player.name:
		log.log_line("=== %s IS VICTORIOUS ===" % player.name.to_upper())
		log.log_line("")
		log.log_line(combat_text["victory"])
		next_button.text = buttons["next_enemy"]
		next_button.disabled = false
	else:
		log.log_line("=== %s IS VICTORIOUS ===" % defender.name.to_upper())
		log.log_line("")
		log.log_line(combat_text["defeat"])
		next_button.text = buttons["game_over"]
		next_button.disabled = true


func _choose_moveset(movesets: Array) -> WeaponClass.Moveset:
	log.log_line("[color=yellow]Choose your attack:[/color]")

	var buttons: Array = []
	for ms in movesets:
		var btn = Button.new()
		btn.text = ms.name
		$VBoxContainer.add_child(btn)
		$VBoxContainer.move_child(btn, next_button.get_index())
		btn.pressed.connect(func(): _moveset_chosen.emit(ms))
		buttons.append(btn)

	var chosen = await _moveset_chosen

	for btn in buttons:
		btn.queue_free()

	log.log_line("[color=gray]→ %s[/color]\n" % chosen.name)
	return chosen


func show_victory():
	var victory = gauntlet_text["final_victory"]
	var buttons = gauntlet_text["buttons"]

	log.log_header(victory["header"])
	log.log_line("")
	log.log_paragraph(victory["text"])

	next_button.text = buttons["complete"]
	next_button.disabled = true


func _on_next_pressed():
	if combat_in_progress:
		return

	current_enemy_index += 1
	log.log_line("")
	log.log_line("")
	start_fight()
