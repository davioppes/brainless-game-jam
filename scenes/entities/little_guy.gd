extends RigidBody2D
class_name little_guy

@export var player: Player
enum State {FOLLOW, FLYING, DROPPED}

var state: State = State.DROPPED


func _physics_process(delta: float) -> void:
	match state:
		State.FOLLOW:
			freeze = true
			freeze_mode = RigidBody2D.FREEZE_MODE_STATIC
			global_position = player.global_position - Vector2(0,100)
		State.DROPPED:
			freeze = false


func follow_player():
	state = State.FOLLOW

func drop():
	state = State.DROPPED
