@tool
extends EditorPlugin


var plugin_control: Control
var plugin_icon: Texture2D = preload("res://addons/grouper/assets/grouper_logo.svg")


func _enter_tree() -> void:
    plugin_control = preload("res://addons/grouper/gui/main_screen.tscn").instantiate()
    EditorInterface.get_editor_main_screen().add_child(plugin_control)
    plugin_control.hide()


func _exit_tree() -> void:
    EditorInterface.get_editor_main_screen().remove_child(plugin_control)
    plugin_control.queue_free()


func _has_main_screen() -> bool:
    return true


func _make_visible(visible: bool) -> void:
    plugin_control.visible = visible


func _get_plugin_name() -> String:
    return "Grouper"


func _get_plugin_icon() -> Texture2D:
    return plugin_icon
