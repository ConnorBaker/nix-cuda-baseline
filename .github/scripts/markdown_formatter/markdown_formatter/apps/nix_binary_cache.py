from __future__ import annotations

from pydantic import BaseModel

from typing import Literal

from markdown_formatter.generic.markdown import Markdown
from markdown_formatter.generic import markdown_table
from markdown_formatter.generic.markdown_size_time import size_time
from markdown_formatter.size import Size
from markdown_formatter.time import Time


class NixBinaryCache(BaseModel, Markdown):
    meta: NixBinaryCache.Meta
    size: Size
    time: Time

    _field_to_description: dict[str, str] = {
        "meta": "Meta",
        "size": "Size",
        "time": "Time",
    }

    class Meta(BaseModel, Markdown):
        compression: Literal["xz", "bzip2", "gzip", "zstd", "none"]
        compression_level: int
        parallel_compression: bool

        _field_to_description: dict[str, str] = {
            "compression": "Compression",
            "compression_level": "Compression Level",
            "parallel_compression": "Parallel Compression",
        }

        def markdown(
            self,
            level: int = 3,
            name: str = "Meta",
        ) -> str:
            body: list[str] = []
            body.append(f"{'#' * level} {name}\n")
            body.append(markdown_table.vertical(self._field_to_description, self))
            body.append("")

            return "\n".join(body)

    def markdown(
        self,
        include_time: bool = False,
        level: int = 2,
        name: str = "Nix Binary Cache",
    ) -> str:
        return size_time(
            field_to_description=self._field_to_description,
            include_time=include_time,
            level=level,
            name=name,
            obj=self,
        )

    @classmethod
    def markdown_batch(
        cls,
        array: list[NixBinaryCache],
        include_time: bool = True,
        level: int = 2,
    ) -> str:
        """
        In batch mode, Meta augments the size and each of the time components.
        """
        first = array[0]
        section_name = f"Nix Binary Cache Batch ({first.meta.compression})"

        size: list[str] = []
        (
            pre_meta_size_header,
            pre_meta_size_separator,
        ) = markdown_table.header_horizontal(first.size._field_to_description).split(
            "\n"
        )
        meta_header, meta_seprarator = markdown_table.header_horizontal(
            first.meta._field_to_description
        ).split("\n")
        meta_size_header = (
            meta_header.removesuffix(" |")
            + " | "
            + pre_meta_size_header.removeprefix("| ")
        )
        meta_size_separator = (
            meta_seprarator.removesuffix(" |")
            + " | "
            + pre_meta_size_separator.removeprefix("| ")
        )
        size.append(f"{meta_size_header}\n{meta_size_separator}")

        time: dict[str, list[str]] = {
            name: [] for name in first.time._field_to_description.keys()
        }
        if include_time:
            for name in time.keys():
                time_component = getattr(first.time, name)
                field_to_description = time_component._field_to_description
                (
                    pre_meta_time_component_header,
                    pre_meta_time_component_separator,
                ) = markdown_table.header_horizontal(field_to_description).split("\n")
                meta_time_component_header = (
                    meta_header.removesuffix(" |")
                    + " | "
                    + pre_meta_time_component_header.removeprefix("| ")
                )
                meta_time_component_separator = (
                    meta_seprarator.removesuffix(" |")
                    + " | "
                    + pre_meta_time_component_separator.removeprefix("| ")
                )
                time[name].append(
                    f"{meta_time_component_header}\n{meta_time_component_separator}"
                )

        for nbc in array:
            meta_row = markdown_table.row_horizontal(
                nbc.meta._field_to_description, nbc.meta
            )
            pre_meta_size_row = markdown_table.row_horizontal(
                nbc.size._field_to_description, nbc.size
            )
            meta_size_row = (
                meta_row.removesuffix(" |")
                + " | "
                + pre_meta_size_row.removeprefix("| ")
            )
            size.append(meta_size_row)

            if include_time:
                for name in time.keys():
                    time_component = getattr(nbc.time, name)
                    field_to_description = time_component._field_to_description
                    pre_meta_time_component_row = markdown_table.row_horizontal(
                        field_to_description, time_component
                    )
                    meta_time_component_row = (
                        meta_row.removesuffix(" |")
                        + " | "
                        + pre_meta_time_component_row.removeprefix("| ")
                    )
                    time[name].append(meta_time_component_row)

        body: list[str] = []
        section_prefix = "#" * level
        subsection_prefix = "#" * (level + 1)
        subsubsection_prefix = "#" * (level + 2)

        body.append(f"{section_prefix} {section_name}\n")
        body.append(f"{subsection_prefix} Size\n")
        body.append("\n".join(size))
        body.append("")

        if include_time:
            body.append(f"{subsection_prefix} Time\n")
            for name, values in time.items():
                body.append(
                    f"{subsubsection_prefix} {first.time._field_to_description[name]}\n"
                )
                body.append("\n".join(values))
                body.append("")

        return "\n".join(body)
