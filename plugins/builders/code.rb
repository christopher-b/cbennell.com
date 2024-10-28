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

  # We don't memoize, as this instance is shared across the site build
  def build_formatter(options)
    # Basic HTML
    formatter = Rouge::Formatters::HTML.new
    # Add line highlighting
    formatter = Rouge::Formatters::HTMLLineHighlighter.new(formatter, highlight_lines: options[:highlight]&.map(&:to_i))
    # Remove newlines added by LineHighlighter
    formatter = ChompFormatter.new(formatter)
    # The Table formatter gives nice gutters
    formatter = Rouge::Formatters::HTMLTable.new(formatter, gutter_class: "gutter", code_class: "code")
    # Wrap in our custom code, including adding captions
    formatter = WrappingFormatter.new(formatter, caption: options[:caption])

    formatter
  end

  def build_lexer(options)
    lang = options[:lang]
    # @TODO: We should add a "guess" if lang is missing
    Rouge::Lexer.find_fancy(lang) || Rouge::Lexers::PlainText
  end

  LEADING_OR_TRAILING_LINE_TERMINATORS = %r{\A(\n|\r)+|(\n|\r)+\z}
  def parse_content(tag)
    tag.content.gsub(LEADING_OR_TRAILING_LINE_TERMINATORS, "")
  end

  # This allow us to accept options in three forms:
  #  - the first option, if given as just a keyword, will be treated as the `lang` attribute
  #  - caption="caption"
  #  - highlight=[1,2,5-9]
  #  @TODO extract this to a helper class
  def parse_options(input)
    options = {}

    # Use regex to split by spaces, but keep quoted strings and arrays together
    parts = input.scan(/(?:\w+="[^"]*"|\w+=\[[^\]]*\]|\w+=\w+|\w+)/)

    # If the first part does not contain an equals sign, treat it as the "lang"
    if parts.first && !parts.first.include?("=")
      options[:lang] = parts.shift
    end

    parts.each do |part|
      if part.include?("=")
        key, value = part.split("=", 2)

        # Handle quoted values by removing surrounding quotes
        if value.start_with?('"')
          value = value.tr('"', "")
          # Handle array values like [1,3,,5-9]
        elsif value.start_with?("[")
          value = parse_array(value)
        end

        options[key.to_sym] = value
      else
        options[part.to_sym] = true # Treat standalone words as true
      end
    end

    options
  end

  def parse_array(value)
    value = value.tr("[]", "") # Remove surrounding brackets
    elements = value.split(",") # Split by commas

    result = []
    elements.each do |element|
      if element.include?("-") # Handle ranges like 5-9
        start_range, end_range = element.split("-").map(&:to_i)
        result.concat((start_range..end_range).to_a)
      elsif !element.empty?
        result << element.to_i # Add individual numbers
      end
    end

    result
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
