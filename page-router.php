<?php
// =============================================================================
// ROTEADOR DE PÁGINAS PERSONALIZADAS - BRAINROTS MONEY
// Serve páginas através de URLs únicas
// =============================================================================

// Obter a URL solicitada
$requestUri = $_SERVER['REQUEST_URI'];
$path = parse_url($requestUri, PHP_URL_PATH);

// Remover barra inicial se existir
$cleanPath = ltrim($path, '/');

// Se for a raiz, servir index.html
if (empty($cleanPath) || $cleanPath === 'index.html') {
    if (file_exists('index.html')) {
        readfile('index.html');
    } else {
        http_response_code(404);
        echo "Página inicial não encontrada";
    }
    exit;
}

// Verificar se é um arquivo estático comum
$staticFiles = ['style.css', 'script.js', 'users.json'];
if (in_array($cleanPath, $staticFiles)) {
    if (file_exists($cleanPath)) {
        // Definir content-type apropriado
        switch (pathinfo($cleanPath, PATHINFO_EXTENSION)) {
            case 'css':
                header('Content-Type: text/css');
                break;
            case 'js':
                header('Content-Type: application/javascript');
                break;
            case 'json':
                header('Content-Type: application/json');
                break;
        }
        readfile($cleanPath);
    } else {
        http_response_code(404);
        echo "Arquivo não encontrado";
    }
    exit;
}

// Verificar se é uma página de usuário
$pageFile = 'pages/' . $cleanPath . '.html';

if (file_exists($pageFile)) {
    // Servir a página personalizada
    header('Content-Type: text/html; charset=UTF-8');
    readfile($pageFile);
    exit;
}

// Se chegou até aqui, a página não foi encontrada
http_response_code(404);
?>
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Página não encontrada - Brainrots Money</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0;
            color: #333;
        }
        
        .error-container {
            background: white;
            padding: 40px;
            border-radius: 20px;
            box-shadow: 0 20px 40px rgba(0,0,0,0.3);
            text-align: center;
            max-width: 500px;
        }
        
        .error-icon {
            font-size: 5em;
            margin-bottom: 20px;
        }
        
        .error-title {
            font-size: 2em;
            color: #e74c3c;
            margin-bottom: 15px;
        }
        
        .error-message {
            color: #666;
            margin-bottom: 30px;
            line-height: 1.6;
        }
        
        .btn {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            text-decoration: none;
            padding: 12px 25px;
            border-radius: 25px;
            display: inline-block;
            transition: transform 0.2s;
        }
        
        .btn:hover {
            transform: translateY(-2px);
        }
        
        .url-info {
            background: #f8f9fa;
            padding: 15px;
            border-radius: 10px;
            margin: 20px 0;
            font-family: monospace;
            color: #666;
            font-size: 0.9em;
        }
    </style>
</head>
<body>
    <div class="error-container">
        <div class="error-icon">🔍</div>
        <div class="error-title">Página não encontrada</div>
        <div class="error-message">
            A URL que você está procurando não existe ou foi removida.<br>
            Verifique se o endereço está correto.
        </div>
        <div class="url-info">
            URL solicitada: <?php echo htmlspecialchars($path); ?>
        </div>
        <a href="/" class="btn">🏠 Voltar ao Início</a>
    </div>
</body>
</html>