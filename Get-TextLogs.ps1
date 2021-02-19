#Load Some libraries
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") 
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") 

#Set up variables and objects
$filepath=Read-Host -Prompt "File to be monitored: "

[int]$refreshrate=Read-Host -Prompt "Refresh Rate (in seconds): "
$refreshrate=$refreshrate*1000

$Form = New-Object System.Windows.Forms.Form    
$Form.Size = New-Object System.Drawing.Size(720,980)
$Form.FormBorderStyle = 'FixedDialog'
$Form.MaximizeBox = $false
$Icon = [system.drawing.icon]::ExtractAssociatedIcon($PSHOME + "\powershell.exe")
$Form.Icon = $Icon
$Form.Text = "Log View"

############################################## Describe/Create OutPutBox

$outputBox = New-Object System.Windows.Forms.TextBox 
$outputBox.Location = New-Object System.Drawing.Size(20,20) 
$outputBox.Size = New-Object System.Drawing.Size(680,900) 
$outputBox.MultiLine = $True 
$outputBox.ReadOnly = $True
$outputBox.Font = New-Object System.Drawing.Font("Calibri",11,[System.drawing.FontStyle]::Bold)
$outputBox.ForeColor = [Drawing.Color]::Green
$outputBox.ScrollBars = "Vertical" 
$Form.Controls.Add($outputBox) 

##############################################
#Not the greatest way to implement refresh but ¯\_(ツ)_/¯

$timer = new-object Windows.Forms.Timer

$timer.Interval=$refreshrate
##############################################

$outputBox.AppendText((Get-Content $filepath | Out-String))
$logs=(Get-Content $filepath | Out-String)
Set-Content C:\tmp\templog.txt -Value $logs
#$timer.add_Tick({GetProcesses})
$timer.add_Tick({
                $diff=(Compare-Object -ReferenceObject (Get-Content C:\tmp\templog.txt) -DifferenceObject $(Get-Content C:\share\install.txt)  | where {$_.SideIndicator -match "=>"}).InputObject;
                foreach ($d in $diff){
                    $outputBox.AppendText(("$d `r`n"))
                    $outoutBox.AppendText("`r`n"); 
                    }
                Write-Host $diff -ErrorAction SilentlyContinue
                $logs=(Get-Content $filepath | Out-String)
                Set-Content C:\tmp\templog.txt -Value $logs
                $Form.Refresh()
                })
$timer.Start()
##############################################

$Form.Add_Shown({$Form.Activate()})
[void] $Form.ShowDialog()
#When window is closed, disposes of objects
$timer.Stop()
$timer.Dispose()
