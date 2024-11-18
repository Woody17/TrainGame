extends Node2D

# Can be used to control a train
class_name Controller

@export var train: Train
# TODO: Make this more generic
@export var slider: VSlider

func _enter_tree() -> void:
	slider.value_changed.connect(_on_slider_changed)

func _on_slider_changed(value: float):
	train.move_speed = -value
