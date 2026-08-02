@tool
class_name GroupTable
extends VBoxContainer


var data_frame: DataFrame


func render(new_frame: DataFrame = null) -> void:
    if new_frame:
        data_frame = new_frame

    if not data_frame:
        return

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
    var new_row: HBoxContainer = HBoxContainer.new()
    return new_row


func _build_header_cell(header: String) -> Button:
    var new_header: Button = Button.new()
    new_header.text = header
    new_header.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    new_header.custom_minimum_size.y = 30
    return new_header


func _build_row_cell(cell_data: String) -> Label:
    var new_cell: Label = Label.new()
    new_cell.text = cell_data
    new_cell.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    new_cell.custom_minimum_size.y = 30
    return new_cell


func _on_header_pressed(header: String) -> void:
    data_frame.sort_by(header)
    render()
