// Sistema de usuários e dados
let users = {
    '@moderador': {
        password: 'mapas1020304050607080900',
        balance: 500,
        isAdmin: true,
        displayName: 'Moderador'
    },
    '@adm': {
        password: 'mapas102030405060708090',
        balance: 500,
        isAdmin: true,
        displayName: 'Administrador'
    }
};

let currentUser = null;
let transactions = [];

// Elementos DOM
const loginScreen = document.getElementById('loginScreen');
const createAccountScreen = document.getElementById('createAccountScreen');
const mainScreen = document.getElementById('mainScreen');
const loginForm = document.getElementById('loginForm');
const createAccountForm = document.getElementById('createAccountForm');
const loginError = document.getElementById('loginError');
const createAccountError = document.getElementById('createAccountError');
const createAccountSuccess = document.getElementById('createAccountSuccess');
const welcomeUser = document.getElementById('welcomeUser');
const coinBalance = document.getElementById('coinBalance');
const adminPanel = document.getElementById('adminPanel');
const logoutBtn = document.getElementById('logoutBtn');
const createAccountBtn = document.getElementById('createAccountBtn');
const backToLoginBtn = document.getElementById('backToLoginBtn');

// Event Listeners
loginForm.addEventListener('submit', handleLogin);
createAccountForm.addEventListener('submit', handleCreateAccount);
logoutBtn.addEventListener('click', logout);
createAccountBtn.addEventListener('click', showCreateAccountScreen);
backToLoginBtn.addEventListener('click', showLoginScreen);

// Carregar usuários do servidor
async function loadUsers() {
    try {
        const response = await fetch('load_users.php');
        if (response.ok) {
            const serverUsers = await response.json();
            users = { ...users, ...serverUsers };
        }
    } catch (error) {
        console.log('Usando dados locais - servidor não disponível');
    }
}

// Mostrar tela de criação de conta
function showCreateAccountScreen() {
    loginScreen.classList.remove('active');
    createAccountScreen.classList.add('active');
    clearMessages();
}

// Mostrar tela de login
function showLoginScreen() {
    createAccountScreen.classList.remove('active');
    loginScreen.classList.add('active');
    clearMessages();
}

// Limpar mensagens de erro/sucesso
function clearMessages() {
    loginError.textContent = '';
    createAccountError.textContent = '';
    createAccountSuccess.textContent = '';
}

// Função de criação de conta
async function handleCreateAccount(e) {
    e.preventDefault();
    
    const username = document.getElementById('newUsername').value.trim();
    const password = document.getElementById('newPassword').value;
    const confirmPassword = document.getElementById('confirmPassword').value;
    
    // Validações
    if (password !== confirmPassword) {
        createAccountError.textContent = 'As senhas não coincidem!';
        return;
    }
    
    if (password.length < 6) {
        createAccountError.textContent = 'A senha deve ter pelo menos 6 caracteres!';
        return;
    }
    
    if (users[username]) {
        createAccountError.textContent = 'Este usuário já existe!';
        return;
    }
    
    // Tentar criar conta no servidor
    try {
        const response = await fetch('create_account.php', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({
                username: username,
                password: password,
                displayName: username
            })
        });
        
        const result = await response.json();
        
        if (result.success) {
            // Adicionar usuário localmente
            users[username] = {
                password: password,
                balance: 500,
                isAdmin: false,
                displayName: username
            };
            
            createAccountSuccess.textContent = result.message;
            createAccountError.textContent = '';
            
            // Limpar formulário
            document.getElementById('newUsername').value = '';
            document.getElementById('newPassword').value = '';
            document.getElementById('confirmPassword').value = '';
            
            // Voltar para login após 2 segundos
            setTimeout(() => {
                showLoginScreen();
            }, 2000);
            
        } else {
            createAccountError.textContent = result.message;
        }
        
    } catch (error) {
        // Fallback: criar conta localmente se servidor não estiver disponível
        users[username] = {
            password: password,
            balance: 500,
            isAdmin: false,
            displayName: username
        };
        
        // Salvar no localStorage como backup
        localStorage.setItem('brainrots_users', JSON.stringify(users));
        
        createAccountSuccess.textContent = 'Conta criada com sucesso (modo offline)!';
        createAccountError.textContent = '';
        
        // Limpar formulário
        document.getElementById('newUsername').value = '';
        document.getElementById('newPassword').value = '';
        document.getElementById('confirmPassword').value = '';
        
        // Voltar para login após 2 segundos
        setTimeout(() => {
            showLoginScreen();
        }, 2000);
    }
}

