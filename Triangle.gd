extends RigidBody2D

export var gravity = 9
var screen_size
var controllable = true

func _ready():
	# screen_size = get_viewport_rect().size
	mode = RigidBody2D.MODE_STATIC

remote func update_position(location, new_rotation, control_state):
	if !get_tree().is_network_server():
		global_transform.origin = location
		rotation = new_rotation
		controllable = control_state

remote func handle_movement(position):
	global_transform.origin = position
	
remote func handle_rotation(rotate):
	rotation = global_transform.get_rotation() + rotate
	
remote func handle_dropped():
	mode = RigidBody2D.MODE_RIGID
	controllable = false

func _process(delta):
	if controllable && !get_tree().is_network_server():
		if Input.is_action_pressed("move_left"):
			rpc("handle_movement", get_global_transform().origin - Vector2(3, 0))
		if Input.is_action_pressed("move_right"):
			rpc("handle_movement", get_global_transform().origin + Vector2(3, 0))
		if Input.is_action_pressed("rotate_clockwise"):
			rpc("handle_rotation", .05)
		if Input.is_action_pressed("rotate_counter_clockwise"):
			rpc("handle_rotation", -.05)
		if Input.is_action_pressed("drop"):
			rpc("handle_dropped")
	
	if get_tree().is_network_server():
		rpc("update_position", global_transform.origin, global_transform.get_rotation(), controllable)

