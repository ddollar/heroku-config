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
    unless quiet
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

  ParseError = Class.new(StandardError)
  LINE = /
  \A
  (?:export\s+)?    # optional export
    ([\w\.]+)         # key
    (?:\s*=\s*|:\s+?) # separator
    (                 # optional value begin
    '(?:\'|[^'])*'  #   single quoted value
    |               #   or
    "(?:\"|[^"])*"  #   double quoted value
    |               #   or
    [^#\n]+         #   unquoted value
    )?                # value end
    (?:\s*\#.*)?      # optional comment
    \z
  /x

  def local_config
    File.read(local_config_filename).split("\n").inject({}) do |hash, line|
      if match = line.match(LINE)
        key, value = match.captures

        value ||= ''
        # Remove surrounding quotes
        value = value.strip.sub(/\A(['"])(.*)\1\z/, '\2')

        if $1 == '"'
          value = value.gsub('\n', "\n")
          # Unescape all characters except $ so variables can be escaped properly
          value = value.gsub(/\\([^$])/, '\1')
        end

        hash[key] = value
      elsif line !~ /\A\s*(?:#.*)?\z/ # not comment or blank line
        raise ParseError.new("Line #{line.inspect} doesn't match format")
      end

      hash
    end
  rescue
    {}
  end

  def local_config_filename
    @local_config_filename ||= options[:env] || '.env'
  end

  def remote_config
    api.get_config_vars(app).body
  end

  def write_local_config(config)
    File.open(local_config_filename, "w") do |file|
      config.keys.sort.each do |key|
        file.puts "#{key}=#{config[key]}"
      end
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

