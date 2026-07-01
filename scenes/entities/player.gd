extends CharacterBody2D
class_name Player


var pickup_object: bool = false
var seedling

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

func _process(delta: float) -> void:
	
	if Input.is_action_just_pressed("pickup") and not pickup_object:
		pickup()
	
	if Input.is_action_just_pressed("drop") and pickup_object:
		drop()


func _physics_process(delta: float) -> void:
	var direction = 0
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	if Input.is_action_pressed("move_left"):
		direction = -1
	if Input.is_action_pressed("move_right"):
		direction = 1

	velocity.x = direction * SPEED

	move_and_slide()


func pickup():
	seedling.follow_player()
	pickup_object = true


func drop():
	seedling.drop()
	pickup_object = false
	seedling = null



func _on_pickup_area_body_entered(body: Node2D) -> void:
	if body is little_guy:
		seedling = body


func _on_pickup_area_body_exited(body: Node2D) -> void:
	pass
