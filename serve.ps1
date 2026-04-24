$port = 3000
$root = "C:\Users\gabyb\Desktop\claude\web"
$listener = [System.Net.HttpListener]::new()
$listener.Prefixes.Add("http://localhost:$port/")
$listener.Start()
Write-Output "Listening on http://localhost:$port"

$mimeTypes = @{
    '.html' = 'text/html; charset=utf-8'
    '.css'  = 'text/css; charset=utf-8'
    '.js'   = 'application/javascript; charset=utf-8'
    '.png'  = 'image/png'
    '.jpg'  = 'image/jpeg'
    '.jpeg' = 'image/jpeg'
    '.svg'  = 'image/svg+xml'
    '.ico'  = 'image/x-icon'
}

while ($listener.IsListening) {
    $context = $listener.GetContext()
    $req     = $context.Request
    $res     = $context.Response

    # CORS headers for local requests
    $res.Headers.Add("Access-Control-Allow-Origin", "*")
    $res.Headers.Add("Access-Control-Allow-Methods", "GET, POST, OPTIONS")
    $res.Headers.Add("Access-Control-Allow-Headers", "Content-Type")

    if ($req.HttpMethod -eq "OPTIONS") {
        $res.StatusCode = 200
        $res.Close()
        continue
    }

    # POST /save-logo — saves binary PNG body to assets/logo-nobg.png
    if ($req.HttpMethod -eq "POST" -and $req.Url.LocalPath -eq "/save-logo") {
        try {
            $ms = [System.IO.MemoryStream]::new()
            $req.InputStream.CopyTo($ms)
            $bytes = $ms.ToArray()
            $savePath = Join-Path $root "assets\logo-nobg.png"
            [System.IO.File]::WriteAllBytes($savePath, $bytes)
            $res.ContentType = "text/plain"
            $body = [System.Text.Encoding]::UTF8.GetBytes("OK: saved $($bytes.Length) bytes")
            $res.ContentLength64 = $body.Length
            $res.OutputStream.Write($body, 0, $body.Length)
        } catch {
            $res.StatusCode = 500
            $body = [System.Text.Encoding]::UTF8.GetBytes("ERROR: $_")
            $res.ContentLength64 = $body.Length
            $res.OutputStream.Write($body, 0, $body.Length)
        }
        $res.Close()
        continue
    }

    # GET — serve static files
    $path = $req.Url.LocalPath
    if ($path -eq '/') { $path = '/index.html' }
    $filePath = Join-Path $root $path.TrimStart('/')

    if (Test-Path $filePath -PathType Leaf) {
        $ext  = [System.IO.Path]::GetExtension($filePath).ToLower()
        $mime = if ($mimeTypes[$ext]) { $mimeTypes[$ext] } else { 'application/octet-stream' }
        $fileBytes = [System.IO.File]::ReadAllBytes($filePath)
        $res.ContentType = $mime
        $res.ContentLength64 = $fileBytes.Length
        $res.OutputStream.Write($fileBytes, 0, $fileBytes.Length)
    } else {
        $res.StatusCode = 404
    }
    $res.Close()
}
