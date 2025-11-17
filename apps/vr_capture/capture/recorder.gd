extends Node

var session_id: String = ""
var frame_count: int = 0

func start_session() -> void:
	session_id = str(Time.get_unix_time_from_system())
	frame_count = 0

func end_session() -> void:
	pass

func capture_frame(viewport: Viewport, camera: Camera3D, pose: Transform3D) -> void:
	var dir := "user://captures/%s/frames" % session_id
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(dir))
	var img := viewport.get_texture().get_image()
	var path := "%s/frame_%05d.png" % [dir, frame_count]
	img.save_png(path)
	_save_metadata(camera, pose, frame_count, path)
	frame_count += 1

func _save_metadata(camera: Camera3D, pose: Transform3D, index: int, image_path: String) -> void:
	var meta_dir := "user://captures/%s" % session_id
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(meta_dir))
	var size := DisplayServer.window_get_size()
	var h := float(size.y)
	var w := float(size.x)
	var vfov := deg_to_rad(camera.fov)
	var fy := h / (2.0 * tan(vfov * 0.5))
	var fx := fy * (w / h)
	var k := {
		"fx": fx,
		"fy": fy,
		"cx": w * 0.5,
		"cy": h * 0.5
	}
	var p := {
		"position": [pose.origin.x, pose.origin.y, pose.origin.z],
		"basis": [
			[pose.basis.x.x, pose.basis.x.y, pose.basis.x.z],
			[pose.basis.y.x, pose.basis.y.y, pose.basis.y.z],
			[pose.basis.z.x, pose.basis.z.y, pose.basis.z.z]
		]
	}
	var entry := {
		"index": index,
		"image_path": image_path,
		"intrinsics": k,
		"pose": p
	}
	# Corrige variável ausente: file_path
	var file_path := "%s/metadata_%05d.json" % [meta_dir, index]
	var f := FileAccess.open(file_path, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify(entry))