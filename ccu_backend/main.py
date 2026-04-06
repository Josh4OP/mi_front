from fastapi import FastAPI, File, UploadFile
from fastapi.responses import JSONResponse
from fastapi.staticfiles import StaticFiles
from pydantic import BaseModel, EmailStr
import json
import shutil
import os
from typing import List, Optional

app = FastAPI(title="CCU FastAPI")

from fastapi.middleware.cors import CORSMiddleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

USERS_FILE = "users.json"
UPLOAD_DIR = os.path.join("uploads", "profile_pics")

os.makedirs(UPLOAD_DIR, exist_ok=True)

app.mount("/uploads", StaticFiles(directory="uploads"), name="uploads")

class UserRegister(BaseModel):
    name: str
    email: EmailStr
    password: str

class UserLogin(BaseModel):
    email: EmailStr
    password: str

class UserChangePassword(BaseModel):
    email: EmailStr
    currentPassword: str
    newPassword: str

def read_users():
    try:
        if not os.path.exists(USERS_FILE):
            return []
        with open(USERS_FILE, "r", encoding="utf-8") as f:
            return json.load(f)
    except:
        return []

def write_users(users):
    with open(USERS_FILE, "w", encoding="utf-8") as f:
        json.dump(users, f, indent=2, ensure_ascii=False)

@app.post("/register")
async def register(user: UserRegister):
    users = read_users()
    if any(u["email"] == user.email for u in users):
        return JSONResponse(status_code=400, content={"success": False, "message": "El usuario ya existe"})
    
    new_user = {
        "name": user.name, 
        "email": user.email, 
        "password": user.password, 
        "profile_pic": None
    }
    users.append(new_user)
    write_users(users)
    return {"success": True, "message": "Usuario registrado con éxito", "user": new_user}

@app.post("/login")
async def login(user: UserLogin):
    users = read_users()
    user_found = next((u for u in users if u["email"] == user.email and u["password"] == user.password), None)
    if user_found:
        return {
            "success": True, 
            "message": f"Bienvenido, {user_found['name']}", 
            "name": user_found["name"], 
            "user": user_found
        }
    
    return JSONResponse(status_code=401, content={"success": False, "message": "Correo o contraseña incorrectos"})

@app.put("/change-password")
async def change_password(data: UserChangePassword):
    users = read_users()
    user_index = next((i for i, u in enumerate(users) if u["email"] == data.email), None)
    if user_index is None:
        return JSONResponse(status_code=404, content={"success": False, "message": "Usuario no encontrado"})
    
    if users[user_index]["password"] != data.currentPassword:
        return JSONResponse(status_code=401, content={"success": False, "message": "La contraseña actual es incorrecta"})
    
    users[user_index]["password"] = data.newPassword
    write_users(users)
    
    return {"success": True, "message": "Contraseña actualizada con éxito"}

@app.post("/upload-profile-pic/{email}")
async def upload_profile_pic(email: str, file: UploadFile = File(...)):
    users = read_users()
    user_index = next((i for i, u in enumerate(users) if u["email"] == email), None)

    if user_index is None:
        return JSONResponse(status_code=404, content={"success": False, "message": "Usuario no encontrado"})

    safe_email = email.replace("@", "_").replace(".", "_")
    file_extension = os.path.splitext(file.filename)[1]
    filename = f"{safe_email}_profile{file_extension}"
    file_path = os.path.join(UPLOAD_DIR, filename)

    try:
        with open(file_path, "wb") as buffer:
            shutil.copyfileobj(file.file, buffer)
    except Exception as e:
        return JSONResponse(status_code=500, content={"success": False, "message": f"Error guardando archivo: {str(e)}"})

    relative_url = f"/uploads/profile_pics/{filename}"
    users[user_index]["profile_pic"] = relative_url
    write_users(users)

    return {
        "success": True, 
        "message": "Foto de perfil actualizada", 
        "profile_pic_url": relative_url
    }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)