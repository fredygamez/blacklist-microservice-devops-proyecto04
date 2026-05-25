# Imagen base oficial Python-slim 3.11
FROM python:3.11-slim

# Definiendo directorio de trabajo dentro del contenedor
WORKDIR /app

# Copiar archivo de dependencias desde la carpeta local src/
COPY src/requirements.txt .

# Instalando dependencias Python sin guardar caché,reduce tamaño de imagen
RUN pip install --no-cache-dir -r requirements.txt

# Copiando el contenido de folder src local a la carpeta src de contenedor
COPY src/ ./src/

# Contenedor usara puerto 5000
EXPOSE 5000

# Comando que ejecuta la aplicación al iniciar contenedor
# CMD ["python", "src/application.py"]
# CMD ["newrelic-admin", "run-program", "python", "src/application.py"]
# Comando para Gunicorn con notación : para objeto WSGI. New Relic necesita Gunicorn para activarse correctamente.
# CMD ["newrelic-admin", "run-program", "gunicorn", "-b", "0.0.0.0:5000", "src.application:application"]
# CMD ["newrelic-admin", "run-program", "gunicorn", "--chdir", "src", "-b", "0.0.0.0:5000", "--preload", "src.application:application"]
CMD ["newrelic-admin", "run-program", "gunicorn", "-b", "0.0.0.0:5000", "src.application:application"]
