extends RigidBody2D
class_name little_guy

@export var wall: PackedScene
@export var platform: PackedScene
@export var player: Player

enum State {FOLLOW, FLYING, DROPPED}
enum ActionState {PLANT, ROLL}

# TileMap locations for tiles
var floor_atlas: Vector2i = Vector2i(0,0)
var wall_atlas: Vector2i = Vector2i(1,0)

var current_state: State = State.DROPPED
var action_state: ActionState = ActionState.ROLL
var original_parent: Node2D = null
var collision_position: Vector2 = Vector2.ZERO
var collision_normal_local: Vector2 = Vector2.ZERO

func _ready() -> void:
	original_parent = get_parent()
	$ColorRect.color = Color(0.667, 0.383, 0.0, 1.0)

	
	
func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	if current_state == State.FLYING and get_contact_count() > 0: # Avoids error when there are no collisions
		collision_position = state.get_contact_collider_position(0)
		collision_normal_local = state.get_contact_local_normal(0)
		
	

func _physics_process(delta: float) -> void:
	pass
	#print(current_state)


func throw():
	current_state = State.FLYING
	
	# Places the little guy back in the main scene
	reparent(original_parent,true)
	freeze = false
	
	# Gives a boost/impulse to the object
	
	var normalized_mouse_direction = get_viewport().get_mouse_position() - global_position
	print(normalized_mouse_direction)
	
	apply_impulse(normalized_mouse_direction.normalized() * 300,position)


func change_action():
	#print("action state: " + str(action_state))
	if action_state == ActionState.ROLL:
		action_state = ActionState.PLANT
		$ColorRect.color = Color(0.0, 0.562, 0.106, 1.0)
	else:
		action_state = ActionState.ROLL
		$ColorRect.color = Color(0.667, 0.383, 0.0, 1.0)


func follow_player():
	current_state = State.FOLLOW
	freeze = true
	freeze_mode = RigidBody2D.FREEZE_MODE_STATIC
	
	# Make it part of the player
	reparent(player,true)
	
	# Set the position to the hold marker in the player scene
	position = player.pickup_position.position
	

func drop():
	current_state = State.DROPPED
	freeze = false
	reparent(original_parent,true)
	reset_physics_interpolation()


func _on_body_entered(body: Node) -> void:
	if body is TileMapLayer:
		if current_state == State.FLYING: # Coordinate has been recorded
			current_state = State.DROPPED
			
			var tile_collision_position = Vector2i(collision_position) / 16
			if collision_normal_local.x == 1.0:
				tile_collision_position.x -= 1
				
			var atlas_coordinates: Vector2i = body.get_cell_atlas_coords(tile_collision_position)
			if action_state == ActionState.PLANT and atlas_coordinates == floor_atlas:
				var new_wall: StaticBody2D = wall.instantiate()
				new_wall.global_position = Vector2(global_position.x,collision_position.y) #+ Vector2(0,($CollisionShape2D.shape.size.y / 2))
				original_parent.call_deferred("add_child",new_wall)
				queue_free()
			elif action_state == ActionState.PLANT and atlas_coordinates == wall_atlas:
				var new_platform: StaticBody2D = platform.instantiate()
				
				# Spawns the platform on the wall, moving the x position right or left by half its size using the normal
				new_platform.global_position = Vector2(collision_position.x + (new_platform.get_node("CollisionShape2D").shape.size.x / 2 * collision_normal_local.x),global_position.y)
				original_parent.call_deferred("add_child",new_platform)
				queue_free()
