from datetime import timedelta,datetime,timezone
from jose import jwt,JWTError
from app.core.config import settings

def create_access_token(data:dict,expires_delta:timedelta | None = None):
    payload = data.copy()
    expire = datetime.now(timezone.utc)+(expires_delta or timedelta(minutes=settings.access_token_expire_minutes))
    payload.update({"exp":expire})
    encoded_jwt = jwt.encode(payload,settings.secret_key,algorithm=settings.algorithm)
    return encoded_jwt

def decode_access_token(token:str)->str | None:
    try:
        payload=jwt.decode(token,settings.secret_key,algorithms=[settings.algorithm])
        id  = payload.get("sub")
        if id is None:
            return None
        return int(id)
    except JWTError as e:
        return None