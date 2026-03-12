extends XROrigin3D

var xr_interface: XRInterface

func _ready():
	xr_interface = XRServer.find_interface("OpenXR")
	if not xr_interface:
		return

	get_viewport().transparent_bg = true

	if xr_interface.is_initialized():
		_enable_passthrough()
	else:
		xr_interface.session_begun.connect(_enable_passthrough)

func _enable_passthrough():
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	get_viewport().use_xr = true
	get_viewport().transparent_bg = true
	xr_interface.environment_blend_mode = XRInterface.XR_ENV_BLEND_MODE_ALPHA_BLEND
