## Hướng dẫn triển khai K3S Lab trên máy cá nhân

### Step 1: Cài ứng dụng chạy nền k8s -> k3d
- các ứng dụng phổ biến: K3d, kind, minikube (Virtual Machine), microK8s, DockerDesktop K8s (Single )
- cài docker desktop -> Cài kubectl -> Cài k3d -> tạo 3 cụm node
- brew install k3d
- ``` k3d cluster create my-mac-lab \
  --agents 2 \
  -p "80:80@loadbalancer" \
  -p "443:443@loadbalancer"
-Kiểm tra: Kubectl get

### Step 2: Tạo các namespace
- Namespace giống như 1 schema trong database, tách riêng vùng ra để quản lý role, tránh trùng...
``      Tạo môi trường cho ứng dụng Spring Boot
        kubectl create namespace dev
        kubectl create namespace prod
    Tạo môi trường riêng cho các công cụ hạ tầng
    kubectl create namespace argocd ``