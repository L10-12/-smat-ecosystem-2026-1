# SMAT

Sistema de Monitoreo Ambiental basado en MQTT, FastAPI y Flutter.

---

# Levantar el Backend

## 1. Crear y activar un entorno virtual

```bash
python -m venv .venv
```

### Windows

```bash
.venv\Scripts\activate
```

### Linux/MacOS

```bash
source .venv/bin/activate
```

## 2. Instalar dependencias

```bash
pip install fastapi uvicorn sqlalchemy pydantic python-jose[cryptography] passlib[bcrypt] python-multipart
```

## 3. Ubicarse en la carpeta del backend

```bash
cd backend/app
```

## 4. Ejecutar el servidor

```bash
uvicorn main:app --host 0.0.0.0 --port 8000 --reload
```

## 5. Verificar funcionamiento

Abrir en el navegador:

```text
http://localhost:8000
```

Documentación interactiva:

```text
http://localhost:8000/docs
```

---

# Levantar la Aplicación Móvil

## 1. Ubicarse en la carpeta del proyecto Flutter

```bash
cd mobile
```

## 2. Configurar la URL base de la API

Modificar la variable `baseUrl` en los archivos de la carpeta services según el dispositivo utilizado para las pruebas.

## 3. Ejecutar la aplicación

```bash
flutter run
```

También puede ejecutarse desde Visual Studio Code presionando:

```text
F5
```

---

# Levantar los Sensores Simulados

## 1. Instalar dependencias

```bash
pip install paho-mqtt requests
```

## 2. Ubicarse en la carpeta de dispositivos IoT

```bash
cd iot_device
```

## 3. Ejecutar el Bridge MQTT

```bash
python mqtt_bridge.py
```

## 4. Ejecutar el Sensor Simulado

En una terminal diferente:

```bash
python mqtt_sender.py
```

## 5. Verificar funcionamiento

Si todo está correctamente configurado, se observarán mensajes MQTT en la consola del sensor y registros de persistencia en la consola del Bridge.

---

# Arquitectura del Sistema

```text
Sensor MQTT
     │
     ▼
Broker MQTT (HiveMQ)
     │
     ▼
Bridge MQTT
     │
     ▼
API FastAPI
     │
     ▼
Base de Datos
     │
     ▼
Aplicación Flutter
```

---