extends StaticBody2D
class_name Door

@export var width: int
@export var height: int
@export var disabled: bool = true

func _ready() -> void:
	$CollisionShape2D.set_deferred("disabled",disabled)

func _process(delta: float) -> void:
	
	if $CollisionShape2D.disabled:
		$ColorRect.modulate = Color(0.0, 0.0, 0.0, 0.529)
	else:
		$ColorRect.modulate = Color(1.0, 1.0, 1.0, 1.0)
	
	$CollisionShape2D.shape.size = Vector2(width * 16,height * 16)
	$CollisionShape2D.position = Vector2((width * 16) / 2, (height * 16) / 2)
	$ColorRect.size = Vector2(width * 16,height * 16)


func disable():
	if $CollisionShape2D.disabled:
		disabled = false
		$CollisionShape2D.set_deferred("disabled",false)
		$ColorRect.modulate = Color(0.0, 0.0, 0.0, 0.529)
	else:
		disabled = true
		$CollisionShape2D.set_deferred("disabled",true)
		$ColorRect.modulate = Color(1.0, 1.0, 1.0, 1.0)
		$Open.play()
		
	
