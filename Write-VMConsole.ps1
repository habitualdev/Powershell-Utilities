param
(
[string]$File1
)

##Grab some libs and create a mouse click type

[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") 
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") 
Add-Type -MemberDefinition '[DllImport("user32.dll")] public static extern void mouse_event(int flags, int dx, int dy, int cButtons, int info);' -Name U32 -Namespace W;


##MAIN##
    ##Get the file and convert it to base64
$Content1 = get-content $File1 -Raw
#$Bytes = [System.Text.Encoding]::UTF8.GetBytes($Content1)
#$Encoded = [System.Convert]::ToBase64String($Bytes)
$Encoded =[Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($Content1))
$stringarray = $Encoded.ToCharArray()
foreach($line in $stringarray)
{
       [W.U32]::mouse_event(6,0,0,0,0)
       [System.Windows.Forms.SendKeys]::SendWait($line)
       [System.Windows.Forms.SendKeys]::SendWait("{ENTER}")      
}

##RESOURCES##
#Base64 Decode
#[Text.Encoding]::Utf8.GetString([Convert]::FromBase64String('BASE64STRINGHERE'))
