extends Node2D


var timer = 4
var finished = false
onready var sprCutscene = $SprLastCutscene
onready var musPlayer = $Outro
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if (Input.is_action_just_pressed("select")):
		timer = 0
	timer -= delta
	if (timer <= 0 and !finished):
		if (sprCutscene.frame == 3):
			timer = 2
		else:
			timer = 4
		if (sprCutscene.frame != 5):
			sprCutscene.frame += 1
		else:
			timer = 10
			finished = true
	if (finished):
		musPlayer.volume_db -= (0.2*60)*delta
		if timer <= 6 and timer > 3:
			$SprDarkBackText.visible = true
		if timer <= 3 and timer > 0:
			$SprDarkBackText.visible = false
		if timer <= 0:
			get_tree().change_scene("res://Scenes/IntroScene.tscn")
		sprCutscene.modulate.a -= (0.01*60)*delta
