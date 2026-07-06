extends Area2D

@onready var interact_label: Label = %InteractLabel

@export var scene: PackedScene
var can_interact: bool = false

func _process(delta: float) -> void:
	if can_interact and Input.is_action_pressed("pickup"):
		display_scene()


func interact():
	interact_label.show()
	can_interact = true

func hide_text():
	interact_label.hide()
	can_interact = false

func display_scene():
	get_tree().change_scene_to_packed(scene)
