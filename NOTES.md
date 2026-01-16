# DevOps Assignment – Implementation Notes
# Dananjana Kuruppuachchi

## 1. Overview

This assignment demonstrates containerizing a web application, deploying it to Kubernetes using Helm, exposing it via Ingress, and structuring a CI/CD pipeline suitable for such a deployment.

The primary goal was **not just to make the application run**, but to apply **production-oriented DevOps practices**, including:

- Secure container builds (non-root)
- Helm-based Kubernetes deployments
- Configurable resources and health probes
- Ingress-based networking
- CI/CD pipeline structure (illustrative, assignment-safe)

-------------------------------------------------------------

## 2. Containerization

The web application was containerized using a custom `Dockerfile` with the following characteristics:

- Base image: `python:3.8-slim`
- Runs as a **non-root user**
- Exposes port **8080** (Kubernetes-friendly)
- Minimal OS dependencies
- Entrypoint-based startup

These choices align with Kubernetes and container security best practices.

-------------------------------------------------------------

## 3. Helm Chart Structure

A Helm chart was created under: `charts/devops-test`
The chart manages all Kubernetes resources required by the application.

### 3.1 Web Application (Deployment)

- Deployed using a `Deployment`
- Replica count configurable via `values.yaml`
- Environment variables injected via Helm values
- CPU & memory **requests and limits** defined
- Readiness and liveness probes configurable via Helm

### 3.2 MySQL Database (StatefulSet)

- Deployed using a `StatefulSet`
- Persistent storage via PVC
- Credentials stored in a Kubernetes `Secret`
- Database initialized using a SQL seed file from a `ConfigMap`
- Startup, readiness, and liveness probes enabled

### 3.3 Services

- ClusterIP services for:
  - Web application
  - MySQL database
- Internal communication via Kubernetes DNS

-------------------------------------------------------------

## 4. Configuration via `values.yaml`

All behavior is configurable through Helm values, including:

- Image repository and tag
- Resource requests and limits
- Health probe timings and paths
- MySQL credentials and persistence
- Ingress host, path, and TLS options

This allows the same Helm chart to be reused across environments.

-------------------------------------------------------------

## 5. Ingress & Networking

- **NGINX Ingress Controller** was used
- Host-based routing via `target.example.com`
- Path-based routing configured
- TLS configuration included but **disabled by default**

Ingress was chosen instead of NodePort to better reflect **real-world production setups**.

-------------------------------------------------------------

## 6. Local Execution & Testing (Minikube)

The entire solution was developed and validated locally using **Minikube**.

### 6.1 Cluster Setup

```bash
minikube start
minikube addons enable ingress
```

### 6.2 Build Image Inside Minikube

```bash
eval $(minikube docker-env)
docker build -t devops-test-web:local .
```
This avoids pushing images to an external registry during local development.

### 6.3 Deploy with Helm

```bash
helm upgrade --install devops-test charts/devops-test -n devops-test
```

### 6.4 Host Mapping for Ingress

```bash
127.0.0.1 target.example.com
```

### 6.5 Verification Steps

- Pod readiness and rollout status
- Service endpoints
- Ingress access
- Application functionality
- Database persistence

Example checks:
```bash
kubectl rollout status deploy/devops-test-web -n devops-test
curl http://target.example.com
kubectl exec -n devops-test mysql-0 -- \
  mysql -e "SELECT * FROM targets.targets;"
```

Data written via the web application was verified directly in MySQL and confirmed to persist across pod restarts.

-------------------------------------------------------------

## 7. CI/CD Pipeline Design

A .gitlab-ci.yml file was added to demonstrate how a Kubernetes + Helm pipeline would be structured.

Important Note
This pipeline is intentionally illustrative.
Jobs may not run end-to-end without real GitLab infrastructure and credentials.

### 7.1 Pipeline Stages

	1.	Build
            - Build Docker image
	        - Push image only if registry credentials exist
	        - Safe fallback for assignment environments
	2.	Test
	        - SonarQube static analysis (allowed to fail)
	        - Helm chart validation:
	        - helm lint
	        - helm template
	3.	Deploy
	        - Helm dry-run deployment
	        - Optional real deployment (manual trigger)
	4.	Prod Test
	        - Optional smoke test using kubectl
	        - Automatically skipped if cluster credentials are not provided

-------------------------------------------------------------

## 8. Design Decisions & Rationale

- Helm over raw YAML
   Enables configurability, reuse, and environment separation.
- Ingress over NodePort
   Bereflects real production networking patterns.
- StatefulSet for MySQL
   Ensures stable storage and identity.
- Explicit resource limits & probes
   Demonstrates operational readiness.
- Pipeline structure over full execution
   Matches assignment expectations while remaining realistic.

-------------------------------------------------------------

## 9. Conclusion

This solution demonstrates a complete Kubernetes deployment lifecycle:
- Secure containerization
- Helm-based application management
- Ingress-based exposure
- Persistent data handling
- CI/CD pipeline structure