extends Area2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	connect("body_entered", self, "_on_LineOfDoom_body_entered")
	connect("body_exited", self, "_on_LineOfDoom_body_exited")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_LineOfDoom_body_entered(body):
	print("entered...")
	print(body.name)
	if body.name.match("*Shape*"):
		body.start_doom_timer()
#		$TimerOfDoom.start(4)


func _on_LineOfDoom_body_exited(body):
	print("exited")
	print(body.name)
	if body.name.match("*Shape*"):
		body.end_doom_timer()
#		$TimerOfDoom.stop()
