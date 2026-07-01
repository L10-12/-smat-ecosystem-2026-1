from pydantic import BaseModel
from typing import Optional
from datetime import datetime

#--------------Clase para Estaciones--------------
class EstacionCreate(BaseModel):
    id: int
    nombre: str
    ubicacion: str


#--------------Clase para Lecturas--------------
class LecturaCreate(BaseModel):
    estacion_id: int
    valor: float
    fecha: Optional[datetime] = None
  
  
  #--------------Clase para Inicio de Sesión--------------  
class LoginPayload(BaseModel):
    username: str
    password: str