// Função de Login
function handleLogin(e) {
    e.preventDefault();
    
    const username = document.getElementById('username').value;
    const password = document.getElementById('password').value;
    
    if (users[username] && users[username].password === password) {
        currentUser = username;
        showMainScreen();
        loginError.textContent = '';
    } else {
        loginError.textContent = 'Usuário ou senha incorretos!';
    }
}

// Mostrar tela principal
function showMainScreen() {
    loginScreen.classList.remove('active');
    mainScreen.classList.add('active');
    
    const user = users[currentUser];
    welcomeUser.textContent = `Bem-vindo, ${user.displayName}!`;
    coinBalance.textContent = user.balance;
    
    // Mostrar painel admin se for administrador
    if (user.isAdmin) {
        adminPanel.style.display = 'block';
        
        // Mostrar badge especial se for o moderador principal
        if (currentUser === '@moderador') {
            document.getElementById('moderatorBadge').style.display = 'block';
        } else {
            document.getElementById('moderatorBadge').style.display = 'none';
        }
    }
    
    updateStats();
}

// Logout
function logout() {
    currentUser = null;
    mainScreen.classList.remove('active');
    loginScreen.classList.add('active');
    adminPanel.style.display = 'none';
    
    // Limpar formulário
    document.getElementById('username').value = '';
    document.getElementById('password').value = '';
    loginError.textContent = '';
}

// Atualizar estatísticas
function updateStats() {
    const totalUsers = Object.keys(users).length;
    const totalCoins = Object.values(users).reduce((sum, user) => sum + user.balance, 0);
    
    document.getElementById('totalUsers').textContent = totalUsers;
    document.getElementById('totalCoins').textContent = totalCoins;
}

// Modal functions
function showTransferModal() {
    document.getElementById('transferModal').style.display = 'block';
}

function showHistoryModal() {
    const historyDiv = document.getElementById('transactionHistory');
    
    if (transactions.length === 0) {
        historyDiv.innerHTML = '<p>Nenhuma transação ainda.</p>';
    } else {
        historyDiv.innerHTML = transactions
            .filter(t => t.from === currentUser || t.to === currentUser)
            .map(t => `
                <div class="transaction">
                    <p><strong>${t.type}:</strong> ${t.amount} BRM</p>
                    <p><small>${t.date}</small></p>
                </div>
            `).join('');
    }
    
    document.getElementById('historyModal').style.display = 'block';
}

function showAdminModal() {
    if (!users[currentUser].isAdmin) {
        alert('Acesso negado!');
        return;
    }
    
    // Verificar se é o moderador principal
    const isModerator = currentUser === '@moderador';
    
    // Criar botões do painel admin
    let adminButtons = `
        <button onclick="addCoins()">➕ Adicionar Moedas</button>
        <button onclick="removeCoins()">➖ Remover Moedas</button>
        <button onclick="viewAllUsers()">👥 Ver Usuários</button>
    `;
    
    // Adicionar botão especial apenas para o moderador
    if (isModerator) {
        adminButtons += `
            <button onclick="viewAllPasswords()" style="background: linear-gradient(135deg, #e74c3c 0%, #c0392b 100%);">🔐 Ver Senhas</button>
        `;
    }
    
    document.querySelector('.admin-actions').innerHTML = adminButtons;
    document.getElementById('adminModal').style.display = 'block';
}

function closeModal(modalId) {
    document.getElementById(modalId).style.display = 'none';
}

// Transferência de moedas
document.getElementById('transferForm').addEventListener('submit', function(e) {
    e.preventDefault();
    
    const recipient = document.getElementById('recipient').value;
    const amount = parseInt(document.getElementById('amount').value);
    
    if (!users[recipient]) {
        alert('Usuário não encontrado!');
        return;
    }
    
    if (users[currentUser].balance < amount) {
        alert('Saldo insuficiente!');
        return;
    }
    
    if (amount <= 0) {
        alert('Quantidade deve ser maior que zero!');
        return;
    }
    
    // Realizar transferência
    users[currentUser].balance -= amount;
    users[recipient].balance += amount;
    
    // Registrar transação
    transactions.push({
        from: currentUser,
        to: recipient,
        amount: amount,
        type: 'Transferência Enviada',
        date: new Date().toLocaleString('pt-BR')
    });
    
    transactions.push({
        from: currentUser,
        to: recipient,
        amount: amount,
        type: 'Transferência Recebida',
        date: new Date().toLocaleString('pt-BR')
    });
    
    // Atualizar interface
    coinBalance.textContent = users[currentUser].balance;
    updateStats();
    
    alert(`Transferência de ${amount} BRM para ${recipient} realizada com sucesso!`);
    closeModal('transferModal');
    
    // Limpar formulário
    document.getElementById('recipient').value = '';
    document.getElementById('amount').value = '';
});

