Add-Type -AssemblyName System.Drawing

$src = "C:\Users\gabyb\Desktop\claude\web\assets\logo.png"
$dst = "C:\Users\gabyb\Desktop\claude\web\assets\logo-nobg.png"

try {
    $bmp = [System.Drawing.Bitmap]::new($src)
    $w = $bmp.Width; $h = $bmp.Height

    # Convert to 32bpp ARGB
    $out = [System.Drawing.Bitmap]::new($w, $h, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $g   = [System.Drawing.Graphics]::FromImage($out)
    $g.DrawImage($bmp, 0, 0)
    $g.Dispose()

    $rect = [System.Drawing.Rectangle]::new(0, 0, $w, $h)
    $fmt  = [System.Drawing.Imaging.PixelFormat]::Format32bppArgb
    $data = $out.LockBits($rect, [System.Drawing.Imaging.ImageLockMode]::ReadWrite, $fmt)
    $bytes = $data.Stride * $h
    $arr = [byte[]]::new($bytes)
    [System.Runtime.InteropServices.Marshal]::Copy($data.Scan0, $arr, 0, $bytes)

    $threshold = 30

    for ($i = 0; $i -lt $arr.Length; $i += 4) {
        $b = $arr[$i]; $g2 = $arr[$i+1]; $r = $arr[$i+2]
        $dist = [Math]::Sqrt(([int]$r-255)*([int]$r-255) + ([int]$g2-255)*([int]$g2-255) + ([int]$b-255)*([int]$b-255))
        if ($dist -le $threshold) {
            $arr[$i+3] = 0   # fully transparent
        } elseif ($dist -le ($threshold * 4)) {
            $alpha = [byte]([float]($dist - $threshold) / ($threshold * 3) * 255)
            $arr[$i+3] = $alpha
        }
        # else keep pixel as-is (alpha stays 255)
    }

    [System.Runtime.InteropServices.Marshal]::Copy($arr, 0, $data.Scan0, $bytes)
    $out.UnlockBits($data)
    $out.Save($dst, [System.Drawing.Imaging.ImageFormat]::Png)
    $bmp.Dispose(); $out.Dispose()
    Write-Host "DONE"
} catch {
    Write-Host "ERROR: $_"
}
