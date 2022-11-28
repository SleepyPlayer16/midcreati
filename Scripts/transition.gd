extends AnimationPlayer

onready var colorRect = get_parent().get_node_or_null("CanvasLayer/ColorRect")

func _ready():
	colorRect.modulate.a = 1
	play("FadeOut")
