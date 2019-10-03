# Smile Tools : usefull methods
#

class SmileTools
  @@override_traces = {}
  @@override_count = {}
  @@override_last_date = {}
  @@traces_enabled = {}
  @@default_smile_plugin_name = :redmine_smile_enhancements

  # Common to all the Plugins
  # 150 : chars available after override count
  #  40 : chars for first prefix
  @@line_length = 110
  cattr_accessor :line_length


  # Common to all the Plugins
  def self.delimiter=(p_delimiter)
    @@delimiter = p_delimiter
    @@delimiter_length = @@delimiter.size
  end

  self::delimiter = '; '
  cattr_reader :delimiter


  # for the logs : trace the chunks with limiting the length of the line
  def self.trace_by_line(
    p_chunks,
    p_first_prefix,
    p_prefix,
    p_last_postfix,
    p_plugin=@@default_smile_plugin_name
  )
    if !p_chunks.is_a?(Array)
      # 1) call to trace meth
      trace_override("self.trace_by_line p_chunks=#{p_chunks.inspect}) is NOT an Array", false, p_plugin)

      return
    end

    current_line_id = 0
    last_chunk_index = p_chunks.size - 1
    first_prefix_length = p_first_prefix.length
    prefix_length = p_prefix.length
    first_chunk = true

    lines = [p_first_prefix.dup]

    p_chunks.each_with_index{ |c, i|
      # 1/ prefix + chunk

      length_after_add = -first_prefix_length

      length_after_add += lines[current_line_id].length

      if i!=0
        length_after_add += @@delimiter_length
      end

      length_after_add += c.length


      # current_line added to lines when :
      # - current_line exceeds wanted length
      # - this is the last chunk, we must get the last line when below max length
      if (length_after_add > @@line_length)
        # start new line
        lines << ''

        current_line_id += 1
        lines[current_line_id] << p_prefix

        first_chunk = true
      end

      # add chunk
      lines[current_line_id] << ( first_chunk ? '' : @@delimiter) + c.to_s

      first_chunk = false
    }

    # 2/ Last postfix
    length_after_add = lines[current_line_id].length + @@delimiter_length + p_last_postfix.length - prefix_length
    if (length_after_add > @@line_length)
      current_line_id += 1
      lines[current_line_id] = p_prefix.dup
    else
      lines[current_line_id] << ' '
    end

    lines[current_line_id] << p_last_postfix

    lines.each{ |t|
      # 2) call to trace meth
      trace_override(t, true, p_plugin)
    }
  end


  def self.trace_override(line, p_count=true, p_plugin=@@default_smile_plugin_name)
    @@override_last_date[p_plugin] = Time.now

    # Count on 6 chars, left justified with spaces
    # - exceptions :
    #   alias_meth_chain has a previous instance_methods or methods tag line
    #   ---> => continuation of a list
    unless line.include?('alias_meth_chain') || line.include?('--->  <')
      override_count_incr(
        (line.count(';') + 1),
        p_plugin
      ) if p_count

      label_override_count = override_count(p_plugin).to_s.ljust(6, ' ')
    else
      label_override_count = '      '
    end

    #-----------------------------
    # 1) Display log traces anyway
    Rails.logger.info 'o=>' + label_override_count + line

    plugin_traces_enabled = traces_enabled?(p_plugin)
    return unless plugin_traces_enabled

    #-----------------------------
    # 2) Override trace in plugin settings
    # Display override traces once  (NOT if plugin is reloaded in dev.)
    # new line
    override_trace_add(
      "<br/>".html_safe, p_plugin
    ) if override_traces(p_plugin).present?

    # override count + line
    override_trace_add(
      ( label_override_count + ERB::Util.h(line) ).gsub(' ', '&nbsp;').gsub(',&nbsp;', ', '),
      p_plugin
    )
  end

  def self.override_traces(p_plugin=@@default_smile_plugin_name)
    @@override_traces[p_plugin] = '' unless @@override_traces[p_plugin]

    @@override_traces[p_plugin]
  end

  def self.override_trace_add(trace, p_plugin)
    @@override_traces[p_plugin] = '' unless @@override_traces[p_plugin]

    @@override_traces[p_plugin] += trace
  end

  def self.reset_override_count(p_plugin)
    @@override_count[p_plugin] = 0
  end

  def self.override_count(p_plugin=@@default_smile_plugin_name)
    reset_override_count(p_plugin) unless @@override_count[p_plugin]

    @@override_count[p_plugin]
  end

  def self.override_count_incr(incr, p_plugin)
    reset_override_count(p_plugin) unless @@override_count[p_plugin]

    @@override_count[p_plugin] += incr
  end

  def self.enable_traces(enable, p_plugin)
    @@traces_enabled[p_plugin] = enable
  end

  def self.traces_enabled?(p_plugin)
    @@traces_enabled[p_plugin] = true if @@traces_enabled[p_plugin] == nil
    @@traces_enabled[p_plugin]
  end

  def self.override_last_date(p_plugin=@@default_smile_plugin_name)
    @@override_last_date[p_plugin]
  end

  def self.debug_scope(a_scope, tag='sc', entete='', sql=false)
    Rails.logger.debug " =>#{tag}   --\\ SCOPE    #{a_scope.klass.name}" + (entete.present? ? ' : ' + entete : '')
    Rails.logger.debug " =>#{tag}       SELECT   #{a_scope.select_values.inspect}" if a_scope.select_values.any?
    if a_scope.where_values_hash.any?
      if a_scope.where_values_hash.is_a?(Array)
        first_where = true
        a_scope.where_values_hash.each_with_index{|w, i|
          Rails.logger.debug " =>#{tag}       #{first_where ? 'WHERE' : '     '}  #{i} #{w.to_s}"
          first_where = false
        }
      else
          Rails.logger.debug " =>#{tag}       WHERE    #{a_scope.where_values_hash.inspect}"
      end
    end
    Rails.logger.debug " =>#{tag}       INCLUDES #{a_scope.includes_values.inspect}" if a_scope.includes_values.any?
    Rails.logger.debug " =>#{tag}       PRELOAD  #{a_scope.preload_values.inspect}" if a_scope.preload_values.any?
    Rails.logger.debug " =>#{tag}       JOINS    #{a_scope.joins_values.inspect}" if a_scope.joins_values.any?
    Rails.logger.debug " =>#{tag}       GROUPS   #{a_scope.group_values.inspect}" if a_scope.group_values.any?
    Rails.logger.debug " =>#{tag}       ORDER    #{a_scope.order_values.inspect}" if a_scope.order_values.any?
    Rails.logger.debug " =>#{tag}" if sql
    Rails.logger.debug " =>#{tag}       #{a_scope.to_sql}" if sql

    Rails.logger.debug " =>#{tag}   --/"
  end

  def self.regex_path_in_plugin(path, plugin=@@default_smile_plugin_name)
    /#{plugin}\/#{Regexp.quote(path)}/
  end

  def self.default_smile_plugin_name
    @@default_smile_plugin_name
  end

  def self.debug_connexion
    Rails.logger.debug "==>conn"
    Rails.logger.debug " =>  db: #{ActiveRecord::Base.connection.current_database}"
  end
end # class SmileTools
