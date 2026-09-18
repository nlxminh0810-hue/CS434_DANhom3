param(
    [string]$Server = '(localdb)\MSSQLLocalDB',
    [ValidatePattern('^[A-Za-z][A-Za-z0-9_]{0,63}$')]
    [string]$Database = 'SoccerHub',
    [switch]$Seed,
    [switch]$Test
)
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Data

function Open-Database([string]$Catalog) {
    $builder = New-Object System.Data.SqlClient.SqlConnectionStringBuilder
    $builder['Data Source'] = $Server
    $builder['Initial Catalog'] = $Catalog
    $builder['Integrated Security'] = $true
    $builder['Connect Timeout'] = 20
    $connection = New-Object System.Data.SqlClient.SqlConnection $builder.ConnectionString
    $connection.Open()
    return $connection
}

function Invoke-Script($Connection, [string]$File) {
    $sql = [IO.File]::ReadAllText((Join-Path $PSScriptRoot $File), [Text.Encoding]::UTF8)
    foreach ($batch in [regex]::Split($sql, '(?im)^\s*GO\s*\r?$')) {
        if ([string]::IsNullOrWhiteSpace($batch)) { continue }
        $command = $Connection.CreateCommand()
        try {
            $command.CommandTimeout = 120
            $command.CommandText = $batch
            [void]$command.ExecuteNonQuery()
        } finally { $command.Dispose() }
    }
    Write-Host "OK $File"
}

$master = Open-Database 'master'
try {
    $command = $master.CreateCommand()
    $command.CommandText = "SELECT DB_ID(@name)"
    [void]$command.Parameters.AddWithValue('@name', $Database)
    $existing = $command.ExecuteScalar()
    $command.Dispose()
    if ($existing -is [DBNull] -or $null -eq $existing) {
        $command = $master.CreateCommand()
        # Database name is validated above; data/log files remain inside the workspace.
        $storage = Join-Path $PSScriptRoot '.data'
        [void][IO.Directory]::CreateDirectory($storage)
        $dataPath = (Join-Path $storage "$Database.mdf").Replace("'", "''")
        $logPath = (Join-Path $storage "${Database}_log.ldf").Replace("'", "''")
        $command.CommandText = "CREATE DATABASE [$Database] ON PRIMARY (NAME=N'$Database',FILENAME=N'$dataPath') LOG ON (NAME=N'${Database}_log',FILENAME=N'$logPath') COLLATE Latin1_General_100_CI_AS"
        [void]$command.ExecuteNonQuery()
        $command.Dispose()
        Write-Host "Created $Database"
    }
} finally { $master.Dispose() }

$connection = Open-Database $Database
try {
    foreach ($file in @('01-schema.sql','02-procedures.sql','03-views.sql')) { Invoke-Script $connection $file }
    if ($Seed) { Invoke-Script $connection '04-seed.sql' }
    if ($Test) { Invoke-Script $connection 'tests.sql' }
    Write-Host "Ready: $Server / $Database"
} finally { $connection.Dispose() }
