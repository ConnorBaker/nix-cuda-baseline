from __future__ import annotations

from pydantic import BaseModel

from markdown_formatter.generic.markdown import Markdown
from markdown_formatter.generic import markdown_table


class Time(BaseModel, Markdown):
    io: Time.IO
    memory: Time.Memory
    time: Time.Time

    _field_to_description: dict[str, str] = {
        "io": "IO",
        "memory": "Memory",
        "time": "Time",
    }

    def markdown(self, level: int = 3, name: str = "Time") -> str:
        body: list[str] = []
        body.append(f"{'#' * level} {name}\n")

        subsection_prefix = "#" * (level + 1)
        for field, description in self._field_to_description.items():
            value = getattr(self, field)
            body.append(f"{subsection_prefix} {description}\n")
            body.append(markdown_table.vertical(value._field_to_description, value))
            body.append("")

        return "\n".join(body)

    class IO(BaseModel):
        commands_issued: str
        exit_status: int
        fs_inputs: int
        fs_outputs: int
        signals_delivered: int
        socket_messages_received: int
        socket_messages_sent: int

        _field_to_description: dict[str, str] = {
            "commands_issued": "Commands Issued",
            "exit_status": "Exit Status",
            "fs_inputs": "Filesystem Inputs",
            "fs_outputs": "Filesystem Outputs",
            "signals_delivered": "Signals Delivered",
            "socket_messages_received": "Socket Messages Received",
            "socket_messages_sent": "Socket Messages Sent",
        }

    class Memory(BaseModel):
        average_resident_set_size_kbytes: int
        average_shared_text_size_kbytes: int
        average_total_memory_use_kbytes: int
        average_unshared_data_size_kbytes: int
        average_unshared_stack_size_kbytes: int
        context_switches_involuntary: int
        context_switches_voluntary: int
        maximum_resident_set_size_kbytes: int
        page_faults_major: int
        page_faults_minor: int
        swaps: int
        system_page_size_bytes: int

        _field_to_description: dict[str, str] = {
            "average_resident_set_size_kbytes": "Average Resident Set Size (KB)",
            "average_shared_text_size_kbytes": "Average Shared Text Size (KB)",
            "average_total_memory_use_kbytes": "Average Total Memory Use (KB)",
            "average_unshared_data_size_kbytes": "Average Unshared Data Size (KB)",
            "average_unshared_stack_size_kbytes": "Average Unshared Stack Size (KB)",
            "context_switches_involuntary": "Context Switches (Involuntary)",
            "context_switches_voluntary": "Context Switches (Voluntary)",
            "maximum_resident_set_size_kbytes": "Maximum Resident Set Size (KB)",
            "page_faults_major": "Page Faults (Major)",
            "page_faults_minor": "Page Faults (Minor)",
            "swaps": "Swaps",
            "system_page_size_bytes": "System Page Size (B)",
        }

    class Time(BaseModel):
        elapsed_kernel_seconds: float
        elapsed_real_seconds: float
        elapsed_user_seconds: float
        percent_cpu: str

        _field_to_description: dict[str, str] = {
            "elapsed_kernel_seconds": "Elapsed Kernel Seconds",
            "elapsed_real_seconds": "Elapsed Real Seconds",
            "elapsed_user_seconds": "Elapsed User Seconds",
            "percent_cpu": "Percent CPU",
        }
