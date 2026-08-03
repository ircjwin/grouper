@tool
class_name GroupTable
extends VBoxContainer


@onready var row: PackedScene = preload("res://addons/grouper/gui/row.tscn")
@onready var header_cell: PackedScene = preload("res://addons/grouper/gui/header_cell.tscn")
@onready var row_cell: PackedScene = preload("res://addons/grouper/gui/row_cell.tscn")

var data_frame: DataFrame


func render(new_frame: DataFrame) -> void:
    data_frame = new_frame

    get_children().map(func(x): x.queue_free())

    var table_header_row: HBoxContainer = _build_row()
    add_child(table_header_row)

    for header: String in data_frame.get_all_columns():
        var table_header_cell: Button = _build_header_cell(header)
        table_header_row.add_child(table_header_cell)
        table_header_cell.pressed.connect(_on_header_pressed.bind(header))

    for row_data in data_frame.get_all_rows():
        var table_row: HBoxContainer = _build_row()
        add_child(table_row)

        for cell_data: String in row_data:
            var table_row_cell: Label = _build_row_cell(cell_data)
            table_row.add_child(table_row_cell)


func _build_row() -> HBoxContainer:
    var new_row: HBoxContainer = row.instantiate()
    return new_row


func _build_header_cell(header: String) -> Button:
    var new_header: Button = header_cell.instantiate()
    new_header.text = header
    return new_header


func _build_row_cell(cell_data: String) -> Label:
    var new_cell: Label = row_cell.instantiate()
    new_cell.text = cell_data
    return new_cell


func _reorder() -> void:
    for idx: int in range(get_child_count() - 1):
        var frame_row: Array = data_frame.get_row(idx)
        var table_row: Node = get_child(idx + 1)

        for idx_1: int in range(table_row.get_child_count()):
            var row_cell: Label = table_row.get_child(idx_1)
            row_cell.text = frame_row[idx_1]


func _on_header_pressed(header: String) -> void:
    data_frame.sort_by(header)
    _reorder()
