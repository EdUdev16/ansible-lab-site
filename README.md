# ansible-lab-site

Playbook Ansible que transforma uma EC2 limpa (Amazon Linux 2023) num servidor com Docker e um site nginx em container.

O Terraform só cria o servidor, de propósito **sem `user_data`**. Quem instala e configura tudo é o Ansible.

## O que o playbook faz
- Instala e habilita o Docker
- Cria `/opt/site` e copia o `index.html` e o `Dockerfile` (pasta `site/`)
- Constrói a imagem e sobe o container na porta 80 (`--restart unless-stopped`)
- Confere que o site responde (`uri`)
- **Idempotente:** rodando de novo, nada muda (`changed=0`). Se o site mudar, um handler reconstrói a imagem e recria o container

## Estrutura
```
terraform/        EC2 + Security Group (HTTP aberto, SSH só do meu IP)
site/             index.html e Dockerfile enviados ao servidor
playbook.yml      configuração do servidor
ansible.cfg       inventário padrão e opções
inventory.ini.example
```

## Como usar
Pré-requisitos: Terraform, Ansible (`uv tool install ansible-core`), AWS CLI com perfil SSO e uma key pair `lab-key` na AWS.

```bash
# 1. Criar o servidor limpo
cd terraform
echo 'ssh_cidr = "SEU.IP.AQUI/32"' > terraform.tfvars
terraform init && terraform apply

# 2. Apontar o inventário para o IP criado
cd ..
cp inventory.ini.example inventory.ini   # trocar IP_DA_EC2 pelo public_ip

# 3. Configurar o servidor
ansible-playbook playbook.yml
ansible-playbook playbook.yml            # 2ª vez: changed=0

# 4. Encerrar tudo (evita custo)
cd terraform && terraform destroy
```

## Resultado
1ª execução: `ok=11 changed=8 failed=0`. 2ª execução: `ok=9 changed=0 failed=0`.

## O que aprendi
- Terraform cria a infraestrutura; Ansible configura o que está dentro dela.
- Idempotência: descrever o estado final em vez de uma sequência de comandos.
- Handlers só rodam quando uma tarefa muda algo, e `meta: flush_handlers` antecipa a execução deles.
- Usei `command`/`shell` para o `docker` (o módulo `community.docker` exige coleção extra e SDK Python no servidor); como próximo passo, trocar por `community.docker`.
