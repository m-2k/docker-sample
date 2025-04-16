FROM alpine:3.21.3

RUN apk add --update --no-cache python3 py3-pip

WORKDIR /app
COPY . /app

RUN python3 -m venv /venv && . /venv/bin/activate && pip3 install --no-cache-dir Flask markdown
# RUN pip3 install --no-cache-dir Flask markdown
ENV PATH="/venv/bin:$PATH"

EXPOSE 5005

CMD ["python3", "app.py"]
