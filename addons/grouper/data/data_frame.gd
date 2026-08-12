@tool
extends Resource


var data: Array
var columns: PackedStringArray


static func create(new_data: Array, new_columns: PackedStringArray) -> Resource:
    var data_frame = new()
    data_frame.data = new_data
    data_frame.columns = new_columns
    return data_frame


func get_row_count() -> int:
    return len(data)


func get_column_count() -> int:
    return len(columns)


func get_row(idx: int) -> Array:
    return data[idx]


func get_column(column_title: String) -> Array:
    var idx: int = columns.find(column_title)
    var column: Array = []

    for row in data:
        column.append(row[idx])

    return column


func get_column_index(column_title: String) -> int:
    return columns.find(column_title)


func get_all_rows() -> Array:
    return data


func get_all_columns() -> PackedStringArray:
    return columns


func add_row(new_data: Array) -> void:
    data.append(new_data)


func add_column(column_data: Array, column_title: String) -> void:
    columns.append(column_title)

    for idx: int in range(len(data)):
        data[idx].append(column_data[idx])


func sort_by(column: String, is_desc: bool = false) -> void:
    var idx: int = columns.find(column)
    data.sort_custom(_column_sort.bind(idx, is_desc))


func _column_sort(row_1: Array, row_2: Array, idx: int, is_desc: bool) -> bool:
    # Workaround for: https://github.com/godotengine/godot/issues/49618
    if row_1[idx] == row_2[idx]:
        return false

    var result: bool = false

    if row_1[idx] < row_2[idx]:
        result = true

    if is_desc:
        result = not result

    return result
