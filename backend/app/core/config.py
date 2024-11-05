import os
from functools import lru_cache
from pathlib import Path

from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    DATABASE_URL: str
    TEST_DATABASE_URL: str | None = None
    ENVIRONMENT: str = "local"

    model_config = SettingsConfigDict(
        # backend/直下の.env.localを指定
        env_file=str(
            Path(__file__).parent.parent.parent
            / f".env.{os.getenv('ENVIRONMENT', 'local')}"
        ),
        env_file_encoding="utf-8",
        case_sensitive=True,
        extra="allow",
    )


@lru_cache
def get_settings() -> Settings:
    return Settings()


settings = get_settings()
