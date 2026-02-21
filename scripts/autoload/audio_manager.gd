extends Node

const MUSIC_LOBBY = "res://assets/audio/music/anatolia lobby music.mp3"
const MUSIC_MENU = "res://assets/audio/music/menu open.mp3"

var music_player: AudioStreamPlayer
var current_track: String = ""
var panels_open: int = 0


func _ready():
	music_player = AudioStreamPlayer.new()
	music_player.bus = "Master"
	add_child(music_player)

	play_music(MUSIC_LOBBY)


func play_music(path: String, volume_db: float = -10.0):
	if current_track == path and music_player.playing:
		return

	var stream = load(path)
	if stream:
		current_track = path
		music_player.stream = stream
		music_player.volume_db = volume_db
		music_player.play()

		if not music_player.finished.is_connected(_on_music_finished):
			music_player.finished.connect(_on_music_finished)


func _on_music_finished():
	music_player.play()


func stop_music():
	music_player.stop()
	current_track = ""


func set_music_volume(volume_db: float):
	music_player.volume_db = volume_db


func on_panel_opened():
	panels_open += 1
	if panels_open == 1:
		play_music(MUSIC_MENU)


func on_panel_closed():
	panels_open = max(0, panels_open - 1)
	if panels_open == 0:
		play_music(MUSIC_LOBBY)
