# 🚗 K8s Infra - Oficina Mecânica

Repositório responsável pela **infraestrutura Kubernetes e AWS** da aplicação **Oficina Mecânica**, desenvolvida pelo **Grupo-SOAT** para o **Tech Challenge – Fase 3**.

O projeto utiliza **Terraform** para provisionamento da infraestrutura e **Kubernetes + Argo CD** para gerenciamento e entrega dos workloads da aplicação.

Além dos componentes da aplicação, este repositório concentra recursos de infraestrutura como **Amazon EKS, Amazon ECR, Amazon RDS, AWS Load Balancer Controller, API Gateway, AWS Lambda, Kafka e observabilidade**.

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
* [Configuração e segredos](#-configuração-e-segredos)
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
* comunicação com Amazon RDS PostgreSQL;
* processamento assíncrono através do Kafka;
* gerenciamento de workloads através do Argo CD;
* exposição externa através do AWS Application Load Balancer;
* autoscaling baseado em CPU;
* coleta de métricas;
* monitoramento e observabilidade;
* provisionamento da infraestrutura através de Terraform.

O repositório também contém os componentes AWS necessários para suportar a arquitetura, incluindo **EKS, ECR, Amazon RDS, API Gateway, Lambda e VPC endpoints**.

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
* Amazon RDS (provisionado pelo repositório `db-oficina-mecanica`);
* AWS Lambda;
* API Gateway;
* VPC endpoints;
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
| Amazon RDS PostgreSQL        | Banco de dados gerenciado                      |
| Amazon API Gateway           | Entrada HTTP + Lambda Authorizer               |
| AWS Lambda                   | Validação de CPF e autorização JWT             |
| AWS ALB                      | Exposição HTTP                                 |
| AWS Load Balancer Controller | Integração ALB + Kubernetes                    |
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
│   ├── hpa.yaml
│   ├── ingress.yaml
│   ├── pvc-kafka.yaml
│   ├── secret.yaml
│   ├── service-kafka.yaml
│   ├── service-kafka-ui.yaml
│   ├── service-mailpit.yaml
│   ├── service-monolito.yaml
│   └── service-ms-orcamentos.yaml
│
├── modules/
│   ├── argocd/
│   ├── aws/
│   │   ├── ecr/
│   │   ├── eks/
│   │   ├── gateway/
│   │   ├── lambda/
│   │   └── network/
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
* Amazon RDS (via `data.aws_db_instance`, sem criar o banco aqui);
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

# 🗄️ Amazon RDS

O banco PostgreSQL é provisionado pelo repositório **db-oficina-mecanica**, fora deste Terraform. Aqui o endpoint é apenas lido, através de:

```text
data "aws_db_instance" "this"
```

A Lambda e o ConfigMap da aplicação usam o host/porta/nome retornados por esse data source, mantendo a infraestrutura agnóstica de conta/região. Por isso o RDS precisa existir antes do `apply` deste repositório.

---

# 🔐 Configuração e segredos

Este repositório **não cria recursos no AWS Secrets Manager**. As informações sensíveis chegam por **GitHub Secrets de organização** e são distribuídas assim:

* **Kubernetes:** o Terraform cria o `kubernetes_secret_v1.app_secret` no namespace da aplicação, com JWT, credenciais do datasource, `POSTGRES_*`, `API_KEY_CHATBOT` e `DEFAULT_USER_PASSWORD`. O arquivo `k8s/secret.yaml` é apenas referência e fica fora do Argo CD (`directory.exclude`).
* **Lambda:** as credenciais do banco e o segredo JWT são injetados como **variáveis de ambiente** da função.

Nenhum valor sensível fica versionado no Git.

---

# λ AWS Lambda

A infraestrutura provisiona **duas** funções (mesmo artefato Java no S3, handlers diferentes):

| Function                          | Handler                                                   | Papel                                    |
| ---------------------------------- | ---------------------------------------------------------- | ----------------------------------------- |
| `oficina-mecanica-validator`       | `br.com.oficina.lambda.ValidatorHandler::handleRequest`    | Valida CPF, consulta `owners`, emite JWT |
| `oficina-mecanica-jwt-authorizer`  | `br.com.oficina.lambda.AuthorizerHandler::handleRequest`   | Lambda Authorizer: valida o JWT nas rotas de negócio |

Ambas rodam em `Java 21` e usam o mesmo artefato (`lambda_s3_key`/`source_hash_code_lambda`), já que é um único build Maven com duas classes de entrada.

O código das funções é obtido através de um artefato armazenado no Amazon S3.

A `validator` roda **dentro da VPC** (subnets padrão + security group dedicado) porque consulta o RDS privado. O security group libera apenas `5432` para o CIDR da VPC e `443` para um **VPC endpoint de CloudWatch Logs**, usado para publicar logs sem NAT. Ela recebe `DATABASE_HOST`, `DATABASE_PORT`, `DATABASE_NAME`, `DATABASE_USER`, `DATABASE_PASSWORD` e `JWT_SECRET` como variáveis de ambiente.

A `jwt-authorizer` só valida o JWT e por isso fica **fora da VPC**, recebendo apenas `JWT_SECRET`. O nome das duas funções é resolvido pelas variáveis de organização `LAMBDA_VALIDATOR_NAME` e `LAMBDA_AUTHORIZER_NAME`.

---

# 🌐 API Gateway

O módulo Terraform:

```text
modules/aws/gateway
```

cria a API `oficina-mecanica-api` com duas famílias de rota:

* **`POST /auth/cpf`** → integração `AWS_PROXY` com a lambda `oficina-mecanica-validator` (sem authorizer - é aqui que o cliente pega o JWT);
* **`POST /auth/login`, `POST /auth/chatbot`, `POST /auth/change-password`** → integração `HTTP_PROXY` direto para o backend (sem authorizer);
* **rotas de negócio** (`var.gateway_resources`: `owners`, `vehicles`, `service-orders`, `catalog`, `supplies`, `suppliers`, `purchase-orders`, `users`, `reporting`) → integração `HTTP_PROXY` **direto para o backend** (`var.backend_url`), protegidas pelo **Lambda Authorizer** (`oficina-mecanica-jwt-authorizer`). Para cada recurso existem as rotas `ANY /{recurso}` e `ANY /{recurso}/{proxy+}`.

O fluxo principal é:

```text
Cliente
   │
   ├── POST /auth/cpf ──────────────► Lambda validator ──► PostgreSQL (owners)
   │                                        │
   │                                    emite JWT
   │
   └── demais rotas (com o JWT) ────► API Gateway
                                          │
                                          ├──► Lambda authorizer (valida o JWT)
                                          │
                                          └──► Backend EKS (HTTP_PROXY, sem passar pela Lambda)
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

O `secret.yaml` não é aplicado pelo Argo CD (fica em `directory.exclude`), pois o segredo real é criado pelo Terraform. A aplicação de observabilidade usa `prune: false` para preservar os ConfigMaps de dashboards/alerting gerenciados pelo Terraform.

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

O workflow `Deploy AWS Resources` (`.github/workflows/terraform.yaml`) responde a:

* `repository_dispatch` `lambda-updated` — disparado pelo repositório `lambda-code` após publicar o artefato no S3;
* `repository_dispatch` `db-deployed` — disparado pelo repositório `db-oficina-mecanica` após subir o RDS;
* `workflow_dispatch` — execução manual (aceita `lambda_key`/`lambda_hash` opcionais).

Cada execução resolve o artefato mais recente da Lambda no bucket S3 (ou usa o payload do dispatch), garante o cluster, aplica a infraestrutura completa e, por fim, atualiza a URL do backend (ALB) e o `configmap` com o endpoint do RDS via Pull Request automático. Um grupo de `concurrency` serializa as execuções para não haver `apply` concorrente.

---

# 🏷️ Atualização das imagens

As aplicações são executadas a partir de imagens Docker publicadas nos repositories ECR provisionados pelo Terraform:

```text
registry-oficina-mecanica-mnl
registry-oficina-mecanica-ms-orcamentos
```

As pipelines de aplicação (`mnl-oficina-mecanica` e `ms-orcamentos`) descobrem a conta AWS via `sts get-caller-identity`, publicam a imagem com a tag do commit e abrem/mergeiam um Pull Request neste repositório atualizando o campo `image` do deployment correspondente. O Argo CD sincroniza a nova imagem.

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

As chaves `SPRING_DATASOURCE_URL` e `POSTGRES_DB` são atualizadas automaticamente pelo pipeline `Deploy AWS Resources` (via Pull Request) com o endpoint do RDS.

Informações sensíveis ficam no `app-secret` (criado pelo Terraform) e nas variáveis de ambiente da Lambda, nunca versionadas.

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

Na raiz, o bucket do state é injetado em tempo de `init` (o `backend.tf` não fixa o bucket, mantendo o repositório agnóstico de conta):

```bash
terraform init -backend-config="bucket=$TF_STATE_BUCKET"
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

Na prática o bootstrap é feito pelo workflow **`Bootstrap AWS`** (`.github/workflows/bootstrap.yaml`), que cria os três buckets usados pelo projeto a partir das variáveis de organização `TF_STATE_BUCKET`, `TF_LAMBDA_BUCKET` e `TF_KAFKA_BUCKET`. O módulo em `bootstrap/` é o equivalente local; como `bucket_name` não tem default, execute-o passando `-var="bucket_name=..."`.

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

Credenciais e informações sensíveis não ficam versionadas. O `app-secret` é criado pelo Terraform a partir de GitHub Secrets de organização, o `k8s/secret.yaml` é só referência (excluído do Argo CD) e a Lambda recebe as credenciais como variáveis de ambiente.

### Rede

A Lambda que acessa o RDS roda dentro da VPC com egress restrito a `5432` (RDS) e `443` (VPC endpoint de CloudWatch Logs), sem exposição pública.

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

A Lambda possui seu próprio repositório de código (`lambda-code`), publica o artefato no S3 e notifica este repositório. O banco é provisionado pelo repositório `db-oficina-mecanica`, que aciona o `Deploy AWS Resources` assim que o RDS sobe. A infraestrutura e a integração com a AWS de ambos são declaradas aqui.

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
| **Amazon RDS**     | Persistência gerenciada (PostgreSQL) |
| **API Gateway**    | Entrada HTTP + Lambda Authorizer    |
| **Lambda**         | Validação de CPF e autorização JWT  |
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
