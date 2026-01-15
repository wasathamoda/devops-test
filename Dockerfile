FROM python:3.8-slim

#copy code
COPY code/ /app/code/
WORKDIR /app/code

#OS deps
RUN apt-get update && apt-get install -y --no-install-recommends curl default-jre && rm -rf /var/lib/apt/lists/*

COPY code/requirements.txt /app/code/requirements.txt

#Install deps
RUN pip install --upgrade pip && pip install --default-timeout=120 --retries 10 -r requirements.txt


RUN useradd -m -u 10001 appuser
USER 10001

EXPOSE 8080

# Start server
ENTRYPOINT [ "./entrypoint.sh" ] 
