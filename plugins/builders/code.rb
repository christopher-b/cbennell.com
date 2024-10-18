class Builders::Code < SiteBuilder
  def build
    liquid_tag :code, as_block: true do |option_string, tag|
      options = parse_options(option_string)

      formatter = build_formatter(options)
      lexer = build_lexer(options)
      content = parse_content(tag)

      tokens = lexer.lex(content)
      formatter.format(tokens)
    end
  end

  def build_formatter(options)
    formatter = Rouge::Formatters::HTML.new
    formatter = Rouge::Formatters::HTMLLineHighlighter.new(formatter, highlight_lines: options[:lines]&.map(&:to_i))
    formatter = ChompFormatter.new(formatter)
    formatter = Rouge::Formatters::HTMLTable.new(formatter, gutter_class: "gutter", code_class: "code")
    formatter = WrappingFormatter.new(formatter, caption: options[:caption])
    formatter
  end

  def build_lexer(options)
    lang = options[:lang]
    Rouge::Lexer.find_fancy(lang) || Rouge::Lexers::PlainText
  end

  LEADING_OR_TRAILING_LINE_TERMINATORS = %r{\A(\n|\r)+|(\n|\r)+\z}
  def parse_content(tag)
    tag.content.gsub(LEADING_OR_TRAILING_LINE_TERMINATORS, "")
  end

  OPTIONS_REGEX = %r{(?:\w+="[^"]*"|\w+=\S+|\w+)}
  def parse_options(input)
    options = {}
    return options if input.empty?

    lang = input.split.shift
    input = input.sub(lang, "").strip
    options[:lang] = lang

    # Split along 3 possible forms -- key="<quoted list>", key=value, or key
    input.scan(OPTIONS_REGEX) do |opt|
      key, value = opt.split("=")
      # If a quoted list, convert to array
      if value&.include?('"')
        value.delete!('"')
        value = value.split
      end
      options[key.to_sym] = value || true
    end
    options
  end

  class WrappingFormatter < Rouge::Formatters::HTML
    TEMPLATE = "<figure class='highlight not-prose'><figcaption>%{caption}</figcaption><pre><code>%{content}</code></pre></figure>".freeze

    attr_reader :options

    def initialize(delegate, options)
      @delegate = delegate
      @options = options
    end

    def stream(tokens)
      yield TEMPLATE % {caption: options[:caption], content: @delegate.format(tokens)}
    end
  end

  class ChompFormatter < Rouge::Formatters::HTML
    def initialize(delegate)
      @delegate = delegate
    end

    def stream(tokens)
      yield @delegate.format(tokens).chomp
    end
  end
end
