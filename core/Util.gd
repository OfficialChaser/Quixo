extends Node

var project_viewport_w = ProjectSettings.get_setting("display/window/size/viewport_width")
var project_viewport_h = ProjectSettings.get_setting("display/window/size/viewport_height")
var project_viewport = Vector2(project_viewport_w, project_viewport_h)

func _ready():
	var visible_viewport = get_viewport().get_visible_rect().size
	
	if round(project_viewport) != round(visible_viewport):
		push_warning("Set project viewport dimensions to " + str(round(visible_viewport)))
		pass
