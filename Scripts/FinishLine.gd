extends Node2D

func _on_Area2D_body_entered(body):
	if (body.name == "Player"):
		$FinishLine.play()
		body.has_won = true
		body.state = body.VICTORY
