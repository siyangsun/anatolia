extends Control

signal creation_complete(stats: CharacterStats, weapon_id: String)

@onready var text_label: RichTextLabel = $VBoxContainer/RichTextLabel
@onready var choices_container: VBoxContainer = $VBoxContainer/ChoicesContainer

var log: TextLog
var text_data: TextData
var creation_data: Dictionary

var current_question_index: int = 0
var stat_points: Dictionary
var chosen_weapon: String = "bronze_dagger"


func _ready():
	log = TextLog.new(text_label)
	text_data = TextData.new()
	creation_data = text_data.load_text("character_creation")

	stat_points = {}
	for stat in CharacterStats.STAT_NAMES:
		stat_points[stat] = 8

	_log_debug("Initial stats: %s" % _format_stat_points())
	show_intro()


func _format_stat_points() -> String:
	var parts: Array = []
	for stat in CharacterStats.STAT_NAMES:
		parts.append("%s=%d" % [stat, stat_points[stat]])
	return ", ".join(parts)


func _format_changes(effects: Dictionary) -> String:
	var parts: Array = []
	for stat in CharacterStats.STAT_NAMES:
		if effects.has(stat):
			var value = effects[stat]
			var sign = "+" if value > 0 else ""
			parts.append("%s %s%d" % [stat.to_upper(), sign, value])
	return ", ".join(parts)


func _log_debug(msg: String):
	print("[CHARACTER CREATION] %s" % msg)


func show_intro():
	log.clear()
	var intro = creation_data["intro"]
	log.log_paragraph(intro["text"])
	_add_choice_button(intro["prompt"], _on_intro_complete)


func _on_intro_complete():
	current_question_index = 0
	show_question()


func show_question():
	_clear_choices()
	log.clear()

	var questions = creation_data["questions"]
	if current_question_index >= questions.size():
		show_results()
		return

	var q = questions[current_question_index]
	log.log_paragraph(q["text"])

	_log_debug("Question %d/%d" % [current_question_index + 1, questions.size()])

	for i in range(q["choices"].size()):
		var choice = q["choices"][i]
		_add_choice_button(choice["text"], _on_choice_selected.bind(i))


func _on_choice_selected(choice_index: int):
	var q = creation_data["questions"][current_question_index]
	var choice = q["choices"][choice_index]

	_log_debug("Selected: \"%s\"" % choice["text"].substr(0, 40))
	_log_debug("Applied: %s" % _format_changes(choice["effects"]))

	for stat in choice["effects"]:
		stat_points[stat] += choice["effects"][stat]

	_log_debug("After Q%d: %s" % [current_question_index + 1, _format_stat_points()])

	if choice.has("weapon"):
		chosen_weapon = choice["weapon"]
		_log_debug("Weapon selected: %s" % chosen_weapon)

	current_question_index += 1
	show_question()


func show_results():
	_clear_choices()
	log.clear()

	var results = creation_data["results"]

	log.log_paragraph(results["pre_stats"])

	log.log_separator("-")
	log.log_line("")

	for stat in CharacterStats.STAT_NAMES:
		log.log_line("%s %d" % [stat.to_upper().rpad(10), stat_points[stat]])

	log.log_line("")
	log.log_line("Sanguis: %d" % (stat_points["fortitudo"] * 10))
	log.log_separator("-")
	log.log_line("")

	log.log_paragraph(results["post_stats"])

	var weapon_name = _get_weapon_name()
	var prompt = TextData.format(results["prompt_template"], {"weapon": weapon_name})
	_add_choice_button(prompt, _on_creation_complete)

	_log_debug("Final: %s" % _format_stat_points())
	_log_debug("Weapon: %s" % weapon_name)


func _get_weapon_name() -> String:
	var data = GameData.new()
	return data.weapons[chosen_weapon]["name"]


func _on_creation_complete():
	var stats = CharacterStats.new(
		stat_points["sinew"],
		stat_points["alacrity"],
		stat_points["virtus"],
		stat_points["fortitudo"]
	)
	creation_complete.emit(stats, chosen_weapon)


func _add_choice_button(text: String, callback: Callable):
	var button = Button.new()
	button.text = text
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	button.pressed.connect(func():
		callback.call()
	)
	choices_container.add_child(button)


func _clear_choices():
	for child in choices_container.get_children():
		child.queue_free()
