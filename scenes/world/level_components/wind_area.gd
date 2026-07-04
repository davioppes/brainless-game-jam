extends Area2D

@export var wind_speed: Vector2
@export var wind_origin: Vector2 = Vector2.ZERO
@export var direction: Vector2 = Vector2.RIGHT # Set the direction of the raycast
@export var collision_shape_size: Vector2 = Vector2.ZERO
@export var player: Player
@export var wind_layer: TileMapLayer

@onready var ray_cast_2d: RayCast2D = $RayCast2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

var original_target_position: Vector2

var object_inside_wind: bool = false
var current_objects_inside: Array = []
var platform_between: bool = false

var collision_point: Vector2 = Vector2.ZERO

func _ready() -> void:
	wind_origin = ray_cast_2d.global_position
	
	# Make sure the raycast points in the right direction
	if direction.x == 0:
		ray_cast_2d.target_position = Vector2(0,collision_shape_2d.shape.size.y) * direction
	else:
		ray_cast_2d.target_position = Vector2(collision_shape_2d.shape.size.x,0) * direction
	
	original_target_position = ray_cast_2d.target_position
	
	body_entered.connect(_object_entered)
	body_exited.connect(_object_exited)
	


func _physics_process(_delta: float) -> void:
	if ray_cast_2d.get_collider() != null and ray_cast_2d.is_colliding():
		# Update the target position of the ray when a collision happens (with a wall)
		collision_point = ray_cast_2d.get_collision_point()
		ray_cast_2d.target_position = collision_point - ray_cast_2d.global_position
		
		# Remove the wind tiles behind the colliding object blocking the wind
		remove_wind_tiles()
	else:
		collision_point = Vector2.ZERO
		ray_cast_2d.target_position = original_target_position # If the object is ever able to be destroyed
	
	# Updates the wind for every object inside the wind area
	for object in current_objects_inside:
		if check_platform_between(object):
			object.wind_velocity = Vector2.ZERO
		else:
			object.wind_velocity = wind_speed * direction

func check_platform_between(object_body: PhysicsBody2D) -> bool:
	if direction == Vector2.RIGHT:
		if ray_cast_2d.global_position < collision_point and collision_point < object_body.global_position:
			platform_between = true
		else:
			platform_between = false
	elif direction == Vector2.LEFT:
		if ray_cast_2d.global_position > collision_point and collision_point > object_body.global_position:
			platform_between = true
		else:
			platform_between = false
	
	return platform_between


func remove_wind_tiles():
	
	if direction.x == 0:
		# Loops through all the tiles from the point of collision to the end of the collision area (raycast target point)
		for i in range(int((ray_cast_2d.global_position.y + original_target_position.y) / 16),int(collision_point.y / 16), -1 * direction.y):
			wind_layer.set_cell(Vector2i(int(collision_point.y / 16),i),3,Vector2i(0,1))
			wind_layer.set_cell(Vector2i(int(collision_point.y / 16) - 1,i),3,Vector2i(0,1))
	else:
		for i in range(int((ray_cast_2d.global_position.x + original_target_position.x) / 16),int(collision_point.x / 16), -1 * direction.x):
			wind_layer.set_cell(Vector2i(i,int(collision_point.y / 16)),3,Vector2i(0,1))
			wind_layer.set_cell(Vector2i(i,int(collision_point.y / 16) - 1),3,Vector2i(0,1))
func _object_entered(body: PhysicsBody2D):
	object_inside_wind = true
	current_objects_inside.append(body)
	
	if "wind_velocity" in body and not check_platform_between(body):
		body.wind_velocity += wind_speed * direction
	elif check_platform_between(body):
		body.wind_velocity = Vector2.ZERO


func _object_exited(body: PhysicsBody2D):
	object_inside_wind = false
	current_objects_inside.erase(body)
	
	if check_platform_between(body):
		body.wind_velocity = Vector2.ZERO
	else:
		body.wind_velocity -= wind_speed * direction
		if body is Player:
			body.wind_linger_velocity += wind_speed * direction
