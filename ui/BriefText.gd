extends Control

class_name BriefText

onready var _text: Label = $Text
onready var _tween: Tween = $Tween
onready var _timer: Timer = $Timer

const RISE_DURATION = 0.75
const FADE_DURATION = 0.25

var text: String = "MISS"
var offset: Vector2 = Vector2.ZERO

func _ready():
	_text.text = text
	_text.rect_position.x += offset.x + rand_range(-10, 10)
	_text.rect_position.y += offset.y
	
	_timer.start(RISE_DURATION - FADE_DURATION)
	_tween.stop_all()
	_tween.interpolate_property(_text, "rect_position:y", _text.rect_position.y, -15, RISE_DURATION, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	_tween.start()

func _on_Timer_timeout():
	_tween.interpolate_property(_text, "custom_colors/font_color:a", 1.0, 0.0, FADE_DURATION, Tween.TRANS_LINEAR, Tween.EASE_OUT)

func _on_Tween_tween_all_completed():
	queue_free()			
