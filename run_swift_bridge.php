<?php
// PHP Bridge Main for L3WWZ76K1- / termuxSwiftMain sync
$targetDir = __DIR__ . '/Sources/termuxSwiftMain';
$mainFile = $targetDir . '/main.swift';

echo "[PHP Bridge] Checking termuxSwiftMain integration...\n";
if (file_exists($mainFile)) {
    $content = file_get_contents($mainFile);
    echo "[PHP Bridge] main.swift loaded successfully (" . strlen($content) . " bytes).\n";
    $output = @shell_exec('swift --version 2>&1');
    echo "[PHP Bridge] Swift Environment: " . (trim($output) ?: "Swift CLI not active") . "\n";
} else {
    echo "[ERROR] main.swift not found in target path.\n";
    exit(1);
}
?>
