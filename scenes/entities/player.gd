extends CharacterBody2D
class_name Player

@onready var pickup_area: Area2D = %PickupArea
@onready var player_collision_shape: CollisionShape2D = %PlayerCollisionShape
@onready var pickup_position: Marker2D = %PickupPosition
@onready var arrow_pointing: Sprite2D = %ArrowPointing
@onready var animated_sprite_2d: AnimatedSprite2D = %AnimatedSprite2D

@export var spawn_point: Marker2D

var player_height: int
var current_facing_direction: int
enum MovementState {IDLE,WALKING,PICKUP,JUMP}
var current_movement_state: MovementState = MovementState.IDLE

var pickup_object: bool = true # Able to pickup object or not
var currently_picked_up: bool = false # If object is currently picked up
var seedling: Node2D = null # Current object that is picked up
var picked_up_seedling: little_guy = null

var wind_velocity: Vector2 = Vector2.ZERO
var wind_linger_velocity: Vector2 = Vector2.ZERO
const SPEED = 100.0
const JUMP_VELOCITY = -300.0
var reduce_jump_height: float = 0.75
var jump_available: bool = true

var coyote_frames = 5 # How many in-air frames to allow jumping
var coyote = false  # Track whether we're in coyote time or not
var last_floor = false  # Last frame's on-floor state


func _ready() -> void:
	
	if get_node("Camera2D") != null:
		var camera: Camera2D = get_node("Camera2D")
		camera.make_current()
	
	$CoyoteTimer.wait_time = coyote_frames / 60.0
	
	if spawn_point:
		global_position = spawn_point.global_position
	
	#player_height = player_collision_shape.shape.size.y
	#print(player_height)
	pickup_area.facing_right = pickup_area.position
	pickup_area.facing_left = Vector2(-pickup_area.position.x,pickup_area.position.y)


func _process(delta: float) -> void:
	arrow_pointing.look_at(get_global_mouse_position())
	
	if Input.is_action_just_pressed("reset_level"):
		get_tree().reload_current_scene()


func _physics_process(delta: float) -> void:
	
	#Handle pickup
	if Input.is_action_just_pressed("pickup"):
		if pickup_object and not currently_picked_up and seedling != null:
			pickup()
		elif not pickup_object and currently_picked_up:
			drop()
	
	#Handle throw
	if Input.is_action_just_pressed("throw") and currently_picked_up:
		throw()
	
	#Handle change action of pickup guy
	if Input.is_action_just_pressed("change_action") and currently_picked_up:
		change_action()
	
	var direction = 0
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		wind_linger_velocity = Vector2.ZERO

	# Handle jump.
	if Input.is_action_just_pressed("jump") and (is_on_floor() or jump_available):
		velocity.y = JUMP_VELOCITY 
		jump_available = false
	if Input.is_action_pressed("move_left"):
		direction = -1
		current_facing_direction = direction
		pickup_area.position = pickup_area.facing_left
		
		current_movement_state = MovementState.WALKING
		animated_sprite_2d.flip_h = true
	if Input.is_action_pressed("move_right"):
		direction = 1
		current_facing_direction = direction
		pickup_area.position = pickup_area.facing_right
		
		current_movement_state = MovementState.WALKING
		animated_sprite_2d.flip_h = false
	
	# Apply the movement to the player
	velocity.x = direction * SPEED
	velocity += wind_velocity
	
	if wind_linger_velocity.x != 0:
		velocity += wind_linger_velocity
	
	# Reduce wind velocity over time while in the air
	if wind_linger_velocity.length() > 0:
		wind_linger_velocity = wind_linger_velocity.move_toward(Vector2.ZERO,delta * 55)
		print(wind_linger_velocity)
	
	
	if direction == 0:
		current_movement_state = MovementState.IDLE
	
	play_animations()
	
	move_and_slide()
	
	if is_on_floor() and not jump_available:
		jump_available = true
	
	if (not is_on_floor()) and jump_available and $CoyoteTimer.is_stopped():
		$CoyoteTimer.start()


func _input(event: InputEvent) -> void:
	if event.is_action_released("jump"):
		if velocity.y < 0.0:
			velocity.y *= reduce_jump_height


func play_animations():
	match current_movement_state:
		MovementState.WALKING:
			if currently_picked_up:
				animated_sprite_2d.play("walking_pickup")
			else:
				animated_sprite_2d.play("walking")
		MovementState.IDLE:
			if currently_picked_up:
				animated_sprite_2d.play("idle_pickup")
			else:
				animated_sprite_2d.play("idle")


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


func _on_coyote_timer_timeout() -> void:
	jump_available = false


func _on_bramble_hitbox_body_entered(body: Node2D) -> void:
	reset_level()


func reset_level():
	get_tree().reload_current_scene()


func _on_pickup_area_area_entered(area: Area2D) -> void:
	if area.has_method("interact"):
		area.interact()


func _on_pickup_area_area_exited(area: Area2D) -> void:
	if area.has_method("interact"):
		area.hide_text()
