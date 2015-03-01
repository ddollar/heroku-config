require "yaml"
require "heroku/command/config"

class Heroku::Command::Config

  # config:pull
  #
  # pull heroku config vars down to the local environment
  #
  # will not overwrite existing config vars by default
  #
  # -i, --interactive  # prompt whether to overwrite each config var
  # -o, --overwrite    # overwrite existing config vars
  # -e, --env ENV      # specify target filename
  # -q, --quiet        # suppress output to stdout
  #
  def pull
    interactive = options[:interactive]
    overwrite   = options[:overwrite]
    quiet       = options[:quiet]

    config = merge_config(remote_config, local_config, interactive, overwrite)
    write_local_config config
    unless quiet || !STDOUT.tty?
      display "Config for #{app} written to #{local_config_filename}"
    end
  end

  # config:push
  #
  # push local config vars to heroku
  #
  # will not overwrite existing config vars by default
  #
  # -i, --interactive  # prompt whether to overwrite each config var
  # -o, --overwrite    # overwrite existing config vars
  # -e, --env ENV      # specify source filename
  # -q, --quiet        # suppress output to stdout
  #
  def push
    interactive = options[:interactive]
    overwrite   = options[:overwrite]
    quiet       = options[:quiet]

    config = merge_config(local_config, remote_config, interactive, overwrite)
    write_remote_config config
    unless quiet
      display "Config in #{local_config_filename} written to #{app}"
    end
  end

private ######################################################################

  def local_config
    config_data = (STDIN.tty?) ? File.read(local_config_filename) : STDIN.read
    config_data.split("\n").inject({}) do |hash, line|
      # Regexp removes leading " from value
      if line =~ /\A([A-Za-z0-9_]+)="?([^\"]+|\\.)*"?\z/

        # Remove trailing " from value
        v = $2.chomp('"')

        # Let YAML parse the value back (with newlines, etc)
        hash[$1] = YAML.load(%Q(---\n"#{v}"\n))
      elsif line != ""
        puts "ERROR: invalid format (should be FOO=bar) --> '#{line}' "
        exit 0
      end
      hash
    end
  rescue
    {}
  end

  def local_config_filename
    filename = (STDIN.tty?) ? '.env' : 'STDIN'
    @local_config_filename ||= options[:env] || filename
  end

  def remote_config
    api.get_config_vars(app).body
  end

  def write_local_config(config)
    keys = ''
    config.keys.sort.each do |key|
      keys += "#{key}=#{config[key].inspect}\n"
    end

    if STDOUT.tty?
      File.open(local_config_filename, "w") do |file|
        file.puts keys
      end
    else
      puts keys
    end
  end

  def write_remote_config(config)
    add_config_vars = config.inject({}) do |hash, (key,val)|
      hash[key] = val unless remote_config[key] == val
      hash
    end

    api.put_config_vars(app, add_config_vars)
  end

  def merge_config(source, target, interactive=false, overwrite=false)
    if interactive
      source.keys.sort.inject(target) do |hash, key|
        value = source[key]
        display "%s: %s" % [key, value]
        hash[key] = value if confirm("Overwrite? (y/N)")
        hash
      end
    else
      filtered_source = filter_source_with_selected_keys(source)
      overwrite ? target.merge(filtered_source) : filtered_source.merge(target)
    end
  end

  def filter_source_with_selected_keys(source)
    keys = args.any? ? args : source.keys
    source.select { |key,_| keys.include?(key) }
  end
end

