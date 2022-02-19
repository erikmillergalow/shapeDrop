extends RigidBody2D

export var gravity = 9
var screen_size
var controllable = true

var single_player = false

var polygon_list = [
	PoolVector2Array([Vector2(-50, 50), Vector2(50, 50), Vector2(50, -50), Vector2(-50, -50)]), # square
	PoolVector2Array([Vector2(-50, 50), Vector2(50, 50), Vector2(-50, -50)]), # triangle
	PoolVector2Array([Vector2(-30, 30), Vector2(90, 30), Vector2(30, -30), Vector2(-30, -30)]), # pointy
	PoolVector2Array([Vector2(-30, 30), Vector2(120, 30), Vector2(120, -30), Vector2(-30, -30)]), # rectangle
]

func _ready():
	# screen_size = get_viewport_rect().size
	mode = RigidBody2D.MODE_STATIC

func init(polygon_index):
	print("Creating a shape manually...")
	var points = polygon_list[polygon_index % polygon_list.size()]
	
	# create the collision polygon and add as child
	var collider = CollisionPolygon2D.new()
	collider.polygon = points
	add_child(collider)
	
	# make the polygon visible
	var shape = Polygon2D.new()
	shape.polygon = points
	add_child(shape)
	
	single_player = get_parent().single_player
	print(single_player)

remote func update_position(location, new_rotation, control_state):
	if !get_tree().is_network_server() || single_player:
		global_transform.origin = location
		rotation = new_rotation
		controllable = control_state

remotesync func handle_movement(position):
	global_transform.origin = position
	
remotesync func handle_rotation(rotate):
	rotation = global_transform.get_rotation() + rotate
	
remotesync func handle_dropped():
	print("remote func dropped")
	
	# only use physics on the server
	if (get_tree().is_network_server()):
		mode = RigidBody2D.MODE_RIGID
	controllable = false

func _process(delta):
	if controllable && (!get_tree().is_network_server() or single_player):
		if Input.is_action_pressed("move_left"):
			print(get_tree().is_network_server())
			rpc("handle_movement", get_global_transform().origin - Vector2(3, 0))
		if Input.is_action_pressed("move_right"):
			rpc("handle_movement", get_global_transform().origin + Vector2(3, 0))
		if Input.is_action_pressed("rotate_clockwise"):
			rpc("handle_rotation", .05)
		if Input.is_action_pressed("rotate_counter_clockwise"):
			rpc("handle_rotation", -.05)
		if Input.is_action_pressed("drop"):
			rpc("handle_dropped")
	
	if get_tree().is_network_server() and not single_player:
		rpc("update_position", global_transform.origin, global_transform.get_rotation(), controllable)
