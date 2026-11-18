<?php
// usage:
// php delete_missing.php 111bb07fb8925762cf65d198155a77d9fa819afaee5a13efceb4aba9b54e7e66 http://z80.ubuntu.wsl:8080/api_jsonrpc.php /root/zabbix-source/templates/db/mssql_odbc/template_db_mssql_odbc.yaml

// program expects to receive 3 arguments. all are mandatory
[, $auth, $api_url, $path] = $argv + array_fill(0, 4, '');

// check if 1st argument 'sid' has been specified
$auth !== '' or die('Define api key'.PHP_EOL);

// check if 2nd argument API URL has been defined
$api_url !== '' or die('Define api URL. for example http://127.0.0.1/api_jsonrpc.php'.PHP_EOL);

// check if 3rd argument is specified 
($path !== '' && file_exists($path)) or die("Incorrect path $path".PHP_EOL);

//echo $path,PHP_EOL;

// define a standart template import API
$request = json_encode([
    'jsonrpc' => '2.0',
    'method' => 'configuration.import',
    'params' => [
        'format' => 'yaml',
        'rules' => [
            'template_groups' => ['updateExisting' => true, 'createMissing' => true],
            'host_groups' => ['updateExisting' => true, 'createMissing' => true],
            'templates' => ['updateExisting' => true, 'createMissing' => true],
            'valueMaps' => ['updateExisting' => true, 'createMissing' => true, 'deleteMissing' => true],
            'templateDashboards' => ['updateExisting' => true, 'createMissing' => true, 'deleteMissing' => true],
            'templateLinkage' => ['createMissing' => true, 'deleteMissing' => true],
            'items' => ['updateExisting' => true, 'createMissing' => true, 'deleteMissing' => true],
            'discoveryRules' => ['updateExisting' => true, 'createMissing' => true, 'deleteMissing' => true],
            'triggers' => ['updateExisting' => true, 'createMissing' => true, 'deleteMissing' => true],
            'graphs' => ['updateExisting' => true, 'createMissing' => true, 'deleteMissing' => true],
            'httptests' => ['updateExisting' => true, 'createMissing' => true, 'deleteMissing' => true]
        ],
        'source' => file_get_contents($path)
    ],
    'id' => (string)time()
]);

$response = file_get_contents($api_url, false, stream_context_create([
                'http' => [
                        'method'  => 'POST',
                        'header'  => ['Content-Type: application/json', 'Authorization: Bearer '.$auth],
                        'content' => $request
        ],'ssl' => [
                        'allow_self_signed'     => true,
                        'verify_peer'           => false,
                        'verify_peer_name'      => false
	]]));

$response = json_decode($response, true);

echo json_encode($response, JSON_PRETTY_PRINT),PHP_EOL;

