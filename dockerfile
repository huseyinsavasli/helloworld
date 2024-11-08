# Base image olarak OpenJDK kullanılıyor
FROM openjdk:11-jdk

# Uygulama JAR dosyasının kopyalanması
COPY target/helloworld.jar /app/helloworld.jar

# Uygulamanın çalıştırılması
CMD ["java", "-jar", "/app/helloworld.jar"]
