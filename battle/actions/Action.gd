extends KinematicBody2D

class_name Action

var velocity: Vector2 = Vector2.ZERO
var texture: Texture = null setget set_texture
onready var sprite: Sprite = $Sprite

var source: Combatant = null

func _ready():
	if (source == null):
		push_error("Use Factory.new_action to create this action")

	set_texture(texture)
		
	if (velocity.x < 0):
		sprite.scale.x = -sprite.scale.x

func set_texture(value: Texture) -> void:
	texture = value
	if (sprite != null && texture != null):
		sprite.texture = value

func _physics_process(delta):
	self.position += velocity * delta
	
func act_on(target: Combatant, level: int) -> void:
	push_error("Action.act_on must be overridden")
