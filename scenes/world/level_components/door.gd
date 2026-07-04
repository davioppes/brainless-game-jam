@tool
extends StaticBody2D
class_name Door

@export var height: int
@export var width: int

func _process(delta: float) -> void:
	$CollisionShape2D.shape.size = Vector2(height * 16,width * 16)
	$CollisionShape2D.position = Vector2((height * 16) / 2, (width * 16) / 2)
	$ColorRect.size = Vector2(height * 16,width * 16)


func disable():
	$CollisionShape2D.set_deferred("disabled",true)
	$ColorRect.modulate = Color(0.0, 0.0, 0.0, 0.529)
