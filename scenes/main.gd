extends Node3D

var xr_interface:XRInterface
var xr_supported = false

func _ready() -> void:
	xr_interface = XRServer.find_interface("OpenXR")
	if xr_interface and xr_interface.is_initialized():
		OS.alert("OpenXR initialized sucessfully")
		
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
		
		get_viewport().use_xr = true
	else:
		OS.alert("OpenXR not initialized")

func _permission_pressed() -> void:
	if not xr_supported:
		OS.alert("WebXR not supported")
		return
