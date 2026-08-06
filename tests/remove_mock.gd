@tool
extends EditorScript


const MOCK_DIR: String = "res://tests/mocks/"
const GLOBAL_CFG_PATH: String = "res://project.godot"
const GLOBAL_GROUP_SECTION: String = "global_group"
const SCENE_CFG_PATH: String = "res://.godot/scene_groups_cache.cfg"


func _run() -> void:
    var temp_dir: DirAccess = DirAccess.open("res://")

    if temp_dir.dir_exists(MOCK_DIR):
        temp_dir.change_dir(MOCK_DIR)

        for filename: String in temp_dir.get_files():
            temp_dir.remove(filename)

    var scene_cfg: ConfigFile = ConfigFile.new()
    scene_cfg.load(SCENE_CFG_PATH)
    scene_cfg.clear()
    scene_cfg.save(SCENE_CFG_PATH)

    var global_cfg: ConfigFile = ConfigFile.new()
    global_cfg.load(GLOBAL_CFG_PATH)
    if global_cfg.has_section(GLOBAL_GROUP_SECTION):
        global_cfg.erase_section(GLOBAL_GROUP_SECTION)
        global_cfg.save(GLOBAL_CFG_PATH)

        EditorInterface.restart_editor(true)
