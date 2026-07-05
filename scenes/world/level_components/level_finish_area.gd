extends Area2D

@export var next_scene: PackedScene


func _on_body_entered(body: Node2D) -> void:
	if body is Player and next_scene:
		var new_scene = next_scene.instantiate()
		owner.get_parent().add_child(new_scene)
		get_tree().current_scene = new_scene
		owner.queue_free()
