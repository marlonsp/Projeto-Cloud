# Projeto de Computação em Nuvem: Provisionamento de Infraestrutura na AWS com Terraform

## 1. Introdução
Este documento descreve o processo de provisionamento de uma arquitetura na AWS utilizando o Terraform. A infraestrutura é composta por um Application Load Balancer (ALB), instâncias EC2 com Auto Scaling e um banco de dados RDS. O Terraform é utilizado como Infraestrutura como Código (IaC) para automatizar a criação e gerenciamento desses recursos na AWS, além de proporcionar uma maior facilidade na escalabilidade de infraestrutura.

## 2. Infraestrutura como Código (IaC) com Terraform

### 2.1 Estrutura do Código
O código Terraform desse projeto é estruturado em arquivos para separar responsabilidades. Os principais arquivos são:

* **main.tf**: Contém configurações globais para o Terraform, incluindo a definição do provedor AWS, a configuração do backend para armazenar o estado remoto e informações sobre as zonas de disponibilidade.
* **ec2.tf**: Contém a definição dos recursos relacionados às instâncias EC2, Application Load Balancer (ALB), Auto Scaling Group (ASG), Launch Template e políticas de escalabilidade.
* **vpc.tf**: Define a infraestrutura da Virtual Private Cloud (VPC) na AWS, incluindo subnets públicas e privadas, uma Internet Gateway, tabelas de roteamento e associações de roteamento.
* **rds.tf**: Define a configuração do Amazon RDS (Relational Database Service) na AWS, incluindo a instância do banco de dados, o grupo de subnets do banco de dados e algumas configurações de segurança.
* **outputs.tf**: Define a saída (output) denominada "lb_endpoint", que fornece o endpoint DNS (nome de domínio) do Application Load Balancer (ALB) criado.

### 2.2 Armazenamento do Estado
No contexto do projeto, foi adotada a estratégia de armazenamento remoto do estado no Amazon S3. Ao utilizar o S3 como backend, benefícios como a consistência do estado entre a equipe e o bloqueio automático durante operações críticas são alcançados. O S3 oferece durabilidade e alta disponibilidade para o armazenamento do estado, garantindo a integridade das informações e facilitando a colaboração entre membros da equipe que podem estar fazendo alterações simultâneas na infraestrutura.

Essa abordagem também permite que diferentes membros da equipe ou mesmo equipes distintas possam colaborar eficientemente no gerenciamento da infraestrutura, mantendo um estado consistente e evitando conflitos durante a aplicação de alterações.

## 3. Application Load Balancer (ALB)

### 3.1 Provisionamento do ALB
O provisionamento do Application Load Balancer (ALB) no projeto é crucial para garantir a distribuição eficiente do tráfego entre as instâncias EC2. No arquivo ec2.tf, o recurso aws_lb é configurado para criar o ALB, especificando seu nome, tipo de balanceamento (application), subnets associadas, e o grupo de segurança correspondente.

A utilização de um Application Load Balancer (ALB) no projeto é justificada por diversos benefícios que ele proporciona para a arquitetura da aplicação na AWS. O ALB atua como um ponto central para distribuir o tráfego de forma equitativa entre as instâncias EC2, proporcionando escalabilidade, alta disponibilidade e melhor desempenho. Ao distribuir as solicitações entre várias instâncias, o ALB contribui para a capacidade de lidar com aumentos de carga de forma eficiente, garantindo uma experiência consistente para os usuários, independentemente do volume de tráfego.

### 3.2 Configuração do Target Group
A configuração dos Target Groups no projeto, especificada no arquivo ec2.tf, é essencial para o funcionamento eficiente do Application Load Balancer (ALB). Esses grupos gerenciam as instâncias EC2, permitindo o balanceamento de carga dinâmico e garantindo a saúde das instâncias por meio de verificações de integridade.

