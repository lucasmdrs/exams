# Nexxera

Created by: Victor Hugo Leite

Favor responder as questões a seguir de forma pública em repositório a ser publicado no
github.com criando as documentações no padrão README. Compartilhe o máximo de informação e
arquivos possivel utilizados no teste (ex: Prints de tela, Dockerfile, scripts ou yaml de automação).

---
1. Suponha que diariamente você recebe atualizações de uma aplicação via ftp, onde ela é
desenvolvida por uma fábrica de software terceira e você não pode sugerir mudanças na esteira
de build, porém precisa automatizar o recebimento do pacote e deploy no servidor de destino.
Elabore uma documentação com a sua sugestão para automatizar o processo e explique o
porquê de cada passo sugerido.
Para este caso, considere que é uma aplicação Java que não depende de um servidor de
aplicação, é iniciada diretamente com java -jar e está hospedada em um servidor linux.

#### [Solução](./question1/README.md)
---

2. Crie um laboratório e inicie uma instacia do minishift (https://github.com/minishift/minishift),
após este passo faça neste minishift o deploy de um docker com nginx e faça ele prover
estaticamente um arquivo json com o seguinte conteúdo:

  {"service": {"oracle": "ok", "redis": "ok", "mongo": "down", "pgsql": "down", "mysql": "ok"}}

  Elabore uma documentação no estilo how-to para que outra pessoa possa replicar o seu experimento.

#### [Solução](./question2/README.md)
---

3. Crie um processo automático que lê o json publicado na questão anterior e gere um alerta via
e-mail de que este serviço não está disponível. Utilize a linguagem que preferir (Shell Script,
Python, Perl, Go, etc...).

#### [Solução](./question3/README.md)
