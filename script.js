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
    
    for (const [username, userData] of Object.entries(users)) {
        userList += `
            <div style="background: white; padding: 15px; margin: 10px 0; border-radius: 8px; border-left: 4px solid #667eea;">
                <strong>${username}</strong> (${userData.displayName})<br>
                Saldo: ${userData.balance} BRM<br>
                Tipo: ${userData.isAdmin ? 'Administrador' : 'Usuário'}
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