extends Control

@onready var output_label: RichTextLabel = $RichTextLabel

var data: GameData
var output_text: String = ""


func _ready():
	data = GameData.new()

	# Create player character
	var player_stats = CharacterStats.new(12, 11, 10, 10)
	var player_weapon = Weapon.new("wootz_steel_blade", data)
	var player = Combatant.new("Player", player_stats, player_weapon)

	log_line("=== PLAYER ===")
	log_line("Weapon: %s" % player_weapon.name)
	log_line("Stats: sinew=%s, alacrity=%s, virtus=%s, fortitudo=%s" % [
		player_stats.sinew, player_stats.alacrity, player_stats.virtus, player_stats.fortitudo
	])
	var pstats = player_weapon.get_stats()
	log_line("Weapon stats: heft=%s, sev=%s, dur=%s, cb=%s" % [
		pstats["heft"], pstats["severity"], pstats["durity"], pstats["counterbalance"]
	])

	log_line("\n")

	# Fight each enemy
	for enemy_id in data.enemies:
		# Reset player HP for each fight
		player.blood = player.max_blood

		var enemy = data.create_enemy(enemy_id)
		log_line("--- VS %s ---" % enemy.name)
		log_line("Enemy weapon: %s" % enemy.weapon.name)
		log_line("Enemy stats: sinew=%s, alacrity=%s, virtus=%s, fortitudo=%s" % [
			enemy.stats.sinew, enemy.stats.alacrity, enemy.stats.virtus, enemy.stats.fortitudo
		])
		log_line("")

		var result = CombatCalc.simulate_combat(player, enemy)

		for line in result["log"]:
			log_line(line)

		log_line("\n")

	output_label.text = output_text


func log_line(text: String = ""):
	output_text += text + "\n"
	print(text)
