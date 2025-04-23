extends Control

var curent_song: int = 1
var song_repeated = 0

var audio_player : AudioStreamPlayer
var audio_playlist: AudioStreamPlaylist

var happy: AudioStreamWAV = preload("res://assets/audio/music/Тяжело_Пришествие_Христа(Happy).wav")
var discovery: AudioStreamWAV = preload("res://assets/audio/music/Discovery.wav")
var deep_diving: AudioStreamWAV = preload("res://assets/audio/music/DeepDiving.wav")
var exploration: AudioStreamWAV = preload("res://assets/audio/music/Exploration.wav")
var upgrade: AudioStreamWAV = preload("res://assets/audio/music/Upgrade.wav")

func _ready() -> void:
	audio_playlist = AudioStreamPlaylist.new()
	
	audio_playlist.set_list_stream(1, happy)
	audio_playlist.set_list_stream(2, discovery)
	audio_playlist.set_list_stream(3, deep_diving)
	audio_playlist.set_list_stream(4, exploration)
	audio_playlist.set_list_stream(5, upgrade)
	
	audio_player = AudioStreamPlayer.new()
	self.add_child(audio_player)
	
	audio_player.set_stream(audio_playlist.get_list_stream(curent_song))
	audio_player.play()
	
	audio_player.finished.connect(_on_finished)

func _on_finished():
	if(song_repeated == 4):
		if(curent_song == 5):
			curent_song = 1
			audio_player.set_stream(audio_playlist.get_list_stream(curent_song))
			audio_player.play()
		else:
			curent_song += 1
			audio_player.set_stream(audio_playlist.get_list_stream(curent_song))
			audio_player.play()
	else:
		song_repeated += 1
		audio_player.play()
