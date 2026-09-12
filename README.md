# 🚗 K8s Infra - Oficina Mecânica

Repositório responsável pela **infraestrutura Kubernetes e AWS** da aplicação **Oficina Mecânica**, desenvolvida pelo **Grupo-SOAT** para o **Tech Challenge – Fase 3**.

O projeto utiliza **Terraform** para provisionamento da infraestrutura e **Kubernetes + Argo CD** para gerenciamento e entrega dos workloads da aplicação.

Além dos componentes da aplicação, este repositório concentra recursos de infraestrutura como **Amazon EKS, Amazon ECR, AWS Load Balancer Controller, API Gateway, AWS Lambda, AWS Secrets Manager, Kafka e observabilidade**.

---

## 📋 Sumário

* [Visão geral](#-visão-geral)
* [Arquitetura](#-arquitetura)
* [Responsabilidades](#-responsabilidades)
* [Tecnologias](#-tecnologias)
* [Estrutura do projeto](#-estrutura-do-projeto)
* [Kubernetes](#-kubernetes)
* [Aplicações](#-aplicações)
* [Ingress e acesso externo](#-ingress-e-acesso-externo)
* [Autoscaling](#-autoscaling)
* [Kafka](#-kafka)
* [Observabilidade](#-observabilidade)
* [Terraform](#-terraform)
* [AWS](#-aws)
* [Argo CD e GitOps](#-argo-cd-e-gitops)
* [Secrets e configuração](#-secrets-e-configuração)
* [Pré-requisitos](#-pré-requisitos)
* [Execução](#-execução)
* [Deploy](#-deploy)
* [Atualização das imagens](#-atualização-das-imagens)
* [Comandos úteis](#-comandos-úteis)
* [Segurança](#-segurança)
* [Licença](#-licença)

---

## 🔎 Visão geral

A infraestrutura foi construída com o objetivo de executar a aplicação Oficina Mecânica em um ambiente Kubernetes, permitindo:

* execução do monólito;
* execução do microsserviço de orçamentos;
* comunicação com PostgreSQL;
* processamento assíncrono através do Kafka;
* gerenciamento de workloads através do Argo CD;
* exposição externa através do AWS Application Load Balancer;
* autoscaling baseado em CPU;
* coleta de métricas;
* monitoramento e observabilidade;
* provisionamento da infraestrutura através de Terraform.

O repositório também contém os componentes AWS necessários para suportar a arquitetura, incluindo **EKS, ECR, Secrets Manager, API Gateway e Lambda**.

---

# 🏗️ Arquitetura

A arquitetura pode ser resumida da seguinte forma:

```text
                              ┌──────────────────────┐
                              │       Cliente        │
                              └──────────┬───────────┘
                                         │
                                         ▼
                              ┌──────────────────────┐
                              │   AWS API Gateway    │
                              └──────────┬───────────┘
                                         │
                                         ▼
                              ┌──────────────────────┐
                              │     AWS Lambda       │
                              │  Validator / Auth    │
                              └──────────┬───────────┘
                                         │
                              ┌──────────┴───────────┐
                              │                      │
                              ▼                      ▼
                       ┌─────────────┐      ┌─────────────────┐
                       │ Amazon RDS  │      │    Amazon EKS   │
                       │ PostgreSQL  │      │                 │
                       └─────────────┘      │ ┌─────────────┐ │
                                            │ │  Monólito   │ │
                                            │ └──────┬──────┘ │
                                            │        │         │
                                            │ ┌──────▼──────┐ │
                                            │ │MS Orçamentos│ │
                                            │ └──────┬──────┘ │
                                            │        │         │
                                            │ ┌──────▼──────┐ │
                                            │ │    Kafka     │ │
                                            │ └─────────────┘ │
                                            │                 │
                                            └─────────────────┘
```

O acesso HTTP ao cluster é realizado através do **AWS Application Load Balancer**, gerenciado pelo AWS Load Balancer Controller.

```text
Internet
   │
   ▼
AWS Application Load Balancer
   │
   ▼
Kubernetes Ingress
   │
   ├── /          → workshop-backend-service
   │
   └── /kafka-ui  → kafka-ui-service
```

O Ingress atual utiliza `ingressClassName: alb`, com ALB internet-facing e targets diretamente nos IPs dos workloads.

---

# 🎯 Responsabilidades

Este repositório possui quatro responsabilidades principais.

### 1. Infraestrutura AWS

Provisionamento dos recursos necessários para a aplicação:

* Amazon EKS;
* Amazon ECR;
* VPC/rede;
* AWS Secrets Manager;
* AWS Lambda;
* API Gateway;
* AWS Load Balancer Controller.

### 2. Infraestrutura Kubernetes

Gerenciamento dos recursos:

* Deployments;
* Services;
* ConfigMaps;
* Secrets;
* PersistentVolumeClaims;
* Ingress;
* HorizontalPodAutoscaler;
* namespaces.

### 3. GitOps

O **Argo CD** acompanha este repositório e utiliza os manifests versionados como fonte de verdade para os deployments Kubernetes.

### 4. Observabilidade

O cluster possui componentes destinados à coleta e visualização de:

* métricas;
* logs;
* traces;
* métricas do Kafka;
* disponibilidade dos serviços.

---

# 🛠️ Tecnologias

| Tecnologia                   | Utilização                                     |
| ---------------------------- | ---------------------------------------------- |
| Kubernetes                   | Orquestração dos containers                    |
| Amazon EKS                   | Cluster Kubernetes                             |
| Terraform                    | Infrastructure as Code                         |
| Argo CD                      | GitOps / CD                                    |
| Helm                         | Instalação de componentes Kubernetes           |
| Amazon ECR                   | Registry das imagens                           |
| AWS ALB                      | Exposição HTTP                                 |
| AWS Load Balancer Controller | Integração ALB + Kubernetes                    |
| PostgreSQL                   | Banco de dados                                 |
| Apache Kafka                 | Mensageria                                     |
| Grafana                      | Dashboards                                     |
| Prometheus                   | Métricas                                       |
| OpenTelemetry                | Traces e telemetria                            |
| Alloy                        | Coleta/encaminhamento de telemetria            |
| Mailpit                      | Servidor SMTP para ambiente de desenvolvimento |

---

# 📁 Estrutura do projeto

```text
k8s-infra-oficina-mecanica/
│
├── .github/
│   └── workflows/
│
├── bootstrap/
│   ├── main.tf
│   ├── outputs.tf
│   ├── providers.tf
│   ├── terraform.tfvars
│   └── variables.tf
│
├── k8s/
│   ├── observability/
│   │   ├── grafana/
│   │   ├── helm/
│   │   ├── blackbox-exporter.yaml
│   │   ├── kafka-exporter.yaml
│   │   ├── kustomization.yaml
│   │   ├── probes-mnl.yaml
│   │   └── servicemonitor-monolito.yaml
│   │
│   ├── configmap.yaml
│   ├── deployment-kafka.yaml
│   ├── deployment-kafka-ui.yaml
│   ├── deployment-mailpit.yaml
│   ├── deployment-monolito.yaml
│   ├── deployment-ms-orcamentos.yaml
│   ├── deployment-postgres.yaml
│   ├── hpa.yaml
│   ├── ingress.yaml
│   ├── pvc-kafka.yaml
│   ├── pvc.yaml
│   ├── secret.yaml
│   ├── service-kafka.yaml
│   ├── service-kafka-ui.yaml
│   ├── service-mailpit.yaml
│   ├── service-monolito.yaml
│   ├── service-ms-orcamentos.yaml
│   └── service-postgres.yaml
│
├── modules/
│   ├── argocd/
│   ├── aws/
│   │   ├── ecr/
│   │   ├── eks/
│   │   ├── gateway/
│   │   ├── lambda/
│   │   ├── network/
│   │   └── secret-manager/
│   │
│   ├── helm/
│   │   ├── aws-load-balancer/
│   │   ├── metrics-server/
│   │   └── observability/
│   │
│   └── kubernetes/
│       └── namespaces/
│
├── backend.tf
├── main.tf
├── outputs.tf
├── providers.tf
├── terraform.tfvars
├── variables.tf
├── versions.tf
└── README.md
```

A estrutura atual separa claramente os manifests Kubernetes dos módulos Terraform reutilizáveis.

---

# ☸️ Kubernetes

Os manifests Kubernetes estão concentrados em `k8s/`.

O namespace principal da aplicação é:

```text
oficina-mecanica
```

Além dele, o Terraform cria namespaces separados para:

```text
oficina-mecanica
argocd
observability
```

Os namespaces são provisionados através de um módulo Terraform específico.

---

# 🚗 Aplicações

## Monólito

O backend principal é executado pelo Deployment:

```text
workshop-backend
```

com container na porta:

```text
8080
```

O Deployment atualmente possui uma réplica inicial e configura recursos de CPU e memória.

Também possui:

* startup probe;
* liveness probe;
* readiness probe;
* OpenTelemetry Java Agent;
* integração com Kafka;
* integração com PostgreSQL;
* configuração através de ConfigMap;
* credenciais através de Secret.

### Health checks

O Kubernetes verifica:

```text
/actuator/health/liveness
/actuator/health/readiness
```

Esses endpoints são utilizados para determinar se o Pod está vivo e pronto para receber tráfego.

---

## Microsserviço de Orçamentos

O microsserviço:

```text
ms-orcamentos
```

é executado na porta:

```text
8081
```

e possui integração com:

* PostgreSQL;
* Kafka;
* Mailpit;
* backend de orçamentos.

A imagem utilizada pelo Deployment é proveniente do registry configurado para o microsserviço.

---

# 🌐 Ingress e acesso externo

O tráfego externo entra no cluster através do AWS Application Load Balancer.

O recurso Kubernetes utilizado é:

```text
Ingress
```

com:

```yaml
ingressClassName: alb
```

e configuração:

```text
scheme: internet-facing
target-type: ip
```

### Rotas

| Path        | Serviço                    |
| ----------- | -------------------------- |
| `/`         | `workshop-backend-service` |
| `/kafka-ui` | `kafka-ui-service`         |

Isso permite que o mesmo ALB encaminhe diferentes caminhos HTTP para diferentes Services Kubernetes.

---

# 📈 Autoscaling

O monólito possui um **HorizontalPodAutoscaler (HPA)**.

Configuração atual:

```text
Minimum replicas: 1
Maximum replicas: 2
CPU target: 80%
```

O HPA monitora a utilização média de CPU do Deployment:

```text
workshop-backend
```

Quando a utilização ultrapassa o limite configurado, o Kubernetes pode aumentar a quantidade de Pods.

A redução possui uma janela de estabilização de 60 segundos para evitar oscilações rápidas.

---

# 📨 Kafka

O cluster possui infraestrutura para processamento assíncrono através do Apache Kafka.

São disponibilizados:

* Kafka;
* Kafka UI;
* PersistentVolumeClaim para armazenamento;
* Service do Kafka;
* Service da Kafka UI;
* Kafka exporter.

A aplicação utiliza:

```text
kafka-service:29092
```

como endereço interno do broker.

A Kafka UI é disponibilizada através do Ingress no caminho:

```text
/kafka-ui
```

---

# 📊 Observabilidade

A infraestrutura possui uma camada dedicada de observabilidade.

```text
k8s/observability/
```

contém componentes relacionados a:

* Grafana;
* Helm;
* Blackbox Exporter;
* Kafka Exporter;
* probes;
* ServiceMonitor;
* Kustomize.

## OpenTelemetry

O monólito utiliza o Java Agent do OpenTelemetry.

O agent é baixado por um `initContainer` e compartilhado com o container principal através de um `emptyDir`.

A aplicação envia a telemetria para:

```text
http://alloy.observability.svc.cluster.local:4318
```

utilizando:

```text
http/protobuf
```

O serviço é identificado como:

```text
mnl-oficina-mecanica
```

### Fluxo de observabilidade

```text
Monólito
   │
   │ OpenTelemetry
   ▼
Alloy
   │
   ├── Métricas
   ├── Logs
   └── Traces
          │
          ▼
   Stack de observabilidade
          │
          ▼
       Grafana
```

---

# 🏗️ Terraform

O Terraform é utilizado para provisionar tanto componentes AWS quanto componentes Kubernetes/Helm.

O arquivo principal instancia módulos para:

* namespaces;
* Metrics Server;
* observabilidade;
* AWS Load Balancer Controller;
* Argo CD;
* ECR;
* network;
* EKS;
* Secrets Manager;
* API Gateway;
* Lambda.

---

## Módulos Terraform

### Kubernetes

```text
modules/kubernetes/namespaces
```

Responsável pela criação dos namespaces.

### AWS

```text
modules/aws/
```

Contém módulos para:

```text
ecr
eks
gateway
lambda
network
secret-manager
```

### Helm

```text
modules/helm/
```

Contém componentes como:

```text
aws-load-balancer
metrics-server
observability
```

### Argo CD

```text
modules/argocd/
```

O módulo gera/configura as aplicações Argo CD utilizadas para acompanhar os manifests do repositório.

---

# ☁️ AWS

A infraestrutura foi preparada para execução no **Amazon EKS**.

## Amazon EKS

O módulo:

```text
modules/aws/eks
```

é responsável pelo cluster Kubernetes.

O módulo recebe, entre outras configurações:

* subnets;
* nome do cluster;
* IAM Role da AWS Academy.

---

## Amazon ECR

Existem dois repositories ECR configurados:

```text
Monólito
└── registry-oficina-mecanica-mnl

Microsserviço
└── registry-oficina-mecanica-ms-orcamentos
```

Ambos são criados através do mesmo módulo Terraform:

```text
modules/aws/ecr
```

O módulo permite configurar:

* nome do repository;
* mutabilidade das tags;
* scan das imagens no push;
* tags AWS.

---

# 🔐 AWS Secrets Manager

O Terraform cria secrets para informações sensíveis da aplicação.

Entre eles:

```text
oficina-mecanica/database-user
oficina-mecanica/database-password
oficina-mecanica/jwt-secret
oficina-mecanica/api-key-chatbot
oficina-mecanica/spring-datasource-password
oficina-mecanica/spring-datasource-username
oficina-mecanica/default-user-password
```

A intenção é manter credenciais fora dos manifests da aplicação e centralizar o armazenamento de informações sensíveis na AWS.

---

# λ AWS Lambda

A infraestrutura também provisiona a Lambda:

```text
oficina-mecanica-validator
```

utilizando:

```text
Java 21
```

e handler:

```text
br.com.oficina.lambda.ValidatorHandler::handleRequest
```

O código da função é obtido através de um artefato armazenado no Amazon S3.

A Lambda recebe configurações relacionadas a:

* credenciais do banco;
* host;
* porta;
* nome do banco;
* segredo JWT;
* URL do backend.

---

# 🌐 API Gateway

O API Gateway é configurado para utilizar a Lambda como integração.

O módulo Terraform:

```text
modules/aws/gateway
```

cria a API:

```text
oficina-mecanica-api
```

e associa a função:

```text
oficina-mecanica-validator
```

O fluxo principal é:

```text
Cliente
   │
   ▼
API Gateway
   │
   ▼
Lambda
   │
   ├── Autenticação / validação
   │
   └── Proxy
          │
          ▼
       Backend EKS
```

---

# 🔄 Argo CD e GitOps

O projeto utiliza **GitOps** para gerenciamento dos deployments Kubernetes.

O conceito adotado é:

```text
GitHub
   │
   │ manifests
   ▼
Argo CD
   │
   │ sync
   ▼
Kubernetes
   │
   ├── Monólito
   ├── MS Orçamentos
   ├── Kafka
   ├── PostgreSQL
   └── Observabilidade
```

O Argo CD utiliza este repositório como fonte de verdade para os manifests Kubernetes.

O módulo Terraform recebe:

```text
git_repo_url
git_target_revision_branch
git_manifests_path
```

e também configura a aplicação de observabilidade.

---

# 🔁 Fluxo de CI/CD

A arquitetura de entrega utiliza uma separação entre **CI**, **registry** e **CD**.

```text
Repositório da aplicação
        │
        │ GitHub Actions
        ▼
   Build da imagem
        │
        ▼
     Amazon ECR
        │
        │ nova versão
        ▼
k8s-infra-oficina-mecanica
        │
        │ alteração do manifest
        ▼
      Argo CD
        │
        ▼
    Amazon EKS
        │
        ▼
       Pods
```

Dessa forma, o processo de deploy segue o princípio:

> **Git como fonte de verdade do estado desejado do cluster.**

---

# 🏷️ Atualização das imagens

As aplicações são executadas a partir de imagens Docker.

Exemplo atual do monólito:

```yaml
image: leonardooziro/sistema-oficina-mecanica-mnl:latest
```

O microsserviço utiliza:

```yaml
image: leonardooziro/ms-orcamentos:latest
```

No fluxo de produção AWS, o objetivo é utilizar os repositories ECR provisionados pelo Terraform:

```text
registry-oficina-mecanica-mnl
registry-oficina-mecanica-ms-orcamentos
```

As pipelines de aplicação podem publicar uma imagem identificada pelo commit e atualizar o manifest correspondente neste repositório.

---

# ⚙️ Configuração da aplicação

O arquivo:

```text
k8s/configmap.yaml
```

concentra configurações não sensíveis utilizadas pelos serviços.

Entre elas:

```text
SPRING_DATASOURCE_URL
POSTGRES_DB
SPRING_KAFKA_BOOTSTRAP_SERVERS
APP_BUDGET_BASE_URL
```

Informações sensíveis devem ser mantidas em `Secret` ou em mecanismos externos de gerenciamento de segredos.

---

# 🚀 Pré-requisitos

Para trabalhar com o projeto localmente, recomenda-se instalar:

* Git;
* Docker;
* kubectl;
* Terraform;
* Helm;
* AWS CLI;
* Argo CD CLI.

Para validar o acesso ao cluster:

```bash
kubectl get nodes
```

Para validar o Terraform:

```bash
terraform version
```

Para validar a AWS CLI:

```bash
aws --version
```

---

# 🧑‍💻 Execução local dos manifests

Caso já exista um cluster Kubernetes configurado:

```bash
kubectl apply -f k8s/
```

Entretanto, para ambientes gerenciados por Argo CD, o fluxo recomendado é utilizar o Git como fonte de verdade e deixar o Argo CD realizar a sincronização.

Para verificar os recursos:

```bash
kubectl get pods -n oficina-mecanica
```

```bash
kubectl get services -n oficina-mecanica
```

```bash
kubectl get ingress -n oficina-mecanica
```

---

# 🏗️ Inicialização do Terraform

Na raiz:

```bash
terraform init
```

Validar:

```bash
terraform validate
```

Visualizar alterações:

```bash
terraform plan
```

Aplicar:

```bash
terraform apply
```

---

# 🧱 Bootstrap

O diretório:

```text
bootstrap/
```

possui uma configuração Terraform separada para recursos necessários antes da infraestrutura principal.

```text
bootstrap/
├── main.tf
├── outputs.tf
├── providers.tf
├── terraform.tfvars
└── variables.tf
```

A separação permite preparar recursos-base antes de executar a infraestrutura principal.

---

# 🔍 Comandos úteis

### Pods

```bash
kubectl get pods -n oficina-mecanica
```

### Deployments

```bash
kubectl get deployments -n oficina-mecanica
```

### Services

```bash
kubectl get services -n oficina-mecanica
```

### Ingress

```bash
kubectl get ingress -n oficina-mecanica
```

### HPA

```bash
kubectl get hpa -n oficina-mecanica
```

### Descrever um Pod

```bash
kubectl describe pod <pod-name> -n oficina-mecanica
```

### Logs

```bash
kubectl logs <pod-name> -n oficina-mecanica
```

### Logs acompanhando em tempo real

```bash
kubectl logs -f <pod-name> -n oficina-mecanica
```

### Argo CD

```bash
argocd app list
```

### Terraform

```bash
terraform plan
terraform apply
terraform output
```

---

# 🔒 Segurança

Alguns princípios utilizados na infraestrutura:

### Secrets

Credenciais e informações sensíveis não devem ser armazenadas diretamente nos manifests versionados.

A infraestrutura utiliza AWS Secrets Manager para armazenar informações sensíveis.

### Health checks

Os workloads possuem probes para evitar que Pods não saudáveis recebam tráfego.

### Resource limits

Os containers possuem requests e limits de CPU, memória e, em determinados workloads, armazenamento efêmero.

### IAM

Os recursos AWS devem utilizar IAM Roles com o menor conjunto de permissões necessário.

### GitOps

Alterações no estado desejado da aplicação devem ser versionadas no Git, permitindo rastreabilidade e auditoria das alterações.

---

# 🧩 Relação com os demais repositórios

A infraestrutura é parte de um ecossistema de repositórios da aplicação.

Um fluxo simplificado é:

```text
┌─────────────────────────────┐
│ Código da aplicação         │
│ Monólito                    │
└──────────────┬──────────────┘
               │
               │ Build
               ▼
        ┌─────────────┐
        │   ECR       │
        └──────┬──────┘
               │
               │ Image
               ▼
┌─────────────────────────────┐
│ k8s-infra-oficina-mecanica  │
│                             │
│ Kubernetes manifests        │
│ Terraform                   │
│ Argo CD                     │
└──────────────┬──────────────┘
               │
               │ GitOps
               ▼
        ┌─────────────┐
        │   EKS       │
        └─────────────┘
```

A Lambda possui seu próprio repositório de código, enquanto sua infraestrutura e integração com AWS são declaradas neste repositório.

---

# 📚 Principais componentes

| Componente         | Responsabilidade                    |
| ------------------ | ----------------------------------- |
| **EKS**            | Cluster Kubernetes                  |
| **ECR**            | Armazenamento das imagens Docker    |
| **Terraform**      | Provisionamento da infraestrutura   |
| **Argo CD**        | Deploy GitOps                       |
| **ALB Controller** | Integração Kubernetes ↔ AWS ALB     |
| **Ingress**        | Roteamento HTTP                     |
| **Monólito**       | Backend principal                   |
| **MS Orçamentos**  | Serviço de orçamentos               |
| **PostgreSQL**     | Persistência                        |
| **Kafka**          | Mensageria                          |
| **Kafka UI**       | Administração/visualização do Kafka |
| **HPA**            | Autoscaling                         |
| **Metrics Server** | Métricas utilizadas pelo Kubernetes |
| **OpenTelemetry**  | Instrumentação                      |
| **Grafana**        | Visualização                        |
| **Alloy**          | Coleta/encaminhamento de telemetria |
| **Mailpit**        | SMTP para desenvolvimento           |

---

# 🎓 Tech Challenge

Este repositório faz parte da solução desenvolvida pelo **Grupo-SOAT** para o:

**FIAP — Tech Challenge / Pós-graduação em Arquitetura de Software**

O projeto demonstra a evolução de uma aplicação de oficina mecânica para uma arquitetura baseada em:

* containers;
* Kubernetes;
* microsserviços;
* mensageria;
* infraestrutura como código;
* GitOps;
* cloud AWS;
* observabilidade;
* autoscaling.

---

# 📄 Licença

Este projeto está licenciado sob a licença **MIT**.

Consulte o arquivo [`LICENSE`](./LICENSE) para mais informações.
