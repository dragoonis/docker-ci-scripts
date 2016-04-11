#!/usr/bin/env php
<?php
$stagingHostFormat = '%s.cs-testing-dv.uk.company.com';
$map = json_decode(shell_exec('php ' . __DIR__ . '/get-tag-to-ports-map.php'), true);
$hostsPortMap = '';
foreach($map as $branch => $portNum) {
    $host = sprintf($stagingHostFormat, $branch);
    $hostsPortMap .= <<<EOF
    {$host} $portNum;

EOF;
}

$vhostTemplatePath = __DIR__ . '/../opt/nginx/staging/multi-site-vhost-template.conf';
$vhost = file_get_contents($vhostTemplatePath);
$vhost = str_replace('{{hostsPortMap}}', $hostsPortMap, $vhost);

// Write out the generated file
$vhostGenPath = __DIR__ . '/../opt/nginx/staging/multi-site-vhost-gen.conf';
file_put_contents($vhostGenPath, $vhost);

// Output the vhost to STDOUT so it can be useful for piping other things
echo $vhost;
exit(0);
