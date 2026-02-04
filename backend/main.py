from fastapi import FastAPI, Depends, Query
from fastapi.middleware.cors import CORSMiddleware
from routes import auth, upload, video
from db.db import engine, get_db
from db.base import Base
from sqlalchemy.orm import Session

app = FastAPI()

origins = ["http://localhost", "http:localhost:3000"]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


app.include_router(auth.router, prefix="/auth")
app.include_router(upload.router, prefix="/upload/video")
app.include_router(video.router, prefix="/video")

@app.get("/")
def root():
    return "hello, aviks"

Base.metadata.create_all(engine)  # Create tables at startup