@tool
extends Control


const GLOBAL_CFG: String = "res://project.godot"
const GLOBAL_GROUP_SECTION: String = "global_group"

const SCENE_CFG: String = "res://.godot/scene_groups_cache.cfg"

const COLUMN_1: String = "Node"
const COLUMN_2: String = "Scene"
const COLUMN_3: String = "Group"
const COLUMN_4: String = "Group Type"

const GLOBAL_GROUP: String = "Global"
const SCENE_GROUP: String = "Scene"

@onready var group_table: GroupTable = %GroupTable

var data_frame: DataFrame
var global_groups: PackedStringArray


func _ready() -> void:
    _build_frame()
    group_table.render(data_frame)


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
            var group_type: String = _type_group(node_group)
            grouped_nodes.append([node_name, scene_path, node_group, group_type])

    return grouped_nodes


# This is a scope, not type
func _type_group(group: String) -> String:
    var group_type: String = SCENE_GROUP

    if group in global_groups:
        group_type = GLOBAL_GROUP

    return group_type


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
