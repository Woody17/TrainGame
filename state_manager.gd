extends Node3D

# Main coordinator of the entire game play
class_name StateManager

@export var track_container: Node3D
@export var is_editing: bool = true
@export var camera: Camera
@export var play_controls: Controller

# Internal State
var track_array: Array[TrackPiece] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_prepareTrackArray()
	_enterEditMode()

func _enterEditMode():
	if track_array.size() > 0:
		_focusTrackPiece(track_array[0])
	camera.has_control = false
	play_controls.hide()

func _enterPlayMode():
	camera.has_control = true
	play_controls.show()

func _focusTrackPiece(piece: TrackPiece):
	camera.position = Vector3(piece.position.x, 5, piece.position.z)
	camera.rotation.x= deg_to_rad(-90)
	camera.look_at(piece.position)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _prepareTrackArray():
	for child in track_container.get_children():
		if child is TrackPiece:
			track_array.push_back(child)
	
