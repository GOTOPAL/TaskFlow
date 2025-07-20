from pydantic import BaseModel
from typing import Optional
class TaskOut(BaseModel):
    id : int
    context :str
    description: str
    status: str
    priority: int
    category_id : int
    model_config = {
        "from_attributes" : True
    }

class AddTask(BaseModel):
    context:str
    description:str
    status:str
    priority:int
    category_id : int 

class UpdateTask(BaseModel):
    context: Optional[str] = None
    description: Optional[str] = None
    status: Optional[str] = None
    priority: Optional[int] = None
    category_id: Optional[int] = None