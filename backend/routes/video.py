import json
from db.models.video import ProcessingStatus, Video, VisibilityStatus
from fastapi import APIRouter, HTTPException, Depends, Query
from db.db import get_db
from sqlalchemy.orm import Session
from sqlalchemy import or_
from db.middleware.auth_middleware import get_current_user
from typing import Optional
import sys

from db.redis_db import redis_client


router = APIRouter()


@router.get("/")
def get_video_by_query(
    video_id: Optional[str] = Query(None, description="Video ID to retrieve"),
    db: Session = Depends(get_db), 
    user=Depends(get_current_user)
):
    """Get a specific video by ID using query parameter"""
    print("Hiiiiiiiiiiiiiiiiiiiiiiiiiiiii")
    if video_id:
        # Strip whitespace from video_id to handle URL encoding issues
        video_id = video_id.strip()
        video = db.query(Video).filter(Video.id == video_id).first()
        if not video:
            raise HTTPException(status_code=404, detail="Video not found")
        return video
    else:
        raise HTTPException(status_code=400, detail="video_id query parameter is required")


@router.get("/all")
def get_all_videos(db: Session = Depends(get_db), user=Depends(get_current_user)):

    all_videos = db.query(Video).filter(
    Video.is_processing == ProcessingStatus.COMPLETED,
    Video.visibility==VisibilityStatus.PUBLIC
    ).all()
    print(all_videos)

    return all_videos

@router.get("/{video_id:path}")
def get_video_info(video_id: str, db: Session = Depends(get_db), user=Depends(get_current_user)):
    # Strip whitespace from video_id to handle URL encoding issues
    video_id = video_id.strip()
    print(f"DEBUG: Function called with video_id='{video_id}'", flush=True)
    sys.stdout.flush()

    cached_key = f"video:{video_id}"
    cached_data = redis_client.get(video_id)

    if cached_data:
        return json.loads(cached_data)
    
    video = db.query(Video).filter(
        Video.id == video_id,
        # Video.is_processing == ProcessingStatus.COMPLETED,  # Allow videos even if still processing
        or_(
            Video.visibility == VisibilityStatus.PUBLIC,
            Video.visibility == VisibilityStatus.UNLISTED
        )  
    ).first()


    
    print(f"DEBUG: Video query result: {video}", flush=True)
    sys.stdout.flush()

    if not video:
        print(f"DEBUG: Video not found for id '{video_id}'", flush=True)
        sys.stdout.flush()
        raise HTTPException(status_code=404, detail=f"Video with id '{video_id}' not found")
    
    print(f"DEBUG: Returning video: {video.id}", flush=True)
    sys.stdout.flush()

    print(f"DEBUG: Video dict: {video.to_dict()}", flush=True)
    sys.stdout.flush()
    


    redis_client.setex(cached_key, 3600, json.dumps(video.to_dict()))
    return video


@router.put("/")
def update_video_by_id(id: str, db: Session = Depends(get_db)):
    # Try to find video by ID first
    video = db.query(Video).filter(Video.id == id).first()
    
    # If not found by ID, try to find by video_s3_key as fallback
    if not video:
        video = db.query(Video).filter(Video.video_s3_key == id).first()

    if not video:
        raise HTTPException(status_code=404, detail=f"Video with id '{id}' not found")

    video.is_processing = ProcessingStatus.COMPLETED
    db.commit()
    db.refresh(video)

    return video






