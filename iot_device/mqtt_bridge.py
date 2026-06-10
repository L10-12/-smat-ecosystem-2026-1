import paho.mqtt.client as mqtt
import requests
import json
import threading
import time
import sys

# CONFIGURACIÓN
MQTT_BROKER = "broker.hivemq.com"
MQTT_PORT = 1883
MQTT_TOPIC = "fisi/smat/estaciones/+/lecturas" # El '+' es un wildcard para el ID de la estación
API_URL = "http://localhost:8000/lecturas/"

# Configuración para obtener el token de autenticación
# RECODAR: ACTIVAR EL BACKEND Y CREAR LA ESTACION A LA QUE SE VA A ENVIAR
LOGIN_URL = "http://localhost:8000/token" 
form_data = {"username": "admin", "password": "12345"}  
token_recibido = requests.post(LOGIN_URL, data=form_data)
TOKEN = token_recibido.json().get("access_token")

# Registro del último mensaje recibido por estación
last_seen = {}
ultima_lectura={}
def validar_envio(estacion_id,valor_actual):
    if estacion_id not in ultima_lectura:
        ultima_lectura[estacion_id] = valor_actual
        print(f"Primera lectura registrada desde este sensor a la estación con id :{estacion_id}")
        return True
    
    if not (valor_actual>1.05*ultima_lectura[estacion_id] or valor_actual<0.95*ultima_lectura[estacion_id]):
        print(f"⚠️ Lectura sin variacion significante")
        ultima_lectura[estacion_id] = valor_actual
        return False
    else:
        ultima_lectura[estacion_id] = valor_actual
        return True

def on_connect(client, userdata, flags, rc):
    if rc == 0:
        print("🟢 Conectado exitosamente al Broker MQTT")
    # Suscribirse al tópico global de lecturas de estaciones
        client.subscribe(MQTT_TOPIC)
        print(f"📡 Escuchando transmisiones en el tópico: {MQTT_TOPIC}")
    else:
        print(f"🔴 Error de conexión al Broker. Código de retorno: {rc}")
        sys.exit(1)

def on_message(client, userdata, msg):
    try:
        # 1. Decodificar el payload binario de MQTT a JSON string
        payload_raw = msg.payload.decode("utf-8")
        data_json = json.loads(payload_raw)

        # 2. Extraer el ID dinámico de la estación desde la estructura del tópico
        # Ejemplo de tópico: "fisi/smat/estaciones/5/lecturas" -> split('/')[-2] extrae el "5"
        topic_parts = msg.topic.split('/')
        estacion_id = int(topic_parts[3])

        print(f"📩 Telemetría recibida de Estación [{estacion_id}]: {data_json}")

        # Actualizar última vez vista
        last_seen[estacion_id] = time.time()
        # 3. Formatear la carga útil para cumplir con el esquema (Pydantic Model) de FastAPI
        api_payload = {
            "estacion_id": int(estacion_id),
            "valor": data_json["valor"],
        }
        if validar_envio(estacion_id,data_json["valor"]):
            # 4. Ingestión de datos segura mediante HTTP POST con Header Bearer Token
            headers = {
                "Authorization": f"Bearer {TOKEN}"
            }
            try:
                response = requests.post(
                    API_URL,
                    json=api_payload,
                    headers=headers
                )

                if response.status_code == 200 or response.status_code == 201:
                    print(f"💾 [DB Sincronizada] Lectura de {api_payload['valor']} cm para la estación con id {estacion_id} guardada en SQLite.")
                
                else:
                    print(f"⚠️ [Fallo de Ingesta] API rechazó el dato. Código: {response.status_code} - {response.text}")

            except requests.exceptions.ConnectionError:
                print("⚠️ La API no está disponible")

            except requests.exceptions.Timeout:
                print("⚠️ Tiempo de espera agotado al conectar con la API")
        
        else:
            print("🟢Procediendo con la siguiente lectura")
            

    except KeyError as e:
        print(f"❌ Error de esquema: Falta la llave {e} en el payload MQTT.")
    except ValueError:
        print("❌ Error de casteo: El valor o el ID de la estación no son numéricos.")
    except Exception as e:
        print(f"❌ Error crítico en el Bridge: {e}")


def check_deadlines():
    while True:
        current_time = time.time()

        for eid, last_time in list(last_seen.items()):
            if current_time - last_time > 30:
                print(f"🚨 ALERTA: Estación {eid} está OFFLINE")

        time.sleep(10)


# Iniciar hilo de monitoreo
threading.Thread(
    target=check_deadlines,
    daemon=True
).start()

# Inicialización del cliente de red MQTT
bridge_client = mqtt.Client()
bridge_client.on_connect = on_connect
bridge_client.on_message = on_message

try:
    print("🚀 Inicializando el Bridge de Acoplamiento SMAT...")
    bridge_client.connect(MQTT_BROKER, MQTT_PORT, 60)
    # Mantener el hilo escuchando activamente de forma síncrona
    bridge_client.loop_forever()
except KeyboardInterrupt:
    print("\n🛑 Bridge detenido por el administrador.")

finally:
    bridge_client.disconnect()
    print("✅ Desconectado del broker")
