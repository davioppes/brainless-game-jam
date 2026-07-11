extends Node2D

@export var next_scene_path: String


func _on_button_pressed() -> void:
	BackgroundMusic.stop_end()
	get_tree().change_scene_to_file(next_scene_path)
	#var new_scene = next_scene.instantiate()
	#print(get_parent())
	#owner.get_parent().add_child(new_scene)
	#get_tree().current_scene = new_scene
	#owner.queue_free()
