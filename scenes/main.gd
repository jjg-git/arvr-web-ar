extends Node3D

var webxr_interface: WebXRInterface
var ar_supported = false
#const XR_TYPE = 'immersive-vr'
const XR_TYPE = 'immersive-ar'
#const XR_TYPE = 'inline'

@onready var environment : Environment = $WorldEnvironment.environment
@onready var xrorigin : XROrigin3D = $XROrigin3D

func _ready():	
	# We assume this node has a button as a child.
	# This button is for the user to consent to entering immersive VR mode.
	%PermissionXRBtn.visible = true
	webxr_interface = XRServer.find_interface("WebXR")
	
	if webxr_interface:
		# WebXR uses a lot of asynchronous callbacks, so we connect to various
		# signals in order to receive them.
		webxr_interface.session_supported.connect(self._webxr_session_supported)
		webxr_interface.session_started.connect(self._webxr_session_started)
		webxr_interface.session_ended.connect(self._webxr_session_ended)
		webxr_interface.session_failed.connect(self._webxr_session_failed)
		
		webxr_interface.is_session_supported(XR_TYPE)

func _write_detected_interfaces() -> void:
	var print_interface:String = ""
	var xr_detected_interfaces = XRServer.get_interfaces()
	var no_of_interfaces = XRServer.get_interface_count()
	var list_interface_str:String = ""
	
	for i in range(no_of_interfaces):
		var interface_idx = xr_detected_interfaces[i]["id"]
		var interface_name = xr_detected_interfaces[i]["name"]
		list_interface_str += "{0}: {1}, ".format([interface_idx, interface_name])
	print_interface += "[%s]" % list_interface_str
	
	%FoundInstance/Value.text = "yes" if webxr_interface else "no"
	%NoOfInterfaces/Value.text = str(no_of_interfaces)
	%ListInterface/Value.text = print_interface

func _alert_detected_interfaces() -> void:
	var print_interface:String = "Detected XR interfaces:\n"
	
	var xr_detected_interfaces = XRServer.get_interfaces()
	
	for i in range(XRServer.get_interface_count()):
		var interface_idx = xr_detected_interfaces[i]["id"]
		var interface_name = xr_detected_interfaces[i]["name"]
		print_interface += "{0}: {1}\n".format([interface_idx, interface_name])
	
	OS.alert(print_interface)

func _webxr_session_supported(session_mode, supported):
	if session_mode == XR_TYPE:
		OS.alert("%s supported" % XR_TYPE)
		ar_supported = supported
		#%PermissionXRBtn.visible = ar_supported

func _permission_request():
	_write_detected_interfaces()
	
	#webxr_interface.session_mode = 'inline'
	webxr_interface.session_mode = XR_TYPE
	# 'bounded-floor' is room scale, 'local-floor' is a standing or sitting
	# experience (it puts you 1.6m above the ground if you have 3DoF headset),
	# whereas as 'local' puts you down at the ARVROrigin.
	# This list means it'll first try to request 'bounded-floor', then
	# fallback on 'local-floor' and ultimately 'local', if nothing else is
	# supported.
	
	# In order to use 'local-floor' or 'bounded-floor' we must also
	# mark the features as required or optional.
	
	if XR_TYPE == 'immersive-ar' or XR_TYPE == 'immersive-vr':
		webxr_interface.requested_reference_space_types = 'unbounded, viewer, local, local-floor'
		webxr_interface.required_features = 'unbounded'
		#webxr_interface.required_features = 'local-floor'
	if XR_TYPE == 'inline':
		webxr_interface.requested_reference_space_types = 'local, local-floor'
		webxr_interface.required_features = 'local-floor'
		
	webxr_interface.optional_features = 'local, local-floor, depth-sensing, hit-test, viewer'
	
	if not webxr_interface.initialize():
		OS.alert("Failed to initialize")
		return


func _webxr_session_started():
	%PermissionXRBtn.visible = false
	#%VirtualController.visible = true
	# This tells Godot to start rendering to the headset.
	get_viewport().use_xr = true
	get_viewport().transparent_bg = true
	
	environment.background_mode = Environment.BG_COLOR
	#environment.background_color = Color(0.0, 0.0, 0.0, 0.0)
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	
	%EnabledFeatures/Value.text = webxr_interface.enabled_features
	%ReferenceSpaceType/Value.text = webxr_interface.reference_space_type
	
func _webxr_session_ended():
	%PermissionXRBtn.visible = true
	#%VirtualController.visible = false
	#%SessionStarted.visible = true
	#%SessionStarted/Label.text = "SESSION JUST ENDED"
	
	OS.alert("Session ended")
	# If the user exits immersive mode, then we tell Godot to render to the web
	# page again.
	get_viewport().use_xr = false
	get_viewport().transparent_bg = false

func _webxr_session_failed(message):
	OS.alert("Session failed: " + message)
