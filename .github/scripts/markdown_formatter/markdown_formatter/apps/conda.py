from __future__ import annotations

from pydantic import BaseModel

from markdown_formatter.generic.markdown import Markdown
from markdown_formatter.size import Size
from markdown_formatter.time import Time


class Conda(BaseModel, Markdown):
    sizes: Conda.Sizes
    time: Time

    _field_to_description: dict[str, str] = {
        "size": "Conda Size",
        "time": "Time",
    }

    def markdown(
        self,
        level: int = 2,
        include_time: bool = False,
        name: str = "Conda",
    ) -> str:
        body: list[str] = []
        body.append(f"{'#' * level} {name}\n")

        body.append(self.sizes.markdown(level=level + 1))

        if include_time:
            body.append(self.time.markdown(level=level + 1))

        return "\n".join(body)

    class Sizes(BaseModel):
        environment: Size
        packages: Size
        packages_compressed: Size

        _field_to_description: dict[str, str] = {
            "environment": "Environment",
            "packages": "Packages",
            "packages_compressed": "Packages (compressed files)",
        }

        def markdown(
            self,
            level=3,
        ) -> str:
            body: list[str] = []
            body.append(f"{'#' * level} Size\n")
            for field, description in self._field_to_description.items():
                value: Size = getattr(self, field)
                body.append(value.markdown(level=level + 1, name=description))

            return "\n".join(body)
