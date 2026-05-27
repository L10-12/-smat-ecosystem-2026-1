Nombre del proyecto: SMAT

    -->Indicaciones para lenvatar el Backend:
    0.Crear un entorno virtual e instalar lo siguiente:
    fastapi uvicorn sqlalchemy  pydantic   python-jose[cryptography]  passlib[bcrypt] python-multipart requests
    
    1.Navegar hasta ubicarse en la carpeta ..\bakend\app
    2.Ya ubicado ejecutar en consola: uvicorn main:app --host 0.0.0.0 --port 8000 --reload
    3.Escribir la siguiente URL en el navegador : http://localhost:8000
    4.En este punto ya se puede saber si el servidor se levanto, 
    recorar que el manejo de ciertos endpoints requiere de autenticación.

    -->Indicaciones para lenvatar la App:
    1.Navegar hasta ubicarse en la carpeta ..\mobile\lib
    2.Seleccionar el dispositivo en el que se probará la app y ajustar la baseUrl según el dispositivo.
    3.Ya ubicado y con en dispositivo seleccionado ejecutar en consola: flutter run (alternativa:presionar F5)
    4.En este punto la app se debe abrir o de lo contrario aparecer un fallo en consola.

    -->Explicación del script 
    El script se comunica con el servidor a traves del uso de los endpoindts, esto se logra usando request. Para que el registro de una letura sea correcto se usa los datos del admin creado en el endpoindt post("/token"), con esto se consigue el token. Con el token ya se tiene permiso de usar los enpoindts asegurados y el bucle en el escript podrá enviar lecturas usando el endpoint post("/lecturas/").
