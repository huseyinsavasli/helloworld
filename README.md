﻿# helloworld

Bu projede, bir CI/CD (Continuous Integration / Continuous Deployment) yapısı kurmayı ve çeşitli altyapı bileşenlerini entegre etmeyi hedefliyoruz. Aşağıda her bir adımın detaylı açıklamalarını bulabilirsiniz.
# 1. Spring Boot 'HelloWorld' Projesi İçin CI/CD Yapısı Kurulması
Amaç:
Bu adımda, Spring Boot tabanlı bir 'HelloWorld' uygulamasının CI/CD süreçlerini kurabilirsiniz.
Adımlar:
# 1.	Proje Oluşturulması ve GitHub'a Yüklenmesi
o	Spring Boot Projesi: Spring Initializr kullanarak bir 'HelloWorld' uygulaması oluşturabilirsiniz. mvn clean install komutuyla projenizi derleyin.
o	GitHub Repo: Projenizi GitHub'a yükleyin. GitHub, kodun versiyon kontrolünü sağlar ve Jenkins pipeline’ı bu repo üzerinden tetiklenir.
# 2.	Jenkins Kurulumu ve Pipeline Tanımlanması
o	Jenkins Kurulumu: Jenkins, CI/CD süreçlerini yönetmek için kullanılır. Docker üzerinde ya da doğrudan Windows, Linux ortamında Jenkins kurulabilir.
Biz burada Docker Desktop kullanacağız.


# 2.1. Docker'ı İndirin ve Başlatın
Eğer Docker kurulu değilse, Docker'ın resmi sitesinden Docker'ı indirip kurmanız gerekiyor.
Docker kurulduktan sonra, Docker servisini başlatın.
# 2.2. Jenkins Docker İmajını İndirin
Docker Hub'dan Jenkins'in resmi Docker imajını çekebilirsiniz. Terminal veya komut satırına aşağıdaki komutu yazın:
Hazırladığım imajı kullanabilirsiniz.
bash
docker pull hsavasli/jenkins-lts
Bu komut, Jenkins'in uzun süreli destek (LTS) sürümünü çeker.
# 2.3. Jenkins Konteynerini Başlatın
Jenkins'i başlatmak için aşağıdaki komutu kullanabilirsiniz:
bash
docker run -d --name jenkins -p 8080:8080 -p 50000:50000 hsavasli/jenkins-lts
•	-d: Jenkins konteynerini arka planda çalıştırır.
•	--name jenkins: Konteynere jenkins adını verir.
•	-p 8080:8080: Jenkins web arayüzüne erişim için 8080 portunu açar.
•	-p 50000:50000: Jenkins'in slave ajanları ile iletişim için kullanılan portu açar.
# 2.4. Jenkins'e Erişim
Jenkins'in çalıştığını doğrulamak için tarayıcınızda şu adresi açın:
http://localhost:8080
İlk kez Jenkins'i başlattığınızda, açılış ekranında Jenkins'in gerekli şifreyi sağlayacağı bir dosya yolunu verecektir. Şifreyi almak için şu komutu çalıştırabilirsiniz:
bash
docker exec -it jenkins cat /var/jenkins_home/secrets/initialAdminPassword
Bu komut size başlangıç şifresini verecektir.
# 2.5. Jenkins Kurulumu
•	Şifreyi girdikten sonra, Jenkins'in ilk kurulum adımlarına yönlendirilirsiniz.
•	İhtiyacınıza göre eklentileri yükleyebilir ve bir yönetici kullanıcı hesabı oluşturabilirsiniz.

Jenkins üzerinde Docker komutlarını kullanabilmek için Docker Pipeline eklentisinin yüklü olması gerekir. Bu eklenti yoksa, Docker komutları çalışmaz. Eklentiyi yüklemek için:
•	Jenkins ana sayfasına gidin.
•	Sol menüden Manage Jenkins'i tıklayın.
•	Manage Plugins'i seçin.
•	Available sekmesine gidin ve "Docker Pipeline" eklentisini arayın.
•	Yükleyin ve Jenkins'i yeniden başlatın.
# 2.6. Jenkinsfile'da docker Kullanımını Kontrol Edin
Docker komutlarını doğru şekilde kullandığınızdan emin olun. docker komutları genellikle şu şekilde kullanılır:
groovy
pipeline {
    agent any
    stages {
        stage('Build') {
            steps {
                script {
                    docker.build('my-app')
                }
            }
        }
    }
}
Eğer docker komutlarını doğru şekilde kullanmıyorsanız, yukarıdaki örnek gibi docker nesnesini doğru biçimde tanımlayın.
# 2.7. Docker Konteyneri ve İzinler
Jenkins'in Docker'ı kullanabilmesi için, Jenkins çalıştıran kullanıcıya Docker komutlarını çalıştırabilme yetkisi verilmiş olmalıdır. Bu yetkiyi vermek için aşağıdaki adımları takip edebilirsiniz:
•	Docker'ı kurduğunuz sunucuda, Jenkins'in çalıştığı kullanıcıyı docker grubuna ekleyin:

