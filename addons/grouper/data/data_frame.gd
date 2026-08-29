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
    var row_count: int = len(data)
    return row_count


func get_column_count() -> int:
    var column_count: int = len(columns)
    return column_count


func get_row(idx: int) -> Array:
    var row: Array = data[idx]
    return row


func get_column(column_title: String) -> Array:
    var column_idx: int = get_column_index(column_title)
    var column: Array = []

    for row in data:
        var column_data: String = row[column_idx]
        column.append(column_data)

    return column


func get_column_index(column_title: String) -> int:
    var column_idx: int = columns.find(column_title)
    return column_idx


func get_all_rows() -> Array:
    return data


func get_all_columns() -> PackedStringArray:
    return columns


func add_row(new_data: Array) -> void:
    data.append(new_data)


func add_column(column_data: Array, column_title: String) -> void:
    columns.append(column_title)
    var row_count: int = get_row_count()

    for i in range(row_count):
        data[i].append(column_data[i])


func sort_by(column: String, is_desc: bool = false) -> void:
    var column_idx: int = get_column_index(column)
    data.sort_custom(_column_sort.bind(column_idx, is_desc))


func _column_sort(row_1: Array, row_2: Array, idx: int, is_desc: bool) -> bool:
    # Workaround for known issue: https://github.com/godotengine/godot/issues/49618
    if row_1[idx] == row_2[idx]:
        return false

    var result: bool = false

    if row_1[idx] < row_2[idx]:
        result = true

    if is_desc:
        result = not result

    return result
