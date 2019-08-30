FROM python:3.6-alpine

# Container options (For layer optim)
WORKDIR /app
ENTRYPOINT ["python", "/app/cassh"]
CMD ["--help"]

COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

# Include code
COPY cassh ./cassh
