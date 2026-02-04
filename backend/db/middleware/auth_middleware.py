import boto3
from fastapi import HTTPException,Cookie
from secret_keys import SecretKeys
cognito_client = boto3.client("cognito-idp", region_name=SecretKeys().REGION_NAME)


def _get_user_from_cognito(access_token: str):
    try:
        user_response = cognito_client.get_user(
            AccessToken=access_token
        )   
        # return user_response
        return {
            attr['Name']: attr['Value'] for attr in user_response.get('UserAttributes', [])
            
        }
    except Exception as e:
        raise HTTPException(500, f"Invalid access token: {str(e)}")
    

def get_current_user(access_token: str = Cookie(None)):
    if not access_token:
        raise HTTPException(401, "Access token is required")
    print(access_token)
    user_info = _get_user_from_cognito(access_token)
    return user_info