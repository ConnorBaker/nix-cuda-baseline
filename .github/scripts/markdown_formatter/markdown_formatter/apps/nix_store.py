from __future__ import annotations

from pydantic import BaseModel

from markdown_formatter.generic.markdown import Markdown
from markdown_formatter.generic.markdown_size_time import size_time
from markdown_formatter.size import Size
from markdown_formatter.time import Time


class NixStore(BaseModel, Markdown):
    size: Size
    time: Time

    _field_to_description: dict[str, str] = {
        "size": "Size",
        "time": "Time",
    }

    def markdown(
        self,
        include_time: bool = False,
        level: int = 2,
        name: str = "Nix Store",
    ) -> str:
        return size_time(
            field_to_description=self._field_to_description,
            include_time=include_time,
            level=level,
            name=name,
            obj=self,
        )
