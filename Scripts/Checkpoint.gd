extends Node2D


var playerDetected = false
onready var spr = $Sprite

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Area2D_body_entered(body):
	if (!playerDetected):
		if (body.name == "Player"):
			body.startPos = position
			playerDetected = true
			spr.frame = 1
			$Check.play()
