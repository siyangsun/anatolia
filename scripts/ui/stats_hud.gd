class_name StatsHUD
extends CanvasLayer

@onready var char_button: Button = $HBoxContainer/CharButton
@onready var equip_button: Button = $HBoxContainer/EquipButton
@onready var char_panel: InspectPanel = $CharPanel
@onready var equip_panel: InspectPanel = $EquipPanel

var combatant: Combatant
var audio_manager: Node


func _ready():
	audio_manager = get_node("/root/AudioManager")

	char_button.pressed.connect(char_panel.toggle)
	equip_button.pressed.connect(equip_panel.toggle)

	char_panel.opened.connect(audio_manager.on_panel_opened)
	char_panel.closed.connect(audio_manager.on_panel_closed)
	equip_panel.opened.connect(audio_manager.on_panel_opened)
	equip_panel.closed.connect(audio_manager.on_panel_closed)


func set_combatant(c: Combatant):
	combatant = c
	refresh()


func refresh():
	if combatant == null:
		return

	var s = combatant.stats
	var char_text = "[b]%s[/b]\n\n[color=gray]Sanguis[/color]\n%.0f / %.0f\n\n[color=gray]Attributes[/color]\n%s" % [
		combatant.name,
		combatant.sanguis, combatant.max_sanguis,
		s.format_stats_vertical()
	]
	char_panel.set_content(char_text)

	var w = combatant.weapon
	var ws = w.get_stats()
	equip_panel.set_content("""[b]%s[/b]
[color=gray]%s %s[/color]

Heft       %.1f kg
Severity   %.1f
Durity     %.1f
Balance    %.1f

Reach      %d paces""" % [
		w.name,
		w.alloy.name, w.weapon_class.name,
		ws["heft"], ws["severity"], ws["durity"], ws["counterbalance"],
		w.reach,
	])
