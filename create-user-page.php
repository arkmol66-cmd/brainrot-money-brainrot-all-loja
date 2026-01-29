<?php
// =============================================================================
// CRIADOR DE PÁGINAS PERSONALIZADAS - BRAINROTS MONEY
// Cria páginas únicas para cada usuário com URLs aleatórias
// =============================================================================

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, GET');
header('Access-Control-Allow-Headers: Content-Type');

// Função para gerar string aleatória
function generateRandomString($length = 12) {
    $characters = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    $randomString = '';
    for ($i = 0; $i < $length; $i++) {
        $randomString .= $characters[rand(0, strlen($characters) - 1)];
    }
    return $randomString;
}

// Função para criar URL única
function createUniqueUrl($username) {
    // Limpar username (apenas letras e números)
    $cleanUsername = preg_replace('/[^a-zA-Z0-9]/', '', $username);
    
    // Gerar código aleatório
    $randomCode = generateRandomString(8);
    
    // Criar URL única
    $uniqueUrl = '/' . $cleanUsername . $randomCode;
    
    return $uniqueUrl;
}

// Função para criar conteúdo da página
function createPageContent($username, $displayName, $balance, $uniqueUrl) {
    $pageContent = <<<HTML
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>$displayName - Brainrots Money</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Arial', sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            color: #333;
        }
        
        .user-card {
            background: white;
            padding: 40px;
            border-radius: 20px;
            box-shadow: 0 20px 40px rgba(0,0,0,0.3);
            text-align: center;
            max-width: 500px;
            width: 90%;
            animation: slideIn 0.8s ease-out;
        }
        
        @keyframes slideIn {
            from {
                opacity: 0;
                transform: translateY(-50px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }
        
        .user-avatar {
            width: 120px;
            height: 120px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            border-radius: 50%;
            margin: 0 auto 20px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 3em;
            color: white;
            text-shadow: 2px 2px 4px rgba(0,0,0,0.3);
        }
        
        .username {
            font-size: 2.5em;
            color: #667eea;
            margin-bottom: 10px;
            font-weight: bold;
        }
        
        .display-name {
            font-size: 1.3em;
            color: #666;
            margin-bottom: 30px;
        }
        
        .balance-section {
            background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%);
            padding: 25px;
            border-radius: 15px;
            margin: 20px 0;
        }
        
        .balance-label {
            font-size: 1.1em;
            color: #666;
            margin-bottom: 10px;
        }
        
        .balance-amount {
            font-size: 3em;
            color: #667eea;
            font-weight: bold;
            margin-bottom: 5px;
        }
        
        .currency {
            font-size: 1.2em;
            color: #999;
        }
        
        .stats {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 15px;
            margin: 25px 0;
        }
        
        .stat-item {
            background: #f8f9fa;
            padding: 15px;
            border-radius: 10px;
            text-align: center;
        }
        
        .stat-label {
            font-size: 0.9em;
            color: #666;
            margin-bottom: 5px;
        }
        
        .stat-value {
            font-size: 1.5em;
            color: #667eea;
            font-weight: bold;
        }
        
        .actions {
            margin-top: 30px;
        }
        
        .btn {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border: none;
            padding: 12px 25px;
            border-radius: 25px;
            font-size: 1em;
            cursor: pointer;
            margin: 5px;
            transition: transform 0.2s;
            text-decoration: none;
            display: inline-block;
        }
        
        .btn:hover {
            transform: translateY(-2px);
        }
        
        .url-info {
            background: #fff3cd;
            padding: 15px;
            border-radius: 10px;
            margin-top: 20px;
            border-left: 4px solid #ffc107;
        }
        
        .url-code {
            font-family: monospace;
            background: #f8f9fa;
            padding: 5px 10px;
            border-radius: 5px;
            color: #e74c3c;
            font-weight: bold;
        }
        
        .footer {
            margin-top: 30px;
            padding-top: 20px;
            border-top: 1px solid #eee;
            color: #999;
            font-size: 0.9em;
        }
    </style>
</head>
<body>
    <div class="user-card">
        <div class="user-avatar">
            🧠
        </div>
        
        <div class="username">$username</div>
        <div class="display-name">$displayName</div>
        
        <div class="balance-section">
            <div class="balance-label">Saldo Atual</div>
            <div class="balance-amount">$balance</div>
            <div class="currency">BRM - Brainrots Money</div>
        </div>
        
        <div class="stats">
            <div class="stat-item">
                <div class="stat-label">Status</div>
                <div class="stat-value">Ativo</div>
            </div>
            <div class="stat-item">
                <div class="stat-label">Tipo</div>
                <div class="stat-value">Usuário</div>
            </div>
        </div>
        
        <div class="url-info">
            <strong>🔗 Sua URL Única:</strong><br>
            <span class="url-code">$uniqueUrl</span><br>
            <small>Esta é sua página pessoal exclusiva!</small>
        </div>
        
        <div class="actions">
            <a href="/" class="btn">🏠 Voltar ao Sistema</a>
            <a href="#" class="btn" onclick="shareUrl()">📤 Compartilhar</a>
        </div>
        
        <div class="footer">
            <strong>💰 Brainrots Money</strong><br>
            Sistema de Moeda Digital<br>
            <small>Página gerada automaticamente</small>
        </div>
    </div>
    
    <script>
        function shareUrl() {
            const url = window.location.href;
            if (navigator.share) {
                navigator.share({
                    title: '$displayName - Brainrots Money',
                    text: 'Confira minha página no Brainrots Money!',
                    url: url
                });
            } else {
                navigator.clipboard.writeText(url).then(() => {
                    alert('URL copiada para a área de transferência!');
                });
            }
        }
        
        // Efeito de partículas
        function createParticle() {
            const particle = document.createElement('div');
            particle.style.position = 'fixed';
            particle.style.width = '6px';
            particle.style.height = '6px';
            particle.style.background = '#667eea';
            particle.style.borderRadius = '50%';
            particle.style.pointerEvents = 'none';
            particle.style.opacity = '0.7';
            particle.style.left = Math.random() * window.innerWidth + 'px';
            particle.style.top = '-10px';
            particle.style.zIndex = '-1';
            
            document.body.appendChild(particle);
            
            const animation = particle.animate([
                { transform: 'translateY(0px)', opacity: 0.7 },
                { transform: 'translateY(' + (window.innerHeight + 10) + 'px)', opacity: 0 }
            ], {
                duration: Math.random() * 3000 + 2000,
                easing: 'linear'
            });
            
            animation.onfinish = () => particle.remove();
        }
        
        // Criar partículas periodicamente
        setInterval(createParticle, 300);
    </script>
</body>
</html>
HTML;
    
    return $pageContent;
}

