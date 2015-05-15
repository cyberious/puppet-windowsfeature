require 'json'
Puppet::Type::type(:windowsfeature).provide(:powershell) do
  commands :powershell =>
             if File.exists? 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe'
               'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe'
             elsif File.exists? 'C:\Windows\systnative\WindowsPowerShell\v1.0\powershell.exe'
               'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe'
             else
               'powershell.exe'
             end
  mk_resource_methods

  def self.instances
    instances = []
    result = get_features_hash
    result.each do |feature|

      installed = feature['Installed'] ? :present : :absent
      instance = new(
        {
          :name => feature['Name'],
          :feature_name => feature['Name'],
          :ensure => installed,
          :display_name => feature['DisplayName'] || '',
          :sub_features => feature['SubFeatures'],
          :feature_type => feature['FeatureType'] || '',
        })
      debug("Returning instance #{instance} for #{feature['DisplayName']}") if feature['Name'] =~ /powershell/i
      instances << instance
    end

    instances
  end

  def self.get_features_hash
    JSON.parse(powershell([powershell_query]))
  end

  def self.prefetch(resources)
    current_instances = instances
    resources.keys.each do |name|
      if provider = current_instances.find { |i| i.name =~ /#{name}/i }
        resources[name].provider = provider
      end
    end
  end

  def determine_command
    case Facter.value(:kernelversion)
      when /6\.1/ then
        'Add-WindowsFeature'
      else
        'Install-WindowsFeature'
    end
  end

  def build_install_command
    cmd = ["Import-Module ServerManager;"]
    cmd << determine_command
    cmd << name
    cmd << "-IncludeManagementTools" if resource[:includemanagementtools]
    cmd << "-IncludeAllSubFeature" if resource[:includesubfeatures]
    cmd << "-Source #{resource[:source]}" if resource[:source]
    cmd << "-Restart:$#{resource[:restart]}"
    cmd.flatten
  end

  def create
    powershell([build_install_command])
  end

  def destroy
    powershell(["Import-Module ServerManager; Remove-WindowsFeature ${features} -Restart:$${_restart} "])
  end


  def exists?
    return @property_hash[:ensure] == :present || false
  end

  def self.powershell_query
    "Get-WindowsFeature | select Name, Installed, DisplayName, SubFeatures, FeatureType | ConvertTo-Json"
  end

end