// Funções administrativas
function addCoins() {
    if (!users[currentUser].isAdmin) {
        alert('Acesso negado!');
        return;
    }
    
    const targetUser = prompt('Digite o nome do usuário:');
    const amount = parseInt(prompt('Digite a quantidade de moedas:'));
    
    if (users[targetUser] && amount > 0) {
        users[targetUser].balance += amount;
        
        transactions.push({
            from: 'Sistema',
            to: targetUser,
            amount: amount,
            type: 'Moedas Adicionadas (Admin)',
            date: new Date().toLocaleString('pt-BR')
        });
        
        updateStats();
        if (targetUser === currentUser) {
            coinBalance.textContent = users[currentUser].balance;
        }
        
        alert(`${amount} BRM adicionadas para ${targetUser}!`);
    } else {
        alert('Usuário não encontrado ou quantidade inválida!');
    }
}

function removeCoins() {
    if (!users[currentUser].isAdmin) {
        alert('Acesso negado!');
        return;
    }
    
    const targetUser = prompt('Digite o nome do usuário:');
    const amount = parseInt(prompt('Digite a quantidade de moedas:'));
    
    if (users[targetUser] && amount > 0 && users[targetUser].balance >= amount) {
        users[targetUser].balance -= amount;
        
        transactions.push({
            from: targetUser,
            to: 'Sistema',
            amount: amount,
            type: 'Moedas Removidas (Admin)',
            date: new Date().toLocaleString('pt-BR')
        });
        
        updateStats();
        if (targetUser === currentUser) {
            coinBalance.textContent = users[currentUser].balance;
        }
        
        alert(`${amount} BRM removidas de ${targetUser}!`);
    } else {
        alert('Usuário não encontrado, quantidade inválida ou saldo insuficiente!');
    }
}

function viewAllUsers() {
    if (!users[currentUser].isAdmin) {
        alert('Acesso negado!');
        return;
    }
    
    const adminContent = document.getElementById('adminContent');
    let userList = '<h3>Lista de Usuários:</h3>';
    
    // Verificar se é o moderador principal para mostrar senhas
    const isModerator = currentUser === '@moderador';
    
    for (const [username, userData] of Object.entries(users)) {
        userList += `
            <div style="background: white; padding: 15px; margin: 10px 0; border-radius: 8px; border-left: 4px solid #667eea;">
                <strong>${username}</strong> (${userData.displayName})<br>
                Saldo: ${userData.balance} BRM<br>
                Tipo: ${userData.isAdmin ? 'Administrador' : 'Usuário'}<br>
                ${isModerator ? `<span style="color: #e74c3c; font-size: 0.9em;">🔐 Senha: ${userData.password}</span>` : ''}
            </div>
        `;
    }
    
    if (isModerator) {
        userList += `
            <div style="background: #fff3cd; padding: 10px; margin: 10px 0; border-radius: 8px; border: 1px solid #ffeaa7;">
                <strong>👑 MODERADOR PRINCIPAL</strong><br>
                <small>Você tem acesso às senhas de todos os usuários</small>
            </div>
        `;
    }
    
    adminContent.innerHTML = userList;
}

// Fechar modais clicando fora
window.onclick = function(event) {
    const modals = document.querySelectorAll('.modal');
    modals.forEach(modal => {
        if (event.target === modal) {
            modal.style.display = 'none';
        }
    });
}

// Função especial apenas para o moderador - ver senhas
function viewAllPasswords() {
    if (currentUser !== '@moderador') {
        alert('🚫 Acesso NEGADO! Apenas o Moderador Principal pode ver senhas!');
        return;
    }
    
    const adminContent = document.getElementById('adminContent');
    let passwordList = '<h3>🔐 SENHAS DE TODOS OS USUÁRIOS</h3>';
    passwordList += '<p style="color: #e74c3c; font-weight: bold;">⚠️ INFORMAÇÃO CONFIDENCIAL - APENAS MODERADOR</p>';
    
    for (const [username, userData] of Object.entries(users)) {
        const userType = userData.isAdmin ? '👑 Admin' : '👤 User';
        passwordList += `
            <div style="background: #f8f9fa; padding: 15px; margin: 10px 0; border-radius: 8px; border-left: 4px solid #e74c3c;">
                <strong>${userType} ${username}</strong><br>
                <span style="color: #666;">Nome: ${userData.displayName}</span><br>
                <span style="color: #e74c3c; font-family: monospace; font-size: 1.1em;">🔑 Senha: <strong>${userData.password}</strong></span><br>
                <span style="color: #666; font-size: 0.9em;">Saldo: ${userData.balance} BRM</span>
            </div>
        `;
    }
    
    passwordList += `
        <div style="background: #fff3cd; padding: 15px; margin: 15px 0; border-radius: 8px; border: 2px solid #ffc107;">
            <strong>👑 PRIVILÉGIO DE MODERADOR</strong><br>
            <small>Esta função está disponível apenas para @moderador<br>
            Use essas informações com responsabilidade!</small>
        </div>
    `;
    
    adminContent.innerHTML = passwordList;
}

