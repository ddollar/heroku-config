require "heroku/command/base"
require "heroku/command/config"

class Heroku::Command::Config < Heroku::Command::Base

  # config:pull
  #
  # pull heroku config vars down to the local environment
  #
  # will not overwrite existing config vars by default
  #
  # -i, --interactive  # prompt whether to overwrite each config var
  # -o, --overwrite    # overwrite existing config vars
  #
  def pull
    interactive = options[:interactive]
    overwrite   = options[:overwrite]

    config = merge_config(remote_config, local_config, interactive, overwrite)
    write_local_config config
    display "Config for #{app} written to #{filename}"
  end

  # config:push
  #
  # push local config vars to heroku
  #
  # will not overwrite existing config vars by default
  #
  # -i, --interactive  # prompt whether to overwrite each config var
  # -o, --overwrite    # overwrite existing config vars
  #
  def push
    interactive = options[:interactive]
    overwrite   = options[:overwrite]

    config = merge_config(local_config, remote_config, interactive, overwrite)
    write_remote_config config
    display "Config in #{filename} written to #{app}"
  end

private ######################################################################

  def filename
    name = options[:filename]
    return name unless name.nil? || name.empty?
    ".env"
  end

  def local_config
    File.read(filename).split("\n").inject({}) do |hash, line|
      if line =~ /\A([A-Za-z_0-9]+)=(.*)\z/
        hash[$1] = $2
      end
      hash
    end
  rescue
    {}
  end

  def remote_config
    api.config_vars(app)
  end

  def write_local_config(config)
    File.open(filename, "w") do |file|
      config.keys.sort.each do |key|
        file.puts "#{key}=#{config[key]}"
      end
    end
  end

  def write_remote_config(config)
    remote_config = api.config_vars(app)

    add_config_vars = config.inject({}) do |hash, (key,val)|
      hash[key] = val unless remote_config[key] == val
      hash
    end

    api.add_config_vars(app, add_config_vars)
  end

  def merge_config(source, target, interactive=false, overwrite=false)
    if interactive
      source.keys.sort.inject(target) do |hash, key|
        value = source[key]
        display "%s: %s" % [key, value]
        hash[key] = value if confirm("Overwite? (y/N)")
        hash
      end
    else
      overwrite ? target.merge(source) : source.merge(target)
    end
  end

end

