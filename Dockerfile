FROM python:3.12.9-slim
RUN apt-get update && apt-get -y install libpq-dev gcc
WORKDIR /app
COPY /src/requirements.txt .
RUN pip install -r requirements.txt
COPY /src .
EXPOSE 8080
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8080"]