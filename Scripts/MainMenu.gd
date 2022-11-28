extends Node2D


var selectedOption = PLAY
var coordinates = [598, 274]
var has_selected = false
var timer = 0.5

enum{
	PLAY,
	TUTORIAL,
	QUIT
}

onready var arrow = $SprArrowSelect
onready var sound = $Move
onready var soundSelect = $MenuSelect
onready var transition = $Transition/AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
	arrow.position.x = coordinates[0]
	arrow.position.y = coordinates[1]


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	arrow.position.x = int(lerp(arrow.position.x, coordinates[0], (0.5*60)*delta))
	arrow.position.y = int(lerp(arrow.position.y, coordinates[1], (0.5*60)*delta))
	if (has_selected):
		timer -= delta
	if (!has_selected):
		if (Input.is_action_just_pressed("down") or Input.is_action_just_pressed("up_menu")):
			sound.play()
		if (Input.is_action_just_pressed("select")):
			soundSelect.play()
	match(selectedOption):
		PLAY:
			if (timer <= 0):
				get_tree().change_scene("res://Scenes/Levels/Level1.tscn")
			if (!has_selected):
				if (Input.is_action_just_pressed("down")):
					selectedOption = TUTORIAL
				if (Input.is_action_just_pressed("up_menu")):
					selectedOption = QUIT
				if (Input.is_action_just_pressed("select")):
					transition.play("FadeIn")
					has_selected = true
			coordinates = [598, 274]
		TUTORIAL:
			if (timer <= 0):
				get_tree().change_scene("res://Scenes/TestScene.tscn")
			if (!has_selected):
				if (Input.is_action_just_pressed("select")):
					transition.play("FadeIn")
					has_selected = true
				if (Input.is_action_just_pressed("down")):
					selectedOption = QUIT
				if (Input.is_action_just_pressed("up_menu")):
					selectedOption = PLAY
			coordinates = [640, 352]
		QUIT:
			if (timer <= 0):
				get_tree().quit()
			if (!has_selected):
				if (Input.is_action_just_pressed("select")):
					transition.play("FadeIn")
					has_selected = true
				if (Input.is_action_just_pressed("down")):
					selectedOption = PLAY
				if (Input.is_action_just_pressed("up_menu")):
					selectedOption = TUTORIAL
			coordinates = [596, 448]
