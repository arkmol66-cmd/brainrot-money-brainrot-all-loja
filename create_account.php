<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type');

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['success' => false, 'message' => 'Método não permitido']);
    exit;
}

$input = json_decode(file_get_contents('php://input'), true);

if (!$input || !isset($input['username']) || !isset($input['password'])) {
    http_response_code(400);
    echo json_encode(['success' => false, 'message' => 'Dados inválidos']);
    exit;
}

$username = trim($input['username']);
$password = $input['password'];
$displayName = $input['displayName'] ?? $username;

// Validações
if (empty($username) || empty($password)) {
    echo json_encode(['success' => false, 'message' => 'Username e senha são obrigatórios']);
    exit;
}

if (strlen($password) < 6) {
    echo json_encode(['success' => false, 'message' => 'Senha deve ter pelo menos 6 caracteres']);
    exit;
}

// Arquivo de usuários
$usersFile = 'users.json';

// Carregar usuários existentes
$users = [];
if (file_exists($usersFile)) {
    $usersData = file_get_contents($usersFile);
    $users = json_decode($usersData, true) ?? [];
}

// Verificar se usuário já existe
if (isset($users[$username])) {
    echo json_encode(['success' => false, 'message' => 'Usuário já existe']);
    exit;
}

// Criar novo usuário
$users[$username] = [
    'password' => $password, // Em produção, use hash da senha
    'balance' => 500,
    'isAdmin' => false,
    'displayName' => $displayName,
    'createdAt' => date('Y-m-d H:i:s')
];

// Salvar no arquivo
if (file_put_contents($usersFile, json_encode($users, JSON_PRETTY_PRINT))) {
    echo json_encode([
        'success' => true, 
        'message' => 'Conta criada com sucesso!',
        'user' => [
            'username' => $username,
            'displayName' => $displayName,
            'balance' => 500
        ]
    ]);
} else {
    echo json_encode(['success' => false, 'message' => 'Erro ao salvar dados']);
}
?>