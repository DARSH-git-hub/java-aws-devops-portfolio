FROM eclipse-temurin:17-jdk-jammy AS build
WORKDIR /app
COPY src/ src/
RUN javac --release 17 -d classes src/*.java
FROM eclipse-temurin:17-jre-jammy
WORKDIR /app
COPY --from=build --chown=10001:10001 /app/classes/ ./classes/
USER 10001:10001
ENV PORT=8080 APP_VERSION=dev
EXPOSE 8080
HEALTHCHECK --interval=10s --timeout=5s --start-period=10s --retries=3 CMD ["java", "-cp", "classes", "HealthCheck"]
ENTRYPOINT ["java", "-cp", "classes", "App"]
