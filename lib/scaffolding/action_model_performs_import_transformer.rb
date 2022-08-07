require "scaffolding/action_model_transformer"

class Scaffolding::ActionModelPerformsImportTransformer < Scaffolding::ActionModelTransformer
  def targets_n
    "performs_import"
  end

  def add_button_to_index_rows
  end

  def scaffold_action_model
    super

    target_index_file = "./app/views/account/scaffolding/completely_concrete/tangible_things/_index.html.erb"

    # # Add the bulk action button to the target _index partial
    # scaffold_add_line_to_file(
    #   target_index_file,
    #   "<%= render \"account/scaffolding/completely_concrete/tangible_things/#{targets_n}_actions/new_button_many\", absolutely_abstract_creative_concept: absolutely_abstract_creative_concept %>",
    #   RUBY_NEW_BULK_ACTION_MODEL_BUTTONS_PROCESSING_HOOK,
    #   prepend: true
    # )

    # Add the action index partial to the target _index partial
    scaffold_add_line_to_file(
      target_index_file,
      "<%= render 'account/scaffolding/completely_concrete/tangible_things/#{targets_n}_actions/index', #{targets_n}_actions: context.completely_concrete_tangible_things_#{targets_n}_actions %>",
      RUBY_NEW_ACTION_MODEL_INDEX_VIEWS_PROCESSING_HOOK,
      prepend: true
    )

    # Add the concern we have to add manually because otherwise it gets transformed.
    add_line_to_file(transform_string("app/models/scaffolding/completely_concrete/tangible_things/#{targets_n}_action.rb"), "include Actions::PerformsImport", CONCERNS_HOOK, prepend: true)

    # Add current attributes of the target model to the import options.
    (child.constantize.new.attributes.keys - ["created_at", "updated_at"]).each do |attribute|
      add_line_to_file(transform_string("app/models/scaffolding/completely_concrete/tangible_things/#{targets_n}_action.rb"), ":#{attribute},", RUBY_NEW_FIELDS_HOOK, prepend: true)
    end

    # Restart the server to pick up the translation files
    restart_server

    lines = File.read("config/routes.rb").lines.map(&:chomp)

    lines.each_with_index do |line, index|
      if line.include?(transform_string("resources :#{targets_n}_actions"))
        lines[index] = "#{line} do\nmember do\npost :approve\nend\nend\n"
        break
      end
    end

    File.write("config/routes.rb", lines.join("\n"))

    puts `standardrb --fix ./config/routes.rb #{transform_string("./app/models/scaffolding/completely_concrete/tangible_things/#{targets_n}_action.rb")}`

    additional_steps.each_with_index do |additional_step, index|
      color, message = additional_step
      puts ""
      puts "#{index + 1}. #{message}".send(color)
    end
    puts ""
  end

  def transform_string(string)
    string = super(string)

    [
      "Performs Import to",
      "append an emoji to",
      "PerformsImport",
      "performs_import",
      "Performs Import",
    ].each do |needle|
      # TODO There might be more to do here?
      # What method is this calling?
      string = string.gsub(needle, encode_double_replacement_fix(replacement_for(needle)))
    end
    decode_double_replacement_fix(string)
  end

  def replacement_for(string)
    case string
    # Some weird edge cases we unwittingly introduced in the emoji example.
    when "Performs Import to"
      # e.g. "Archive"
      # If someone wants language like "Targets Many to", they have to add it manually or name their model that.
      action.titlecase
    when "append an emoji to"
      # e.g. "archive"
      # If someone wants language like "append an emoji to", they have to add it manually.
      action.humanize
    when "PerformsImport"
      action
    when "performs_import"
      action.underscore
    when "Performs Import"
      action.titlecase
    else
      "🛑"
    end
  end
end