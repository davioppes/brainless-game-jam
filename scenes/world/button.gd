extends Area2D
class_name LevelButton

signal disable_door

@export var connecting_door: Door


func _ready() -> void:
	disable_door.connect(connecting_door.disable)


func _on_body_entered(_body: Node2D) -> void:
	disable_door.emit()
	$AnimationPlayer.play("press")


func _on_body_exited(_body: Node2D) -> void:
	$AnimationPlayer.play("release")
