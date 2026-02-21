class_name TextLog
extends RefCounted

enum Channel {
	UI,
	DEBUG,
	ALL,
}

var _lines: Array[String] = []
var _output_label: RichTextLabel = null


func _init(output_label: RichTextLabel = null):
	_output_label = output_label
	if _output_label:
		_output_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART


func set_output(output_label: RichTextLabel):
	_output_label = output_label
	if _output_label:
		_output_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART


func log_line(text: String = "", channel: Channel = Channel.ALL):
	if channel == Channel.ALL or channel == Channel.DEBUG:
		print(text)

	if channel == Channel.ALL or channel == Channel.UI:
		_lines.append(text)
		_update_display()


func log_paragraph(text: String, channel: Channel = Channel.ALL):
	# Logs text that will be word-wrapped, adds blank line after
	log_line(text, channel)
	log_line("", channel)


func log_debug(text: String):
	log_line(text, Channel.DEBUG)


func log_ui(text: String):
	log_line(text, Channel.UI)


func log_lines(lines: Array, channel: Channel = Channel.ALL):
	for line in lines:
		log_line(line, channel)


func log_text(text_array: Array, channel: Channel = Channel.ALL):
	# Joins array into paragraph, for text that should wrap together
	var joined = " ".join(text_array)
	log_paragraph(joined, channel)


func log_separator(char: String = "=", length: int = 50, channel: Channel = Channel.ALL):
	log_line(char.repeat(length), channel)


func log_header(text: String, channel: Channel = Channel.ALL):
	log_separator("=", 50, channel)
	log_line(text, channel)
	log_separator("=", 50, channel)


func log_subheader(text: String, channel: Channel = Channel.ALL):
	log_separator("-", 50, channel)
	log_line(text, channel)
	log_separator("-", 50, channel)


func clear():
	_lines.clear()
	_update_display()


func get_text() -> String:
	return "\n".join(_lines)


func _update_display():
	if _output_label:
		_output_label.text = "\n".join(_lines)
