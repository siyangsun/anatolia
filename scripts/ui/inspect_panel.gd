class_name InspectPanel
extends Panel

signal opened
signal closed

@onready var content_label: RichTextLabel = $VBoxContainer/RichTextLabel
@onready var close_button: Button = $VBoxContainer/CloseButton

var panel_id: String = ""


func _ready():
	close_button.pressed.connect(hide_panel)
	visible = false


func show_panel():
	visible = true
	opened.emit()


func hide_panel():
	visible = false
	closed.emit()


func toggle():
	if visible:
		hide_panel()
	else:
		show_panel()


func set_content(text: String):
	content_label.text = text
