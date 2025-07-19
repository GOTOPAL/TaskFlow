from pydantic import BaseModel

class TaskOut(BaseModel):
    context :str
    description: str
    status: str
    priority: int

    model_config = {
        "from_attributes" : True
    }