### 3.3 Health Checks
A integração de Health Checks, como delineado no arquivo ec2.tf, desempenha um papel fundamental no fortalecimento da resiliência da aplicação, assegurando que apenas instâncias EC2 saudáveis recebam tráfego. Esses checks, implementados no Target Group do Application Load Balancer (ALB), avaliam a condição das instâncias com base em critérios como respostas de protocolo, intervalos e contagens de sucesso.

## 4. EC2 com Auto Scaling
## 4.1 Launch Template

No contexto da gestão eficiente das instâncias EC2 e escalabilidade automática, o projeto incorpora a criação de um Launch Template, conforme definido no arquivo ec2.tf. Nesse bloco de código, é configurado um recurso aws_launch_template que estabelece uma imagem de máquina (AMI) pré-instalada com a aplicação. Esse Launch Template é fundamental para a escalabilidade automática, pois define as configurações iniciais necessárias para a criação de instâncias EC2 em resposta a variações na carga de trabalho. A utilização de uma AMI pré-configurada com a aplicação garante consistência e eficiência na implementação das instâncias, contribuindo para uma arquitetura ágil e responsiva às demandas dinâmicas da aplicação.

### 4.2 Auto Scaling Group (ASG)
O projeto incorpora a provisionamento de um Auto Scaling Group (ASG) para garantir a escalabilidade automática da infraestrutura, conforme especificado no arquivo ec2.tf. O recurso aws_autoscaling_group é configurado para utilizar o Launch Template previamente criado, assegurando que novas instâncias EC2 sejam automaticamente adicionadas ou removidas com base nas políticas de escalabilidade definidas. Essa abordagem permite que a infraestrutura se ajuste dinamicamente às variações na carga de trabalho, garantindo uma distribuição equilibrada do tráfego e uma resposta eficiente às demandas da aplicação.


### 4.3 Políticas de Escalabilidade
O gerenciamento dinâmico da escalabilidade é reforçado por meio da definição de políticas no projeto, conforme expresso no arquivo ec2.tf. Políticas de escalabilidade são estabelecidas com base em CloudWatch Alarms, garantindo uma resposta automatizada às variações na demanda. Essas políticas são configuradas para acionar ações do Auto Scaling Group (ASG) quando métricas de utilização da CPU indicam mudanças significativas na carga de trabalho. Em particular, as políticas são ativadas quando a utilização da CPU ultrapassa 70%, indicando a necessidade de adicionar instâncias, ou quando cai abaixo de 20%, sugerindo a remoção de instâncias para otimizar recursos. Essa integração com o CloudWatch promove uma adaptação proativa da infraestrutura, garantindo que a capacidade das instâncias EC2 seja dinamicamente ajustada para atender eficientemente às demandas da aplicação.

### 4.4 Integração com ALB
A integração fluida entre o Auto Scaling Group (ASG) e o Application Load Balancer (ALB) é essencial para a dinâmica de distribuição de tráfego no projeto, conforme delineado no arquivo ec2.tf. O recurso aws_autoscaling_group é configurado para se integrar ao ALB por meio do Target Group designado. Essa integração possibilita que o tráfego seja distribuído de maneira dinâmica entre as instâncias EC2 gerenciadas pelo ASG. Dessa forma, à medida que novas instâncias são adicionadas ou removidas em resposta às políticas de escalabilidade, o ALB ajusta automaticamente a distribuição do tráfego, assegurando uma operação contínua e eficiente da aplicação

## 5. Banco de Dados RDS

### 5.1 Provisionamento do RDS
O provisionamento do banco de dados é crucial para o projeto, conforme definido no arquivo rds.tf. Uma instância do Amazon RDS, utilizando o motor MySQL ou PostgreSQL, é provisionada com a configuração db.t2.micro, representando uma instância de menor escala disponível. Essa escolha busca otimizar os recursos, adequando a capacidade do banco de dados às demandas da aplicação. A instância RDS é provisionada com configurações adicionais, como backups automáticos, uma janela de manutenção especificada, e a habilitação do Multi-AZ para garantir alta disponibilidade. Essas medidas contribuem para a criação de um ambiente de banco de dados confiável, dimensionado conforme necessário e resiliente a possíveis falhas.

