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
