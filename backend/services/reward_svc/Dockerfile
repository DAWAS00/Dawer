FROM python:3.12-slim
WORKDIR /app
COPY ../../requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY ../../shared/ ./shared/
COPY . ./service/
ENV PYTHONPATH=/app
ENV PORT=8080
EXPOSE 8080
CMD ["uvicorn", "service.main:app", "--host", "0.0.0.0", "--port", "8080"]
