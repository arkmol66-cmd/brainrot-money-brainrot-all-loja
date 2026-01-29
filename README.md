# Brainrots Money - Sistema de Moeda Digital

## Como usar

### 1. Configuração
- Para usar com servidor PHP, certifique-se de que o PHP está instalado
- Execute em um servidor local (XAMPP, WAMP, ou `php -S localhost:8000`)
- Os dados dos usuários serão salvos no arquivo `users.json`

### 2. Usuários Administradores Padrão
- **@moderador** / senha: `mapas1020304050607080900`
- **@adm** / senha: `mapas102030405060708090`

### 3. Criando Nova Conta
1. Na tela de login, clique em "Criar Conta"
2. Preencha os dados (senha mínima de 6 caracteres)
3. A conta será salva no arquivo `users.json`
4. Todos os novos usuários começam com 500 BRM

### 4. Funcionalidades
- **Usuários normais**: Ver saldo, transferir moedas, histórico
- **Administradores**: Todas as funções + adicionar/remover moedas de qualquer usuário

### 5. Arquivos do Sistema
- `index.html` - Interface principal
- `style.css` - Estilos
- `script.js` - Lógica do frontend
- `create_account.php` - API para criar contas
- `load_users.php` - API para carregar usuários
- `users.json` - Banco de dados dos usuários

### 6. Modo Offline
Se o servidor PHP não estiver disponível, o sistema funciona em modo offline usando localStorage do navegador.

## Estrutura do arquivo users.json
```json
{
  "username": {
    "password": "senha_do_usuario",
    "balance": 500,
    "isAdmin": false,
    "displayName": "Nome de Exibição",
    "createdAt": "2024-01-01 12:00:00"
  }
}
```