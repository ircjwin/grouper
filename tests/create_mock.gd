@tool
extends EditorScript


const SCENE_MAX: int = 20
const NODE_CHILD_MAX: int = 3
const NODE_GROUP_MAX: int = 4
const GLOBAL_GROUP_MAX: int = 5

const MOCK_DIR: String = "res://tests/mocks/"
const SCENE_SUFFIX: String = ".tscn"
const GLOBAL_CFG_PATH: String = "res://project.godot"
const GLOBAL_GROUP_SECTION: String = "global_group"

var whitelist: Resource = preload("res://tests/whitelist.gd").new()
var node_names: Array[String] = whitelist.node_names
var group_names: Array[String] = whitelist.group_names
var node_groups: Array


func _run() -> void:
    var temp_dir: DirAccess = DirAccess.open("res://")
    if not temp_dir.dir_exists(MOCK_DIR):
        temp_dir.make_dir(MOCK_DIR)

    _build_mock()

    var global_groups: Array = _select_global_groups()
    if global_groups:
        _register_global_groups(global_groups)
        EditorInterface.restart_editor(true)


func _select_global_groups() -> Array:
    var adj_max: int = clampi(GLOBAL_GROUP_MAX, 0, len(node_groups))
    var global_groups: Array = []

    for _i: int in range(adj_max):
        var global_group: String

        while true:
            global_group = node_groups.pick_random()

            if not global_groups.has(global_group):
                break

        global_groups.append(global_group)

    return global_groups


func _register_global_groups(global_groups: Array) -> void:
    var global_cfg: ConfigFile = ConfigFile.new()
    global_cfg.load(GLOBAL_CFG_PATH)

    for global_group: String in global_groups:
        global_cfg.set_value(GLOBAL_GROUP_SECTION, global_group, "")

    global_cfg.save(GLOBAL_CFG_PATH)


func _build_mock() -> void:
    node_names.shuffle()

    for _i: int in range(SCENE_MAX):
        var node: Node = _create_node(node_names.pop_back())

        for _j: int in range(_roll(NODE_CHILD_MAX)):
            _create_child(node_names.pop_back(), node)

        _create_scene(node)


func _roll(rand_max: int = 1) -> int:
    return randi() % rand_max


func _create_node(name: String) -> Node:
    var adj_max: int = clampi(NODE_GROUP_MAX, 0, len(group_names))
    var node: Node = Node.new()
    node.name = name

    for _i: int in range(_roll(adj_max)):
        var node_group: String

        while true:
            node_group = group_names.pick_random()

            if not node.is_in_group(node_group):
                break

        if not node_groups.has(node_group):
            node_groups.append(node_group)

        node.add_to_group(node_group, true)

    return node


func _create_child(name: String, parent: Node, owner: Node = null) -> Node:
    var node: Node = _create_node(name)
    parent.add_child(node)
    node.owner = owner if owner else parent
    return node


func _create_scene(root: Node) -> void:
    var packed_node: PackedScene = PackedScene.new()
    packed_node.pack(root)
    ResourceSaver.save(packed_node, MOCK_DIR + root.name.to_lower() + SCENE_SUFFIX)
