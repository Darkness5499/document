1) Kiến trúc & chuẩn bị (môi trường tối thiểu)

Mục tiêu: có môi trường để thực hành end-to-end.

Cơ bản cần:

| Thành phần                     | Vai trò                               | Gợi ý / Công cụ                                                 |
| ------------------------------ | ------------------------------------- | --------------------------------------------------------------- |
| **Source Repo**                | Lưu trữ source code, trigger pipeline | 🧱 *GitLab* hoặc *GitHub*                                       |
| **CI Server**                  | Thực thi pipeline build/test/deploy   | ⚙️ *Jenkins* (cài trên K8S hoặc VM)                             |
| **Docker Registry**            | Lưu image build từ Jenkins            | 🐳 *Harbor* hoặc *GitLab Container Registry*                    |
| **Kubernetes Cluster**         | Deploy ứng dụng                       | ☸️ *minikube*, *k3s*, *kind* (dev) / *EKS*, *GKE*, *AKS* (prod) |
| **Cluster Manager (optional)** | Quản lý multi-cluster dễ hơn          | 🧭 *Rancher*                                                    |
| **Image Scanner**              | Quét lỗ hổng bảo mật của image        | 🔒 *Trivy* (open-source) hoặc *Snyk / Anchore*                  |
| **Monitoring**                 | Theo dõi hệ thống & pipeline          | 📊 *Prometheus + Grafana*                                       |
| **Access Tool**                | Công cụ truy cập cluster              | 🔧 *kubectl* + file *kubeconfig* cho Jenkins                    |


2) Cấu trúc project & file mẫu

Gợi ý folder repo:

myapp/
├─ src/...
├─ Dockerfile
├─ Jenkinsfile
├─ k8s/
│   ├─ deployment.yaml
│   ├─ service.yaml
│   └─ ingress.yaml
└─ charts/ (nếu dùng Helm)

Dockerfile ví dụ (Spring Boot / Java)
FROM eclipse-temurin:17-jdk-jammy AS build
WORKDIR /app
COPY . .
RUN ./mvnw -DskipTests package

FROM eclipse-temurin:17-jre-jammy
WORKDIR /app
COPY --from=build /app/target/myapp.jar /app/myapp.jar
ENTRYPOINT ["java","-jar","/app/myapp.jar"]

Kubernetes manifest cơ bản (k8s/deployment.yaml)
apiVersion: apps/v1
kind: Deployment
metadata:
name: myapp
labels: {app: myapp}
spec:
replicas: 2
selector: {matchLabels: {app: myapp}}
template:
metadata:
labels: {app: myapp}
spec:
containers:
- name: myapp
image: harbor.company.com/myproject/myapp:REPLACE_TAG
ports:
- containerPort: 8080
readinessProbe:
httpGet:
path: /actuator/health
port: 8080
initialDelaySeconds: 10
periodSeconds: 10

3) Jenkinsfile (Declarative) — pipeline end-to-end

File Jenkinsfile mẫu (build → scan → push → deploy):

pipeline {
agent any

environment {
REGISTRY = "harbor.company.com"
PROJECT = "myproject"
IMAGE = "${REGISTRY}/${PROJECT}/myapp"
}

stages {
stage('Checkout') {
steps { git url: 'https://gitlab.com/yourteam/myapp.git', branch: 'main' }
}

    stage('Build') {
      steps {
        sh 'mvn -DskipTests package -B'
        sh "docker build -t ${IMAGE}:${BUILD_NUMBER} ."
      }
    }

    stage('Unit Test') {
      steps {
        sh 'mvn test -B'
      }
    }

    stage('Scan Image (Trivy)') {
      steps {
        sh "trivy image --severity CRITICAL,HIGH --exit-code 1 ${IMAGE}:${BUILD_NUMBER} || true"
        // Nếu muốn fail pipeline khi có issue: remove "|| true"
      }
    }

    stage('Push to Harbor') {
      steps {
        withCredentials([usernamePassword(credentialsId: 'harbor-creds', usernameVariable: 'H_USER', passwordVariable: 'H_PWD')]) {
          sh "docker login ${REGISTRY} -u ${H_USER} -p ${H_PWD}"
          sh "docker push ${IMAGE}:${BUILD_NUMBER}"
        }
      }
    }

    stage('Deploy to K8S') {
      steps {
        withCredentials([file(credentialsId: 'kubeconfig', variable: 'KUBECONFIG_FILE')]) {
          sh 'mkdir -p $HOME/.kube && cp $KUBECONFIG_FILE $HOME/.kube/config'
          sh "kubectl set image deployment/myapp myapp=${IMAGE}:${BUILD_NUMBER} --record"
          sh "kubectl rollout status deployment/myapp -w --timeout=2m"
        }
      }
    }
}

post {
success { echo "✅ Pipeline succeeded" }
failure { echo "❌ Pipeline failed" }
}
}


Ghi chú:

Lưu kubeconfig và Harbor creds vào Jenkins Credentials (kitchen: harbor-creds, kubeconfig).

trivy có tuỳ chọn --exit-code. Bạn có thể cấu hình để fail pipeline khi phát hiện CVE mức cao.

4) Image scanning & policy

Dùng Trivy trong pipeline để scan image vừa build.

