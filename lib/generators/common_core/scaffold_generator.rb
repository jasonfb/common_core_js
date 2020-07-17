require 'rails/generators/erb/scaffold/scaffold_generator'

module CommonCore
  class ScaffoldGenerator < Erb::Generators::ScaffoldGenerator


    hook_for :form_builder, :as => :scaffold

    source_root File.expand_path('templates', __dir__)
    attr_accessor :path, :singular, :plural, :singular_class, :nest_with


    def initialize(*meta_args) #:nodoc:
      super

      begin
        object = eval(class_name)
      rescue StandardError => e
        puts "Ooops... it looks like there is no object for #{class_name}. Please define the object + database table first."
        exit
      end

      begin
        @columns = object.columns.map(&:name).map(&:to_sym).reject{|x| x==:updated_at || x==:created_at || x==:id}
      rescue StandardError => e
        puts "Ooops... it looks like is an object for #{class_name}. Please create the database table with fields first. "
        exit
      end

      args = meta_args[0]
      @singular = args[0].tableize.singularize # should be in form hello_world






      @plural = @singular + "s" # supply to override; leave blank to use default
      @singular_class = @singular.titleize.gsub(" ", "")
      @nest = nil
      @namespace = nil
      @nested_args = []

      @auth = "current_user"
      @auth_identifier = nil

      args[1..-1].each do |a|
        var_name, var_value = a.split("=")
        case (var_name)

        when "plural"
          @plural = var_value
        when "nest"
          @nest = var_value
        when "namespace"
          @namespace = var_value
        when "auth"
          @auth = var_value
        when "auth_identifier"
          @auth_identifier = var_value || ""
        end
      end

      flags = meta_args[1]
      flags.each do |f|
        case (f)
        when "--god"
          @auth = nil
        when "--with-index"
          @with_index = true
        when "--specs-only"
          @specs_only = true
        when "--no-specs"
          @no_specs = true
        end
      end

      if @specs_only && @no_specs
        puts "oops… you seem to have specified both the --specs-only flag and --no-specs flags. this doesn't make any sense, so I am aborting. sorry."
        exit
      end

      if @auth_identifier.nil? && !@auth.nil?
        @auth_identifier = @auth.gsub("current_", "")
      end

      if !@nest.nil?
        @nested_args = @nest.split("/")

        @nested_args_plural = {}
        @nested_args.each do |a|
          @nested_args_plural[a] = a + "s"
        end
      end
    end

    def formats
      [format]
    end

    def format
      nil
    end

    def copy_controller_and_spec_files
      @default_colspan = @columns.size

      unless @specs_only
        template "controller.rb", File.join("app/controllers#{namespace_with_dash}", "#{plural}_controller.rb")
      end

      unless @no_specs
        template "controller_spec.rb", File.join("spec/controllers#{namespace_with_dash}", "#{plural}_controller_spec.rb")
      end
    end

    def list_column_headings
      @columns.map(&:to_s).map{|col_name| '      %th{:scope => "col"} ' + col_name.humanize}.join("\r")
    end

    def columns_spec_with_sample_data
      @columns.map { |c|
        if eval("#{singular_class}.columns_hash['#{c}']").nil?
          byebug
        end
        type = eval("#{singular_class}.columns_hash['#{c}']").type
        random_data = case type
          when :integer
            rand(1...1000)
          when :string
            FFaker::AnimalUS.common_name
          when :text
            FFaker::AnimalUS.common_name
          when :datetime
            Time.now + rand(1..5).days
        end
        c.to_s + ": '" + random_data.to_s + "'"
      }.join(", ")
    end

    def controller_class_name
      res = ""
      res << @namespace.titleize + "::" if @namespace
      res << plural.titleize.gsub(" ", "") + "Controller"
      res
    end

    def singular_name
      @singular
    end

    def plural_name
      plural
    end

    def auth_identifier
      @auth_identifier
    end


    def path_helper
      "#{@namespace+"_" if @namespace}#{(@nested_args.join("_") + "_" if @nested_args.any?)}#{singular}_path"
    end

    def path_arity
      res = ""
      if @nested_args.any?
        res << nested_objects_arity + ", "
      end
      res << "@" + singular
    end

    def line_path_partial
      "#{@namespace+"/" if @namespace}#{singular}/line"
    end

    def nested_assignments
      @nested_args.map{|a| "#{a}: @#{a}"}.join(", ") #metaprgramming into Ruby hash
    end

    def nested_objects_arity
      @nested_args.map{|a| "@#{a}"}.join(", ")
    end

    def nested_arity_for_path
      @nested_args.join(", ") #metaprgramming into arity for the Rails path helper
    end

    def object_scope
      if @auth
        if @nested_args.none?
          @auth + ".#{plural}"
        else
          "@" + @nested_args.last + ".#{plural}"
        end
      else
        @singular_class
      end
    end


    def all_objects_root
      if @auth
        if @nested_args.none?
          @auth + ".#{plural}"
        else
          "@" + @nested_args.last + ".#{plural}"
        end
      else
        @singular_class + ".all"
      end
    end

    def any_nested?
      @nested_args.any?
    end

    def all_objects_variable
      # needs the authenticated root user
      "#{@auth}.#{ @nested_args.map{|a| "#{@nested_args_plural[a]}.find(@#{a})"}.join('.') + "." if @nested_args.any?}#{plural}"
    end

    def auth_object
      @auth
    end

    def copy_view_files
      return if @specs_only
      js_views.each do |view|
        formats.each do |format|
          filename = cc_filename_with_extensions(view, ["js","erb"])
          template filename, File.join("app/views#{namespace_with_dash}", controller_file_path, filename)
        end
      end


      haml_views.each do |view|
        formats.each do |format|
          filename = cc_filename_with_extensions(view, "haml")
          template filename, File.join("app/views#{namespace_with_dash}", controller_file_path, filename)
        end
      end
    end

    def namespace_with_dash
      if @namespace
        "/#{@namespace}"
      else
        ""
      end
    end

    def namespace_with_trailing_dash
      if @namespace
        "#{@namespace}/"
      else
        ""
      end
    end

    def js_views
      %w(index create destroy edit new update)
    end

    def haml_views
      res =  %w(_edit _form _line _list _new)
      if @with_index
        res << 'all'
      end
      res
    end


    def handler
      :erb
    end


    def create_merge_params
      if @auth
        "#{@auth_identifier}: #{@auth}"
      else
        ""
      end
    end

    def model_has_strings?
      false
    end


    def model_search_fields # an array of fields we can search on
      []
    end


    private # thor does something fancy like sending the class all of its own methods during some strange run sequence
    # does not like public methods

    def cc_filename_with_extensions(name, file_format = format)
      [name, file_format].compact.join(".")
    end
  end

end



