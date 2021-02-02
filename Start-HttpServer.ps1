##Quick and dirty Administrator test, to prevent any red walls of death

function Test-Administrator  
{  
    [OutputType([bool])]
    param()
    process {
        [Security.Principal.WindowsPrincipal]$user = [Security.Principal.WindowsIdentity]::GetCurrent();
        return $user.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator);
    }
}

if(-not (Test-Administrator))
{
    # TODO: define proper exit codes for the given errors 
    Write-Error "This script must be executed as Administrator.";
    exit 1;
}

$ErrorActionPreference = "Stop";

##MAIN##

$VerbosePreference="Continue"
Clear-Host
$Continue=$true

##Variable and object setup##

$Listener=[System.Net.HttpListener]::new()
$address = Read-Host -Prompt "IP address to listen at."
$port = Read-Host -Prompt "Port to listen on."
$listenerhost = "http://" + $address+ ":" + $port + "/"
$Listener.Prefixes.Add($listenerhost)

#Start the Listener
$Listener.Start()

#Lets START THE LOOP!
while ($Continue) {
  $Context=$Listener.GetContext()
  Write-Verbose $Context.Request.RawUrl
  if ($Context.Request.QueryString.HasKeys()) {
    $Continue=$false
    $Context.Request.QueryString.Keys | ForEach-Object { "$_ = $($Context.Request.QueryString.GetValues("$_"))" }
  }

  ##Make Sure we're working##
  else {
    if ($Context.Request.Url.Segments.Count -eq 1) {
      $Content=[System.Text.Encoding]::UTF8.GetBytes("<html><body>I'm Alive</body></html>")
      $Context.Response.ContentType="text/html"
      $Context.Response.ContentEncoding=[System.Text.Encoding]::UTF8
      $Context.Response.ContentLength64=$Content.Length
      $Context.Response.KeepAlive=$false
      $Context.Response.StatusCode=200
      $Context.Response.StatusDescription="OK"
      $Context.Response.OutputStream.Write($Content, 0, $Content.Length)
      $Context.Response.OutputStream.Close()
      $Context.Response.Close()
    }

    ##File responses. Grabs from C:\url##
    else {
      if ($Context.Request.Url.LocalPath.EndsWith(".zip")) { $Context.Response.ContentType="application/octet-stream" }
      elseif ($Context.Request.Url.LocalPath.EndsWith(".exe")) { $Context.Response.ContentType="application/octet-stream" }
      elseif ($Context.Request.Url.LocalPath.EndsWith(".msi")) { $Context.Response.ContentType="application/octet-stream" }
      elseif ($Context.Request.Url.LocalPath.EndsWith(".txt")) { $Context.Response.ContentType="application/octet-stream" }
      elseif ($Context.Request.Url.LocalPath.EndsWith(".json")) { $Context.Response.ContentType="application/octet-stream" }
      else { $Context.Response.ContentType="text/plain" }
      if (Test-Path -Path ("C:"+$Context.Request.Url.LocalPath.Replace("/","\"))) {
        $Content=Get-Content -Encoding Byte -Path ("C:"+$Context.Request.Url.LocalPath.Replace("/","\"))
        $Context.Response.ContentEncoding=[System.Text.Encoding]::Default
        $Context.Response.ContentLength64=$Content.Length
        $Context.Response.KeepAlive=$false
        $Context.Response.StatusCode=200
        $Context.Response.StatusDescription="OK"
        $Context.Response.OutputStream.Write($Content, 0, $Content.Length)
        $Context.Response.OutputStream.Close()
        $Context.Response.Close()
      }

    
      else {
        Write-Warning "File not found."
        $Content=[System.Text.Encoding]::UTF8.GetBytes("<html><body>File not found.</body></html>")
        $Context.Response.ContentType="text/html"
        $Context.Response.ContentEncoding=[System.Text.Encoding]::UTF8
        $Context.Response.ContentLength64=$Content.Length
        $Context.Response.KeepAlive=$false
        $Context.Response.StatusCode=404
        $Context.Response.StatusDescription="File not found"
        $Context.Response.OutputStream.Write($Content, 0, $Content.Length)
        $Context.Response.OutputStream.Close()
        $Context.Response.Close()
      }
    }
  }
}
$Listener.Stop()


#http://x.x.x.x:xxxx/?$Continue=$false  --- This will make the listener die.#
