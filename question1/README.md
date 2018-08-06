#### Proposta 1

Não ficou claro se poderia solicitar ao menos algum checksum do arquivo enviado por FTP, para poder garantir a integridade do arquivo e se a transferencia foi completa.
Não foi especificado se eu possuo controle do servidor FTP ou se sou apenas um outro cliente que deve acessar o FTP para receber o pacote.
Também existe uma certa dúvida quanto a automação do recebimento, se deve ser no exato momento ou se existe uma folga mínima por exemplo 1min.

As dúvidas acimas refletem na questão de como o serviço/script trabalharia, se seria invocado por cron, ou um serviço contínuo utilizando supervisord ou como um daemon.

Minhas sugestões para o recebimento e deploy, tendo liberdade para tratar os casos acima, seria:

1.  Deve ser encaminhado um arquivo chamado md5sum.txt com o checksum md5 do arquivo .jar para garantir a integridade.

2.  O serviço de cron deveria rodar o script de recebimento a cada minuto

    `* * * * * /opt/automation/deploy.sh  >> /opt/automation/automation.log`

3.  No diretório /opt/automation/ ficariam os arquivos referentes a esta automação, um arquivo com as variáveis, um com as funções, um com o script, uma pasta com a applicação .jar, uma pasta com os arquivos necessários para o Ansible e um arquivo com os logs

    ```bash
    ### /opt/automation
    .
    ├── ansible_files
    │   └── playbook.yml
    |   └── inventory
    |   └── key.pem
    ├── application
    ├── functions.sh
    ├── deploy.sh
    ├── logs.log
    └── vars.conf
    ```

    ```bash
    ### vars.conf
    FTP_DIR_PATH="/path/to/ftp_dir"
    ANSIBLE_VERBOSE_LEVEL="v"
    ANSIBLE_PLAYBOOK="playbook.yml"
    ANSIBLE_TAGS="deploy_jar,supervisord"
    ANSIBLE_INVENTORY="inventory"
    MAX_LOG_SIZE=10000
    ```

    ```bash
    ### functions.sh
    fn_check_for_file() {
      # check if file exist and it's integrity and exits if error occurs
      ls ${FTP_DIR_PATH}/md5sum.txt > /dev/null 2>&1 \
      && md5sum -c ${FTP_DIR_PATH}/md5sum.txt > /dev/null 2>&1 \
      || exit 0

      # remove md5file to prevent concurrency and remove any possible existing .jar files from previous job
      rm ${FTP_DIR_PATH}/md5sum.txt /opt/automation/application/*.jar
      mv ${FTP_DIR_PATH}/*.jar /opt/automation/application/
    }

    fn_start_deploy() {
      # start a Asible playbook to deploy the application
      ansible-playbook \
        -i ansible_files/${ANSIBLE_INVENTORY} \
        -b -${ANSIBLE_VERBOSE_LEVEL} \
        -t ${ANSIBLE_TAGS} \
        ansible_files/${ANSIBLE_PLAYBOOK}

      if [ $? -eq 0 ]; then
        echo -e "The application was successfully deployed!\n"
        exit 0
      fi

      echo -e "There was an error during the deploy, check the log file for more information\n" > /dev/stderr
      exit 1
    }

    fn_clear_logs() {
      # should replace this with logrotate
      LOG_SIZE=$(du -s /opt/automation/logs.log | awk '{print $1}')
      [ ${LOG_SIZE} -gt ${MAX_LOG_SIZE}] && echo "" > /opt/automation/logs.log
    }
    ```

    ```bash
    ### deploy.sh
    #!/bin/bash

    source vars.conf
    source functions.sh

    fn_clear_logs
    echo -e "Looking for new update..\n"
    fn_check_for_file
    echo -e "Starting new deploy..\n"
    fn_start_deploy
    ```

4.  O deploy seria feito por um playbook do [Ansible](<>), pois é muito boa para descrever processos de deploy e caso seja necessário instalar a aplicação para mais de um servidor, basta incluir no inventário.

5.  Sem me extender muito, o playbook faria a instalação do supervisord caso não existisse já no servidor destino, pegaria o nome do novo arquivo .jar, copiaria para o servidor com um nome padrão, geraria um novo ini por template para o supervisord caso não existisse, reiniciaria o serviço do supervisord.

6.  Para manter a aplicação rodando no servidor eu usaria o [supervisord](<>), pois é um jeito simples de manter um serviço rodando
