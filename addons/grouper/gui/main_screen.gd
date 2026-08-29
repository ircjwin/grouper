@tool
extends Control


# Prevents global namespace pollution
const DataFrame = preload("res://addons/grouper/data/data_frame.gd")
const GroupTable = preload("res://addons/grouper/gui/group_table.gd")

const GLOBAL_CFG: String = "res://project.godot"
const GLOBAL_GROUP_SECTION: String = "global_group"
const GLOBAL_SCOPE: String = "Global"
const SCENE_CFG: String = "res://.godot/scene_groups_cache.cfg"
const SCENE_SCOPE: String = "Scene"
const COLUMN_1: String = "Node"
const COLUMN_2: String = "Scene"
const COLUMN_3: String = "Group"
const COLUMN_4: String = "Group Scope"
const UPDATING_MSG: String = "Updating..."
const SINGLE_SEC: String = "second"
const PLURAL_SEC: String = "seconds"
const SINGLE_MIN: String = "minute"
const PLURAL_MIN: String = "minutes"

var last_update: int
var update_timer: int
var is_updating: bool

@onready var group_table: GroupTable = %GroupTable
@onready var update_label: Label = %UpdateLabel
@onready var refresh_button: Button = %RefreshButton


func _ready() -> void:
    _display_table()

    refresh_button.icon = get_theme_icon(&"Reload", &"EditorIcons")
    refresh_button.pressed.connect(_on_refresh_button_pressed)


func _process(_delta: float) -> void:
    if is_updating:
        update_label.text = UPDATING_MSG
        refresh_button.hide()
        return

    refresh_button.show()

    var time_unit: String
    var since_update: int = (Time.get_ticks_msec() - last_update) / 1000

    if since_update < 60:
        time_unit = SINGLE_SEC if since_update == 1 else PLURAL_SEC
    else:
        since_update /= 60
        time_unit = SINGLE_MIN if since_update < 2 else PLURAL_MIN

    if since_update != update_timer:
        update_label.text = "Last updated %d %s ago" % [since_update, time_unit]
        update_timer = since_update


func _display_table() -> void:
    is_updating = true

    var data_frame: DataFrame = _build_frame()
    group_table.render(data_frame)
    last_update = Time.get_ticks_msec()

    is_updating = false


func _on_refresh_button_pressed() -> void:
    _display_table()


func _build_frame() -> DataFrame:
    var new_frame := DataFrame.create([], [COLUMN_1, COLUMN_2, COLUMN_3, COLUMN_4])
    var global_groups: PackedStringArray = _fetch_global_groups()

    for scene_path: String in _fetch_scene_paths():
        var new_rows: Array = _get_grouped_nodes(scene_path, global_groups)

        for row_data: Array in new_rows:
            new_frame.add_row(row_data)

    return new_frame


func _get_grouped_nodes(scene_path: String, global_groups: PackedStringArray) -> Array:
    var grouped_nodes: Array
    var packed_scene: PackedScene = load(scene_path)
    var scene_state: SceneState = packed_scene.get_state()
    var node_count: int = scene_state.get_node_count()

    for i in range(node_count):
        var node_groups: PackedStringArray = scene_state.get_node_groups(i)

        for node_group: String in node_groups:
            var node_name: String = scene_state.get_node_name(i)
            var group_scope: String = GLOBAL_SCOPE if node_group in global_groups else SCENE_SCOPE
            var node_data: Array = [node_name, scene_path, node_group, group_scope]
            grouped_nodes.append(node_data)

    return grouped_nodes


func _load_config(path: String) -> ConfigFile:
    var new_cfg := ConfigFile.new()
    new_cfg.load(path)
    return new_cfg


func _fetch_scene_paths() -> PackedStringArray:
    var scene_cfg: ConfigFile = _load_config(SCENE_CFG)
    var scene_paths: PackedStringArray = scene_cfg.get_sections()
    return scene_paths


func _fetch_global_groups() -> PackedStringArray:
    var global_groups: PackedStringArray
    var global_cfg: ConfigFile = _load_config(GLOBAL_CFG)

    if global_cfg.has_section(GLOBAL_GROUP_SECTION):
        global_groups = global_cfg.get_section_keys(GLOBAL_GROUP_SECTION)

    return global_groups
