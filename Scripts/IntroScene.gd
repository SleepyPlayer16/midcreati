extends Node2D


var timer = 6
var transTimer = 2
var startTrans = false

onready var introSpr = $SprIntroCutscene
onready var transition = $Transition/AnimationPlayer
onready var musPlayer = $IntroMus

func _ready():
	Engine.set_target_fps(60)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if (Input.is_action_just_pressed("select")):
		timer = 0
	if (Input.is_action_just_pressed("enter")):
		startTrans = true
		transition.play("FadeIn")
	
	timer -= delta
	if (timer <= 0):
		timer = 6
		if introSpr.frame != 3:
			introSpr.frame += 1
		else:
			transition.play("FadeIn")
			startTrans = true
	if (startTrans):
		musPlayer.volume_db -= (1*60)*delta
		transTimer -= delta
	if (transTimer <= 0):
		transition.play("FadeOut")
		get_tree().change_scene("res://Scenes/MainMenu.tscn")