bash
sudo usermod -aG docker jenkins
•	Daha sonra Jenkins'i yeniden başlatın.
# 2.8. Jenkins için Docker Yolu
Eğer Jenkins'in Docker komutlarına erişebilmesi için özel bir ortam değişkeni veya yapılandırma gerekiyorsa, pipeline içinde withEnv veya benzer bir yapı kullanarak Docker yolunu eklemeyi deneyebilirsiniz:
groovy
pipeline {
    agent any
    environment {
        DOCKER_HOME = '/usr/bin/docker' // Docker'ın bulunduğu yeri belirtin
    }
    stages {
        stage('Build') {
            steps {
                script {
                    docker.build('my-app')
                }
            }
        }
    }
}
# 2.9. Jenkins’in Docker veya Maven’ı Tanıyıp Tanımadığını Kontrol Edin
Eğer Jenkins konteyner içinde çalışıyorsa ve konteyner içerisinde Docker veya Maven kurulu değilse, Jenkins’in bu araçları kullanabilmesi için ya bu araçları Jenkins container'ına kurmanız ya da Jenkins ile host makine arasında uygun bir bağlantı yapmanız gerekir.
Docker İçin:
Jenkins konteynerine Docker komutlarını çalıştırabilmesi için Docker daemon'ına erişim izni vermeniz gerekebilir:
bash
docker run -v /var/run/docker.sock:/var/run/docker.sock ...
Burada büyük ihtimalle şu şekilde bir hatayla karşılaşma ihtimaliniz var.

+ docker build -t helloworld:latest .
permission denied while trying to connect to the Docker daemon socket at unix:///var/run/docker.sock: Post "http://%2Fvar%2Frun%2Fdocker.sock/v1.24/build?buildargs=%7B%7D&cachefrom=%5B%5D&cgroupparent=&cpuperiod=0&cpuquota=0&cpusetcpus=&cpusetmems=&cpushares=0&dockerfile=dockerfile&labels=%7B%7D&memory=0&memswap=0&networkmode=default&rm=1&shmsize=0&t=helloworld%3Alatest&target=&ulimits=null&version=1": dial unix /var/run/docker.sock: connect: permission denied

Çözümü: docker exec -u root -it jenkins chown jenkins:jenkins /var/run/docker.sock


# 2.10.Jenkins konteynerinde Maven'ı elle yüklemek:
•	Jenkins konteyneri çalışırken, konteyner içine docker exec komutuyla giriş yaparak Maven'ı yükleyebilirsiniz:
bash
docker exec -u root -it jenkins bash
apt-get update && apt-get install -y maven


# 2.. Jenkins Sunucusunun Yeniden Başlatılması
Yukarıdaki değişiklikleri yaptıktan sonra, Jenkins sunucusunu yeniden başlatmayı unutmayın. Bu, yapılan yapılandırma değişikliklerinin geçerli olmasını sağlar.

Pipeline Tanımlanması: Jenkinsfile kullanarak, build, test, deploy süreçlerini otomatikleştiren bir pipeline oluşturun. Örneğin:

pipeline {
    agent any
    stages {
        stage('Checkout') {
            steps {
                git 'https://github.com/your-repo/helloworld.git'
            }
        }
        stage('Build') {
            steps {
                sh './mvnw clean install'
            }
        }
        stage('Test') {
            steps {
                sh './mvnw test'
            }
        }
        stage('Docker Build') {
            steps {
                sh 'docker build -t your-image-name .'
            }
        }
        stage('Push to Docker Hub') {
            steps {
                docker.withRegistry('https://index.docker.io/v1/', 'dockerhub-credentials') {
                    docker.image(‘helloworld’).push()
                }
            }
        }
        stage('Deploy to Kubernetes') {
            steps {
                sh 'kubectl apply -f k8s/deployment.yaml'
            }
        }
    }
}

