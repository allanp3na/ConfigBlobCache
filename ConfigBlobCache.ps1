cls
asnp *sharepoint* -ErrorAction SilentlyContinue

$listwebapps = Get-SPWebApplication
$webapps = $listwebapps.url

function Show-Menu{
    Clear-Host
    Write-Host "******************************************************"
    Write-Host "WebApplications da Farm."
    Write-Host ""
    for ($i = 0; $i -lt $webapps.Count; $i++){
        Write-Host ('{0,10}. {1}' -f ($i + 1), $webapps[$i]) 
    }
    Write-Host " q. Sair."
    Write-Host ""
    Write-Host "******************************************************"
    Write-Host ""
    Write-Host "Selecione a WebApp para executar as configurações de BlobCache: " -ForegroundColor Yellow -NoNewline
    $UserInput = Read-Host 
    if ($UserInput -eq 'q') { break }
        foreach($input in $UserInput.Split(' ')) {
            if ([int]::TryParse($input,[ref]$null) -and 1..$webapps.Count -contains [int]$input){
                $webappsIndex = [int]$input - 1
                Write-Host ""
                Write-Host "*** $($webapps[$webappsIndex]) ***" -ForegroundColor Yellow -BackgroundColor DarkCyan
                #sleep 2
                $webselecionado = $($webapps[$webappsIndex])
                Show-Config
                #$webappBlob = Get-SPWebApplication $webselecionado
                #$Bloblocation = $webappBlob.WebConfigModifications.value[4]
                #Write-Host "Pasta do BlobCache $Bloblocation"
            } else {
                $availableOptions = 1..$webapps.Count -join ','
                Write-Host ""
                Write-Host "Opcao invalida!" -ForegroundColor Red
                Write-Host "Digite apenas uma das opcoes: " -NoNewline
                Write-Host $availableOptions -ForegroundColor Yellow -nonewline
                Write-Host " ou " -NoNewline
                Write-Host "q" -ForegroundColor Magenta -NoNewline
                Write-Host " para sair." 
                Write-Host ""
            }
      }
}

$Config = @("Verificar", "Habilitar", "Desabilitar", "Limpeza do Blobcache")
 function Show-Config{

    Write-Host ""
    Write-Host "******************************************************"
    Write-Host "Configuracoes de BlobCache."
    Write-Host ""
    for ($i = 0; $i -lt $Config.Count; $i++){
        Write-Host ('{0,10}. {1}' -f ($i + 1), $Config[$i]) 
    }
    Write-Host " q. Sair."
    Write-Host "******************************************************"
    Write-Host ""
    Write-Host "Selecione a configuracao para executar no WebApp: " -ForegroundColor Yellow -NoNewline
    $UserInput = Read-Host 
        if ($UserInput -eq 'q') { break }
        foreach($input in $UserInput.Split(' ')) {
            if ([int]::TryParse($input,[ref]$null) -and 1..$Config.Count -contains [int]$input) 
            {
                $ConfigIndex = [int]$input - 1
                Write-Host ""
                Write-Host "*** $($Config[$ConfigIndex]) ***" -ForegroundColor Yellow -BackgroundColor DarkCyan
                Write-Host ""
                #sleep 2
                $Configselect = $($Config[$ConfigIndex])
                if($Configselect -eq 'Verificar'){
                Verificar-Blob
                }
                if($Configselect -eq 'Habilitar'){
                Habilitar-Blob
                }
                if($Configselect -eq 'Desabilitar'){
                Desabilitar-Blob
                }
                if($Configselect -eq 'Limpeza do Blobcache'){
                Limpeza-Blob
                }
                 } else {
                $availableOptions = 1..$Config.Count -join ','
                Write-Host ""
                Write-Host "Opcao invalida!" -ForegroundColor Red
                Write-Host "Digite apenas uma das opcoes: " -NoNewline
                Write-Host $availableOptions -ForegroundColor Yellow -nonewline
                Write-Host " ou " -NoNewline
                Write-Host "q" -ForegroundColor Magenta -NoNewline
                Write-Host " para sair." 
                Write-Host ""
            }
      }
            
}

