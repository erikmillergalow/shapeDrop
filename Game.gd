extends Node2D

const SERVER_IP = "127.0.0.1"
const SERVER_PORT = 44444
const MAX_PLAYERS = 2

var polygon_index = 0
var player_ids = []
var current_player = 0

export var single_player = false
var triangle_scene = preload("res://Triangle.tscn")
var shape_scene = preload("res://Shape.tscn")

func _ready():
	var peer = NetworkedMultiplayerENet.new()
	
	if "--server" in OS.get_cmdline_args() or single_player:
		print("Starting server...")
		peer.create_server(SERVER_PORT, MAX_PLAYERS)
		get_tree().network_peer = peer
		if single_player:
			player_ids.append(0)
			player_ids.append("computer")
			spawn_shape()
		else:
			player_ids.append(0)
			get_tree().connect("network_peer_connected", self, "_player_connected")
	else:
		print('Starting client...')
		peer.create_client(SERVER_IP, SERVER_PORT)
		get_tree().network_peer = peer

func _process(delta):
	if !get_tree().is_network_server() or single_player:
		if Input.is_action_pressed("drop"):
			if single_player:
				print("Current player: ", player_ids[current_player])
				trigger_respawn()
			else:
				rpc("trigger_respawn")

func _player_connected(id):
	# add player to playerlist
	player_ids.append(id)
	# spawn a piece
	trigger_respawn()

remote func trigger_respawn():
	$SpawnTimer.start()

remotesync func spawn_shape():
	# spawn new shape on server and clients
	var shape_spawn_location = get_node("Spawn/PathFollow2D")
	var shape = shape_scene.instance()
	print(shape_spawn_location.position)
	#shape.position = shape_spawn_location.position
	shape.position = Vector2(580, 100)
	add_child(shape)
	shape.init(polygon_index)
	
	polygon_index += 1
	
	# next player's turn
	if get_tree().is_network_server():
		current_player = (current_player + 1) % player_ids.size()

# run on server
func _on_SpawnTimer_timeout():
	print("Spawning")
	rpc("spawn_shape")
	
	
