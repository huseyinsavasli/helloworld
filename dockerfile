# Base image olarak OpenJDK kullanılıyor
FROM openjdk:17-jdk-slim

# Uygulama JAR dosyasının kopyalanması
COPY target/helloworld-0.0.1-SNAPSHOT.jar /app/helloworld.jar

# Uygulamanın çalıştırılması
CMD ["java", "-jar", "/app/helloworld.jar"]
