FROM python:3.6-alpine as builder

WORKDIR /app
RUN apk add --no-cache \
      openssh \
      openssl \
      postgresql-dev \
      gcc \
      musl-dev
COPY . .
RUN pip install --no-cache-dir -r requirements.txt -t vendor

FROM python:3.6-alpine

WORKDIR /app
RUN apk add --no-cache \
      libssl1.1 \
      openssh-client \
      postgresql-libs

COPY --from=builder /app /app

USER guest
ENTRYPOINT [ "python", "./server.py" ]