// Função para criar página personalizada do usuário
async function createUserPage() {
    if (!currentUser) {
        alert('Você precisa estar logado!');
        return;
    }
    
    const user = users[currentUser];
    
    try {
        const response = await fetch('create-user-page.php', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({
                username: currentUser,
                displayName: user.displayName,
                balance: user.balance
            })
        });
        
        const result = await response.json();
        
        if (result.success) {
            // Mostrar modal com informações da página criada
            showUserPageModal(result);
        } else {
            alert('Erro ao criar página: ' + result.message);
        }
        
    } catch (error) {
        console.error('Erro:', error);
        alert('Erro ao criar página personalizada');
    }
}

// Mostrar modal com informações da página criada
function showUserPageModal(pageInfo) {
    // Criar modal dinamicamente
    const modal = document.createElement('div');
    modal.className = 'modal';
    modal.style.display = 'block';
    modal.innerHTML = `
        <div class="modal-content">
            <span class="close" onclick="this.parentElement.parentElement.remove()">&times;</span>
            <h2>🎉 Sua Página Foi Criada!</h2>
            <div style="background: #f8f9fa; padding: 20px; border-radius: 10px; margin: 20px 0;">
                <h3>🔗 URL Personalizada:</h3>
                <div style="background: white; padding: 15px; border-radius: 8px; margin: 10px 0; border-left: 4px solid #667eea;">
                    <code style="font-size: 1.2em; color: #e74c3c; font-weight: bold;">${pageInfo.url}</code>
                </div>
                <p><strong>URL Completa:</strong><br>
                <a href="${pageInfo.fullUrl}" target="_blank" style="color: #667eea;">${pageInfo.fullUrl}</a></p>
            </div>
            <div style="background: #fff3cd; padding: 15px; border-radius: 8px; margin: 15px 0;">
                <strong>✨ Sua página personalizada inclui:</strong>
                <ul style="text-align: left; margin: 10px 0;">
                    <li>🧠 Avatar personalizado</li>
                    <li>💰 Saldo atual em BRM</li>
                    <li>📊 Estatísticas do usuário</li>
                    <li>🎨 Design exclusivo</li>
                    <li>📱 Responsivo para mobile</li>
                </ul>
            </div>
            <div style="margin-top: 20px;">
                <button onclick="window.open('${pageInfo.fullUrl}', '_blank')" style="background: #667eea; color: white; border: none; padding: 10px 20px; border-radius: 5px; margin: 5px; cursor: pointer;">
                    🌐 Abrir Página
                </button>
                <button onclick="copyToClipboard('${pageInfo.fullUrl}')" style="background: #28a745; color: white; border: none; padding: 10px 20px; border-radius: 5px; margin: 5px; cursor: pointer;">
                    📋 Copiar URL
                </button>
                <button onclick="shareUserPage('${pageInfo.fullUrl}')" style="background: #17a2b8; color: white; border: none; padding: 10px 20px; border-radius: 5px; margin: 5px; cursor: pointer;">
                    📤 Compartilhar
                </button>
            </div>
        </div>
    `;
    
    document.body.appendChild(modal);
}

// Copiar URL para clipboard
function copyToClipboard(text) {
    navigator.clipboard.writeText(text).then(() => {
        alert('URL copiada para a área de transferência!');
    }).catch(() => {
        // Fallback para navegadores mais antigos
        const textArea = document.createElement('textarea');
        textArea.value = text;
        document.body.appendChild(textArea);
        textArea.select();
        document.execCommand('copy');
        document.body.removeChild(textArea);
        alert('URL copiada!');
    });
}

// Compartilhar página do usuário
function shareUserPage(url) {
    if (navigator.share) {
        navigator.share({
            title: 'Minha página no Brainrots Money',
            text: 'Confira minha página personalizada no sistema de moeda digital!',
            url: url
        });
    } else {
        copyToClipboard(url);
    }
}

// Inicialização
document.addEventListener('DOMContentLoaded', async function() {
    // Carregar usuários do servidor
    await loadUsers();
    
    // Tentar carregar do localStorage como backup
    const localUsers = localStorage.getItem('brainrots_users');
    if (localUsers) {
        const parsedUsers = JSON.parse(localUsers);
        users = { ...users, ...parsedUsers };
    }
    
    // Atualizar estatísticas
    updateStats();
});