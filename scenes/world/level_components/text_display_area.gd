extends Area2D

@export var label_to_display: Label

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		label_to_display.show()


func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		label_to_display.hide()
