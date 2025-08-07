FROM python:3.11-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY api/ ./api/
EXPOSE 8686
# ↓↓↓ この最後の行を、Renderの指示($PORT)に従うように変更します ↓↓↓
CMD uvicorn api.main:app --host 0.0.0.0 --port $PORT