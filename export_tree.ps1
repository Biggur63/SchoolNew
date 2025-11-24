# export_tree.ps1
# Скрипт для генерации дерева Hugo-сайта в консоль и JSON

$rootPath = Get-Location

# --- Функция для дерева с отступами ---
Function Get-TreeIndented {
    param ($Path, $Level = 0)
    $indent = "  " * $Level
    Get-ChildItem -Path $Path -Force | Where-Object { $_.Name -notmatch '^(?:\.|node_modules)$' } | ForEach-Object {
        if ($_.PSIsContainer) {
            Write-Output "$indent$($_.Name)/"
            Get-TreeIndented -Path $_.FullName -Level ($Level + 1)
        } else {
            Write-Output "$indent$($_.Name)"
        }
    }
}

# --- Функция для JSON ---
Function Get-TreeJson {
    param ($Path)
    $children = @()
    Get-ChildItem -Path $Path -Force | Where-Object { $_.Name -notmatch '^(?:\.|node_modules)$' } | ForEach-Object {
        if ($_.PSIsContainer) {
            $children += @{
                name = $_.Name
                children = (Get-TreeJson -Path $_.FullName)
            }
        } else {
            $children += @{ name = $_.Name }
        }
    }
    return $children
}

# --- Вывод дерева с отступами ---
Write-Output "`n--- Дерево сайта ---"
Get-TreeIndented -Path $rootPath

# --- Вывод JSON ---
$jsonTree = @{
    name = $rootPath.Path
    children = Get-TreeJson -Path $rootPath
} | ConvertTo-Json -Depth 10

Write-Output "`n--- Дерево в формате JSON ---"
Write-Output $jsonTree

# --- При желании сохранить JSON в файл ---
# $jsonTree | Out-File -FilePath "site_tree.json" -Encoding UTF8

