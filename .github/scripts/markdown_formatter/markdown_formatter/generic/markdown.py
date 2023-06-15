from abc import ABC, abstractmethod

class Markdown(ABC):
    @abstractmethod
    def markdown(self, level: int = 1, name: str = "") -> str:
        pass