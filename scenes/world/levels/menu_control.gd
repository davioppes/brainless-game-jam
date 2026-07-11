extends Control

#@export var next_scene: PackedScene
@export var next_level_path: String


func _on_button_pressed() -> void:
	BackgroundMusic.start_playing()
	get_tree().change_scene_to_file(next_level_path)
	#var new_scene = next_scene.instantiate()
	#owner.get_parent().add_child(new_scene)
	#get_tree().current_scene = new_scene
	#owner.queue_free()


func _on_exit_button_pressed() -> void:
	get_tree().quit()