# 2. Docker İmajı ve Güvenlik Taraması
Amaç:
Docker imajını oluşturmak ve güvenlik açıklarını taramak için Trivy gibi araçlar kullanarak, güvenliği artırmak.
Adımlar:

# 1.	Docker İmajı Oluşturulması
Dockerfile yazın ve Spring Boot projenizi bu Dockerfile üzerinden bir Docker imajına dönüştürün:

FROM openjdk:17-jdk-slim
COPY target/helloworld-0.0.1-SNAPSHOT.jar /app/helloworld.jar
CMD ["java", "-jar", "/app/helloworld.jar"]


# 2.	Trivy Kullanarak Güvenlik Taraması
Trivy bir güvenlik tarayıcısıdır. Docker imajlarını tarayarak bilinen güvenlik açıklarını kontrol eder. Jenkinsfile içinde Trivy'yi şu şekilde kullanabilirsiniz:
stage('Docker Security Scan') {
            steps {
                sh 'trivy image --skip-db-update --timeout 20m --scanners vuln ${DOCKER_IMAGE}'
            }
        }


Trivy, tarama sırasında herhangi bir güvenlik açığı bulursa, build süreci durdurulabilir.



konteyner içerisine Trivy kurulumunu şu adımlarla gerçekleştirebilirsin:
# 1.	Trivy'nin paket listesini ekleyin:
İlk olarak Trivy'nin paket listelerini eklemek için gereken GPG anahtarını ve kaynak deposunu ekleyelim.
bash
apt update && apt install -y gnupg
Daha sonra Trivy'nin resmi anahtarını ekleyin:
bash
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 18C0C872
# 2.	Trivy paket deposunu ekleyin:
bash
echo "deb https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main" | tee -a /etc/apt/sources.list.d/trivy.list
# 3.	Trivy'yi yükleyin:
Depoyu ekledikten sonra, Trivy'yi yükleyebilirsiniz:
bash
apt update && apt install -y trivy
# 4.	Kurulumu doğrulayın:
Kurulumun başarılı olup olmadığını doğrulamak için aşağıdaki komutu çalıştırarak Trivy sürümünü kontrol edebilirsiniz:
bash
trivy --version



# 3. Kubernetes'e Otomatik Dağıtım
Amaç:
Başarılı build'leri Kubernetes ortamına otomatik olarak dağıtmak.
Adımlar:
# 1.	Helm Kullanarak Dağıtım Yapılması
o	Helm Chart: Kubernetes uygulamalarını yönetmek için Helm kullanabilirsiniz. Helm Chart'lar, Kubernetes manifestolarını (deployment, services, ingress vb.) şablonlar halinde yönetir.
o	Helm Chart Oluşturma: helm create helloworld komutuyla bir chart oluşturun ve gerekli yapılandırmaları yapın.
o	Deployment ve Ingress Yapılandırması: Helm Chart içinde Kubernetes deployment.yaml ve ingress.yaml dosyalarını oluşturun. Bu dosyalar, uygulamanızın Kubernetes üzerinde nasıl çalışacağını tanımlar.
# 2.	Jenkinsfile ile Kubernetes'e Deploy Edilmesi
o	kubectl komutları ile Kubernetes’e dağıtım yapılabilir:
stage('Deploy to Kubernetes') {
    steps {
        sh 'kubectl apply -f kubernetes/deployment.yaml'
    }
}
# 4. Kubernetes Ingress Yapılandırmasıyla Erişime Açılması
Amaç:
Uygulamanızı dış dünyadan erişilebilir hale getirmek için Kubernetes Ingress kullanmak.

Adımlar:
# 1.	Ingress Controller Kurulumu
o	Kubernetes’e ingress controller kurulması gerekir. Nginx veya Traefik gibi ingress controller’ları kullanabilirsiniz.
Örneğin Nginx ingress controller’ı kurmak için:
Bash:
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/cloud/deploy.yaml
# 2.	Ingress Kaynağının Oluşturulması
Uygulamanızın dışarıya açılabilmesi için bir ingress kaynağı oluşturmanız gerekecek:
Yaml:
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: helloworld-ingress
  namespace: default
spec:
  rules:
    - host: helloworld.example.com
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: helloworld-service
                port:
                  number: 80

# 3.	DNS Yönlendirmesi
DNS yönlendirmesinin yapılması, uygulamanızın dışarıdan erişilebilir olmasını sağlar.


