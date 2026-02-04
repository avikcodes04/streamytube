import boto3
from db.db import get_db
from db.models.video import Video
from fastapi import APIRouter,Depends, HTTPException
from pydantic_models.upload_models import UploadMetadata
from sqlalchemy.orm import Session
from secret_keys import SecretKeys
from db.middleware.auth_middleware import get_current_user
import uuid



router = APIRouter()
secret_keys = SecretKeys()
s3_client = boto3.client(
    "s3", 
    region_name = secret_keys.REGION_NAME
)

@router.get("/url")
def get_presigned_url(user=Depends(get_current_user)):
    try:
        video_id= f"videos/{user['sub']}/{uuid.uuid4()}.mp4"
        print(video_id)
        response = s3_client.generate_presigned_url(
            "put_object",
            Params={
                "Bucket": secret_keys.AWS_RAW_VIDEOS_BUCKET,        
                "Key": video_id,
                "ContentType": "video/mp4",
            },
        )
        print(response)

        return {"url": response, "video_id": video_id}
    except Exception as e:
        raise HTTPException(500, f"Error generating presigned URL: {str(e)}")
    

@router.get("/url/thumbnail")
def get_presigned_url_thumbnail(video_id: str,user=Depends(get_current_user)):
    try:
        print("RAW video_id:", video_id, type(video_id))

        
        
        thumbnail_id = video_id.replace("videos/", "thumbnails/").replace(".mp4", ".jpg")
        print("RAW video_id:", thumbnail_id, type(thumbnail_id))
        print(thumbnail_id)
        response = s3_client.generate_presigned_url(
            "put_object",
            Params={
                "Bucket": secret_keys.AWS_RAW_THUMBNAILS_BUCKET,        
                "Key": thumbnail_id,
                "ContentType": "image/jpg",
                "ACL":"public-read"
                      
            },
        )
        print(response)

        return {"url": response, "thumbnail_id": thumbnail_id, "upload status ":"its uploading my friend"}
    except Exception as e:
        raise HTTPException(500, f"Error generating presigned URL: {str(e)}")
    
@router.post("/metadata")
def upload_metadata(
    metadata:UploadMetadata,
    user=Depends(get_current_user),
    db:Session=Depends(get_db),
):
    new_video=Video(
    id=metadata.video_id,  
    title=metadata.title,
    description=metadata.description,
    video_s3_key=metadata.video_s3_key,
    visibility=metadata.visibility,
    user_id=user["sub"],
    )

    db.add(new_video)
    db.commit()
    db.refresh(new_video)
    return new_video