// Processar requisição
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $input = json_decode(file_get_contents('php://input'), true);
    
    if (!$input || !isset($input['username'])) {
        http_response_code(400);
        echo json_encode(['success' => false, 'message' => 'Username é obrigatório']);
        exit;
    }
    
    $username = $input['username'];
    $displayName = $input['displayName'] ?? $username;
    $balance = $input['balance'] ?? 500;
    
    // Criar URL única
    $uniqueUrl = createUniqueUrl($username);
    
    // Criar nome do arquivo (sem a barra inicial)
    $fileName = 'pages/' . substr($uniqueUrl, 1) . '.html';
    
    // Criar diretório se não existir
    if (!file_exists('pages')) {
        mkdir('pages', 0755, true);
    }
    
    // Criar conteúdo da página
    $pageContent = createPageContent($username, $displayName, $balance, $uniqueUrl);
    
    // Salvar arquivo
    if (file_put_contents($fileName, $pageContent)) {
        // Salvar registro no banco de dados de páginas
        $pagesDb = 'pages/pages_db.json';
        $pages = [];
        
        if (file_exists($pagesDb)) {
            $pages = json_decode(file_get_contents($pagesDb), true) ?? [];
        }
        
        $pages[$username] = [
            'url' => $uniqueUrl,
            'fileName' => $fileName,
            'displayName' => $displayName,
            'balance' => $balance,
            'created' => date('Y-m-d H:i:s'),
            'lastUpdated' => date('Y-m-d H:i:s')
        ];
        
        file_put_contents($pagesDb, json_encode($pages, JSON_PRETTY_PRINT));
        
        echo json_encode([
            'success' => true,
            'message' => 'Página criada com sucesso!',
            'url' => $uniqueUrl,
            'fileName' => $fileName,
            'fullUrl' => (isset($_SERVER['HTTPS']) ? 'https' : 'http') . '://' . $_SERVER['HTTP_HOST'] . $uniqueUrl
        ]);
    } else {
        echo json_encode(['success' => false, 'message' => 'Erro ao criar página']);
    }
    
} elseif ($_SERVER['REQUEST_METHOD'] === 'GET') {
    // Listar páginas existentes
    $pagesDb = 'pages/pages_db.json';
    
    if (file_exists($pagesDb)) {
        $pages = json_decode(file_get_contents($pagesDb), true) ?? [];
        echo json_encode(['success' => true, 'pages' => $pages]);
    } else {
        echo json_encode(['success' => true, 'pages' => []]);
    }
    
} else {
    http_response_code(405);
    echo json_encode(['success' => false, 'message' => 'Método não permitido']);
}
?>