@tool
extends Control


const GLOBAL_CFG: String = "res://project.godot"
const GLOBAL_GROUP_SECTION: String = "global_group"

const SCENE_CFG: String = "res://.godot/scene_groups_cache.cfg"

const COLUMN_1: String = "Node"
const COLUMN_2: String = "Scene"
const COLUMN_3: String = "Group"
const COLUMN_4: String = "Group Scope"

const SINGLE_SEC: String = "second"
const PLURAL_SEC: String = "seconds"
const SINGLE_MIN: String = "minute"
const PLURAL_MIN: String = "minutes"

const GLOBAL_GROUP: String = "Global"
const SCENE_GROUP: String = "Scene"

const DataFrame = preload("res://addons/grouper/data/data_frame.gd")
const GroupTable = preload("res://addons/grouper/gui/group_table.gd")

@onready var group_table: GroupTable = %GroupTable
@onready var update_label: Label = %UpdateLabel
@onready var refresh_button: Button = %RefreshButton

# Doesn't seem like this script needs a local DataFrame
var data_frame: DataFrame
var global_groups: PackedStringArray
var last_update: int
var is_updating: bool
var current_time: int


func _ready() -> void:
    _display_table()

    refresh_button.icon = get_theme_icon(&"Reload", &"EditorIcons")
    refresh_button.pressed.connect(_on_refresh_button_pressed)


func _process(_delta: float) -> void:
    if is_updating:
        update_label.text = "Updating..."
        refresh_button.hide()
        return

    refresh_button.show()

    var time_since: int
    var time_unit: String
    var since_update: int = (Time.get_ticks_msec() - last_update) / 1000

    if since_update < 60:
        time_since = since_update

        if time_since == 1:
            time_unit = SINGLE_SEC
        else:
            time_unit = PLURAL_SEC
    else:
        time_since = since_update / 60

        if time_since < 2:
            time_unit = SINGLE_MIN
        else:
            time_unit = PLURAL_MIN

    if time_since != current_time:
        update_label.text = "Last updated %d %s ago" % [time_since, time_unit]
        current_time = time_since


func _display_table() -> void:
    is_updating = true

    _build_frame()
    group_table.render(data_frame)
    last_update = Time.get_ticks_msec()

    is_updating = false


func _on_refresh_button_pressed() -> void:
    _display_table()


func _build_frame() -> void:
    data_frame = DataFrame.create([], [COLUMN_1, COLUMN_2, COLUMN_3, COLUMN_4])
    global_groups = _fetch_global_groups()

    for scene_path: String in _fetch_scene_paths():
        var new_rows: Array = _get_grouped_nodes(scene_path)
        for new_row: Array in new_rows:
            data_frame.add_row(new_row)


func _get_grouped_nodes(scene_path: String) -> Array:
    var grouped_nodes: Array
    var packed_scene: PackedScene = load(scene_path)
    var scene_state: SceneState = packed_scene.get_state()
    var node_count: int = scene_state.get_node_count()

    for node_idx: int in range(node_count):
        var node_groups: PackedStringArray = scene_state.get_node_groups(node_idx)

        for node_group: String in node_groups:
            var node_name: String = scene_state.get_node_name(node_idx)
            var group_scope: String = _get_group_scope(node_group)
            grouped_nodes.append([node_name, scene_path, node_group, group_scope])

    return grouped_nodes


func _get_group_scope(group: String) -> String:
    var group_scope: String = SCENE_GROUP

    if group in global_groups:
        group_scope = GLOBAL_GROUP

    return group_scope


func _load_config(path: String) -> ConfigFile:
    var new_cfg: ConfigFile = ConfigFile.new()
    new_cfg.load(path)
    return new_cfg


func _fetch_scene_paths() -> PackedStringArray:
    var scene_cfg: ConfigFile = _load_config(SCENE_CFG)
    return scene_cfg.get_sections()


func _fetch_global_groups() -> PackedStringArray:
    var global_groups: PackedStringArray
    var global_cfg: ConfigFile = _load_config(GLOBAL_CFG)

    if global_cfg.has_section(GLOBAL_GROUP_SECTION):
        global_groups = global_cfg.get_section_keys(GLOBAL_GROUP_SECTION)

    return global_groups
