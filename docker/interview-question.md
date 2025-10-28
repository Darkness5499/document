1. Cách tối ưu docker file
    - giảm số lượng layer, mỗi một câu lệnh trong dockerfile sẽ tạo thành 1 layer
    - kiểm tra bằng cách gõ **docker history docker_image_name**

```dockerfile
RUN apt-get update && apt-get install -y curl vim && rm -rf /var/lib/apt/lists/*

```

    - Xoá cache

```dockerfile
RUN apt-get update && apt-get install -y \
    python3 \
    && rm -rf /var/lib/apt/lists/*
```

    - Dùng base image nhỏ hơn để tối ưu

---------
# 🐳 Docker Interview Questions for Backend Developers

## 🔹 I. Basic Docker Concepts
- What is Docker, and how is it different from a virtual machine?
- What is a Docker image and a Docker container?
- What is the difference between `docker run`, `docker start`, and `docker exec`?
- How does Docker achieve isolation between containers?
- What is the purpose of the Docker daemon and Docker client?
- How can you list all running containers and images?
- Explain the Docker architecture (client–daemon–registry).

---

## 🔹 II. Dockerfile & Image Optimization
- What’s the difference between `CMD` and `ENTRYPOINT`?
- How does Docker layer caching work?
- How can you reduce Docker image size?
- What is a multi-stage build, and when should you use it?
- Why is `.dockerignore` important?
- What’s the difference between `COPY` and `ADD` in Dockerfile?
- What is the best base image for production?

---

## 🔹 III. Docker Networking
- What are the types of Docker networks? (bridge, host, overlay, none)
- How do containers communicate within the same network?
- How do you expose a container port to the host?
- What is the difference between `EXPOSE` and `-p` flag?
- How do you connect two running containers?

---

## 🔹 IV. Docker Volumes & Storage
- What is a Docker volume, and why do we use it?
- Difference between **bind mounts** and **named volumes**?
- How do you persist data in Docker?
- What happens to data if a container is removed?

---

## 🔹 V. Docker Compose
- What is Docker Compose and why is it useful?
- What are common keys in `docker-compose.yml`?
- How can you define dependencies between services in Compose?
- How do you scale a service with Docker Compose?

---

## 🔹 VI. Real-world / DevOps Integration
- How do you push and pull images to a private Docker registry?
- How would you deploy a microservice system using Docker Compose or Kubernetes?
- What is the difference between Docker Swarm and Kubernetes?
- How do you use Docker in a CI/CD pipeline?
- How do you debug a failed container? (`docker logs`, `docker exec -it`)
- What’s the impact of using the “latest” tag in production?

---

## 🔹 VII. Scenario / Troubleshooting
- Your Docker container keeps restarting — how do you debug it?
- The container can’t connect to another service — what do you check first?
- Image size is too large — what steps do you take?
- Build is slow — how to improve it?
- How do you handle environment variables securely in Docker?

---

✅ **Tip for Interviews**
> Focus on explaining **how you apply Docker**