function Verificar-Blob{

    $WebappBlob = Get-SPWebApplication $Webselecionado
    $BlobLocation = $null
    $BlobTrue = $null
    Write-Host $WebappBlob.url -ForegroundColor Yellow -BackgroundColor DarkCyan
    Write-Host "" 
    if ($WebappBlob.WebConfigModifications.value -match "BlobCache" -and $WebappBlob.WebConfigModifications.name -match "enable" -and $WebappBlob.WebConfigModifications.value -like "true"){
        $BlobLocation = $webappBlob.WebConfigModifications.value -match 'BlobCache'
        $BlobTrue = $webappBlob.WebConfigModifications.value -eq 'True'
        Write-Host "BlobCache ativo: " -NoNewline -ForegroundColor Yellow
        Write-Host $BlobTrue -ForegroundColor Green
        Write-Host "Caminho BlobCache: " -NoNewline -ForegroundColor Yellow
        Write-Host $BlobLocation -ForegroundColor Green
        Write-Host ""
    
        } else {
        $BlobLocation = $webappBlob.WebConfigModifications.value -match 'BlobCache'
        $BlobTrue = $webappBlob.WebConfigModifications.value -eq 'True'
        Write-Host ""
        Write-Host "BlobCache inexistente." -ForegroundColor Red
        Write-Host ""
        Write-Host "BlobCache ativo: " -NoNewline -ForegroundColor Yellow
        Write-Host $BlobTrue -ForegroundColor Red
        Write-Host "Caminho BlobCache: " -NoNewline -ForegroundColor Yellow
        Write-Host $BlobLocation -ForegroundColor Red
        Write-Host ""
    }
    
}


function Habilitar-Blob{
    
    $WebappHabilitar = Get-SPWebApplication $Webselecionado
    $BlobCacheFolder = $null
    if ($WebappHabilitar.WebConfigModifications.value -match "BlobCache" -and $WebappHabilitar.WebConfigModifications.name -match "enable" -and $WebappHabilitar.WebConfigModifications.value -like "True")  {
        Write-Host ""
        Write-Host "BlobCache existente." -ForegroundColor Red
        Write-Host "Verifique ou Desabilite antes de Habilitar." -ForegroundColor Yellow
        Write-Host ""
        Break
    }
    Write-Host $WebappHabilitar.url -ForegroundColor Yellow -BackgroundColor DarkCyan
    Write-Host ""
    Write-Host "******************************************************"
    Write-Host ""
    Write-Host "Para habiltiar o BlobCache e necessario digitar o caminho completo da pasta."
    Write-Host "" 
    Write-Host "Exemplo: D:\BlobCache\15"
    Write-Host "Exemplo: E:\BlobCache\PortalTeste"
    Write-Host "Exemplo: F:\BlobCache\TestePortal"
    Write-Host ""    
    Write-Host "******************************************************"
    Write-Host ""
    Write-Host "Digite o caminho completo da pasta do BlobCache: " -NoNewline -ForegroundColor Yellow
    $BlobCacheFolder = Read-Host
    if ($BlobCacheFolder -eq '') { 
        Write-Host ""
        Write-Host "Caminho vazio invalido."  -ForegroundColor Red
        Break 
    }

    # SPWebConfigModification to enable BlobCache 
    $configMod1 = New-Object Microsoft.SharePoint.Administration.SPWebConfigModification 
    $configMod1.Path = "configuration/SharePoint/BlobCache"
    $configMod1.Name = "enabled"
    $configMod1.Sequence = 0 
    $configMod1.Owner = "BlobCacheMod"
    $configMod1.Type = 1 
    $configMod1.Value = "True"
        
    # SPWebConfigModification to enable client-side Blob caching (max-age) 
    $configMod2 = New-Object Microsoft.SharePoint.Administration.SPWebConfigModification 
    $configMod2.Path = "configuration/SharePoint/BlobCache"
    $configMod2.Name = "max-age"
    $configMod2.Sequence = 0 
    $configMod2.Owner = "BlobCacheMod"
    $configMod2.Type = 1 
    $configMod2.Value = "86400"
        
    # SPWebConfigModification to change the default location for the Blob Cache files
    $configMod3 = New-Object Microsoft.SharePoint.Administration.SPWebConfigModification
    $configMod3.Path = "configuration/SharePoint/BlobCache"
    $configMod3.Name = "location"
    $configMod3.Sequence = "0"
    $configMod3.Owner = "BlobCacheMod"
    $configMod3.Type = 1
    $configMod3.Value = $BlobCacheFolder
    
    # SPWebConfigModification to change the path attribute
    $configMod4 = New-Object Microsoft.SharePoint.Administration.SPWebConfigModification 
    $configMod4.Path = "configuration/SharePoint/BlobCache"
    $configMod4.Name = "path"
    $configMod4.Sequence = 0 
    $configMod4.Owner = "BlobCacheMod"
    $configMod4.Type = 1 
    $configMod4.Value = "\.(exe|zip|pdf|doc|docx|xls|xlsx|woff|eot|ttf|svg|gif|jpg|jpeg|jpe|jfif|bmp|dib|tif|tiff|themedbmp|themedcss|themedgif|themedjpg|themedpng|ico|png|wdp|hdp|css|js|asf|avi|flv|m4v|mov|mp3|mp4|mpeg|mpg|rm|rmvb|wma|wmv|ogg|ogv|oga|webm|xap)$"
        
    # SPWebConfigModification to set disk size Blob caching in GB (maxSize) 
    $configMod5 = New-Object Microsoft.SharePoint.Administration.SPWebConfigModification 
    $configMod5.Path = "configuration/SharePoint/BlobCache"
    $configMod5.Name = "maxSize"
    $configMod5.Sequence = 0 
    $configMod5.Owner = "BlobCacheMod"
    $configMod5.Type = 1 
    $configMod5.Value = "25"

    #omitVaryStar
    $configMod6 = New-Object Microsoft.SharePoint.Administration.SPWebConfigModification 
    $configMod6.Path = "configuration/system.web"
    $configMod6.Name = "caching"
    $configMod6.Sequence = 65536 
    $configMod6.Owner = "SomeUniqueIdentifier"
    $configMod6.Type = 0 
    $configMod6.Value = "<caching/>"

    $configMod7= New-Object Microsoft.SharePoint.Administration.SPWebConfigModification 
    $configMod7.Path = "configuration/system.web/caching"
    $configMod7.Name = 'outputCache[@omitVaryStar="true"]'
    $configMod7.Sequence = 65536 
    $configMod7.Owner = "SomeUniqueIdentifier"
    $configMod7.Type = 0
    $configMod7.Value = '<outputCache omitVaryStar="true"/>'
    
    Write-Host ""
    Write-Host "Habilitando as configurações de Blobcahe." -ForegroundColor Yellow
    $webappHabilitar.WebConfigModifications.Add($configMod1) 
    $webappHabilitar.WebConfigModifications.Add($configMod2)
    $webappHabilitar.WebConfigModifications.Add($configMod3)
    $webappHabilitar.WebConfigModifications.Add($configMod4)
    $webappHabilitar.WebConfigModifications.Add($configMod5)
    $webappHabilitar.WebConfigModifications.Add($configMod6)
    $webappHabilitar.WebConfigModifications.Add($configMod7)
    $webappHabilitar.Update() 
    $webappHabilitar.Parent.ApplyWebConfigModifications()
    
    Write-Host ""
    sleep 20
    Write-Host -ForegroundColor Green "BlobCache habilitado com sucesso!"
    Write-Host ""
}


