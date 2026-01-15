FROM mattiashem/python:3.7

#copy code
COPY code/ /app/code/
WORKDIR /app/code

#Install deps
RUN pip install --upgrade pip && pip install -r requirements.txt


#OS deps
RUN apt-get update && apt-get install -y --no-install-recommends curl default-jre && rm -rf /var/lib/apt/lists/*

RUN useradd -m -u 10001 appuser
USER 10001

EXPOSE 8080

# Start server
ENTRYPOINT [ "./entrypoint.sh" ] 
