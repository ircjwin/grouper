@tool
class_name GroupTable
extends Control


@onready var row: PackedScene = preload("res://addons/grouper/gui/row.tscn")
@onready var header_cell: PackedScene = preload("res://addons/grouper/gui/header_cell.tscn")
@onready var row_cell: PackedScene = preload("res://addons/grouper/gui/row_cell.tscn")
@onready var header_container: VBoxContainer = %HeaderContainer
@onready var row_container: VBoxContainer = %RowContainer
@onready var updown_icon: Texture2D = get_theme_icon(&"GuiSpinboxUpdown", &"EditorIcons")
@onready var asc_icon: Texture2D = get_theme_icon(&"GuiSpinboxUp", &"EditorIcons")
@onready var desc_icon: Texture2D = get_theme_icon(&"GuiSpinboxDown", &"EditorIcons")

var data_frame: DataFrame
var last_sort: String
var is_desc: bool


func render(new_frame: DataFrame) -> void:
    _clear()
    
    data_frame = new_frame

    var header_row: HBoxContainer = _build_row()
    header_container.add_child(header_row)
    header_container.move_child(header_row, 0)

    for header: String in data_frame.get_all_columns():
        var header_cell: Button = _build_header_cell(header)
        header_row.add_child(header_cell)
        header_cell.pressed.connect(_on_header_pressed.bind(header))

    for row_data in data_frame.get_all_rows():
        var row: HBoxContainer = _build_row()
        row_container.add_child(row)

        for cell_data: String in row_data:
            var row_cell: Label = _build_row_cell(cell_data)
            row.add_child(row_cell)


func _clear() -> void:
    data_frame = null
    last_sort = ""
    is_desc = false

    header_container.get_children().map(func(x): if x is HBoxContainer: x.queue_free())
    row_container.get_children().map(func(x): x.queue_free())


func _build_row() -> HBoxContainer:
    var new_row: HBoxContainer = row.instantiate()
    return new_row


func _build_header_cell(header: String) -> Button:
    var new_header: Button = header_cell.instantiate()
    new_header.text = header
    new_header.icon = updown_icon
    return new_header


func _build_row_cell(cell_data: String) -> Label:
    var new_cell: Label = row_cell.instantiate()
    new_cell.text = cell_data
    return new_cell


func _reorder() -> void:
    for idx: int in range(row_container.get_child_count()):
        var frame_row: Array = data_frame.get_row(idx)
        var table_row: HBoxContainer = row_container.get_child(idx)

        for idx_1: int in range(table_row.get_child_count()):
            var row_cell: Label = table_row.get_child(idx_1)
            row_cell.text = frame_row[idx_1]


func _change_header_icon(header: String, icon: Texture2D = null) -> void:
    var header_icon: Texture2D

    if icon:
        header_icon = icon
    else:
        header_icon = desc_icon if is_desc else asc_icon

    var header_idx: int = data_frame.get_column_index(header)
    var header_button: Button = header_container.get_child(0).get_child(header_idx)
    header_button.icon = header_icon


func _on_header_pressed(header: String) -> void:
    if header == last_sort:
        is_desc = not is_desc
        _change_header_icon(header)
    else:
        if last_sort:
            _change_header_icon(last_sort, updown_icon)

        is_desc = false
        _change_header_icon(header)
        last_sort = header

    data_frame.sort_by(header, is_desc)
    _reorder()
