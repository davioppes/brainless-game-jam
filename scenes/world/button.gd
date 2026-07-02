extends StaticBody2D

var is_pressed: bool = false
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D


func _on_area_2d_body_entered(body: Node2D) -> void:
	if not is_pressed:
		is_pressed = true
		collision_shape_2d.scale.y = collision_shape_2d.scale.y * 0.5
		print("pressed")


func _on_area_2d_body_exited(body: Node2D) -> void:
	if is_pressed:
		collision_shape_2d.scale.y = 1
		print("release")
		is_pressed = false
