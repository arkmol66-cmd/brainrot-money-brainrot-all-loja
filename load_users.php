<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET');

$usersFile = 'users.json';

// Usuários padrão (administradores)
$defaultUsers = [
    '@moderador' => [
        'password' => 'mapas1020304050607080900',
        'balance' => 500,
        'isAdmin' => true,
        'displayName' => 'Moderador'
    ],
    '@adm' => [
        'password' => 'mapas102030405060708090',
        'balance' => 500,
        'isAdmin' => true,
        'displayName' => 'Administrador'
    ]
];

$users = $defaultUsers;

// Carregar usuários do arquivo se existir
if (file_exists($usersFile)) {
    $fileUsers = json_decode(file_get_contents($usersFile), true);
    if ($fileUsers) {
        $users = array_merge($defaultUsers, $fileUsers);
    }
}

echo json_encode($users);
?>