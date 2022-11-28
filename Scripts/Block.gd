extends StaticBody2D

var detectedPlayer = false
var detectedCollision = false
var type
var frameDetectorAmount = 3
var animation_speed = 3
var forming = true
var blueDuration = 2
var cantForm = false
var beginDestruction = false
var shouldFall = false
var okayToGivePlayerJump = true
var moveTimer = 0

enum{
	GREEN,
	RED,
	BLUE
}

onready var animSprite = $BlockSprites
onready var collision = $CollisionShape2D
onready var rayCast = $RayCast2D
onready var cantPlaceSfx = $CantPlace
onready var blockBreakSfx = $BlockBreak
onready var player = get_parent().get_node_or_null("Player")

func _ready():
	animSprite.speed_scale = animation_speed

func _physics_process(delta):
	if (shouldFall):
		moveTimer += int((1*60)*delta)
		if moveTimer % 30 == 0:
			position.y += (64*60)*delta
	if (player.die):
		destroyBlock()
	
	#if i dont do this shit the code breaks for some go damn reason 
	if (type == null and frameDetectorAmount <= -1):
		blockBreakSfx.play()
		type = GREEN
	########################
	frameDetectorAmount-=(1*60)*delta
	if frameDetectorAmount <= 0:
		if (!cantForm):
			if (!detectedPlayer and !detectedCollision):
				type = BLUE
		else:
			if (type != GREEN):
				type = RED
				detectedCollision = true
	else:
		if (detectedPlayer):
			if (type != GREEN):
				blockBreakSfx.play()
				type = GREEN
	
	match(type):
		GREEN:
			animation_speed = 0.5
			animSprite.speed_scale = animation_speed
			animSprite.play("GreenBreak")
			if (animSprite.frame == 4):
				destroyBlock()
		BLUE:
			collision.disabled = false
			if (animSprite.frame == 3 and forming):
				animSprite.play("BlueIdle")
				forming = false
			if (forming):
				animSprite.play("BlueForm")
			if (!forming):
				blueDuration -= delta
				if (blueDuration <= 0):
					if (!beginDestruction):
						blockBreakSfx.play()
						beginDestruction = true
						animSprite.play("BlueBreak")
				if (beginDestruction):
					collision.disabled = true
					if (animSprite.frame == 4):
						destroyBlock()
		RED:
			animSprite.play("RedBreak")
			if (animSprite.frame == 0):
				cantPlaceSfx.play()
			if (animSprite.frame == 4):
				destroyBlock()
			if (detectedPlayer):
				if (type != GREEN):
					blockBreakSfx.play()
					type = GREEN
				if (okayToGivePlayerJump and type != RED):
					player.has_jumped = false
					okayToGivePlayerJump = false

func _on_PlayerDetector_body_entered(body):
	if (body.name == "Player"):
		if body.velocity.y < 0 or body.is_on_floor():
			if (shouldFall):
				blueDuration = 0
		detectedPlayer = true
		if (okayToGivePlayerJump and type != RED):
			body.has_jumped = false
			okayToGivePlayerJump = false
	else:
		if (body.name != self.name and type != GREEN):
			type = RED
			detectedCollision = true
		
func destroyBlock():
	player.blockAmmo -= 1
	player.hp -= 1
	queue_free()

func _on_PlayerDetector_area_entered(area):
	if (area.name == "unSafeZone"):
		if (type != GREEN):
			cantForm = true
	if (area.name == "WaterFall"):
		shouldFall = true
