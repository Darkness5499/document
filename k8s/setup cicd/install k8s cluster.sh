# Sau khi cài đặt Docker và bật K8s trên docker
=> đã có sẵn k8s và có kubectl

# Cài đặt WSL (Window subsystem for Linux)
Cài đặt WSL (Window subsystem for Linux), một layer trên window giúp thao tác với các lệnh linux thay vì phải cài máy ảo

#Cài Helm, trình quản lý gói cho k8s
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Tạo namespace (không gian làm việc) và cài đặt jenkins
helm repo add jenkins https://charts.jenkins.io
helm repo update
helm install myjenkins jenkins/jenkins -n jenkins --create-namespace

# forward port của pod jenkins ra ngoài, -n jenkins là tên namespace
kubectl port-forward -n jenkins pod/myjenkins-0 8080:8080

# lấy mật khẩu jenkins mặc định
kubectl get secret -n jenkins #liệt kê các secret trong namespace
kubectl get secret myjenkins -n jenkins -o yaml # lấy file yaml của jenkins
   
jenkins-admin-password: YzNqd2JNd3pPVFJKNThueFhCa3Z3dw==
jenkins-admin-user: YWRtaW4=
# Decode password
echo "YzNqd2JNd3pPVFJKNThueFhCa3Z3dw==" | base64 --decode && echo
# Decode username
echo "YWRtaW4=" | base64 --decode && echo
# Username: admin
# Password: c3jwbMwzOTRJ58nxXBkvww


# Một số lệnh
Kubectl get namespace # liệt kê các namespace hiện có
kubectl get pods -n jenkins # lấy danh sách các pod bên trong namespace jenkins
kubectl logs myjenkins-0 -n jenkins # xem logs pod
kubectl delete pod -n jenkins myjenkins-0 #delete pod để restart
kubectl get pod myjenkins-0 -n jenkins -o yaml #đọc cấu hình, xem jenkins đang mount ra đâu
kubectl exec -it -n jenkins myjenkins-0 -- /bin/bash #exec vào một pod và chạy terminal

# Cài đặt các plugin cần thiết cho jenkins
Defaulted container "jenkins" out of: jenkins, config-reload, config-reload-init (init), init (init)
failed to try resolving symlinks in path "/var/log/pods/jenkins_myjenkins-0_ae1b18d0-8544-4243-92c4-c390a40946dd/jenkins/0.log": lstat /var/log/pods/jenkins_myjenkins-0_ae1b18d0-8544-4243-92c4-c390a40946dd/jenkins: no such file or directory


#Token githubb



# Cài đặt docker registry - Harbor
helm repo add harbor https://helm.goharbor.io
helm repo update
kubectl create namespace harbor
helm install harbor harbor/harbor -n harbor
kubectl get svc -n harbor
kubectl port-forward svc/harbor-portal -n harbor 8081:80 #forward portal ra ngoài
kubectl get secrets -n harbor # lấy các secret
kubectl get secret harbor-core -n harbor -o yaml
kubectl get secret harbor-core -n harbor -o jsonpath="{.data.HARBOR_ADMIN_PASSWORD}" #lấy password Harbor12345
kubectl get secret harbor-core -n harbor -o yaml | findstr HARBOR_ADMIN_PASSWORD #lấy password



#Cài đặt Ingress Controller
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update

helm install ingress-nginx ingress-nginx/ingress-nginx \
  --namespace ingress-nginx \
  --create-namespace

kubectl get pods -n ingress-nginx
kubectl get svc -n ingress-nginx

kubectl apply -f jenkins-ingress.yaml #apply cấu hình cho jenkins

kubectl run kaniko-test --image=gcr.io/kaniko-project/executor:v1.11.0 --restart=Never -- /kaniko/executor --help