function Desabilitar-Blob{

    $WebappDesabilitar = Get-SPWebApplication $Webselecionado
    Write-Host "******************************************************"
    Write-Host ""  
    Write-Host "Remover todas configurações de Blobcahe?" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Digite " -ForegroundColor Yellow -NoNewline 
    Write-Host "y" -ForegroundColor Yellow -BackgroundColor DarkCyan -NoNewline 
    Write-Host  " para Confirmar ou " -ForegroundColor Yellow -NoNewline 
    Write-Host  "x" -ForegroundColor Yellow -BackgroundColor DarkCyan -NoNewline 
    Write-Host  " para Sair: " -NoNewline -ForegroundColor Yellow
    $ConfirmWebDesabilitar = Read-Host
    Write-Host ""
    if($ConfirmWebDesabilitar -eq 'y'){
        $WebappDesabilitar.WebConfigModifications.Clear()
        $WebappDesabilitar.Update() 
        $WebappDesabilitar.Parent.ApplyWebConfigModifications()
        sleep 20
        Write-Host ""
        Write-Host -ForegroundColor Green "BlobCache desabilitado com sucesso!"
        Write-Host ""
        Write-Host "******************************************************"
        Write-Host ""
    } else {Break}
}

 function Limpeza-Blob{

    $LimpezaBlob = Get-SPWebApplication $Webselecionado
    $BlobLocation = $null
    $BlobTrue = $null
    if ($LimpezaBlob.WebConfigModifications.value -match "BlobCache" -and $LimpezaBlob.WebConfigModifications.name -match "enable" -and $LimpezaBlob.WebConfigModifications.value -like "True")  {
        $BlobLocation = $LimpezaBlob.WebConfigModifications.value -match 'BlobCache'
        $BlobTrue = $LimpezaBlob.WebConfigModifications.value -eq 'True'
        Write-Host "******************************************************"
        Write-Host ""
        Write-Host "Configuracao de BlobCache:"
        Write-Host ""
        Write-Host "BlobCache ativo: " -NoNewline
        Write-Host $BlobTrue -ForegroundColor Green
        Write-Host "Caminho BlobCache: " -NoNewline 
        Write-Host $BlobLocation -ForegroundColor Green 
        Write-Host ""
        Write-Host "Realizar a limpeza do BlobCache?"-ForegroundColor Yellow
        Write-Host "Digite " -ForegroundColor Yellow -NoNewline 
        Write-Host "y" -ForegroundColor Yellow -BackgroundColor DarkCyan -NoNewline 
        Write-Host  " para Confirmar ou " -ForegroundColor Yellow -NoNewline 
        Write-Host  "x" -ForegroundColor Yellow -BackgroundColor DarkCyan -NoNewline 
        Write-Host  " para Sair: " -NoNewline -ForegroundColor Yellow
        $ConfirmWebLimpeza = Read-Host
        Write-Host ""
        if($ConfirmWebLimpeza -eq 'y'){
            $listservers = Get-SPServer | where { $_.role -ne "Invalid"} 
            $servers = $listservers.Name
            Write-Host ""
            Write-host 'Iniciando limpeza do BlobCache.' -ForegroundColor Yellow
            $configModOff = New-Object Microsoft.SharePoint.Administration.SPWebConfigModification 
            $configModOff.Path = "configuration/SharePoint/BlobCache"
            $configModOff.Name = "enabled"
            $configModOff.Sequence = 0 
            $configModOff.Owner = "BlobCacheMod"
            $configModOff.Type = 1 
            $configModOff.Value = "True"
            $null = $LimpezaBlob.WebConfigModifications.Remove($configModOff)
            $LimpezaBlob.Update() 
            $LimpezaBlob.Parent.ApplyWebConfigModifications()
            sleep 30
            foreach($server in $servers){
                Write-Host ""
              Write-Host "Servidor: " -NoNewline
                Write-Host $server -ForegroundColor Cyan -NoNewline
                $netbloblocation = "\\$server\$($BlobLocation.replace(':','$'))"
                $testPath = Test-Path "$netbloblocation"
                if($testPath -eq $true){
                    $testPath = Test-Path "$netbloblocation\BackupBlob"
                    if($testPath -ne $true){
                        $newbkp = New-Item -Name "BackupBlob" -ItemType "Directory" -Path $netbloblocation
                    }
                    sleep 1
                    $time = (Get-Date).ToString("_ddMMyyyy-HHmmss")
                  Get-ChildItem -Path $netbloblocation | Where {$_.Name -ne "BackupBlob"} | Rename-Item -NewName {$_.Name + "$time"} -Force 
                    sleep 1
                    Get-ChildItem -Path $netbloblocation | Where {$_.Name -ne "BackupBlob"} |Move-Item -Destination "$netbloblocation\BackupBlob" -Force 
                    Write-Host " Concluido." -ForegroundColor Green
                sleep 2
                    } else { Write-Host " Pasta inexistente." -ForegroundColor Red }
            }
            Write-Host ""
            Write-host 'Finalizando limpeza do Blobcache.' -ForegroundColor Yellow
            $configModOn = New-Object Microsoft.SharePoint.Administration.SPWebConfigModification 
            $configModOn.Path = "configuration/SharePoint/BlobCache"
            $configModOn.Name = "enabled"
            $configModOn.Sequence = 0 
            $configModOn.Owner = "BlobCacheMod"
            $configModOn.Type = 1 
            $configModOn.Value = "True"
            $null = $LimpezaBlob.WebConfigModifications.Add($configModOn)
            $LimpezaBlob.Update() 
            $LimpezaBlob.Parent.ApplyWebConfigModifications()
            
            sleep 20
            Write-Host ""
            Write-host 'Limpeza concluida com sucesso!' -ForegroundColor Green
            Write-Host ""
            Write-Host "******************************************************"
          }
    } else {
    Write-Host ""
    Write-Host "BlobCache nao encontrado." -ForegroundColor Red
    Write-Host ""
    }

}

while ($true) 
{
    Show-Menu
    Write-Host ""
    $null = Read-Host "Precione ENTER para voltar"
}
