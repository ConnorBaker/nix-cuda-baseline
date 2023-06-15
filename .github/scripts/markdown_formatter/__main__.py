# Formats output of Nix apps from this repository as markdown tables

# ruff: noqa: E501
from __future__ import annotations

import json
from argparse import ArgumentParser, Namespace
from sys import stdin
from typing import Literal, get_args

from markdown_formatter.apps.conda import Conda
from markdown_formatter.apps.docker import DockerImage
from markdown_formatter.apps.nix_binary_cache import NixBinaryCache
from markdown_formatter.apps.nix_store import NixStore

App = Literal["Conda", "DockerImage", "NixBinaryCache", "NixStore"]


def main(args: Namespace) -> None:
    app: App = args.app
    batched: bool = args.batched
    include_time: bool = args.include_time
    level: int = args.level
    match app:
        case "Conda":
            data: Conda = Conda.parse_raw(stdin.read())
            print(data.markdown(include_time=include_time, level=level))
        case "DockerImage":
            data: DockerImage = DockerImage.parse_raw(stdin.read())
            print(data.markdown(include_time=include_time, level=level))
        case "NixBinaryCache":
            if batched:
                objs = json.load(stdin)
                assert isinstance(objs, list)
                assert len(objs) > 0
                array = list(map(NixBinaryCache.parse_obj, objs))
                print(
                    NixBinaryCache.markdown_batch(
                        array=array, include_time=include_time, level=level
                    )
                )
            else:
                data: NixBinaryCache = NixBinaryCache.parse_raw(stdin.read())
                print(data.markdown(include_time=include_time, level=level))

        case "NixStore":
            data: NixStore = NixStore.parse_raw(stdin.read())
            print(data.markdown(include_time=include_time, level=level))
        case _:
            raise ValueError(f"Invalid app: {app}")


if __name__ == "__main__":
    parser = ArgumentParser(
        description="Format output of Nix apps as markdown tables -- reads from stdin and writes to stdout"
    )
    parser.add_argument("--app", choices=get_args(App), type=str, required=True)
    parser.add_argument(
        "--batched",
        action="store_true",
        help="Whether to read a JSON array of objects from a particular App and create horizontal tables rather than a single vertical table (only applicable to NixBinaryCache))",
    )
    parser.add_argument(
        "--include-time",
        action="store_true",
        help="Whether to include time information",
    )
    parser.add_argument(
        "--level", type=int, default=2, help="How many levels of headers to include"
    )

    args: Namespace = parser.parse_args()
    main(args)
