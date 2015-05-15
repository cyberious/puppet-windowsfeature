Puppet::Type.newtype(:windowsfeature) do
  desc 'Manage windows features'

  ensurable

  newparam(:name, :namevar => true)

  newparam(:feature_name, :array_matching => :all) do
    desc 'features to install'

  end

  newparam(:includemanagementtools) do
    newvalues(true, false)
  end

  newparam(:includesubfeatures) do
    newvalues(true, false)
  end

  newparam(:source)

  newparam(:timeout) do
    defaultto 300
  end

  newproperty(:display_name) do
    desc 'DisplayName: Read-Only'
  end

  newproperty(:feature_type) do
    desc 'FeatureType, role or service role: Read-Only'
  end

  newproperty(:sub_features) do
    desc 'SubFeatures that are included: Read-Only'
  end
end
