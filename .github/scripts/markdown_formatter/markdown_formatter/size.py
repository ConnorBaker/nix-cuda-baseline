from __future__ import annotations

from pydantic import BaseModel

from markdown_formatter.generic.markdown import Markdown
from markdown_formatter.generic import markdown_table


class Size(BaseModel, Markdown):
    bytes: int
    human_readable: str

    _field_to_description: dict[str, str] = {
        "bytes": "Size (B)",
        "human_readable": "Size",
    }

    def markdown(self, level: int = 3, name: str = "Size") -> str:
        body: list[str] = []
        body.append(f"{'#' * level} {name}\n")
        body.append(markdown_table.vertical(self._field_to_description, self))
        body.append("")

        return "\n".join(body)
