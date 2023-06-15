# Create a Markdown section for a simple object with only size and time fields

from markdown_formatter.generic.markdown import Markdown
from markdown_formatter.time import Time


def size_time(
    field_to_description: dict[str, str],
    name: str,
    obj: object,
    include_time: bool = False,
    level: int = 2,
) -> str:
    body: list[str] = []
    body.append(f"{'#' * level} {name}\n")
    for field, description in field_to_description.items():
        value: Markdown = getattr(obj, field)
        assert isinstance(value, Markdown)
        if not isinstance(value, Time) or include_time:
            body.append(value.markdown(level=level + 1, name=description))

    return "\n".join(body)
