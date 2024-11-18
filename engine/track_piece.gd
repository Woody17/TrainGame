extends Node3D

class_name TrackPiece

@export var path: Path3D
@export var area: Area3D
	
func getAreaRID():
	return area.get_rid()

func getTrackPosition(position: Vector3) -> Vector3:
	var local_pos = path.to_local(position)
	return path.to_global(path.curve.get_closest_point(local_pos))
