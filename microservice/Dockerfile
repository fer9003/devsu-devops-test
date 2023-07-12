FROM node:18.16-alpine
LABEL maintainer="FernandoMora f90mora@gmail.com"
LABEL description="Dockerfile for nodejsapp devsu"

WORKDIR /app
COPY ./package.json .
RUN npm install && npm cache clean --force
COPY . .

#Values que se agregan desde el Servidor de CI
ENV DATABASE_NAME ${DATABASE_NAME}
ENV DATABASE_USER ${DATABASE_USER}
ENV DATABASE_PASSWORD ${DATABASE_PASSWORD}

RUN addgroup -S pipeline && \
    adduser -S nodeapp -G pipeline && \
    chown -R nodeapp:pipeline /app && \
    chmod -R 744 /app

USER nodeapp

EXPOSE 8000

HEALTHCHECK --interval=40s --timeout=5s --retries=3 \
CMD wget -qO- http://localhost:8000/ || exit 1

CMD ["npm", "start"]