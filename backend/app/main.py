from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.api.v1 import router as v1_router

app = FastAPI(title="Todo API", description="A simple todo API", version="1.0.0")

# CORSの設定
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# v1のルーターを登録
app.include_router(v1_router, prefix="/api/v1")


@app.get("/health")
def health():
    print("health check")
    return {"status": "ok"}
