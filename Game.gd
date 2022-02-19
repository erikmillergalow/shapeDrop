extends Node2D

const SERVER_IP = "127.0.0.1"
const SERVER_PORT = 44444
const MAX_PLAYERS = 2

var polygon_index = 0

export var single_player = true
#var shape_type = 
var triangle_scene = preload("res://Triangle.tscn")
var shape_scene = preload("res://Shape.tscn")

func _ready():
	var peer = NetworkedMultiplayerENet.new()
	
	if "--server" in OS.get_cmdline_args() or single_player:
		print("Starting server...")
		peer.create_server(SERVER_PORT, MAX_PLAYERS)
		get_tree().network_peer = peer
		if single_player:
			spawn_shape()
		else:
			get_tree().connect("network_peer_connected", self, "_player_connected")
	else:
		print('Starting client...')
		peer.create_client(SERVER_IP, SERVER_PORT)
		get_tree().network_peer = peer

func _process(delta):
	if !get_tree().is_network_server() or single_player:
		if Input.is_action_pressed("drop"):
			if single_player:
				trigger_respawn()
			else:
				rpc("trigger_respawn")

func _player_connected(id):
	trigger_respawn()

remote func trigger_respawn():
	print("Trigger respawn")
	$SpawnTimer.start()

remotesync func spawn_shape():
	# spawn new shape on server and clients
	var shape_spawn_location = get_node("Spawn/PathFollow2D")
	var shape = shape_scene.instance()
	# shape.init(shape_type)
	add_child(shape)
	shape.init(polygon_index)
	shape.global_transform.origin = shape_spawn_location.position
	
	polygon_index += 1

# run on server
func _on_SpawnTimer_timeout():
	print("Spawning")
	rpc("spawn_shape")
	
	
