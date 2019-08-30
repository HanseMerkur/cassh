FROM python:3.6-alpine

WORKDIR /app

COPY . .

RUN pip install --no-cache-dir -r requirements.txt -t vendor

USER guest
ENTRYPOINT [ "python", "./cassh_web.py" ]