Uygulamayı Helm ile dağıtmak:

# 1. Jenkinsfile Hazırlığı
Jenkins pipeline'ınızı hazırlamışsınız. Burada şunlar dikkat edilmesi gereken noktalar:
•	Environment değişkenleri: Tüm gerekli değerleri (Docker image, Helm release adı, kubeconfig dosyası vb.) tanımlamışsınız.
•	Helm Chart Yapısı: Jenkins pipeline'ında helm upgrade --install komutunda ./helloworld dizinini kullanıyorsunuz. Bu dizinin, Helm Chart formatında hazır olduğundan emin olun.
________________________________________
# 2. GitHub Repository
•	Helm Chart Dosyaları: helloworld/ dizininde Helm Chart dosyalarınız olmalıdır. Minimum şu dosyalar gereklidir:
o	Chart.yaml: Chart metadata bilgisi.
o	values.yaml: Varsayılan değerler (ör. image repository, tag, replicas).
o	templates/deployment.yaml: Deployment tanımı.
o	templates/service.yaml: Service tanımı.
o	templates/ingress.yaml: Ingress tanımı.
Örnek bir values.yaml dosyası:
yaml
replicaCount: 2

image:
  repository: hsavasli/helloworld
  tag: latest
  pullPolicy: IfNotPresent

service:
  type: LoadBalancer
  port: 80
  targetPort: 8080

ingress:
  enabled: true
  host: helloworld.local
  path: /
________________________________________
# 3. Pipeline Aşamaları
## 1.	Checkout:
o	GitHub deposundan kodlarınızı çekiyor. Helm Chart dizini de bu depoda olmalı.
## 2.	Set Permissions:
o	mvnw betiğinin çalışabilir olmasını sağlıyor.
## 3.	Build:
o	Maven kullanarak Java projenizi derliyor ve JAR dosyanızı oluşturuyor.
## 4.	Docker Build:
o	Projenizin Docker image’ini helloworld:latest etiketiyle oluşturuyor.
## 5.	Docker Security Scan:
o	Trivy kullanarak image üzerinde güvenlik açıklarını tarıyor.
6.	Docker Tag:
o	Docker image’i DockerHub’da hsavasli/helloworld:latest olarak etiketliyor.
## 7.	Push to DockerHub:
o	DockerHub’a image’i yüklüyor.
## 8.	Deploy to Kubernetes with Helm:
o	Helm kullanarak uygulamanızı Kubernetes kümenize dağıtıyor. helm upgrade --install komutu:
o	Mevcut bir release varsa günceller, yoksa yeni bir release oluşturur.
o	image.repository ve image.tag değişkenlerini values.yaml üzerine yazar.
________________________________________
# 4. Helm ile Kubernetes Dağıtımı
Helm, YAML dosyalarını şablon haline getirerek kolay dağıtım yapmanızı sağlar. Dağıtımı gerçekleştirmek için Jenkins pipeline şu işlemleri yapar:
•	helm upgrade --install ile Helm Chart’taki şablon dosyalarınızı kullanarak Deployment, Service ve Ingress kaynaklarını oluşturur veya günceller.
•	values.yaml dosyasındaki değerler üzerinden konfigürasyon yapar.
________________________________________
# 5. Kubernetes Ortamının Hazırlığı
•	Kubernetes Cluster:
o	Docker Desktop üzerinde Kubernetes aktif olmalı.
•	Kubeconfig Dosyası:
o	Jenkins konteynerında /var/jenkins_home/.kube/config yolunda doğru kubeconfig dosyasının olduğundan emin olun.
o   Docker Desktop uygulamasının çalıştığı host üzerindeki .kube/config dosyasını kopyalamalısınız.
•	Ingress Controller:
o	Kubernetes cluster'ınızda NGINX Ingress Controller yüklü olmalıdır:
bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/cloud/deploy.yaml
o	/etc/hosts dosyanıza şu girdiyi ekleyin:
127.0.0.1 helloworld.local
________________________________________

# 6. Test ve Kontroller
•	Jenkins pipeline’ınızı çalıştırarak uygulamanın Kubernetes üzerinde dağıtıldığını doğrulayın.
•	Kubernetes kaynaklarını kontrol edin:
bash
kubectl get deployments
kubectl get services
kubectl get ingress
•	Uygulamayı test etmek için http://helloworld.local adresini tarayıcınızda açın.





