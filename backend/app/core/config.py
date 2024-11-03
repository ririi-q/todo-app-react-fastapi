from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    DATABASE_URL: str = "postgresql://postgres:postgres@localhost:5432/postgres"
    TEST_DATABASE_URL: str = "postgresql://postgres:postgres@localhost:5432/test"


settings = Settings()
