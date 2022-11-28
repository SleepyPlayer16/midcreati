extends KinematicBody2D

var velocity = Vector2.ZERO
var gravity = 25
var has_jumped = false
var topSpeed = 250
var jumpPower = -525
var acceleration = 35
var direction = 1
var friction = 12
var state
var fallDamageTimer = 6
var fallDamage = 1
var hp = 0
var blockAmmo = 0
var max_blockNumber = 3
var startPos
var die = false
var winTimer = 0
var has_won = false

enum {
	IDLE,
	MOVE,
	JUMP,
	DEAD,
	VICTORY,
	DEBUG
}

onready var playerSprite = $PlayerSprite
onready var collisionShape = $Collision
onready var audioPlayer = get_parent().get_node_or_null("Music")
onready var jumpSFX = $Jump
onready var deathSFX = $Death
onready var hpBar = $CanvasLayer/SprLifeBar
onready var transition = $Transition/AnimationPlayer
onready var camera = $Camera
onready var block = preload("res://Scenes/Objects/Player/Block.tscn")

func _ready():
	transition.play("FadeOut")
	state = IDLE
	startPos = position
	
func _input(event):
	if (event is InputEventMouseButton) and event.pressed:
		if event.button_index == BUTTON_LEFT:
			if (blockAmmo < max_blockNumber):
				var blockToInstance = block.instance()
				if (hp != max_blockNumber-1):
					hp += 1
				blockAmmo += 1
				event = make_input_local(event)
				blockToInstance.position = (get_global_mouse_position() / 64).floor() * 64
				get_parent().add_child(blockToInstance)

func _physics_process(delta):
	var input = Vector2.ZERO
	input.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	if (blockAmmo >= 0 and hp <= max_blockNumber):
		hpBar.frame = blockAmmo
	else:
		hpBar.frame = 0
	if (Input.is_action_just_pressed("restart")):
		get_tree().reload_current_scene()
#	if hp < 0:
#		hp = 0
#	
	if (Input.is_action_pressed("downGame")):
		camera.offset_v = int(lerp(camera.offset_v, 7, (0.3*60)*delta))
	if (camera.offset_v != 0 and !Input.is_action_pressed("downGame")):
		camera.offset_v = int(lerp(camera.offset_v, 0, (0.5*60)*delta))

	if (!die and !has_won):
		if (input.x > 0):
			state = MOVE
			playerSprite.scale.x = 2
			direction = 1
		elif (input.x < 0):
			state = MOVE
			playerSprite.scale.x = -2
			direction = -1
		else:
			if (is_on_floor()):
				state = IDLE
			applyFriction()
		
		apply_gravity()
	
	match(state):
		IDLE:
			idle()
		MOVE:
			move(input.x)
		DEAD: 
			dead()
		VICTORY:
			victory()
			
	if (is_on_floor()):
		has_jumped = false
	if (!die and !has_won):
		if (Input.is_action_just_pressed("jump") and !has_jumped):
			has_jumped = true
			jumpSFX.play()
			velocity.y = jumpPower
			state = MOVE
	var snap = Vector2.DOWN * 1 if is_on_floor() else Vector2.ZERO
	velocity = move_and_slide_with_snap(velocity, snap, Vector2.UP)
#	velocity = move_and_slide(velocity, Vector2.UP)
	
func idle():
	if (!die):
		if (is_on_floor()):
			playerSprite.animation = "Idle"
		else:
			state = MOVE
	
func move(amount):
	if (!die):
		applyAcceleration(amount)	
		if (!is_on_floor()):
			if (velocity.y < 0):
				playerSprite.animation = "Jump"
			else:
				playerSprite.animation = "Fall"
		else: 
			playerSprite.animation = "Walk"

func dead():
	die = true
	velocity.y = 0
	velocity.x = 0
	playerSprite.animation = "Death"
	playerSprite.speed_scale = 5
	
func victory():
	if (audioPlayer):
		audioPlayer.stop()
	has_won = true
	hpBar.visible = false
	playerSprite.animation = "Win"
	velocity.x = 0
	velocity.y = 0
	winTimer += get_physics_process_delta_time()
	if (winTimer >= 2 and winTimer < 4):
		transition.play("FadeIn")
	if (winTimer > 3):
		match(get_tree().current_scene.name):
			"TestScene":
				get_tree().change_scene("res://Scenes/MainMenu.tscn")
			"Level1":
				get_tree().change_scene("res://Scenes/Levels/Level2.tscn")
			"Level2":
				get_tree().change_scene("res://Scenes/LastCutscene.tscn")

func apply_gravity():
#	if (is_on_floor()):
#		if (fallDamageTimer < 5 and fallDamageTimer > 3):
#			hp += 1
#		if (fallDamageTimer < 4 and fallDamageTimer > 2):
#			hp += 2
#		if (fallDamageTimer < 3 and fallDamageTimer > 1):
#			hp += 3
#		if (fallDamageTimer < 2 and fallDamageTimer > 0):
#			hp += 4
#		fallDamageTimer = 6
		
	if (state != DEBUG):
		velocity.y += (gravity*60)*get_physics_process_delta_time()
		if (is_on_floor()):
			friction = 20
		else:
			if velocity.y > 400:
				fallDamageTimer -= get_physics_process_delta_time()*4
			friction = 10
			
func applyAcceleration(amount):
	velocity.x = move_toward(velocity.x, topSpeed * amount, (acceleration*60)*get_physics_process_delta_time())

func applyFriction():
	velocity.x = move_toward(velocity.x, 0, (friction*60)*get_physics_process_delta_time())

func _on_PlayerSprite_animation_finished():
	if (die):
		playerSprite.speed_scale = 1
		die = false
		state = IDLE
		position = startPos
		hp = 0
		blockAmmo = 0	