## 6. Aplicação
A aplicação é desenvolvida como uma API RESTful ou uma aplicação web simples, e é construída com o framework FastAPI. Utilizando SQLAlchemy, ela implementa operações CRUD para a entidade "Item". A API oferece endpoints para criar, ler, atualizar e excluir itens, persistindo dados em um banco de dados, possivelmente um RDS da AWS. Com uma rota "/healthcheck" para verificação de status, o design modular e orientado a padrões RESTful facilita a escalabilidade e manutenção da aplicação, alinhando-se com as configurações de infraestrutura propostas no projeto.

### 6.1 Conexão com o Banco de Dados
A aplicação demonstra habilidade na conexão com o banco de dados RDS, permitindo a execução de operações CRUD (Create, Read, Update, Delete). Essa funcionalidade é essencial para a interação eficiente e consistente com o banco de dados, garantindo que a aplicação possa armazenar e recuperar dados no RDS provisionado.

## 7. Tutorial para utilização do projeto:

### 1 - Instalação do Terraform e AWS CLI:

Baixe e instale o Terraform: [Download do Terraform](https://developer.hashicorp.com/terraform/install)
Instale a AWS CLI: [Instruções de Instalação da AWS CLI](https://docs.aws.amazon.com/pt_br/cli/latest/userguide/getting-started-install.html)
### 2 - Geração das Chaves de Acesso AWS no IAM:

Acesse o Console da AWS e vá para o serviço IAM (Identity and Access Management).
Crie um novo usuário ou utilize um existente.
Vincule políticas necessárias (pelo menos, AmazonEC2FullAccess, AmazonRDSFullAccess, AmazonS3FullAccess, e outras conforme necessário).
Na conclusão, anote as chaves de acesso (Access Key ID e Secret Access Key).
### 3 - Configuração do AWS CLI:

Abra o terminal e execute o comando aws configure.
Insira as chaves de acesso, a região padrão, e o formato de saída desejado.
### 4 - Criação do Bucket S3 e Alteração do Código Main para Usá-lo:

No Console da AWS, crie um novo bucket S3.
No arquivo main.tf, altere o bloco backend "s3" para apontar para o novo bucket:
```
  backend "s3" {
    bucket = "nome-do-bucket"
    key    = "remote-state/terraform.tfstate"
    region = "us-east-1"
  }
```
### 5 - Terraform Init:

No terminal, navegue até o diretório onde estão os arquivos Terraform.
Execute o comando 
``` bash
terraform init
``` 
para inicializar o estado e instalar os plugins necessários.
### 6 - Terraform Plan:

Execute o comando:
``` bash
terraform plan
```
para visualizar as alterações planejadas na infraestrutura.
### 7 - Terraform Apply (Auto-Approve):

Execute o comando:
``` bash
terraform apply -auto-approve
```
para criar a infraestrutura na AWS.
### 8 - Acesso ao Link Resultante no Terminal:

Após a conclusão bem-sucedida do terraform apply, procure no terminal o link gerado, ele forneçe acesso direto para o load balancer, que irá direcionar o usuário para alguma das instancias e acessar a aplicação.
### 9 - Terraform Destroy (Auto-Approve):

Quando necessário, para destruir a infraestrutura criada, execute:
``` bash
terraform destroy -auto-approve
```

### [Vídeo demonstrando o tutorial](https://youtu.be/v1_EZqx88uk)

## 8. Estimativa de Custos do Projeto: Anexo da Calculadora de Preços da AWS
A estimativa detalhada dos custos associados ao projeto pode ser encontrada no arquivo "Estimativa de Custos - Calculadora de Preços da AWS.pdf", anexado a esta documentação. Esse documento fornece uma visão abrangente dos custos envolvidos na implementação e operação da infraestrutura proposta na AWS, ajudando a compreender e planejar efetivamente os gastos associados ao projeto. Recomenda-se revisar cuidadosamente a estimativa de custos para obter uma compreensão clara dos custos previstos antes de prosseguir com a implementação da infraestrutura.