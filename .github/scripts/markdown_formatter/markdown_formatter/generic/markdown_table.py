def header_vertical() -> str:
    """
    Returns a markdown table header with the following format:
    | Name | Value |
    | ---- | ----- |
    """
    return "| Name | Value |\n| ---- | ----- |"


def rows_vertical(field_to_description: dict[str, str], obj: object) -> list[str]:
    """
    Returns a list of markdown table rows with the following format:

    | {description} | {getattr(obj, field)} |

    for each field and description in field_to_description.

    Note that this relies on the field_to_description dict being ordered, which is only true
    for Python 3.7+.

    Args:
        field_to_description (dict[str, str]): A dict mapping field names to descriptions.
        obj (object): The object to get the field values from.
    """
    ret: list[str] = []
    for field, description in field_to_description.items():
        value = getattr(obj, field)
        assert isinstance(
            value, (bool, int, float, str)
        ), "Value must be a primitive type"
        ret.append(f"| {description} | {value} |")

    return ret


def vertical(field_to_description: dict[str, str], obj: object) -> str:
    """
    Returns a markdown table with the following format:
    | Name | Value |
    | ---- | ----- |
    | {description} | {getattr(obj, field)} |

    for each field and description in field_to_description.

    Note that this relies on the field_to_description dict being ordered, which is only true
    for Python 3.7+.

    Args:
        field_to_description (dict[str, str]): A dict mapping field names to descriptions.
        obj (object): The object to get the field values from.
    """
    header = header_vertical()
    rows = "\n".join(rows_vertical(field_to_description, obj))
    table = f"{header}\n{rows}"
    return table


def header_horizontal(field_to_description: dict[str, str]) -> str:
    """
    Returns a markdown table header where each column is a description in field_to_description.

    Note that this relies on the field_to_description dict being ordered, which is only true
    for Python 3.7+.

    Args:
        field_to_description (dict[str, str]): A dict mapping field names to descriptions.
    """
    column_names = list(field_to_description.values())
    column_name_row = "| " + " | ".join(column_names) + " |"
    column_separator_row = "| " + " | ".join(["----"] * len(column_names)) + " |"
    return f"{column_name_row}\n{column_separator_row}"


def row_horizontal(field_to_description: dict[str, str], obj: object) -> str:
    """
    Returns a markdown table row where each column is a value in obj.

    Note that this relies on the field_to_description dict being ordered, which is only true
    for Python 3.7+.

    Args:
        field_to_description (dict[str, str]): A dict mapping field names to descriptions.
        obj (object): The object to get the field values from.
    """
    columns: list[str] = []
    for field in field_to_description.keys():
        value = getattr(obj, field)
        assert isinstance(
            value, (bool, int, float, str)
        ), "Value must be a primitive type"
        columns.append(str(value))

    row = "| " + " | ".join(columns) + " |"
    return row


def horizontal(field_to_description: dict[str, str], obj: object) -> str:
    """
    Returns a markdown table where each column is a value in obj.

    Note that this relies on the field_to_description dict being ordered, which is only true
    for Python 3.7+.

    Args:
        field_to_description (dict[str, str]): A dict mapping field names to descriptions.
        obj (object): The object to get the field values from.
    """
    header = header_horizontal(field_to_description)
    row = row_horizontal(field_to_description, obj)
    table = f"{header}\n{row}"
    return table
