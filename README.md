# Projeto de Computação em Nuvem: Provisionamento de Infraestrutura na AWS com Terraform

## 1. Introdução
Este documento descreve o processo de provisionamento de uma arquitetura na AWS utilizando o Terraform. A infraestrutura é composta por um Application Load Balancer (ALB), instâncias EC2 com Auto Scaling e um banco de dados RDS. O Terraform é utilizado como Infraestrutura como Código (IaC) para automatizar a criação e gerenciamento desses recursos na AWS.

## 2. Infraestrutura como Código (IaC) com Terraform

### 2.1 Estrutura do Código
O código Terraform é estruturado em módulos para separar responsabilidades. Os principais módulos são:

ec2_module: Responsável por criar instâncias EC2 e configurar o Auto Scaling.
rds_module: Responsável por provisionar o banco de dados RDS.
alb_module: Responsável por criar o Application Load Balancer.
network_module: Módulo opcional para configurar a rede (VPC, subnets, etc.).

### 2.2 Armazenamento do Estado
O estado do Terraform é armazenado em um bucket S3 para garantir a consistência e permitir o bloqueio do estado durante operações críticas.

### 2.3 Comandos Únicos
O script Terraform é capaz de criar e destruir a infraestrutura completa com um único comando, proporcionando facilidade e automação no gerenciamento da infraestrutura.

Comando para criação:

bash
Copy code
terraform init
terraform apply
Comando para destruição:

bash
Copy code
terraform destroy

## 3. Application Load Balancer (ALB)

### 3.1 Provisionamento do ALB
Um Application Load Balancer é provisionado para distribuir o tráfego entre as instâncias EC2.

### 3.2 Configuração do Target Group
Target Groups são configurados para gerenciar as instâncias EC2, permitindo o balanceamento de carga.

### 3.3 Health Checks
Health Checks são implementados para garantir que o tráfego seja direcionado apenas para instâncias saudáveis, aumentando a resiliência da aplicação.

## 4. EC2 com Auto Scaling
4.1 Launch Configuration
Um Launch Configuration é criado com uma AMI pré-instalada da aplicação.

### 4.2 Auto Scaling Group (ASG)
Um Auto Scaling Group é provisionado utilizando o Launch Configuration criado, garantindo a escalabilidade automática.

### 4.3 Políticas de Escalabilidade
Políticas de escalabilidade baseadas em CloudWatch Alarms são definidas para garantir que o Auto Scaling responda a alterações na demanda (ex: CPU Utilization > 70%).

### 4.4 Integração com ALB
O Auto Scaling Group é integrado ao ALB através do Target Group, permitindo que o tráfego seja distribuído dinamicamente entre as instâncias EC2.

## 5. Banco de Dados RDS

### 5.1 Provisionamento do RDS
Uma instância RDS MySQL ou PostgreSQL é provisionada com a configuração db.t2.micro.

### 5.2 Configurações Adicionais
Backups automáticos são habilitados, e uma janela de manutenção é definida para garantir a integridade dos dados.
Security Groups são configurados para permitir apenas que as instâncias EC2 se conectem ao RDS.
Multi-AZ é habilitado para garantir alta disponibilidade.

## 6. Aplicação
A aplicação é desenvolvida como uma API RESTful ou uma aplicação web simples.

### 6.1 Conexão com o Banco de Dados
A aplicação é capaz de se conectar ao banco de dados RDS e realizar operações CRUD.

### 6.2 Métricas e Logs
Métricas e logs são implementados utilizando o CloudWatch para monitorar o desempenho da aplicação e identificar possíveis problemas.

## Conclusão
Este documento fornece uma visão geral do processo de provisionamento da infraestrutura na AWS utilizando o Terraform. Ao seguir as instruções aqui descritas, será possível criar uma arquitetura robusta e altamente escalável, com automação e monitoramento integrados.