#!/usr/bin/env php
<?php
$ret = shell_exec('docker ps --format "{{.ID}} {{.Image}}" | grep pplweb');
$containers = explode("\n", $ret);
$clean = [];
foreach ($containers as $c) {

    if (empty($c)) {
        continue;
    }

    list($containerId, $imageName) = explode(" ", $c);

    // Get Image Tag
    $imageTag = $imageName;
    if ( ($pos = strrpos($imageName, ':')) !== false ) {
        $imageTag = substr($imageName, ($pos + 1));
    }
    $imageTag = strtolower($imageTag);

    // Get the host port
    $hostPort = trim(shell_exec(sprintf(
        'docker inspect --format "{{range .NetworkSettings.Ports}}{{range .}}{{.HostPort}}{{end}}{{end}}" %s',
        $containerId
    )));

    if(empty($hostPort) || !is_numeric($hostPort)) {
        continue;
    }

    $clean[$imageTag] = $hostPort;
}
$output = json_encode($clean);
echo $output;
exit(0);
