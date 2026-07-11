extends Node2D

var final_level: bool = false

func start_playing():
	$AudioStreamPlayer.play()

func stop_playing():
	$AudioStreamPlayer.stop()

func next_level():
	$NextLevel.play()

func end():
	final_level = true
	$End.play()

func stop_end():
	final_level = false
	$End.stop()


func _on_end_finished() -> void:
	$End.play()


func play_wind(db: int):
	$Wind.volume_db = db
	$Wind.play()


func stop_wind():
	$Wind.stop()
