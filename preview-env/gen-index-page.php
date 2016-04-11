#!/usr/bin/env php
<?php

$hostFormat = 'http://%s.cs-testing-st.company.com';
$deploymentsDir = '/appl/deployments/';

if(!is_dir($deploymentsDir)) {
    die('<h1>Error: no deployment dir found</h1>');
}

$dirs = new DirectoryIterator($deploymentsDir);

$html = '';
foreach($dirs as $fileInfo) {

    if($fileInfo->isFile() || $fileInfo->isDot()) {
        continue;
    }

    $hostName = sprintf($hostFormat, strtolower($fileInfo->getFilename()));
    $linkFormat = '<h1><a href="%s">%s</a></h1>';
    $html .= sprintf($linkFormat, $hostName, $fileInfo->getFilename());
}

if(empty($html)) {
    die('<h1>Error: no deployments found in deployment dir</h1>');
}

echo $html;