Có thể tích hợp Harbor vulnerability scanner (Clair/Trivy) để scan tự động khi image push.

Policy example: fail pipeline nếu có CVE CRITICAL hoặc HIGH.

Ví dụ lệnh trivy fail khi có high/critical:

trivy image --exit-code 1 --severity CRITICAL,HIGH harbor.company.com/myproject/myapp:TAG

5) Deployment strategies trên K8S

Rolling update (mặc định): zero-downtime.

Blue/Green: deploy sang namespace/Service khác → switch traffic.

Canary: dùng Istio/Linkerd hoặc manual split traffic (k8s Service + Ingress) để test 5–10% user.

Mẫu kubectl set image trong Jenkins dùng rolling update.

6) Quản lý image & retention

Sử dụng Harbor:

Tagging convention: semver hoặc build_number + git_sha (1.2.3, build-123-gabc123).

Retention policy: xóa tag cũ > 30 ngày.

Replication: push sang registry dự phòng.

7) Tích hợp với Rancher (nếu dùng)

Rancher quản lý cluster: bạn có thể deploy qua Rancher UI hoặc gọi Rancher API từ Jenkins.

Cách 1: Jenkins chạy kubectl với kubeconfig cluster (được Rancher cấp).

Cách 2: Jenkins trigger Rancher App (Helm) via API để upgrade workload.

8) Monitoring & Alerts cho quá trình build/deploy/image

Pipeline alerts: Jenkins → Slack/Email/Webhook.

Deploy monitoring: Prometheus + Grafana + Alertmanager.

Registry alerts: Harbor scan results (notify when new CVE).

Cluster events: Falco (security), kubewatch (events → Slack).

9) Security best practices (ngay từ đầu)

Không lưu secrets trong repo. Dùng:

Jenkins Credentials (username/password, kubeconfig file, secret text).

K8s Secrets (or HashiCorp Vault / SealedSecrets).

Jenkins Agents: dùng agent images minimal, ephemeral agents (Kubernetes plugin).

Least privilege: service account cho Jenkins có đúng permissions cần thiết (RBAC).

Image signing: enable Notary / Cosign for image provenance.

Network policies: giới hạn traffic giữa pod.

10) Branching & promotion workflow (ví dụ)

feature/* → MR → develop → CI build + integration tests.

develop → MR → staging → CD to staging namespace (auto).

staging → MR → main (or release) → CD to production (manual approval).

Trong Jenkinsfile: use when { branch 'staging' } để tách steps.

11) Rollback & disaster recovery

K8S: kubectl rollout undo deployment/myapp.

Maintain image tag history in Harbor.

Keep backups of persistent volumes + etcd snapshot for cluster.

12) Checklist để bạn triển khai từng bước (playbook ngắn)

Tạo repo GitLab + push skeleton project.

Cài K8S (k3s/minikube) → verify kubectl get nodes.

Cài Jenkins (Helm) trên K8S hoặc VM.

Cài Harbor (Helm) hoặc enable GitLab registry.

Tạo Jenkins Credentials: docker registry, kubeconfig, git token.

Thêm Jenkinsfile, Dockerfile, k8s/ manifest vào repo.

Trigger pipeline: confirm build → image pushed → deployed.

Thêm Trivy scan stage & test failing rule.

Cài Rancher (nếu cần) để quản lý cluster multiple.

Setup Prometheus/Grafana + alerts; Hook Jenkins → Slack.

13) Thực hành: các lệnh hữu dụng

Login Harbor:

docker login harbor.company.com -u user -p password


Build & push:

docker build -t harbor.company.com/myproject/myapp:1.0 .
docker push harbor.company.com/myproject/myapp:1.0


Scan:

trivy image --severity CRITICAL,HIGH harbor.company.com/myproject/myapp:1.0


Update deployment:

kubectl set image deployment/myapp myapp=harbor.company.com/myproject/myapp:1.0
kubectl rollout status deployment/myapp

14) Nâng cao (khi bạn đã quen)

Dùng Helm charts cho deploy; helm upgrade --install.

Dùng Argo CD / Flux để đạt GitOps (push manifest → Argo CD sync → deploy).

Dùng OPA + Gatekeeper để policy enforcement trên K8S.

Dùng image signing (cosign) + admission controller để chỉ allow signed images.

15) Tài nguyên mẫu nhanh (bạn có thể copy)

Jenkinsfile (đã có ở trên) — bắt đầu ở đây.

Dockerfile (mẫu) — thay theo tech stack.

k8s/deployment.yaml — đổi REPLACE_TAG thành ${BUILD_NUMBER} hoặc image tag.

Nếu bạn muốn — mình có thể làm trực tiếp (từng bước) cho bạn:

A. Tạo một Jenkinsfile hoàn chỉnh cho project Java/Node/Python (bạn nói stack).

B. Viết Helm chart cơ bản + values.yaml.

C. Viết pipeline cho canary deploy với Istio/Ingress.

D. Tạo script Jenkins để scan bằng Trivy và fail khi CVE ≥ HIGH.

Bạn muốn mình bắt đầu với A: Jenkinsfile hoàn chỉnh hay B: Helm chart + k8s manifest? Mình sẽ xuất code sẵn để bạn paste vào repo.