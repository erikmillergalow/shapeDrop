extends Node2D

const SERVER_IP = "127.0.0.1"
const SERVER_PORT = 44444
const MAX_PLAYERS = 2

var polygon_index = 0
var player_ids = []
var players = []
var current_player = 0

export var single_player = true
var triangle_scene = preload("res://Triangle.tscn")
var shape_scene = preload("res://Shape.tscn")
var player_scene = preload("res://Player.gd")

var polygon_list = [
	PoolVector2Array([Vector2(-50, 50), Vector2(50, 50), Vector2(50, -50), Vector2(-50, -50)]), # square
	PoolVector2Array([Vector2(-50, 50), Vector2(50, 50), Vector2(-50, -50)]), # triangle
	PoolVector2Array([Vector2(-30, 30), Vector2(90, 30), Vector2(30, -30), Vector2(-30, -30)]), # pointy
	PoolVector2Array([Vector2(-30, 30), Vector2(120, 30), Vector2(120, -30), Vector2(-30, -30)]), # rectangle
	PoolVector2Array([Vector2(-30, 30), Vector2(30, 30), Vector2(-30, -30)]), # small triangle
]

func _ready():
	var peer = NetworkedMultiplayerENet.new()
	
	if "--server" in OS.get_cmdline_args() or single_player:
		print("Starting server...")
		peer.create_server(SERVER_PORT, MAX_PLAYERS)
		get_tree().network_peer = peer
		if single_player:
			# set up two players
			var player_1 = Player.new()
			player_1.init(1, polygon_list)
			add_child(player_1)
			players.append(player_1)
			player_1.initialize_inventory()
			var player_2 = Player.new()
			add_child(player_2)
			player_2.init(2, polygon_list)
			players.append(player_2)
			player_2.initialize_inventory()
			spawn_shape()
		else:
			#player_ids.append(1)
			get_tree().connect("network_peer_connected", self, "_player_connected")
	else:
		print('Starting client...')
		peer.create_client(SERVER_IP, SERVER_PORT)
		get_tree().network_peer = peer
		
		var player = Player.new()
		player.init(peer.get_unique_id(), polygon_list)
		add_child(player)
		players.append(player)
		player.initialize_inventory()
		
	set_process_input(true)

func _input(event):
	if !get_tree().is_network_server() or single_player:
		if event.is_action_pressed("drop"):
			if single_player:
				print("Current player: ", players[current_player])
				trigger_respawn()
			else:
				rpc("trigger_respawn")

func _player_connected(id):
	# add player to playerlist
	var player = Player.new()
	player.init(id, polygon_list)
	add_child(player)
	players.append(player)
	player.initialize_inventory()
	
	# spawn a piece
	spawn_first_shape()

remote func spawn_first_shape():
	$SpawnTimer.start()

remotesync func trigger_respawn():
#	var sender_id = get_tree().get_rpc_sender_id()
#	print("Sender ID: ", sender_id)
#	if sender_id == current_player:
	players[current_player].pieces.remove(polygon_index)
	players[current_player].initialize_inventory()
	
	polygon_index = 0

	# next player's turn
	if get_tree().is_network_server() or single_player:
		current_player = (current_player + 1) % players.size()
		$SpawnTimer.start()

remotesync func spawn_shape():
	# spawn new shape on server and clients
	var shape = shape_scene.instance()
	shape.position = Vector2(580, 100)
	add_child(shape)
	#var vertices = players[current_player].pieces[0]
	print("Spawning for next player:", current_player)
	shape.init(players[current_player].pieces)
	
#	# next player's turn
#	if get_tree().is_network_server():
#		current_player = (current_player + 1) % player_ids.size()

# run on server
func _on_SpawnTimer_timeout():
	print("Spawning")
	rpc("spawn_shape")

func _on_TimerOfDoom_timeout():
	print("Player:", current_player, "loses!")
