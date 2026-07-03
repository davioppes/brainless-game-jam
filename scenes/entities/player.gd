extends CharacterBody2D
class_name Player

@onready var pickup_area: Area2D = %PickupArea
@onready var player_collision_shape: CollisionShape2D = %PlayerCollisionShape
@onready var pickup_position: Marker2D = %PickupPosition
@onready var arrow_pointing: Sprite2D = %ArrowPointing

var player_height: int
var current_facing_direction: int

var pickup_object: bool = true # Able to pickup object or not
var currently_picked_up: bool = false # If object is currently picked up
var seedling: Node2D = null # Current object that is picked up
var picked_up_seedling: little_guy = null

var wind_velocity: Vector2 = Vector2.ZERO
const SPEED = 100.0
const JUMP_VELOCITY = -300.0

func _ready() -> void:
	player_height = player_collision_shape.shape.size.y
	print(player_height)
	pickup_area.facing_right = pickup_area.position
	pickup_area.facing_left = Vector2(-pickup_area.position.x,pickup_area.position.y)


func _process(delta: float) -> void:
	arrow_pointing.look_at(get_global_mouse_position())
	
	if Input.is_action_just_pressed("reset_level"):
		get_tree().change_scene_to_file("res://scenes/world/test_world.tscn")


func _physics_process(delta: float) -> void:
	
	
	
	if Input.is_action_just_pressed("pickup"):
		if pickup_object and not currently_picked_up and seedling != null:
			pickup()
		elif not pickup_object and currently_picked_up:
			drop()

	if Input.is_action_just_pressed("throw") and currently_picked_up:
		throw()
		
	if Input.is_action_just_pressed("change_action") and currently_picked_up:
		change_action()
	
	var direction = 0
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	if Input.is_action_pressed("move_left"):
		direction = -1
		current_facing_direction = direction
		pickup_area.position = pickup_area.facing_left
	if Input.is_action_pressed("move_right"):
		direction = 1
		current_facing_direction = direction
		pickup_area.position = pickup_area.facing_right

	velocity.x = direction * SPEED
	velocity += wind_velocity

	move_and_slide()


func throw():
	picked_up_seedling.throw()
	currently_picked_up = false
	picked_up_seedling = null
	arrow_pointing.visible = false


func change_action():
	picked_up_seedling.change_action()


func pickup():
	arrow_pointing.visible = true
	picked_up_seedling = seedling
	picked_up_seedling.follow_player()
	currently_picked_up = true


func drop():
	arrow_pointing.visible = false
	print(picked_up_seedling.global_position)
	picked_up_seedling.drop()
	currently_picked_up = false
	picked_up_seedling = null


func _on_pickup_area_body_entered(body: Node2D) -> void:
	if body is little_guy:
		body.modulate = Color(0.75, 0.73, 0.0, 0.576)
		pickup_object = true
		seedling = body


func _on_pickup_area_body_exited(body: Node2D) -> void:
	if body is little_guy:
		body.modulate = Color(1.0, 1.0, 1.0, 1.0)
		pickup_object = false
		seedling = null
